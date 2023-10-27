@name Gibby Airstrike
@persist BulletIndex OTime DTime LNumber HNumber UsedIndex:array Explosions:array AirstikeBottom:vector AirstikeTop:vector
@persist CircleMaxSize CircleRadius CircleAlpha FireAirstrike FireTimer InProgress FoundNade Nade:entity
interval(50)
timer("UpdateModels", 100)

if(first()){
    InProgress = 0
    BulletIndex = 2
    CircleRadius = 0
    CircleAlpha = 255
    FireAirstrike = 1

    CircleMaxSize = 2500
    
    DTime = curtime()
    OTime = curtime()
    
    Explosions = array("explode_1","explode_2","explode_3","explode_4","explode_5","explode_6","explode_8","explode_9")
    
    function findAndRemove(Remove){
        foreach(K, V:number = UsedIndex){
            if(V == Remove){
                UsedIndex:removeNumber(K)
                break
            }
        }
    }
}

if(InProgress){
    if(CircleRadius < CircleMaxSize){
        CircleRadius += CircleMaxSize * tickInterval() * 2
        CircleRadius = clamp(CircleRadius, 0, CircleMaxSize)
        holoAlpha(0, 255)
        holoAng(0, ang())
        holoScaleUnits(0, vec(CircleRadius, CircleRadius, 64))
    }elseif(CircleAlpha > 0){
        CircleAlpha -= 512 * tickInterval() * 2
        CircleAlpha = clamp(CircleAlpha, 0, 255)
        holoAlpha(0, CircleAlpha)
    }elseif(FireAirstrike && curtime() - FireTimer > 0.1){
        holoCreate(BulletIndex, AirstikeTop + vec(sin(random(-180, 180)) * random(-CircleRadius / 2, CircleRadius / 2), cos(random(-180, 180)) * random(-CircleRadius / 2, CircleRadius / 2), -100), vec(10, 5, 5), ang(90 + random(-2, 2), random(-180, 180), 0), vec4(255, 0, 0, 255), "icosphere3")
        holoEntity(BulletIndex):setTrails(100, 100, 1, "effects/beam_generic01", vec(255, 0, 0), 255)
        holoDisableShading(BulletIndex, 1)
        UsedIndex:pushNumber(BulletIndex)
        BulletIndex++
        
        FireTimer = curtime()
        timer("EnableAir", 5000)
    }
    
    if(clk("UpdateModels")){
        DTime = curtime() - OTime
        OTime = curtime()
        LNumber = inf()
        HNumber = 2
        
        foreach(K, V:number = UsedIndex){
            if(V < LNumber){
                LNumber = V
            }
            if(V > HNumber){
                HNumber = V
            }
        }
        BulletIndex = HNumber + 1
        
        for(I = LNumber, HNumber, 1){
            if(!holoEntity(I):isValid()){
                continue
            }
            
            Ranger = rangerOffset(8000 * DTime, holoEntity(I):pos(), holoEntity(I):angles():forward())
            
            holoPos(I, Ranger:position())
            if(Ranger:hit() || holoEntity(I):pos():z() < AirstikeBottom:z()){
                holoEntity(I):soundPlay(randint(1, 4), 0, Explosions[randint(0, 8), string])
                blastDamage(owner(), owner(), Ranger:position(), CircleMaxSize / 4, 100)
                holoAlpha(I, 0)
                findAndRemove(I)
            }
        }
    }
    
    if(clk("EnableAir")){
        soundStop(0)
        FireAirstrike = 0
    }elseif(!FireAirstrike && HNumber <= 2){
        timer("DeleteAllHolos", 2500)
        InProgress = 0
    }
}else{
    findByClass("npc_grenade_frag")
    
    if(clk("DeleteAllHolos")){
        holoDeleteAll()
    }
    
    if(FoundNade && !InProgress){
        if(!Nade:isValid()){
            holoCreate(0, AirstikeBottom, vec(), ang(), vec(255, 0, 0), "cylinder")
            holoEntity(0):soundPlay(0, 0, "ep2_outland_12.base_alarm_loop")
            holoDisableShading(0, 1)

            CircleRadius = 0
            CircleAlpha = 255
            FireAirstrike = 1
            InProgress = 1
            
            DTime = 0
            OTime = curtime() + 1
        }
    }
    
    FoundNade = 0
    foreach(K, V:entity = findToArray()){
        #if(V:owner() == owner()){
            FoundNade = 1
            
            rangerFilter(V)
            Ranger = rangerOffset(100000, V:boxCenterW() + vec(0, 0, 10), vec(0, 0, 1))
            AirstikeTop = Ranger:position()
            
            rangerFilter(V)
            Ranger = rangerOffset(100000, AirstikeTop, vec(0, 0, -1))
            AirstikeBottom = Ranger:position()
            
            Nade = V
            break
        #}
    }
}
