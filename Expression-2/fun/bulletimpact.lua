@name BulletImpact
@persist BulletIndex BulletSpeed OTime DTime LNumber HNumber Spread IkarosMode BulletColor:vector UsedIndex:array

interval(30)
runOnKeys(owner(), 1)

if(first()){
    BulletIndex = 1
    DTime = curtime()
    OTime = curtime()
    
    IkarMode = 1
    
    if(IkarMode){
        BulletColor = vec(254, 127, 156)
    }else{
        BulletColor = vec(255, 0, 0)
    }
    
    # Units / Second
    BulletSpeed = 3000
    
    function findAndRemove(Remove){
        foreach(K, V:vector4 = UsedIndex){
            if(V:x() == Remove){
                UsedIndex:removeVector4(K)
                break
            }
        }
    }
    
    function number findHoloArray(HoloIndex){
        foreach(K, V:vector4 = UsedIndex){
            if(V:x() == HoloIndex){
                return K
            }
        }
    }
    
    function number isUsed(HoloIndex, ID){
        foreach(K, V:vector4 = UsedIndex){
            if(V:y() == ID && V:x() != HoloIndex){
                return 1
            }
        }
        return 0
    }
}

DTime = curtime() - OTime
OTime = curtime()

if(owner():keyUse()){
    if(holoCanCreate()){
        OwnerEyeAng = owner():eyeAngles()
        switch(IkarMode){
            case 0,
            Spread = clamp(owner():vel():length() / 100, 0, 2.5)
            RandomAngle = random(-1000, 1000)
            Angle = OwnerEyeAng + ang(sin(RandomAngle) * random(-Spread, Spread), cos(RandomAngle) * random(-Spread, Spread), 0)
            owner():plySetAng(clamp(OwnerEyeAng + ang(random(-1, 0), random(-0.5, 0.5), 0), ang(-89, -360, 0), ang(89, 360, 0)))
            
            holoCreate(BulletIndex, owner():shootPos(), vec(2.5, 0.1, 0.1), Angle, BulletColor)
            break
            
            case 1,
            OwnerEyeAng *= ang(0, 1, 0)
            OwnerEyeAng += ang(0, random(-90, 90), 0)
            holoCreate(BulletIndex, owner():shootPos() - OwnerEyeAng:forward() * vec(15), vec(2.5, 0.1, 0.1), ang(-90, 0, 0), BulletColor)
            break
        }
        
        owner():soundPlay(1, 0, "Weapon_RPG.Single")
        
        holoEntity(BulletIndex):setTrails(5, 2, 10, "effects/beam_generic01", BulletColor, 255)
        holoDisableShading(BulletIndex, 1)
        UsedIndex:pushVector4(vec4(BulletIndex, 0, 0, 0))
        BulletIndex++
    }
}

LNumber = inf()
HNumber = 1
foreach(K, V:vector4 = UsedIndex){
    if(V:x() < LNumber){
        LNumber = V:x()
    }
    if(V:x() > HNumber){
        HNumber = V:x()
    }
}
BulletIndex = HNumber + 1

for(I = LNumber, HNumber, 1){
    if(!holoEntity(I):isValid()){
        continue
    }
    
    Forward = holoEntity(I):forward()
    HoloPos = holoEntity(I):pos()
    HoloAngle = Forward:toAngle()
    
    rangerFilter(owner())
    Ranger = rangerOffset(BulletSpeed * DTime, HoloPos, Forward)

    if(Ranger:hit()){
        holoDelete(I)
        switch(IkarMode){
            case 0,
            blastDamage(owner(), owner(), Ranger:position(), 500, 10)
            break
            
            case 1,
            blastDamage(owner(), owner(), Ranger:position(), 500, 10)
            break
        }
        findAndRemove(I)
    }else{
        switch(IkarMode){
            case 0,
            holoPos(I, Ranger:position())
            break
            
            case 1,
            findByClass("npc_*")
            
            WantedAngle = (owner():aimPos() - Ranger:position()):toAngle():forward()
            Delta = WantedAngle - Forward
            
            holoPos(I, Ranger:position())
            holoAng(I, (Forward + Delta / 2):toAngle())
            
            ArrayIndex = findHoloArray(I)
            foreach(K, V:entity = findToArray()){
                if(!isUsed(I, V:id()) && V:isAlive()){             
                    WantedAngle = (V:pos() - Ranger:position()):toAngle():forward()
                    Delta = WantedAngle - Forward
                    
                    holoAng(I, (Forward + Delta / 2):toAngle())
                    UsedIndex[ArrayIndex, vector4] = vec4(I, V:id(), 0, 0)
                    break
                }
            }
            break
        }
    }
}
