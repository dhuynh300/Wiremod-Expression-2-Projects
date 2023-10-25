@name PlayerPrediction
@persist Time TimeDelta HoloSupers

runOnTick(1)

if(first()){
    #Time in seconds!
    Time = 4
    TimeDelta = Time / (2 / tickInterval())
    print(TimeDelta)
}

HoloCount = 0
HoloPos = owner():pos()
HoloVelocity = owner():vel()
for(I = 0, Time, TimeDelta){
    HoloVelocity -= vec(0, 0, gravity() * TimeDelta)
    HoloPos += HoloVelocity * TimeDelta

    holoCreate(HoloCount)
    holoPos(HoloCount, HoloPos)
    HoloCount++
}
