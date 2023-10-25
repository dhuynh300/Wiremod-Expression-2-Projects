@name SpreadAlgorithems
@persist Spread Scale RandomNumber:array Target:entity Iterations
@persist [Number]:array
@persist [ResultsOld ResultsNew ResultsCat]:array

if(Iterations < 10){
    interval(0)
}else{
    printColor(vec(255,0,0), "Old:"+ResultsOld:average())
    printColor(vec(0,255,0), "New:"+ResultsNew:average())
    printColor(vec(0,0,255), "Cat:"+ResultsCat:average())
}

Bullets = 10
Spread = 1

function number shootBullets(InAngle:angle, InPos:vector, Color:vector4){
    HitCount = 0
    for(I = 0, Bullets - 1, 1){
        Angle = InAngle + RandomNumber[I, angle]
        EndPos = InPos + Angle:forward() * Scale
        
        Ranger = rangerOffset(InPos, EndPos)
        if(Ranger:entity() == Target){
            HitCount++
        }
    }
    return HitCount
}

for(I = 0, Bullets - 1, 1){
    RandomNumber[I, angle] = ang(random(-Spread,Spread), random(-Spread,Spread), 0)
}

findByClass("npc_*")
Target = find()

Angles = (Target:boxCenterW() - entity():pos()):toAngle()
Scale = Target:boxCenterW():distance(entity():pos()) + 128

# NO METHOD
foreach(K, V:angle=RandomNumber){
    foreach(K1, V1:angle=RandomNumber){
        Node1 = vec(V)
        Node2 = vec(V1)
        Distance = Node1:distance2(Node2) ^ 2
        Number[K, number] = Number[K, number] + Distance
    }
}

# MY METHOD
BestIndex = 0
BestDistance = inf()
foreach(K, V:number=Number){
    if(V < BestDistance){
        BestDistance = V
        BestIndex = K
    }
}

# CAT METHOD
Average = vec(0, 0, 0)
foreach(K, V:angle=RandomNumber){
    Average += vec(V)
}
Average /= RandomNumber:count()

BestIndex2 = 0
BestDistance2 = inf()
foreach(K, V:angle=RandomNumber){
    Dist = vec(V):distance2(Average)
    if(Dist < BestDistance2){
        BestDistance2 = Dist
        BestIndex2 = K
    }
}

# CALCULATE
Old = shootBullets(Angles - RandomNumber[0, angle], entity():pos(), vec4(255,0,0,150))
New = shootBullets(Angles - RandomNumber[BestIndex, angle], entity():pos(), vec4(0,255,0,150))
Cat = shootBullets(Angles - RandomNumber[BestIndex2, angle], entity():pos(), vec4(0,0,255,150))
ResultsOld[Iterations, number] = Old
ResultsNew[Iterations, number] = New
ResultsCat[Iterations, number] = Cat
Iterations++
