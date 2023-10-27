@name ApplyAngForce Tester
@inputs E:entity
@persist LOS:angle EAngle:angle Error:angle IC Mul
@model models/hunter/blocks/cube025x025x025.mdl
@strict

interval(0)
runOnKeys(owner(), 1)

if(first()){
    IC = (1 / (180 / pi() / (100 / 2.54)^2))
    Mul = 1 / tickInterval()
    E:propFreeze(1)
    E:propGravity(0)
    E:setPos(entity():pos() + vec(0, 0, E:boxSize():length()))
    E:setAng(ang(0))
    E:setMass(50000)
    E:setTrails(10, 10, 2, "effects/beam_generic01", vec(255), 255)
    holoCreate(1)
    holoScale(1, vec(0.5))
    print("angSpeedLimit: " + angSpeedLimit())
}else{
    K = keyClkPressed()
    D = owner():keyPressed(K)
    if(D){
        switch(K){
            case "mouse_5",
            E:propFreeze(0)
            E:propSetVelocity(vec(0))
            break
            default,
            #print(toString(round(curtime(), 2)) + ", " + K)
            break
        }
    }
}

if(clk("interval")){
    TargetPos = owner():shootPos()
    EAngle = angnorm(E:angles())
    EAngleRate = $EAngle
    LOS = angnorm((TargetPos - E:massCenter()):toAngle())
    LOSRate = $LOS
    Error = LOSRate - EAngleRate
    Temp1 = vec(LOSRate):length()
    Temp2 = vec(EAngleRate):length()
    Temp3 = vec(Error):length()
    print(toString(round(Temp3, 2)) + ", " + toString(round(Temp1, 2)) + ", " + toString(round(Temp2, 2)))
    
    # Angle Stuff
    DeltaAng = E:toLocal(LOS + LOSRate * curtime() / Mul + ang(0, 0, EAngle:roll()))
    Q = quat(DeltaAng)
    A = rotationAxis(Q) * vec(DeltaAng):length()
    T = (A * Mul - E:angVelVector()) * E:inertia() * IC
    E:applyTorque(T)
    E:applyForce(E:forward() * E:mass() * 1000)
    holoPos(1, TargetPos)
}

# CONCLUSION: To appy a force that results in a delta of Degrees/Second,
# use applyTorque with input of desired deg/s * inertia * (1 / (180 / pi() / (100 / 2.54)^2))
# which the constant is found on https://github.com/wiremod/wire/blob/5edc3b6ea7e1671025344ea52b85042870398c74/lua/entities/gmod_wire_expression2/core/entity.lua#L638
