@name rangertest
@inputs 
@outputs 
@persist 
@trigger 

runOnTick(1)

if(first()){
    holoCreate(1)
    holoCreate(2)
    holoColor(1, vec(255, 0, 0))
    holoColor(2, vec(0, 255, 0))
    holoScaleUnits(1, vec(0.5))
    holoScaleUnits(2, vec(0.5))
    holoDisableShading(1, 1)
    holoDisableShading(2, 1)
}

Forward = entity():forward()
Offset = vec(0, 0, -10)

rangerFilter(entity())
Ranger1 = rangerOffset(100, entity():pos() + Offset, Forward)
holoPos(1, Ranger1:position())

rangerFilter(entity())
Ranger2 = rangerOffset(100, Ranger1:position() + Forward * 16, Forward)
holoPos(2, Ranger2:positionLeftSolid())
