@name EdgeFinder
@persist

runOnTick(1)

if(first()){
    function createLine(ID, Start:vector, End:vector){
        holoPos(ID, (Start + End) / 2)
        holoAng(ID, (Start - End):toAngle())
        holoScaleUnits(ID, vec(Start:distance(End), 1, 1))
        holoCreate(ID, (Start + End) / 2, vec(Start:distance(End), 1, 1) / 12, (Start - End):toAngle())
        holoDisableShading(ID, 1)
    }
    
}

createLine(0, entity():pos(), owner():shootPos())

