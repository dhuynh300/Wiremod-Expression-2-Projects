@name killing flying rat
@persist Index Max Array:array
interval(0)
if(Index < Max){
    V = Array[Index + 1, entity]
    V:setMass(10000)
    Closest = owner()
    Distance = inf()
    Pos = V:pos()
    foreach(K1, V1:entity = Array){
        if(V1 != V){
            TempDist = V1:pos():distance2(Pos)
            if(TempDist < Distance){
                Distance = TempDist
                Closest = V1
            }
        }
    }
    V:applyForce(((Closest:pos() + owner():pos() + vec(0, 0, 100)) / 2 - V:pos()):toAngle():forward() * V:mass() * 500)
    Index++
}else{
    findByModel("models/pigeon.mdl")
    Array = findToArray()
    Max = Array:count()
    Index = 0
}
