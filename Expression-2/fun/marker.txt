@name Marker
@inputs Ent:entity
@persist DropPos:vector Toggle StartTime

runOnTick(1)
if(first()){
    DropPos = entity():pos() + vec(0, 0, gravity() * 4)
    I = 1
    while(perf() && holoCanCreate()){
        holoCreate(I, DropPos - vec(50, 0, I * 50))
        holoDisableShading(I, 1)
        holoColor(I, vec(0, 255, 0))
        I++
    }
    
}

if(changed(owner():keyUse()) & owner():keyUse()){
    if(Toggle){
        Ent:propFreeze(0)
    }else{
        Ent:propFreeze(1)
        Ent:setPos(DropPos)
        Ent:setAng(ang(0))
    }
    Toggle = !Toggle
}

if(Ent:vel():z() != 0){
    print(Ent:vel(), curtime() - StartTime)
}else{
    StartTime = curtime()
}
