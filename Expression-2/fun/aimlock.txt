@name Aimlock
@persist 

runOnTick(1)

if(owner():keyDuck()){
    findByClass("npc_*")
    findSortByDistance(owner():shootPos())
    foreach(K, V:entity = findToArray()){
        if(V:isAlive()){
            TargetPos = V:attachmentPos("eyes")
            if(V:attachmentPos("eyes") == vec()){
                TargetPos = V:boxCenterW() - vec(0, 0, 10)
            }
            
            Angle = (TargetPos - owner():shootPos()):toAngle()
            owner():plySetAng(Angle)
            break
        }
    }
}
