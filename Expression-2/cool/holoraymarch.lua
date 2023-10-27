@name HoloRayMarch
@inputs EGP:wirelink
@persist Vector:vector Direction:vector Distance Index2 X Y Width Height FOV Res CamAng:angle CamPos:vector

interval(0)

if(first()){
    EGP:egpClear()
    
    function createLine(Index:number, Start:vector, End:vector){
        holoPos(Index, (Start + End) / 2)
        holoAng(Index, (Start - End):toAngle())
        holoScaleUnits(Index, vec(Start:distance(End), 1, 1))
    }
    
    function number getDistBox(Index:number, In:vector){
        Abs = holoEntity(Index):pos() - In
        Vector3 = vec(abs(Abs:x()), abs(Abs:y()), abs(Abs:z())) - holoScaleUnits(Index) / 2
        return min(maxVec(Vector3, vec(0)):length() + min(max(Vector3:x(), max(Vector3:y(), Vector3:z())), 0), In:z() - entity():pos():z())
    }
    
    function number getDistSph(Index:number, In:vector){
        return min(In:distance(holoEntity(Index):pos()) - holoScaleUnits(Index):z() / 2, In:z() - entity():pos():z())
    }
    
    #Line
    holoCreate(10)
    holoColor(10, vec(255, 0, 0))
    holoDisableShading(10, 1)
    
    #Line 2
    holoCreate(11)
    holoColor(11, vec(0, 0, 255))
    holoDisableShading(11, 1)
    
    #Light
    holoCreate(2)
    holoPos(2, entity():pos() + vec(1000, 1000, 160))
    holoModel(2, "sphere3")
    holoDisableShading(2, 1)
    holoScaleUnits(2, vec(10))
    
    #Target
    holoCreate(3)
    holoPos(3, entity():pos() + vec(500, 500, 50))
    holoColor(3, vec(0, 255, 0))
    holoModel(3, "sphere3")
    holoDisableShading(3, 1)
    holoScaleUnits(3, vec(100))
    
    holoCreate(4)
    holoModel(4, "models/editor/camera.mdl")
    
    Width = 128
    Height = 128
    FOV = 45
    Res = 2
    
    CamPos = entity():pos() + vec(0, 0, 250)
    CamAng = (holoEntity(3):pos() - CamPos):toAngle()
}

while(Y < Height && perf(30)){
    if(X < Width){
        if(Distance < 4096){
            PixNormX = (X - Width / 2) / Width
            PixNormY = (Y - Height / 2) / Height
            
            Ang = ang(PixNormY * FOV, PixNormX * -FOV, 0) + CamAng
            Direction = Ang:forward()
            
            Vector = CamPos + Direction * Distance
            Distance2 = getDistSph(3, Vector)
            Distance += Distance2
            
            createLine(10, CamPos, Vector)
            holoPos(4, CamPos)
            holoAng(4, Ang)
            
            if(Distance2 == Vector:z() - entity():pos():z() && Distance2 <= 0.5){
                Hit = 0
                DistLight = 0
                VecLight = Vector
                DirLight = (holoEntity(2):pos() - Vector):toAngle():forward()
                while(getDistSph(2, VecLight) > 0 && perf(50)){
                    VecLight = Vector + DirLight * DistLight
                    DistLight2 = getDistSph(3, VecLight)
                    DistLight += DistLight2
                    createLine(11, Vector, VecLight)
                    if(DistLight2 <= 0){
                        Hit = 1
                        break
                    }
                }
                if(Hit){
                    Streach = vec2(512) / vec2(Width, Height)
                    EGP:egpBox(Index2, vec2(X, Y) * Streach, Streach * Res)
                    EGP:egpColor(Index2, vec(30))
                    Index2++
                }else{
                    Streach = vec2(512) / vec2(Width, Height)
                    EGP:egpBox(Index2, vec2(X, Y) * Streach, Streach * Res)
                    EGP:egpColor(Index2, vec(100))
                    Index2++
                }
                
                X += Res
                Distance = 0
            }elseif(Distance2 <= 0){
                Streach = vec2(512) / vec2(Width, Height)
                EGP:egpBox(Index2, vec2(X, Y) * Streach, Streach * Res)
                Index2++
                
                X += Res
                Distance = 0
            }
        }else{
            X += Res
            Distance = 0
        }
    }else{
        X = 0
        Y += Res
    }
}
