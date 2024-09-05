@name MissileTest
@inputs Missile:entity
@persist [LOS, AngForce]:angle Target:entity TurnMul
@model models/maxofs2d/cube_tool.mdl
@strict

interval(0)

if(first()){
    function number normalizeSingleAngle(Ang){  
        ReturnAngle = Ang
        while(ReturnAngle > 180.0){
            ReturnAngle -= 360.0
        }
        while(ReturnAngle < -180.0){
            ReturnAngle += 360.0
        }
        return ReturnAngle
    }
    
    function angle normalizeAngle(Ang:angle){
        return ang(normalizeSingleAngle(Ang:pitch()), normalizeSingleAngle(Ang:yaw()), normalizeSingleAngle(Ang:roll()))
    }
    
    Target = noentity()
    TurnMul = 100
    
    Missile:setTrails(10, 10, 2, "effects/beam_generic01", vec(255), 255)

    Missile:propGravity(0)
    Missile:setMass(1000)
}

if(Target:isValid()){
    if(owner():keyReload()){
        Missile:propFreeze(0)
    }
    
    Missile:applyAngForce(ang(0, 0, -(Missile:angVel():roll() + Missile:angles():roll() * 16)) * Missile:mass())
    MissilePos = Missile:massCenter()
    
    print(round(Target:vel():length()) + ", " + round(Missile:vel():length()))
    TargetPos = Target:massCenter()
    TargetAng = normalizeAngle(Missile:toLocal(TargetPos):toAngle())
    
    LOS = normalizeAngle((TargetPos - MissilePos):toAngle())
    LOSRate = normalizeAngle($LOS)
    
    DeltaAng = normalizeAngle(TargetAng + LOSRate * curtime() / TurnMul)
    AngForce = DeltaAng * Missile:mass() * TurnMul
    Missile:applyAngForce(AngForce + $AngForce * 3)
    Missile:applyForce(Missile:forward() * Missile:mass() * 1000)
    
    print(vec(LOSRate):length() + ", " + vec(DeltaAng):length())
    
    AL = vec(Missile:angVel()):length()
    if(AL >= angSpeedLimit()){
        print("OVER angSpeedLimit!")
    }
}else{
    findByClass("gw_*")
    TempTarget = find()
    if(TempTarget:isValidPhysics()){
        Target = TempTarget
        Target:propGravity(0)
        Target:propFreeze(1)
        #Target:setPos(entity():pos() + vec(0, 0, 300))
        
        Missile:propFreeze(1)
        Missile:setPos(entity():pos() + vec(0, 0, 100))
        Missile:setAng(ang(-90, 0, 0))
        print("Got Target!")
    }
    
    #Target = owner()
}
