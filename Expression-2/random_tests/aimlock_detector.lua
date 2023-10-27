@name Aimlock Detector
@persist Target:entity Violations Threshold
@persist M_YAW M_PITCH M_SENS M_MINDELTA:angle
@persist [OldAng CurAng Delta]:angle

# TODO : Mouse acceleration???
# TODO : Other things like mouse acceleration (recoil, etc.)
# TODO : Breaks when it hits angle limits/rolls over e.g.: -89, 89, -180, 180

runOnTick(1)

if(first()){
    N_SENS = 2
    M_PITCH = M_YAW = 0.022
    M_MINDELTA = ang(M_PITCH, M_YAW, 0) * N_SENS / 2
    
    Target = owner()
    Violations = 0
    Threshold = ceil(1 / tickInterval())
    print(Threshold, M_MINDELTA)
}

OldAng = CurAng
CurAng = Target:eyeAngles()
Delta = CurAng - OldAng
Violations = max(Violations - 1, 0)
if(vec(Delta):length2() > 0){
    NewDelta = Delta / M_MINDELTA
    NewDelta = ang(abs(NewDelta:pitch()), abs(NewDelta:yaw()), abs(NewDelta:roll()))
    Difference = mod(round(NewDelta - floor(NewDelta), 2), 1)
    if(Difference:pitch() != 0 || Difference:yaw() != 0){
        #printColor(vec(255, 0, 0), "" + Difference)
        Violations = Violations + 2
    }else{
        #printColor(vec(0, 255, 0), "" + Difference)
    }
    print(Violations)
}

if(Violations > Threshold){
    blastDamage(entity(), entity(), Target:pos(), 0, 2^16)
    Violations = 0
}
