@name ThrusterDrone
@inputs PropEnt:entity
@outputs PitchUp PitchDown YawLeft YawRight RollLeft RollRight Height Front Back Left Right
@persist AngThreshold AngThrottle PosThreshold PosThrottle WantedPos:vector ActualEnt:entity

interval(0)
if(first()){
    AngThreshold = 0.1
    AngThrottle = 0.1
    PosThreshold = 1
    PosThrottle = 10
    
    ActualEnt = PropEnt
    if(!ActualEnt:isValid()){
        ActualEnt = entity()
    }
}

WantedPos = owner():pos() + vec(sin(curtime() * 64) * 512, cos(curtime() * 64) * 512, 128)
WX = WantedPos:x()
WY = WantedPos:y()
WZ = WantedPos:z()

Ang = ActualEnt:angles() + ActualEnt:angVel() * tickInterval()
AP = Ang:pitch()
AY = Ang:yaw()
AR = Ang:roll()

Pos = ActualEnt:pos() + ActualEnt:vel() / 2
PX = Pos:x()
PY = Pos:y()
PZ = Pos:z()

if(AP > AngThreshold){
    PitchUp = AngThrottle
    PitchDown = 0
}elseif(AP < -AngThreshold){
    PitchUp = 0
    PitchDown = AngThrottle
}else{
    PitchUp = 0
    PitchDown = 0
}

if(AY > AngThreshold){
    YawLeft = 0
    YawRight = AngThrottle
}elseif(AY < -AngThreshold){
    YawLeft = AngThrottle
    YawRight = 0
}else{
    YawLeft = 0
    YawRight = 0
}

if(AR > AngThreshold){
    RollLeft = AngThrottle
    RollRight = 0
}elseif(AR < -AngThreshold){
    RollLeft = 0
    RollRight = AngThrottle
}else{
    RollLeft = 0
    RollRight = 0
}

if(PX < WX - PosThreshold){
    Front = PosThrottle
    Back = 0
}elseif(PX > WX + PosThreshold){
    Front = 0
    Back = PosThrottle
}else{
    Front = 0
    Back = 0
}

if(PY < WY - PosThreshold){
    Left = PosThrottle
    Right = 0
}elseif(PY > WY + PosThreshold){
    Left = 0
    Right = PosThrottle
}else{
    Left = 0
    Right = 0
}

if(PZ < WZ - PosThreshold){
    Height = PosThrottle
}elseif(PZ > WZ + PosThreshold){
    Height = -PosThrottle
}else{
    Height = 0
}
