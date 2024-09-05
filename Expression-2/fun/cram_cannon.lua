@name CRAM Cannon
@outputs Arm Detonate
@persist [Target Prop Bomb]:entity Start:vector Stop Toggle

interval(0)

if(owner():keyUse() && !Toggle){
    findByClass("npc_*")
    findSortByDistance(owner():aimPos())
    
    propSpawnEffect(0)
    
    Prop = propSpawn("models/thedoctor/bomb_gbu10.mdl", 1)
    Prop:setAlpha(0)
    
    Start = Prop:boxCenterW()
    
    G = gravity()
    M = inf()
    
    V = 3000
    V = clamp(V, 0, speedLimit())
    
    Prop:propDrag(0)
    Prop:propSetFriction(0)
    Prop:propSetBuoyancy(0)
    Prop:propGravity(G)
    Prop:setMass(M)
    
    Target = find()#findResult(randint(1, findToArray():count()))
    Pos = Target:pos() + vec(0, 0, Target:height())
    print("Target:", Target)
    
    D = vec2(Start):distance(vec2(Pos))
    
    H = Pos:z() - Start:z()
    A1 = -toDeg(atanr( (V ^ 2 + sqrt(V ^ 4 - G * (G * D ^ 2 + 2 * H * V ^ 2))) / (G * D) ))
    A2 = -toDeg(atanr( (V ^ 2 - sqrt(V ^ 4 - G * (G * D ^ 2 + 2 * H * V ^ 2))) / (G * D) ))
    
    if(isnan(A1) || isnan(A2)){
        printColor(vec(255, 0, 0), "Target is Too Far!")
        
        propDeleteAll()
        selfDestructAll()
    }
    
    H1 = (V ^ 2 * sin(-A1) ^ 2) / (2 * G)
    H2 = (V ^ 2 * sin(-A2) ^ 2) / (2 * G)
    
    rangerFilter(Prop)
    Ranger = rangerOffset(16384, Start, vec(0, 0, 1))
    MaxHeight = Ranger:position():z() - Start:z()
    
    A = A2
    if( H1 < MaxHeight){
        A = A1
    }
    
    printColor(vec(0, 0, 255), "First Angle: " + A1)
    printColor(vec(0, 0, 255), "Second Angle: " + A2)
    printColor(vec(0, 0, 255), "Angle of Choice: " + A)
    printColor(vec(0, 0, 255), "Predicted Distance: " + D)
    
    ToTarget = (Pos - Start):toAngle()
    Direction = ang(A, ToTarget:yaw(), 0):forward()
    
    Prop:propFreeze(0)
    Prop:setAng(ToTarget)
    Prop:propSetVelocity(Direction * V)
    
    holoCreate(1, Start, vec(1), ToTarget, vec4(255, 255, 255, 0), Prop:model())
    holoParent(1, Prop)
    
    W = Prop:boxSize():length() / 10
    holoEntity(1):setTrails(W, W, 2, "trails/laser", vec(255, 0, 0), 255)
    
    findByClass("gb5_*")
    Bomb = findResult(1)
    Bomb:setAng(ang(-90, 0, 0))
    Bomb:setPos(holoEntity(1):pos())
    Bomb:createWire(entity(), "Arm", "Arm")
    Bomb:createWire(entity(), "Detonate", "Detonate")
    Arm = 1
    
    noCollideAll(Bomb, 1)
    
    Prop:soundPlay(0, 0, "explode_9")
    Prop:soundPlay(1, 0, "lostcoast.siren_citizen")
    
    Stop = 1
    Toggle = 1
    timer("Enable", 100)
}

if(Toggle){
    if(clk("Enable")){
        holoAlpha(1, 255)
        Stop = 0
    }elseif(clk("Delete") || !Prop:isValid()){
        propDeleteAll()
        selfDestructAll()
        printColor(vec(0, 255, 0), "Deleted!" )
    }
    
    if((!Target:isAlive() || Prop:vel():length2() < 1000) && !Stop){
        holoUnparent(1)
        holoAlpha(1, 0)
        
        Bomb:deparent()
        Bomb:propSetVelocity(Prop:vel() * 100)
        Prop:propStatic(1)
        noCollideAll(Prop, 1)
    
        if(!Bomb){
            holoEntity(1):soundPlay(1, 0, "explode_1")
            blastDamage(Prop, Prop, Prop:boxCenterW(), 8192, 8192)
        }
        Detonate = 1
    
        printColor(vec(255, 0, 0), "Dist: " + vec2(Prop:boxCenterW()):distance(vec2(Start)))
        timer("Delete", 2500)
        Stop = 1
    
    }elseif(!Stop){
        holoAng(1, Prop:vel():toAngle() + ang(0, 0, curtime() * vec2(Prop:vel()):length()))
        Bomb:parentTo(holoEntity(1))
    }
}
