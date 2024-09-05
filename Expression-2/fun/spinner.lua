@inputs S:entity
@outputs RPM Force
@persist Pos:vector LastPos:vector Time LastTime

interval(0)

Yaw = mod(S:angles():yaw() + 225, 360) - 180

if(first()){
    holoCreate(1)
    holoParent(1, S)
    holoScaleUnits(1, vec(128, 1, 12))
    holoDisableShading(1, 1)
    holoPos(1, S:boxCenterW() + ang(0, Yaw, 0):forward() * 64)
    holoAng(1, ang(0, Yaw, 0))
    
    holoCreate(2)
    holoScaleUnits(2, vec(256, 1, 12))
    holoDisableShading(2, 1)
    holoPos(2, S:boxCenterW() - vec(128, 0, 0))
    holoAng(2, ang())
}

RPM = S:angVelVector():length() / 6
S:applyAngForce(ang(0, -S:angVel():yaw() * S:mass() * 4, 0))

LastTime = Time
Time = curtime()
Interval = Time - LastTime

LastPos = Pos
Pos = owner():eyeTrace():position()
Distance = vec2(Pos):distance(vec2(LastPos))

Angle = (Pos - S:boxCenterW()):toAngle()
Force = mod(Angle:yaw() - Yaw + 180, 360) - 180

S:applyAngForce(ang(0, Force * S:mass() * Distance * 10, 0))
