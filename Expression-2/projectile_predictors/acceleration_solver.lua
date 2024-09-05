@name Acceleration Solver
@persist PrvArr:array DragBase:vector MaxHolos Step AirDensity
@model models/hunter/blocks/cube05x05x05.mdl

#1 = Velocity
#2 = Acceleration

# physics_debug_entity m_dragCoefficient

interval(0)

findByModel("models/hunter/blocks/cube1x1x1.mdl")
Ent = findResult(1)

if(first()){
    DragBase = vec()
    AirDensity = airDensity()
    Step = tickInterval()
    PrvArr = array()
    MaxHolos = 0
    
    function vector convertToIVP(Vec:vector){
        return vec(Vec:x(), -Vec:z(), Vec:y()) * 0.0254
    }
    
    # The object HAS to have an angle of (0, 0, 0)
    function vector computeOrthographicAreas(Ent:entity, Epsilon){
        AABMin = Ent:aabbWorldMin()
        AABMax = Ent:aabbWorldMax()
        
        Side = sqrt(Epsilon)
        if(Side < 1e-4){
            Side = 1e-4
        }
        
        #Size = AABMax - AABMin
        OrthoAreas = vec(1)
        for(Axis = 0, 2, 1){
            RealAxis = Axis + 1
            U = (Axis + 1) % 3 + 1
            V = (Axis + 2) % 3 + 1
            
            Hits = 0
            Total = 0
            HalfSide = Side * 0.5
            
            U0 = AABMin[U] + HalfSide
            while(U0 < AABMax[U]){
                V0 = AABMin[V] + HalfSide
                while(V0 < AABMax[V]){
                    Start = vec()
                    End = vec()
                    
                    Start[RealAxis] = AABMin[RealAxis] - 1
                    End[RealAxis] = AABMax[RealAxis] + 1
                    Start[U] = U0
                    End[U] = U0
                    Start[V] = V0
                    End[V] = V0
                    
                    Ranger = rangerOffset(Start, End)
                    if(Ranger:hit()){
                        Hits++
                    }
                    Total++
                    
                    #
                    V0 += Side
                }
                #
                U0 += Side
            }
            
            if(Total <= 0){
                Total = 1
            }
            
            OrthoAreas[RealAxis] = Hits / Total
        }
        
        #print("OrthoArea:", round(OrthoAreas, 3), round(OrthoAreas:length(), 3), Ent:surfaceArea(), Hits, Total)
        print("OrthoArea:", round(OrthoAreas, 3))
        return OrthoAreas
    }
    
    function vector absVector(Vec:vector){
        return vec(abs(Vec:x()), abs(Vec:y()), abs(Vec:z()))
    }
    
    #[
    function vector vectorTransform(In:vector, TransformMatrix:matrix4){
        Out = vec(
            In:dot(TransformMatrix:row(0)),
            In:dot(TransformMatrix:row(1)),
            In:dot(TransformMatrix:row(2))
        )
        return Out
    }
    ]#
    
    function vector calcDragBase(Ent:entity){
        AABMin = Ent:aabbMin()
        AABMax = Ent:aabbMax()
        
        Delta = AABMax - AABMin
        Delta = convertToIVP(Delta) #vec(Delta:x(), -Delta:z(), Delta:y()) * 0.0254
        Delta = vec(abs(Delta:x()), abs(Delta:y()), abs(Delta:z()))
        
        #AreaFraction = computeOrthographicAreas(Ent, 0.25)
        DragBasis = vec(Delta:y() * Delta:z(),
                        Delta:x() * Delta:z(),
                        Delta:x() * Delta:y())# * AreaFraction
        
        return DragBasis * (1 / Ent:mass())
    }
    
    function vector matrixMul(Matrix:matrix, In:vector){
        ScalarA = (Matrix:row(0):x()) * In:x() + (Matrix:row(1):x()) * In:y() + (Matrix:row(2):x()) * In:z()
        ScalarB = (Matrix:row(0):y()) * In:x() + (Matrix:row(1):y()) * In:y() + (Matrix:row(2):y()) * In:z()
        ScalarC = (Matrix:row(0):z()) * In:x() + (Matrix:row(1):z()) * In:y() + (Matrix:row(2):z()) * In:z()
        
        Out = vec(ScalarA, ScalarB, ScalarC)
        return Out
    }
    
    function number getDragInDirection(Dir:vector){
        DragCoefficient = 1
        
        Mat = matrix4(Ent):rotationMatrix()
        Out = matrixMul(Mat, Dir)
        return DragCoefficient * absVector(Out):dot(absVector(DragBase))
    }
    
    function vector calcDrag(Ent:entity, Vel:vector){
        #[
        #DragForce = AirDensity * Vel * Vel * DragBase * 0.5
        #DragForce = Vel:toAngle():forward() * -DragForce:length()
        DragForce = Vel:toAngle():forward() * Vel:length2() * Step / 4.65
        DragForce = DragForce / Ent:mass()
        return -DragForce
        ]#
        
        #[
        DragForce = -2 * getDragInDirection(Vel:normalized()) * AirDensity * Step
        return Vel * DragForce
        ]#
        
        Mat = matrix4(Ent):rotationMatrix()
        Out = matrixMul(Mat, Vel:normalized())
        
        DragForce = -0.5 * AirDensity * Vel * Vel * DragBase
        return DragForce / Ent:mass() * Vel:toAngle():forward() * Step
    }
    
    function vector calcDelta(CurVal:vector, Index){
        Delta = CurVal - PrvArr[Index, vector]
        PrvArr[Index, vector] = CurVal
        return Delta #round(Delta)
    }
    
    function drawMotion(Ent:entity, Vel:vector){
        I = 0
        HoloPos = Ent:boxCenterW()
        HoloVel = Vel
        #HoloAcl = Acel
        while(perf() && I < MaxHolos){
            HoloVel += calcDrag(Ent, HoloVel)
            
            HoloVel -= vec(0, 0, gravity()) * Step
            HoloPos += HoloVel * Step
            holoPos(I + 10, HoloPos)
            I++
        }
    }
    
    if(0){
        Ent:propFreeze(1)
        Ent:setAng(ang(0))
        print(calcDragBase(Ent))
    }
    
    # 64 kg vec(0.022457774131656,0.022221461365412,0.022458231520131)
    # 256 kg vec(0.005614443532914,0.005555365341353,0.0056145578800328)
    # This changes based on mass and prop model
    DragBase = calcDragBase(Ent)
    print("DragBase:", round(DragBase, 3))
}

if(!MaxHolos && holoCanCreate()){
    while(perf() && holoCanCreate()){
        MaxHolos++
        holoCreate(MaxHolos)
    }
    print(MaxHolos + " Max Holos")
}

if(Ent){
    #Pos = Ent:boxCenterW()
    Vel = Ent:vel()
    
    Acel = calcDelta(Vel, 1) / tickInterval()
    #calcDrag(Ent, Vel)
    #print((Ent:forward() * 0.2 + vec(0.2)))
    if(changed(Vel)){
        print(round(calcDrag(Ent, Vel), 2), round(Acel, 2), round(gravity() * Step), round(Vel, 2))
    }
    
    if(owner():keyReload()){
        drawMotion(Ent, Vel)
    }elseif(owner():keyZoom()){
        Ent:propFreeze(0)
        Ent:setAng(ang(0))
        Ent:applyForce((owner():pos() - Ent:pos()) * Ent:mass() * 100)
        #Ent:applyForce(vec(0, 0, -Ent:mass() * 1000))
    }
    
    #[
    Mat1 = matrix4(Ent)
    Pos1 = Mat1:pos()
    Ang1 = Mat1:rotationMatrix():toAngle()
    holoPos(1, Pos1)
    holoAng(1, Ang1)
    print(Pos1)
    ]#
}else{
    PrvArr:clear()
}
