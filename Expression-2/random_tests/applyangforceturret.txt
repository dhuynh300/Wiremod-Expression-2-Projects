@name ApplyAngForceTurret
@inputs Rocket:entity
@persist 

interval(0)
if(first()){
    Rocket:propGravity(0)
    Rocket:propSetVelocity(vec(0))
}

Angle = (owner():boxCenterW() - Rocket:massCenter()):toAngle()
Delta = Rocket:toLocal(Angle) * 100
Rocket:applyAngForce((Delta - Rocket:angVel()) * Rocket:mass() * ang(shiftL(Rocket:inertia())) * 2)

