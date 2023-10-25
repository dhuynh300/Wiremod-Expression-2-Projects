@name Rockets!
@inputs #Rocket:entity
@outputs 
@persist Rocket:entity RocketState Target:vector

interval(0)
if(first()){
    findByClass("gw_*")
    findSortByDistance(entity():pos())
    Rocket = find()
    
    findByClass("npc_*")
    findSortByDistance(entity():pos())
    Target = find():massCenter()
    
    
    RocketState = 0
    Rocket:propFreeze(1)
    Rocket:propGravity(1)
    Rocket:propSetVelocity(vec(0))
    Rocket:setMass(5000)
    Rocket:setPos(entity():pos() + vec(50))
    Rocket:setAng(ang(-90, 0, 0))
    timer("Init", 500)
}

switch(clkName()){
    case "Init",
    timer("Launch", 0)
    break
    case "Launch",
    Rocket:propFreeze(0)
    Rocket:applyForce(vec(0, 0, Rocket:mass() * gravity() * 2))
    Rocket:setTrails(10, 10, 10, "effects/beam_generic01", vec(255), 255)
    Rocket:soundPlay(1, 0, "NPC_Combine.GrenadeLaunch")
    break
    case "Fly",
    RocketState = 1
    Rocket:soundPlay(1, 0, "PropAPC.FireRocket")
    break
}

switch(RocketState){
    case 1, # Fly
    Rocket:applyForce(Rocket:forward() * Rocket:mass() * 100)
    break
    default,
        if(Rocket:vel():z() < 0){
            timer("Fly", 0)
        }
    break
}

#Droop compensate
Distance = Rocket:massCenter():distance(Target) / Rocket:vel():length()
ZDiff = Target:z() - Rocket:vel():z() * Distance * Distance
NewPos = vec(Target:x(), Target:y(), ZDiff)
NewAng = (NewPos - Rocket:massCenter()):toAngle()

Angle = (Target - Rocket:massCenter()):toAngle()
DroopAng = Angle - NewAng
Delta = Rocket:toLocal(Angle) + DroopAng / 16

Force = Delta * Rocket:mass() * 10 - Rocket:angVel() * Rocket:mass()
Rocket:applyAngForce(Force * 4)
print(floor(DroopAng), floor(Rocket:vel():length()), floor(ZDiff))
