@name RayMarching?
@inputs EGP:wirelink Ent:entity
@persist Circle:vector4 X Y Width Height FOV Index
interval(0)
if(first()){
    function number distToCircle(Vector:vector){
        return Vector:distance(vec(Circle)) - Circle:w()
    }
    function number rayMarch(Start:vector, Direction:vector){
        Distance = 0
        while(Distance < 8192 && perf(85)) {
            RayVec = Start + Direction * Distance
            CurrentDist = distToCircle(RayVec)
            Distance += CurrentDist
            if(CurrentDist <= 0){
                return 1
            }elseif(CurrentDist <= 1){
                EGP:egpBox(Index, vec2(X, Y), vec2(5))
                EGP:egpColor(Index, vec(255,0,0))
                Index++
                return 0
            }
        }
        return 0
    }
    EGP:egpClear()
    EGP:egpBox(0, vec2(512/2), vec2(512))
    EGP:egpColor(0, vec(0))
    
    Index = 1
    Circle = vec4(0, -30, 0, 29)
    
    X = -5
    Width = 128
    Height = 128
    FOV = 180
}

# i = x = width
# j = y = height
if(Y < Height) {
    if(Y < Height){
        if(X < Width){
            PixNormX = X / Width
            PixNormY = Y / Height
                
            Ang = vec(PixNormX * FOV + FOV / 2, PixNormY * FOV + FOV / 2, 0)
            Ent:setAng(ang(Ang))
                
            if(rayMarch(vec(0, 0, 0), Ang)){
                EGP:egpBox(Index, vec2(X, Y), vec2(5))
                Index++
            }
            X += 1
        }else{
            X = 0
            Y += 1
        }
    }
}
