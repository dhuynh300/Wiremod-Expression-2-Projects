@name Projectile Solver
@inputs InProjectile:entity
@inputs EGP:wirelink
@outputs 
@persist Projectile:entity [ShootPos PosOffset]:vector Target:entity ProjectileSpeed ProjectileGravityMod TargetTime
@persist EGPGraph:array PolyArray:array LastDrawn LastDrawnIndex

interval(0)

if(first()){
    EGP:egpClear()
    EGP:egpDrawTopLeft(1)
    ProjectileSpeed = speedLimit() - 100 #u/s
    ProjectileGravityMod = 0
    PosOffset = vec(0, 0, 10)
    holoCreate(1)
    
    Projectile = InProjectile
    
    function shootProjectile(Position:vector){
        #Projectile:setMass(inf())
        Projectile:setMass(10)
        Projectile:propDrag(0)
        Projectile:propGravity(gravity() * ProjectileGravityMod)
    
        Angle = (Position - ShootPos):toAngle()
        Projectile:setPos(ShootPos)
        Projectile:applyAngForce(ang(randint(-1, 1)) * inf())
        Projectile:propSetVelocity(Angle:forward() * ProjectileSpeed)
        Projectile:soundPlay(0, 0, "Weapon_Gauss.ChargeLoop")
        holoPos(1, Position)
    }
    
    function number travelTime(Position:vector){
        return ShootPos:distance(Position) / ProjectileSpeed
    }
    
    function vector predictPos(Entity:entity, Time){
        ZModifier = 0
        EntityPos = Entity:pos() + PosOffset
        EntityVelocity = Entity:vel()
        if(EntityVelocity:z() != 0){
            ZModifier = gravity() * Time * Time * 0.5
        }
        return EntityPos + EntityVelocity * Time - vec(0, 0, ZModifier)
    }
    
    timer("Draw", 0)
}

findByClass("player")
findSortByDistance(entity():pos())
Target = find()

if(Projectile:isValid()){
    if(changed(owner():keyZoom()) && owner():keyZoom() || clk("Shoot")){
        ShootPos = entity():boxCenterW() + vec(0, 0, 250)
        TargetTime = travelTime(Target:pos() + PosOffset)
        TargetTimeStep = 1
        Sign = 0
        DirectTime = TargetTime
        
        FoundTarget = 0
        EGPGraph:clear()
        while(perf()){
            TargetPos = predictPos(Target, TargetTime)
            TravelTime = travelTime(TargetPos)
            EGPGraph:pushNumber(TargetTime - TravelTime)
            
            if(changed(Sign)){
                TargetTimeStep /= 3
            }
            
            if(TargetTime > TravelTime){
                TargetTime -= TargetTimeStep
                Sign = -1
            }elseif(TargetTime < TravelTime){
                TargetTime += TargetTimeStep
                Sign = 1
            }else{
                FoundTarget = 1
                shootProjectile(TargetPos)
                print("Coming in " + TravelTime + "s, Direct:" + DirectTime + "s, Dif:" + (DirectTime - TravelTime) + "s")
                timer("Shoot", (TravelTime + 2) * 1000)
                break
            }
        }
        
        if(!FoundTarget){            
            timer("Shoot", 100)
        }
    }
}else{
    propSpawn("models/props_junk/watermelon01.mdl", 0)
    findByModel("models/props_junk/watermelon01.mdl")
    findSortByDistance(entity():pos())
    Projectile = find()
    timer("Shoot", 1000)
}

if(changed(Target:isAlive()) && !Target:isAlive()){
    #Projectile:soundPlay(0, 0, "Dora")
    Target:soundPlay(0, 0, "punchies/1.wav")
    propDeleteAll()
}

# Draw Graph
if(clk("Draw")){
    GraphSize = 512
    GraphOffset = vec2(egpScrW(owner()) - GraphSize, 0)
    PlotSize = GraphSize / (EGPGraph:count() - 1)
    
    K = LastDrawn
    EGPIndex = LastDrawnIndex
    if(K >= EGPGraph:count()){
        K = 1
        EGPIndex = 2
    }
    
    EGP:egpClear()
    EGP:egpBox(1, GraphOffset, vec2(512))
    EGP:egpColor(1, vec())
    
    #[
    while(K <= EGPGraph:count() && perf(50)){
        V = EGPGraph[K, number] * 10000
        #TODO : convert to egpPoly
        EGP:egpRoundedBox(EGPIndex, GraphOffset + vec2((K - 1) * PlotSize, max(0, GraphSize - V - PlotSize / 2)), vec2(PlotSize))
        LastDrawn = K
        LastDrawnIndex = EGPIndex + 1
        EGPIndex++
        K++
    }
    ]#
    
    PolyArray:clear()
    foreach(K1, V1:number=EGPGraph){
        PolyArray:pushVector2(GraphOffset + vec2((K1 - 1) * PlotSize, max(0, GraphSize - V1 * 1000)))
    }
    EGP:egpLineStrip(2, PolyArray)
    
    timer("Draw", 50)
}





