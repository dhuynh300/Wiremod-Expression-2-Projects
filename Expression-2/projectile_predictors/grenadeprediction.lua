@name GrenadePrediction
@persist Time TimeDelta HoloSupers Found

runOnEntitySpawn(1)
runOnEntityRemove(1)
findByClass("npc_grenade_frag")

if(first()){
    #Time in seconds!
    Time = 2.5
    TimeDelta = Time / (1 / tickInterval())
}

Entity = findResult(1)
if(Entity){
    if(!Found){
        Found = 1
        HoloCount = 0
        HoloPos = Entity:pos()
        HoloVelocity = Entity:vel()
        print(HoloVelocity:length())
        for(I = 0, Time, TimeDelta){
            HoloVelocity -= vec(0, 0, gravity() * TimeDelta)
            HoloPos += HoloVelocity * TimeDelta

            holoCreate(HoloCount)
            holoPos(HoloCount, HoloPos)
            HoloCount++
        }
    }
}else{
    Found = 0
}
