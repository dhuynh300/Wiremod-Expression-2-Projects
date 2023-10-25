@name Radar
@persist RdrPos:vector RdrParentAng:angle RdrAngDelta RdrAngRate
@persist RdrCenterAng RdrAngLimMin RdrAngLimMax
@persist RdrDist Width Height [Mins Maxs]:vector RdrAng:angle
@strict

# TODO : fix local vs world angles

if(first()){
    rangerIgnoreWorld(1)
    rangerFilter(entity():isWeldedTo())
    rangerPersist(1)
    
    MaxAng = 360
    RdrCenterAng = 90
    RdrAngLimMin = RdrCenterAng - MaxAng / 2
    RdrAngLimMax = RdrCenterAng + MaxAng / 2
    
    RdrPos = vec(0) #entity():pos()
    RdrParentAng = ang(0) #ang(0, RdrCenterAng, 0)
    RdrAng = ang(0)
    RdrAngDelta = 0
    
    RdrAngRate = MaxAng * tickInterval() * 1 # Degrees per tick
    RdrDist = 16384
    Width = toRad(RdrAngRate) * RdrDist
    Height = Width * 4
    
    holoCreate(1, RdrPos, vec(1), RdrParentAng, vec(255), "models/props_rooftop/roof_dish001.mdl")
    
    # Lines
    holoCreate(2)
    holoDisableShading(2, 1)
    holoMaterial(2, "models/wireframe")
    function drawLine(Index, Start:vector, End:vector) {
        holoPos(Index, (Start + End + toWorld(vec(0, 0, Height), ang(0), vec(0), RdrAng)) / 2)
        holoAng(Index, (End - Start):toAngle())
        holoScaleUnits(Index, -vec(Start:distance(End), Width, Height))
    }
    
    holoCreate(3)
}

event tick() {
    if(changed(owner():keyUse()) && owner():keyUse() || 1){
        # Update vars
        RdrPos = entity():pos()
        RdrParentAng = ang(0, RdrCenterAng, 0)
        WeldEnt = entity():isWeldedTo()
        if(WeldEnt:isValidPhysics()){
            RdrParentAng += WeldEnt:angles()
        }
        
        RdrAngDelta += RdrAngRate
        ClampedDelta = (RdrAngDelta + 180) % 360 - 180 + RdrCenterAng
        
        if(ClampedDelta <= RdrAngLimMin || ClampedDelta >= RdrAngLimMax){
            RdrAngRate *= -1
        }
    }
    
    # Real angle
    RdrAng = toWorldAng(vec(0), ang(0, ClampedDelta - RdrCenterAng, 0), vec(0), RdrParentAng)
    
    # Radar functions
    RdrForward = RdrAng:forward()
    Mins = toWorld(vec(0, -Width / 2, 0), ang(0), vec(0), RdrAng)
    Maxs = toWorld(vec(0, Width / 2, Height), ang(0), vec(0), RdrAng)
    R = rangerOffsetHull(RdrDist, RdrPos, RdrForward, Mins, Maxs)
    if(R:hit()){
        Entity = R:entity()
        if(Entity:isValid()){
            print(curtime(), Entity)
        }
    }
    
    # Update animations
    holoPos(1, RdrPos)
    holoAng(1, RdrAng)
    
    # Debug
    drawLine(2, RdrPos, RdrPos + RdrForward * RdrDist)
    holoPos(3, R:position())
}
