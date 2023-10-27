@name Carpet Bomber
@inputs EGP:wirelink
@outputs Arm Launch
@persist HoloMax Selecting Running RunStart EndPercent PlaneSpeed PlaneIndex
@persist LaneDistance [AimPos LanePos LaneStart LaneEnd LaneForward PlanePos]:vector LaneAngle:angle

#next idea = ace bomber from btd5

if(first()){
    EGP:egpClear()
    Arm = 0
    Launch = 0
    Selecting = 0
    Running = 0
    RunStart = 0
    EndPercent = 2
    
    PlaneSpeed = 10000
    LaneDistance = 10000
    
    AimPos = vec()
    LanePos = vec()
    LaneStart = vec()
    LaneEnd = vec()
    LaneForward = vec()
    LaneAngle = ang()
    
    function number ulerp(I, O, N){
        return (1 - N) * I + N * O
    }
    
    function vector vlerp(I:vector, O:vector, N){
        X = ulerp(I:x(), O:x(), N)
        Y = ulerp(I:y(), O:y(), N)
        Z = ulerp(I:z(), O:z(), N)
        return vec(X, Y, Z)
    }
    
    HoloMax = 21
    for(I = 1, HoloMax, 1){
        holoCreate(I)
        holoDisableShading(I, 1)
        holoColor(I, vlerp(vec(0, 255, 0), vec(255, 0, 0), I / HoloMax))
        holoScaleUnits(I, vec(100))
    }
    
    PlaneIndex = HoloMax + 1
    holoCreate(PlaneIndex)
    holoModel(PlaneIndex, "models/xqm/jetbody3_s3.mdl")
    holoEntity(PlaneIndex):setTrails(500, 500, 0.2, "trails/smoke", vec(251, 139, 35), 255)
}

event keyPressed(Player:entity, _:string, Down:number, KeyBind:string) {
    if(Player == owner()){
        if(KeyBind == "use" && !Running){
            if(Down){
                Selecting = 1
            }elseif(Selecting){
                Selecting = 0
                
                RunStart = curtime()
                Running = 1
                
                holoAng(PlaneIndex, LaneAngle + ang(0, 90, 0))
                holoEntity(PlaneIndex):soundPlay(1, 0, "thrusters/jet03.wav")
                soundLevel(1, 160)
                printColor(vec(255, 255, 0), "Flying towards coordinates " + LanePos + "...")
            }
        }
    }
}

event tick() {
    if(Running){
        Percent = (curtime() - RunStart) * PlaneSpeed / LaneDistance - 4
        if(Percent < EndPercent){
            PlanePos = vlerp(LaneStart, LaneEnd, Percent)
            holoPos(PlaneIndex, PlanePos)
            
            if(PlanePos:isInWorld()){
                if(inrange(Percent + 0.9, 0, 1)){
                    if(!Arm){
                        printColor(vec(255, 0, 0), "Bombing...")
                    }
                    
                    S = 2000
                    for(_ = 1, 1, 1){
                        E = sentSpawn("gw_fab250", PlanePos, LaneAngle, 0)
                        #E:noCollideAll(1)
                        
                        E:applyForce((LaneForward * PlaneSpeed + vec(randvec2(-1, 1) * S) - vec(0, 0, speedLimit())) * E:mass())
                        E:applyAngForce(ang(randvec(-1, 1)) * E:mass() * angSpeedLimit())
                        
                        E:createWire(entity(), "Arm", "Arm")
                        E:createWire(entity(), "Launch", "Launch")
                        
                        Arm++
                        Launch++
                    }
                }
                
                EndPercent = Percent + 0.5
            }
        }else{
            printColor(vec(0, 255, 0), "Run complete. Dropped " + Arm + " bombs.")
            soundStop(1)
            
            Arm = 0
            Launch = 0
            Running = 0
        }
    }elseif(Selecting){
        if(!owner():keyWalk()){
            AimPos = owner():aimPos()
            rangerHitEntities(0)
            R = rangerOffset(10000, AimPos, vec(0, 0, 1))
            LanePos = R:position() - vec(0, 0, 4000)
            LaneAngle = owner():eyeAngles() * ang(0, 1, 0) + ang(0, 90, 0)
        }else{
            LaneAngle = (owner():aimPos() - LanePos):toAngle() * ang(0, 1, 0)
        }
        
        LaneForward = LaneAngle:forward()
        LaneStart = LanePos - LaneForward * LaneDistance / 2
        LaneEnd = LanePos + LaneForward * LaneDistance / 2
        
        HoloStart = AimPos - LaneForward * LaneDistance / 2
        HoloEnd = AimPos + LaneForward * LaneDistance / 2
        for(I = 1, HoloMax, 1){
            holoPos(I, vlerp(HoloStart, HoloEnd, (I - 1) / (HoloMax - 1)))
        }
    }
}
