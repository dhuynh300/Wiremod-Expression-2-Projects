@name 

runOnTick(1)
if(first()){
    entity():streamStart(1, "")
    streamDisable3D(1)
    streamRadius(1, streamMaxRadius())
    
    holoCreate(1)
    holoCreate(2)
    holoCreate(3)
    holoModel(1, "models/weapons/w_rif_ak47.mdl")
    holoModel(2, "models/weapons/w_rif_ak47.mdl")
    holoScale(3, vec())
    holoPos(1, entity():pos() + vec(20, 0, 20))
    holoPos(2, entity():pos() + vec(-20, 0, 20))
    holoAng(1, ang(-60, 0, 0))
    holoAng(2, ang(-60, 180, 0))
    holoParent(1, 3)
    holoParent(2, 3)
    holoParent(3, entity())
}

holoAng(3, ang(0, (curtime() * 250 % 360), 0))

