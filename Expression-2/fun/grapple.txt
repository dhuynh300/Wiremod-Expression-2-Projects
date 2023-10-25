@name Grapple
@inputs EGP:wirelink
@persist GrapplePos:vector GrappleEnable GrappleCooldown MaxSpeed MaxDistance
@persist 
@persist Owner:entity Gravity TickInterval Timer

if(first()){
    GrappleEnable = 1
    GrappleCooldown = 1
    MaxSpeed = speedLimit()
    MaxDistance = MaxSpeed * 2
    
    Owner = owner()
    Gravity = gravity()
    TickInterval = tickInterval()
    Timer = curtime()
    
    runOnTick(1)
    runOnKeys(Owner, 1)
    
    EGP:egpClear()
    WH = egpScrSize(Owner)
    Speed = 1
    
    Size = 32
    EGP:egpBox(1, WH / 2, vec2(2))
    EGP:egpBox(2, vec2(), vec2(Size, 2))
    EGP:egpBox(3, vec2(), vec2(Size, 2))
    EGP:egpBox(4, vec2(), vec2(Size, 2))
    EGP:egpBox(5, vec2(), vec2(Size, 2))
    EGP:egpAngle(4, 90)
    EGP:egpAngle(5, 90)
    EGP:egpParent(2, 1)
    EGP:egpParent(3, 1)
    EGP:egpParent(4, 1)
    EGP:egpParent(5, 1)
    
    EGP:egpText(6, "100%", WH / 2 + vec2(0, 30))
    EGP:egpSize(6, 24)
    EGP:egpAlign(6, 1, 1)
    
    EGP:egpText(7, "Time Left: 5s", WH / 2 + vec2(0, 54))
    EGP:egpSize(7, 24)
    EGP:egpAlign(7, 1, 1)
    
    EGP:egp3DTracker(10, vec())
    EGP:egpParent(10, entity())
    EGP:egpText(11, "E2", vec2())
    EGP:egpAlign(11, 1, 1)
    EGP:egpParent(11, 10)
    
    EGP:egp3DTracker(20, vec())
    EGP:egpBox(21, vec2(), vec2(2))
    EGP:egpBox(22, vec2(), vec2(Size, 2))
    EGP:egpBox(23, vec2(), vec2(Size, 2))
    EGP:egpBox(24, vec2(), vec2(Size, 2))
    EGP:egpBox(25, vec2(), vec2(Size, 2))
    EGP:egpAngle(24, 90)
    EGP:egpAngle(25, 90)
    EGP:egpParent(21, 20)
    EGP:egpParent(22, 21)
    EGP:egpParent(23, 21)
    EGP:egpParent(24, 21)
    EGP:egpParent(25, 21)
    
    EGP:egpAlpha(21, 0)
    EGP:egpAlpha(22, 0)
    EGP:egpAlpha(23, 0)
    EGP:egpAlpha(24, 0)
    EGP:egpAlpha(25, 0)
}else{
    KeyPressed = keyClkPressedBind()
    
    if(GrappleEnable){
        Delta = max(Timer - curtime(), 0)
        Percent = Delta / GrappleCooldown
        EGP:egpColor(6, vec(Percent * 255, 255 - 255 * Percent, 0))
        EGP:egpSetText(6, round(((1 - Percent) * 100)):toString() + "%")
    
        if(Delta){
            EGP:egpSetText(7, "Time Left: " + round((Timer - curtime()), 1):toString() + "s")
        }else{
            EGP:egpSetText(7, "")
        }
    }else{
        EGP:egpSetText(6, "")
    }

    Ranger = Owner:eyeTrace()
    
    if(Owner:shootPos():distance(Ranger:position()) > MaxDistance){
        EGP:egpColor(1, vec(255, 0, 0))
        EGP:egpColor(2, vec(255, 0, 0))
        EGP:egpColor(3, vec(255, 0, 0))
        EGP:egpColor(4, vec(255, 0, 0))
        EGP:egpColor(5, vec(255, 0, 0))
    }else{
        EGP:egpColor(1, vec(0, 255, 0))
        EGP:egpColor(2, vec(0, 255, 0))
        EGP:egpColor(3, vec(0, 255, 0))
        EGP:egpColor(4, vec(0, 255, 0))
        EGP:egpColor(5, vec(0, 255, 0))
        
        if(GrappleEnable && curtime() > Timer && KeyPressed == "use"){
            GrapplePos = Ranger:position() + vec(0, 0, Owner:height() * 0.5)
            EGP:egp3DTracker(20, GrapplePos)
            EGP:egpAlpha(21, 255)
            EGP:egpAlpha(22, 255)
            EGP:egpAlpha(23, 255)
            EGP:egpAlpha(24, 255)
            EGP:egpAlpha(25, 255)
            
            if(Owner:isOnGround()){
                Owner:plyApplyForce(vec(0, 0, Gravity))
            }
            
            GrappleEnable = 0
        }
    }
        
    if(!GrappleEnable){
        OwnerBoxCenter = Owner:boxCenterW()
        Distance = vec2(OwnerBoxCenter):distance(vec2(GrapplePos))
        if(KeyPressed != "duck" && Distance > 128){
            if(!keyClk()){
                Angle = (GrapplePos - OwnerBoxCenter):toAngle()
                Force = clamp(Angle:forward() * MaxSpeed - Owner:vel(), 0, MaxSpeed * TickInterval)
                Force += vec(0, 0, Gravity * TickInterval * 2)
                
                Owner:plyApplyForce(Force)
            }
            
            Color = vec(
            sinr(3.14 * Distance) ^ 2 * 255,
            sinr(3.14 * (Distance + 0.66)) ^ 2 * 255,
            sinr(3.14 * (Distance + 0.33)) ^ 2 * 255)
            
            EGP:egpColor(21, Color)
            EGP:egpColor(22, Color)
            EGP:egpColor(23, Color)
            EGP:egpColor(24, Color)
            EGP:egpColor(25, Color)
            
        }else{
            GrappleEnable = 1
            Timer = curtime() + GrappleCooldown + TickInterval
            EGP:egpAlpha(21, 0)
            EGP:egpAlpha(22, 0)
            EGP:egpAlpha(23, 0)
            EGP:egpAlpha(24, 0)
            EGP:egpAlpha(25, 0)
        }
    }
}
