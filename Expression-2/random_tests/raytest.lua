@name 
@inputs 
@outputs 
@persist CalculatedTime Bullets Counter
@trigger 

interval(CalculatedTime * 1000)

if(first()){
    Interval = 0.5 # In Seconds
    Interval = max(Interval, tickInterval())
    RPM = 6000
    
    CalculatedTime = 1 / (RPM / 60)
    Bullets = floor(max(Interval / CalculatedTime, 1))
    print(Bullets)
    
    for(I = 1, Bullets, 1){
        holoCreate(I)
    }
}

rangerFilter(owner())
Trace = rangerOffset(8192, owner():shootPos(), owner():eyeAngles():forward())
holoPos(Counter % Bullets, Trace:position())
Counter++
