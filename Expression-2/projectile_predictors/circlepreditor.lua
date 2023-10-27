@name CirclePreditor
@inputs A:entity
@persist E:entity MaxH TimeStep [Vel Acl VelL AclL]:vector [AngVel AngAcl]:angle
@model models/props_c17/FurnitureWashingmachine001a.mdl

if(first()){
    MaxH = 0
    TimeStep = tickInterval() / 4 # Remember that with smaller intervals, the more accurate

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
    
    E = owner()
    B = calcDragBasis(E)
    print(B:x() + ", " + B:y() + ", " + B:z())
}
event tick() {
    if(MaxH < holoMaxAmount()){
        while(holoCanCreate() && perf()){
            MaxH++
            holoCreate(MaxH)
            holoDisableShading(MaxH, 1)
            holoScale(MaxH, vec(0.5))
            #holoModel(MaxH, owner():model())
        }
    }
    
    E = A
    
    OldVel = Vel
    
    Vel = E:vel()
    Acl = $Vel / tickInterval()
    
    VelL = E:velL()
    AclL = $VelL / tickInterval()
    
    AngVel = angnorm(Vel:toAngle() - OldVel:toAngle()) / tickInterval()
    AngAcl = $AngVel / tickInterval()
    
    if(owner():keyUse()){
        HPos = E:pos()
        HVel = VelL
        HAcl = Acl
        
        HAng = E:angles()
        HAngVel = AngVel
        HAngAcl = AngAcl
        
        I = 1
        while(I <= MaxH && perf()){
            HVel += HAcl * TimeStep
            HPos += toWorld(HVel * TimeStep, ang(0), vec(0), HAng)
            
            holoPos(I, HPos)
            
            #HAngVel += HAngAcl * TimeStep
            HAng += HAngVel * TimeStep
            
            holoAng(I, HAng)
            
            P = (I - 1) / (MaxH - 1)
            holoColor(I, vec(255 * P, 255 - 255 * P, 0))
            I++
        }
        
        print(round(Vel), round(AngVel))
    }
}
