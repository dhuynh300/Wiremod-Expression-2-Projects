@name eyeAng Test
@persist OldEyeAng:angle

runOnTick(1)

CurEyeAng = owner():eyeAngles()
if(changed(CurEyeAng)){
    DeltaAng = CurEyeAng - OldEyeAng
    print(DeltaAng:pitch():toString(), DeltaAng:yaw():toString())
    OldEyeAng = CurEyeAng
}
