@persist PrvArr:array DragBasis:vector Step MaxHolos AirDensity
@persist [TargetVel TargetAcl AvgVel AvgAcl]:vector 
@persist Projectile:entity [ShootPos PosOffset]:vector Target:entity ProjectileSpeed ProjectileGravityMod
@persist ProjEntArr:table ProjectileIndex AvgArray:array AvgIndex Sounds:array NextAttackTime
@model models/props_trainyard/fueling_tower.mdl

findByModel("models/hunter/blocks/cube1x1x1.mdl")
#findByClass("wac*")
Target = findResult(1)

if(first()){
    PrvArr = array()
    Step = tickInterval()
    MaxHolos = 0
    AirDensity = 0
    
    Projectile = noentity()
    ProjectileSpeed = speedLimit() - 100 #u/s
    ProjectileGravityMod = 0
    ShootPos = vec(0, 0, 0)
    PosOffset = (Target:aabbMin() + Target:aabbMax()) / 2
    
    ProjEntArr = table()
    ProjectileIndex = 1
    
    AvgArray = array()
    AvgIndex = 1
    
    Sounds = array("Weapon_FlameThrower.FireLoop", "Weapon_Degreaser.FireLoop", "Weapon_BackBurner.FireLoop")
    #Sounds = array("grenade_tow.TrailLoop", "weapon_rpg.TrailLoop")
    NextAttackTime = 0
    
    runOnTick(1)
    runOnLast(1)
    propSpawnEffect(0)
    
    # Delta solver
    function vector calcDelta(CurVal:vector, Index){
        Delta = CurVal - PrvArr[Index, vector]
        PrvArr[Index, vector] = CurVal
        return Delta
    }
    
    # Drag functions
    function vector convertToIVP(Vec:vector){
        return vec(Vec:x(), -Vec:z(), Vec:y()) * 0.0254
    }
    
    # This changes based on mass and prop model
    function vector calcDragBasis(Ent:entity){
        AABMin = Ent:aabbMin()
        AABMax = Ent:aabbMax()
        
        Delta = AABMax - AABMin
        Delta = convertToIVP(Delta)
        Delta = vec(abs(Delta:x()), abs(Delta:y()), abs(Delta:z()))
        
        #AreaFraction = computeOrthographicAreas(Ent, 0.25)
        DragBasis = vec(Delta:y() * Delta:z(),
                        Delta:x() * Delta:z(),
                        Delta:x() * Delta:y())# * AreaFraction
        
        return DragBasis * (1 / Ent:mass())
    }
    
    function number getDragInDirection(Ent:entity, Vel:vector){
        Matrix = matrix(Ent:angles())
        Out = Matrix * Vel
        
        return
            abs(Out:x() * DragBasis:x()) +
            abs(Out:y() * DragBasis:y()) +
            abs(Out:z() * DragBasis:z())
    }
    
    # Doesn't work great with acceleration prediction
    function vector calcDrag(Ent:entity, Vel:vector){
        DragForce = -0.5 * getDragInDirection(Ent, Vel) * AirDensity * Step
        
        if(DragForce < -1.0){
            DragForce = -1.0
        }
        
        if(DragForce < 0.0){
            return Vel * DragForce
        }
        
        return vec(0, 0, 0)
    }
    
    # Prediction functions
    function vector predictPos(Ent:entity, Vel:vector, Acl:vector, Time){
        return Ent:pos() + Vel * Time + Acl * Time * Time * 0.5
    }
    
    function vector predictPosNoAcl(Ent:entity, Vel:vector, Time){
        return Ent:pos() + Vel * Time + vec(0, 0, -gravity()) * Time * Time * 0.5
    }
    
    function number travelTime(Position:vector){
        return ShootPos:distance(Position) / ProjectileSpeed
    }
    
    # Shooting functions
    function shootProjectile(Position:vector, Fuse){
        Angle = (Position - ShootPos):toAngle()
        propSpawn("models/military2/bomb/bomb_gbu10.mdl", ShootPos, Angle, 0)
        findByModel("models/military2/bomb/bomb_gbu10.mdl")
        findSortByDistance(entity():pos())
        Projectile = find()
        ProjEntArr:pushArray(array(Projectile, curtime() + Fuse))
        ProjectileIndex = ProjEntArr:count() + 1
        
        Projectile:setMass(1000)
        Projectile:propDrag(0)
        Projectile:propGravity(gravity() * ProjectileGravityMod)
    
        Projectile:propSetAngVelocity(vec(720, 0, 0))
        Projectile:propSetVelocity(Angle:forward() * ProjectileSpeed)
        Projectile:soundPlay(ProjectileIndex % 14 + 1, 0, Sounds[randint(1, Sounds:count()), string])
        Projectile:setTrails(20, 1, 0.2, "effects/beam_generic01", vec(255, 128, 0), 255)
        
        TempEffect = effect()
        TempEffect:play("bloodspray")
        TempEffect:setScale(10)
        TempEffect:setMagnitude(10)
        TempEffect:setRadius(10)
        TempEffect:setOrigin(ShootPos)
        TempEffect:setStart(ShootPos)
        TempEffect:play("bloodspray")
        entity():soundPlay(0, 0, "wac.wac_pl_a10.MissileShoot")
        holoPos(1, Position)
    }
    
    DragBasis = calcDragBasis(Target)
    print("DragBasis:\n", round(DragBasis, 3))
}elseif(last()){
    propDeleteAll()
}elseif(clk("checkProjectiles")){
    foreach(K:number, V:array = ProjEntArr){
        V1 = V[1, entity]
        if(curtime() >= V[2, number] || V1:vel():length() < (ProjectileSpeed - 1)){
            Pos = V1:boxCenterW()
            HoloIndex = MaxHolos - K
            holoPos(HoloIndex, Pos)
            holoEntity(HoloIndex):soundPlay(HoloIndex, 0, "outland_07.Explosion_Console_01")
            blastDamage(V1, V1, Pos, 1000, 50)
            
            TempEffect = effect()
            TempEffect:setOrigin(Pos)
            TempEffect:setNormal(V1:forward())
            TempEffect:play("Explosion")
            
            V1:propDelete()
            ProjEntArr:remove(K)
        }
    }
}else{
    if(holoCanCreate()){
        while(perf() && holoCanCreate()){
            MaxHolos++
            holoCreate(MaxHolos)
            holoColor(MaxHolos, vec(0, 255, 0))
            holoDisableShading(MaxHolos, 1)
        }
        holoColor(1, vec(255, 0, 0))
        print(MaxHolos + " Max Holos")
    }
    
    if(Target){
        AirDensity = airDensity()
        
        TargetVel = Target:vel()
        TargetAcl = calcDelta(TargetVel, 1) / Step
        
        # Averages
        MaxAvgCount = 20
        AvgArray[AvgIndex % MaxAvgCount + 1, vector] = TargetVel
        AvgIndex++
        
        AvgVel = vec(0, 0, 0)
        foreach(K, V:vector=AvgArray){
            AvgVel += V
        }
        AvgVel /= AvgArray:count()
        AvgAcl = calcDelta(AvgVel, 2) / Step
        # Averages End
        
        if(owner():keyZoom() && propCanCreate() && curtime() > NextAttackTime){
            ShootPos = entity():boxCenterW() + vec(0, 0, 250)
            TargetTime = travelTime(Target:pos() + PosOffset)
            TargetTimeStep = 1
            Sign = 0
            DirectTime = TargetTime
            
            while(perf(50)){
                #TargetPos = predictPos(Target, TargetVel, TargetAcl, TargetTime) + PosOffset
                TargetPos = predictPos(Target, AvgVel, AvgAcl, TargetTime) + PosOffset
                TravelTime = travelTime(TargetPos)
                
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
                    TargetPos = predictPos(Target, AvgVel, AvgAcl, TargetTime - tickInterval() * 2) + PosOffset
                    TravelTime = travelTime(TargetPos)
                    shootProjectile(TargetPos, TravelTime)
                    
                    print("Coming in " + round(TravelTime, 2) + "s, Direct:" + round(DirectTime, 2) + "s, Dif:" + round(DirectTime - TravelTime, 2) + "s")
                    
                    NextAttackTime = curtime() + 0.3
                    break
                }
            }
        }else{
            I = 2
            Time = Step
            while(perf() && I < MaxHolos - 20){
                holoPos(I, predictPos(Target, AvgVel, AvgAcl, Time) + PosOffset)
                holoColor(I, vec(0, 255, 0))
                I++
                Time += Step
            }
            #[
            I = 2
            Time = Step
            TempMaxHolos = MaxHolos - 20
            while(perf() && I < TempMaxHolos * 1 / 3){
                holoPos(I, predictPosNoAcl(Target, TargetVel, Time) + PosOffset)
                holoColor(I, vec(255, 0, 0))
                I++
                Time += Step
            }
            
            Time = Step
            while(perf() && I < TempMaxHolos * 2 / 3){
                holoPos(I, predictPos(Target, TargetVel, TargetAcl, Time) + PosOffset)
                holoColor(I, vec(0, 255, 0))
                I++
                Time += Step
            }
            
            Time = Step
            while(perf() && I < TempMaxHolos * 3 / 3){
                holoPos(I, predictPos(Target, AvgVel, AvgAcl, Time) + PosOffset)
                holoColor(I, vec(0, 0, 255))
                I++
                Time += Step
            }
            ]#
        }
    }
    
    timer("checkProjectiles", 10)
}
