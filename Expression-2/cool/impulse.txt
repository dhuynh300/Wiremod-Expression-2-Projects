@name Impulse
@persist 

runOnKeys(owner(), 1)

if(owner():keyUse()){
    Force = (owner():boxCenterW() - owner():aimPos()):toAngle():forward() * 25000 / owner():boxCenterW():distance(owner():aimPos())
    if(owner():vel():z() < 0){
        Force -= vec(0, 0, owner():vel():z())
    }
    owner():plyApplyForce(Force)
}
