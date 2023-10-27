@name MultiBullets
@inputs EGP:wirelink
@persist RPM CalculatedTime TimeToNextFire Interval TextSize Offset
@persist OldOrigin:vector OldAngles:angle
# Experiment to see how to solve the problem of the server
# can't keep up with a firerate of a fast gun like the minigun

interval(Interval * 1000)
#runOnKeys(owner(), 1)

if(first()){
    function createLine(ID, Start:vector, End:vector, Color:vector){
        holoCreate(ID, (Start + End) / 2, vec(Start:distance(End), 0.5, 0.5) / 12, (Start - End):toAngle(), Color)
        holoDisableShading(ID, 1)
    }
    
    function fireBullets(Bullets, Spread, Origin:vector, Angles:angle){
        ShootPos = OldOrigin
        ShootAngles = OldAngles
        
        holoCreate(0, Origin)
        holoCreate(1, OldOrigin)
        
        holoDisableShading(0, 1)
        holoDisableShading(1, 1)
        
        holoColor(0, vec(255, 0, 0))
        holoColor(1, vec(0, 0, 255))
        
        for(I = 1, Bullets, 1){
            Percent = I / Bullets
            ShootPos = (Origin * Percent + OldOrigin * (1 - Percent))
            ShootAngles = nlerp(quat(OldAngles), quat(Angles), Percent):toAngle()#slerp(quat(OldAngles), quat(Angles), Percent):toAngle()
            #ShootPos = (Origin * Percent + OldOrigin * (1 - Percent))
            #ShootAngles = (Angles * Percent + ShootAngles * (1 - Percent))
            
            RandomAngle = random(-180, 180)
            SpreadX = sin(RandomAngle) * random(-1, 1) * Spread
            SpreadY = cos(RandomAngle) * random(-1, 1) * Spread
            
            rangerFilter(owner())
            BulletAngle = ShootAngles + ang(SpreadX, SpreadY, 0)
            Trace = rangerOffset(8192, ShootPos, BulletAngle:forward())
            
            ColorPercent = I / Bullets * 255
            createLine(I + 1, ShootPos, Trace:position(), vec(255 - ColorPercent, ColorPercent, ColorPercent / 2))
            
            blastDamage(entity(), entity(), Trace:position(), 1, 34)
        }
        
        owner():soundPlay(1, 0, "Weapon_RPG.Single")
    }
    
    Interval = 0.1 # In Seconds
    Interval = max(Interval, tickInterval())
    RPM = 6000
    
    CalculatedTime = 1 / (RPM / 60)
    TimeToNextFire = curtime()
    
    Offset = 0
    TextSize = EGP:egpSizeNum(0)
    
    #====================================================================================================
    
    EGP:egpClear()
    
    EGP:egpText(1, (RPM / 60):toString() + " Rounds Per Second" , vec2(512/2, 512/2 + Offset))
    EGP:egpAlign(1, 1, 1)
    Offset += TextSize
    
    EGP:egpText(2, "CalculatedTime: " + CalculatedTime:toString() + "s Per Bullet", vec2(512/2, 512/2 + Offset))
    EGP:egpAlign(2, 1, 1)
    Offset += TextSize
}

if(owner():keyUse()){
    Time = curtime()
    if(Time >= TimeToNextFire){
        OldOffset = Offset
        TimeToNextFire = Time + CalculatedTime
        Bullets = floor(max(Interval / CalculatedTime, 1))
        
        EGP:egpText(3, "Bullets That Should've Shot Last Tick: " + (Bullets):toString(), vec2(512/2, 512/2 + Offset))
        EGP:egpAlign(3, 1, 1)
        Offset += TextSize
        
        fireBullets(Bullets, 0, owner():shootPos(), owner():eyeAngles())
        Offset = OldOffset
    }
}

OldOrigin = owner():shootPos()
OldAngles = owner():eyeAngles()
