@name FLAK
@outputs Arm Detonate Launch
@persist [Missiles Targets]:array E:entity TIndex

#angnorm

if(first()){
    TIndex = 1
    Missiles = array()
    Targets = array()
    E = noentity()
    
    timer("attackInterval", 0)
    timer("radarInterval", 0)
}

if(clk("attackInterval")){
    if(owner():keyUse() && perf(90)){
        SPos = owner():shootPos()# + vec(0, 0, 50)
        SAng = (owner():aimPos() - SPos):toAngle()
        LE = E
        E = sentSpawn("gw_m390", SPos, SAng, 0)
        if(LE:isValidPhysics()){
            E:noCollide(LE)
        }
        #E:noCollideAll(1)
        
        E:setMass(50000)
        E:propGravity(0)
        E:propDrag(0)
        
        E:applyForce(E:forward() * E:mass() * speedLimit())
        E:applyAngForce(ang(0, 0, E:mass() * angSpeedLimit()))
        
        E:createWire(entity(), "Arm", "Arm")
        E:createWire(entity(), "Launch", "Launch")
        Arm++
        Launch++
        
        Missiles:pushEntity(E)
        #print(Missiles:count())
    }
    timer("attackInterval", tickInterval() * 1000 * 0)
}elseif(clk("radarInterval")){
    BlastRadius = 1500
    
    if(TIndex > Targets:count() && findCanQuery()){
        findByClass("npc_*")
        Targets = findToArray()
        TIndex = 1
    }
    
    while(TIndex <= Targets:count() && perf()){
        Target = Targets[TIndex, entity]
        if(Target:isAlive()){
            TargetPos = Target:boxCenterW()
            foreach(K2, Bomb:entity=Missiles){
                if(Bomb:isValid()){
                    BombPos = Bomb:boxCenterW()
                    if(TargetPos:distance(BombPos) < BlastRadius){
                        Bomb:createWire(entity(), "Detonate", "Detonate")
                        #Bomb:setAng((TargetPos - BombPos):toAngle())
                        print("BOOM!", round(curtime(), 2))
                    }
                }else{
                    Missiles:removeEntity(K2)
                    TIndex--
                    break
                }
            }
        }
        TIndex++
    }
    
    Detonate++
    timer("radarInterval", 0)
}
