@name SEnt
@inputs Target:entity
@outputs Arm Detonate Launch
@persist [Missiles Offsets]:array AimPos:vector Launching Index

interval(0)
if(first()){
    Launch = 1
    Launching = 0
    D = 1000
    Offsets = array(
        vec(-D * 1.5, D * 1.5, 0), vec(-D * 0.5, D * 1.5, 0), vec(D * 0.5, D * 1.5, 0), vec(D * 1.5, D * 1.5, 0),
        vec(-D * 1.5, D * 0.5, 0), vec(-D * 0.5, D * 0.5, 0), vec(D * 0.5, D * 0.5, 0), vec(D * 1.5, D * 0.5, 0),
        vec(-D * 1.5, -D * 0.5, 0), vec(-D * 0.5, -D * 0.5, 0), vec(D * 0.5, -D * 0.5, 0), vec(D * 1.5, -D * 0.5, 0),
        vec(-D * 1.5, -D * 1.5, 0), vec(-D * 0.5, -D * 1.5, 0), vec(D * 0.5, -D * 1.5, 0), vec(D * 1.5, -D * 1.5, 0)
    )
}

if(owner():keyUse() && !Launching){
    AimPos = owner():aimPos()
    Launching = 1
    Index = 1
}

if(Launching){
    if(Index <= Offsets:count()){
        SPos = entity():pos() + Offsets[Index, vector] + vec(0, 0, 300)
        SAng = (AimPos - SPos):toAngle()
        E = sentSpawn("gw_harpoon", SPos, SAng, 0)
        E:applyForce(vec(0, 0, 1000) * E:mass())
        E:createWire(entity(), "Launch", "Launch")
        Index++
        Launch++
    }else{
        Launching = 0
    }
}

#[
foreach(K, V:entity=Missiles){
    V:applyAngForce(((AimPos - V:boxCenterW()):toAngle() - V:angles()) * V:mass() * 10)
}
]#
