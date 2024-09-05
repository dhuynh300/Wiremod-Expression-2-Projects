@name CalcTrajObjWitDrag
@inputs E:entity
@persist MaxH TimeStep [Velocity Acceleration]:vector
@model models/props_c17/FurnitureWashingmachine001a.mdl

if(first()){
    MaxH = 0
    TimeStep = tickInterval() # Remember that with smaller intervals, the more accurate

    # Drag functions
    function vector convertToIVP(Vec:vector){
        return vec(Vec:x(), -Vec:z(), Vec:y()) * 0.0254
    }
    
    # This changes based on mass and prop model
    function vector calcDragBasis(Ent:entity){
        AABMin = Ent:aabbMin()
        AABMax = Ent:aabbMax()
        
        Delta = AABMax - AABMin
        Delta = convertToIVP(Delta)
        Delta = vec(abs(Delta:x()), abs(Delta:y()), abs(Delta:z()))
        
        #AreaFraction = computeOrthographicAreas(Ent, 0.25)
        DragBasis = vec(Delta:y() * Delta:z(),
                        Delta:x() * Delta:z(),
                        Delta:x() * Delta:y())# * AreaFraction
        
        T = DragBasis * (1 / Ent:mass())
        return T
    }
    
    B = calcDragBasis(E)
    print(B:x() + ", " + B:y() + ", " + B:z())
}
event tick() {
    if(MaxH < holoMaxAmount()){
        while(holoCanCreate()){
            MaxH++
            holoCreate(MaxH)
            holoColor(MaxH, vec(0, 255, 0))
            holoDisableShading(MaxH, 1)
        }
    }
    
    Velocity = E:vel()
    Acceleration = $Velocity / tickInterval()
    
    # TODO : angular velocity and local velocity/acceleration for circle movements
    if(owner():keyUse() || 1){
        HPos = E:massCenter()
        HVel = E:vel()
        HAcl = Acceleration
        TEMP = $Acceleration
        
        IVP_C = calcDragBasis(E) * 0.0254
        DragForce_C = -0.5 * airDensity() * TimeStep
        
        I = 1
        while(I <= MaxH && perf()){
            HAcl += TEMP
            HVel += HAcl * TimeStep
            
            IVP = HVel * IVP_C
            DragDir = abs(IVP:x()) + abs(IVP:y()) + abs(IVP:z())
            DragForce = clamp(DragDir * DragForce_C, -1, 0)
            HVel += HVel * DragForce
            
            HPos += HVel * TimeStep
            
            holoPos(I, HPos)
            
            P = (I - 1) / (MaxH - 1)
            holoColor(I, vec(255 * P, 255 - 255 * P, 0))
            I++
        }
        
        IVP = Velocity * IVP_C
        DragDir = abs(IVP:x()) + abs(IVP:y()) + abs(IVP:z())
        DragForce = clamp(DragDir * DragForce_C, -1, 0)
        DragVector = Velocity * DragForce
        
        print(round(Velocity:z(), 2), round(Acceleration:z(), 2),
            round(($Acceleration):z(), 2), round(DragVector:z(), 2)
            )
    }
    
    if(owner():keyUse()){
        E:applyAngForce(ang(0, 10, 0) * E:mass())
    }
    
    E:applyForce(E:angles():forward() * E:mass() * 10)
    
    #[
    OldVel = Velocity
    Velocity = E:vel() # Make sure it persists
    D = $Velocity
    if(changed(D)){
        DBasis = vec(0.009)
        Temp1 = convertToIVP(E:vel()) * DBasis
        DFloat = abs(Temp1:x()) + abs(Temp1:y()) + abs(Temp1:z())
        DForce = -0.5 * DFloat * airDensity() * tickInterval()
        DForceClamp = clamp(DForce, -1, 0)
        NewVel = E:vel() + E:vel() * DForceClamp
        NewVel2 = OldVel + OldVel * DForceClamp
        print(round(Velocity:z()), round(D:z()), round(gravity() * tickInterval()), round(NewVel:z()),
            round(Velocity:z() - NewVel:z(), 2), round(Velocity:z() - NewVel2:z(), 2))
        #print(round(Velocity:z() - NewVel:z(), 3))
    }
    ]#
}
