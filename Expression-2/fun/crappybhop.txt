@name CrappyBhop
@inputs EGP:wirelink
@persist LastVelocity:vector

runOnTick(1)

TotalVelocity = vec()

#[
if(owner():vel():z() == 0 && LastVelocity:z() != 0){
    Speed = vec2(owner():vel()):length()
    MaxSpeed = owner():plyGetSpeed() + 100
    if(Speed > MaxSpeed){
        SpeedReduce = MaxSpeed - Speed
        if(SpeedReduce < 0){
            TotalVelocity -= (owner():vel() * vec(1, 1, 0)):toAngle():forward() * -SpeedReduce
        }else{
            print("sumtingwong")
        }
    }
}
]#

if(owner():keyJump() && owner():vel():z() == 0){
    TotalVelocity += vec(0, 0, owner():plyGetJumpPower() + 50)
}

LastVelocity = owner():vel()
if(TotalVelocity:length() > 0){
    owner():plyApplyForce(TotalVelocity)
}

if(owner():keyJump()){
    MaxTurn = toDeg(atanr(30, vec2(owner():vel()):length()))
    EyeAngle = owner():eyeAngles()
    if(owner():keyLeft()){
        owner():plySetAng(EyeAngle + ang(0, MaxTurn, 0))
    }elseif(owner():keyRight()){
        owner():plySetAng(EyeAngle - ang(0, MaxTurn, 0))
    }
}

EGP:egpText(1, "Velocity: " + round(vec2(owner():vel()):length()) + "u/s", egpScrSize(owner()) * vec2(0.5, 0.75))
EGP:egpAlign(1, 1, 1)
