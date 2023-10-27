@name b2studios cannon
@outputs Arm Detonate
@persist ITimeStep PSpeed Tune [Target E]:entity [Bombs]:array Ammo:string
@persist Ticks TicksOffset RadarTicks [LTPos LTVel LTAcl]:vector DetectionRadius G:gtable
@model models/props/coop_autumn/fall_apc_turret/fall_apc_turret_top.mdl
@strict

#https://docs.google.com/document/d/1TKhiXzLMHVjDPX3a3U0uMvaiW1jWQWUmYpICjIDeMSA/edit

if(first()){
    ITimeStep = 0.5
    PSpeed = speedLimit()
    Tune = -0.25
    Target = owner()
    E = noentity()
    Bombs = array()
    Ammo = "gw_m61" #"gw_m61"
    
    Ticks = 1
    TicksOffset = 0
    RadarTicks = 1
    LTPos = LTVel = LTAcl = vec(0)
    DetectionRadius = 12000
    
    propSpawnUndo(0)
    enableConstraintUndo(0)
    
    holoCreate(1)
    holoModel(1, "hq_sphere")
    holoMaterial(1, "models/wireframe")
    holoAlpha(1, 10)
    holoAng(1, ang(0))
    holoScale(1, vec(-DetectionRadius / 6))
    
    G = gTable("b2studios_cannon", 0)
    GT = G:toTable()
    if(!GT:exists("entities")){
        G["entities", array] = array()
    }
    I = 1
    while(I < G["entities", array]:count()){
        V = G["entities", array][I, entity]
        if(!V:isValid() || V == entity()){
            G["entities", array]:remove(I)
        }else{
            I++
        }
    }
    G["entities", array]:pushEntity(entity())
    
    function fireProjectile(){
        TPos = Target:massCenter()
        TVel = Target:vel()
        TAcl = LTAcl
        
        EPos = E:massCenter()
        EVel = E:vel()
        EAcl = vec(0, 0, -gravity())
        
        NTPos = vec(0)
        NEPos = vec(0)
        Radius = 0
        Distance = EPos:distance(TPos)
        
        # Precalculate
        TAcl *= 0.5
        EAcl *= 0.5
        
        Time = Distance / PSpeed
        TimeStep = ITimeStep
        BestDelta = 10
        BestTime = 0
        I = 0
        while(perf(95)){
            NTPos = TPos + (TVel + TAcl * Time) * Time
            NEPos = EPos + (EVel + EAcl * Time) * Time
            
            Radius = PSpeed * Time
            Distance = NEPos:distance(NTPos)
            
            Delta = abs(Distance - Radius)
            if(Delta < BestDelta){
                BestDelta = Delta
                BestTime = Time
            }
            
            if(Radius > Distance && TimeStep > 0){
                TimeStep = TimeStep * Tune
            }elseif(Radius < Distance && TimeStep < 0){
                TimeStep = TimeStep * Tune
            }elseif(TimeStep == 0){
                # E2 does not have enough precision
                Time = BestTime
                NTPos = TPos + (TVel + TAcl * Time) * Time
                NEPos = EPos + (EVel + EAcl * Time) * Time
                Radius = PSpeed * Time
                Distance = NEPos:distance(NTPos)
                break
            }
            
            Time += TimeStep
            I++
        }
        
        TrailColor = vec(255, 0, 0)
        if(BestDelta > 1){
            TrailColor = vec(255, 255, 0)
        }
        E:setTrails(10, 10, 0.1, "effects/beam_generic01", TrailColor, 255)
        
        AimAngle = angnorm((NTPos - NEPos):toAngle())
        entity():setAng(AimAngle)
        SI = Ticks % 15 + 1
        entity():soundPlay(SI, 1, "Weapon_CSGO_M4A1.SilencedSingle")
        soundLevel(SI, 160)
        soundVolume(SI, 1)
        
        E:propFreeze(0)
        E:setAng(AimAngle)
        E:propSetVelocity(AimAngle:forward() * PSpeed)
        
        Bombs:pushEntity(E)
        Bombs:pushNumber(curtime() + Time - 0.15)
    }
}

event tick() {
    EntPos = entity():pos()
    holoPos(1, EntPos)
    findByClass("gw_*")
    findClipFromClass(Ammo)
    findClipToSphere(EntPos, DetectionRadius)
    findSortByDistance(EntPos)
    Target = find()
    
    if(Target:isValidPhysics()){
        if(!((Ticks + TicksOffset) % RadarTicks)){
            DTime = tickInterval() * RadarTicks
            LTPos = Target:massCenter()
            LTVel = $LTPos / DTime
            LTAcl = $LTVel / DTime
            
            if(Ticks > RadarTicks * 2 && perf(5)){
                LE = E
                E = sentSpawn(Ammo, EntPos, ang(-90, 0, 0), 1)
                if(LE:isValid()){
                    E:noCollide(LE)
                }
                
                E:propDrag(0)
                E:createWire(entity(), "Arm", "Arm")
                Arm++
                
                fireProjectile()
            }
        }
        
        Ticks++
    }else{
        Ticks = 0
    }
    
    I = 1
    while(I <= Bombs:count() && perf()){
        BombEnt = Bombs[I, entity]
        if(!BombEnt:isValid()){
            Bombs:remove(I + 1)
            Bombs:remove(I)
            continue
        }elseif(curtime() >= Bombs[I + 1, number]){
            BombEnt:createWire(entity(), "Detonate", "Detonate")
            
            Bombs:remove(I + 1)
            Bombs:remove(I)
            continue
        }
        
        I += 2
    }
    Detonate++
    
    CCount = G["entities", array]:count()
    if(changed(CCount)){
        foreach(K, V:entity = G["entities", array]){
            if(V == entity()){
                TicksOffset = round((K - 1) / CCount * RadarTicks)
                break
            }
        }
    }
}
