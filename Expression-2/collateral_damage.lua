@name Collateral Damage
@persist T:array I

if(first()){
    T = array()
    I = 1
}elseif(clk("stopAttack")){
    concmd("-attack")
}

event tick() {
    if(owner():keyWalk()){
        SPos = owner():shootPos()
        Count = T:count()
        
        if(findCanQuery() && I > Count){
            findByClass("npc_*")
            findSortByDistance(SPos)
            T = findToArray()
            I = 1
        }
        
        Count = T:count()
        while(I <= Count && perf()){
            V = T[I, entity]
            if(V:isAlive()){
                EPos = V:attachmentPos("eyes")
                
                rangerFilter(array(V, owner()))
                R = rangerOffset(EPos, SPos)
                HG = R:hitGroup()
                Ent = R:entity()
    
                if(HG == "head" && Ent:isAlive()){
                    Ang = angnorm((EPos - SPos):toAngle())
                    owner():plySetAng(Ang)
                    if(concmd("+attack")){
                        print(curtime())
                        timer("stopAttack", 0)
                    }
                    break
                }
            }
            
            I++
        }
    }else{
        I = 1
    }
}
