@name Elevator
@inputs Lift:entity
@outputs 
@persist 

interval(0)
Lift:propFreeze(1)
Lift:setAng(owner():eyeAngles() * ang(0, 1, 0))
Lift:setPos(owner():pos() + (owner():eyeAngles() * ang(0, 1, 0)):forward() * 50 + vec(0, 0, 10))
