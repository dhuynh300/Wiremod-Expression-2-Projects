@name RocketTime
@inputs Missile:entity ThrusterEnt:entity
@outputs ThrustVec:vector
@persist Stage TimeSinceLaunch MinThrust MaxThrust
@persist LastVel:vector # Debug
@strict
@model models/props_borealis/bluebarrel001.mdl

interval(0)

if(first()){
    holoCreate(1)
    holoScaleUnits(1, vec(1))
    
    Stage = 0
    TimeSinceLaunch = 0
    MinThrust =  Missile:mass() * gravity() * tickInterval() * 2
    MaxThrust = Missile:mass() * gravity() / 2
    
    ThrustVec = vec(0, 0, 0)
    
    #Debug
    LastVel = vec()
    
    Missile:propFreeze(1)
    Missile:setPos(entity():pos() + vec(0, 0, Missile:boxSize():length()))
    Missile:setAng(ang(-90, -135, 0))
    
    ThrusterEnt:setPos(entity():pos() + vec(0, 0, Missile:boxSize():length()))
}

MissilePos = Missile:massCenter()
MissileVel = Missile:vel()

switch(Stage){
    case 0, # Unfreeze
        if(!MissileVel:length2() && !ThrusterEnt:vel():length2() && TimeSinceLaunch > 0.1){
            Missile:propFreeze(0)
            
            TimeSinceLaunch = 0
            Stage = 1
        }
    break
    
    case 1, # Launch & Rotate
        ThrustVec = vec(0, 0, 1) * MaxThrust
        if(TimeSinceLaunch >= 0.1){
            ThrustVec = vec(0, 0, 0)
            
            if(TimeSinceLaunch >= 0.5){
                ThrustVec = vec(1, 0, 0) * MinThrust
                if(TimeSinceLaunch >= 0.56){
                    ThrustVec = vec(0, 0, 0)
                }
                
                if(TimeSinceLaunch >= 1.29){
                    ThrustVec = vec(-1, 0, 0) * MinThrust
                }
                
                if(TimeSinceLaunch >= 1.33){
                    ThrustVec = vec(0, 0, 0)
                }
                
                if(TimeSinceLaunch >= 1.4){
                    TimeSinceLaunch = 0
                    Stage = 2
                }
            }
        }
    break
    
    case 2, # Fly
        ThrustVec = vec(0, 0, 1) * MaxThrust #vec(0, 0, 1) * lerp(MinThrust, MaxThrust, TimeSinceLaunch / 10)
        
        TargetPos = entity():pos()
        TargetDelta = TargetPos - MissilePos
        TargetAngle = TargetDelta:toAngle()
        DeltaAngle = TargetAngle:forward():toAngle() - Missile:angles():forward():toAngle()
    break
}

TimeSinceLaunch += tickInterval()

# Debug
holoPos(1, MissilePos + Missile:forward() * Missile:boxSize():length())
if(changed(MissileVel)){
    print(round(MissileVel:length()) + ", " + round((MissileVel - LastVel):length()) + ", " + ThrustVec)
}
LastVel = MissileVel
