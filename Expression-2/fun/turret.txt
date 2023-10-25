@name Turret
@inputs Turret:entity User:entity
@outputs Fire Force Damage NumBullets Spread Delay Sound:string Tracer:string
@persist FlipFlop LastTime
runOnTick(1)

if(first()){
    Fire = 0
    Force = 1000000
    Damage = 1000000
    NumBullets = 1000000
    Delay = 0.05
    Sound = ""
    Tracer = ""
    
    findByClass("gmod_wire_turret")
    findSortByDistance(entity():pos())
    Turret = find()
    
    Turret:createWire(entity(), "Fire", "Fire")
    Turret:createWire(entity(), "Force", "Force")
    Turret:createWire(entity(), "Damage", "Damage")
    Turret:createWire(entity(), "NumBullets", "NumBullets")
    Turret:createWire(entity(), "Spread", "Spread")
    Turret:createWire(entity(), "Delay", "Delay")
    Turret:createWire(entity(), "Sound", "Sound")
    Turret:createWire(entity(), "Tracer", "Tracer")
}

Fire = 0
findByClass("npc_*")
#findByClass("player")
FindArray = findToArray()
foreach(K, V:entity = FindArray){
    if(V == owner()){
        continue
    }elseif(V:health() > 0){
        TargetPos = V:boxCenterW() + V:vel() * tickInterval()
        Turret:setAng((TargetPos - Turret:boxCenterW()):toAngle())
        User:setPos(Turret:boxCenterW() - Turret:up() * 10)
        User:setAng((TargetPos - User:boxCenterW()):toAngle() + ang(90, 0, 0))
        Fire = 1
        break
    }
}

if(curtime() > LastTime){
    LastTime = curtime() + Delay
    FlipFlop = !FlipFlop
    if(FlipFlop){
        Spread = 0
    }else{
        Spread = 0.005
    }
}
