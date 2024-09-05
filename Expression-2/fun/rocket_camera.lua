# Spawn a GBomb5 or HBomb, bomb then use crouch to enter camera and then run key to launch and aim
@inputs EGP:wirelink CamPos:vector CamDir:vector CamAng:angle
@outputs Activated Parent:entity Position:vector FOV Arm Detonate
@persist Rocket:entity HitPos:vector OldHitPos:vector LockOnTargets:array LockEntity:entity AnimStage

# 100ms is fine, 50ms is optimal
interval(50)

if(first()){
    # Find neareast cam controller
    findByClass("gmod_wire_cameracontroller")
    findSortByDistance(entity():pos())
    WireEntity = find()
    
    # Wire everything up
    entity():createWire(WireEntity, "CamPos", "CamPos")
    entity():createWire(WireEntity, "CamDir", "CamDir")
    entity():createWire(WireEntity, "CamAng", "CamAng")
    WireEntity:createWire(entity(), "Activated", "Activated")
    WireEntity:createWire(entity(), "FLIR", "Activated")
    WireEntity:createWire(entity(), "Parent", "Parent")
    WireEntity:createWire(entity(), "Position", "Position")
    WireEntity:createWire(entity(), "FOV", "FOV")
    
    # Find neareast EGP
    findByClass("gmod_wire_egp_hud")
    findSortByDistance(entity():pos())
    WireEntity = find()
    
    # Wire everything up
    entity():createWire(WireEntity, "EGP", "wirelink")
    
    # Set FOV and functions
    FOV = 70
    function angle angleNormalize(Angle:angle){
        Angle = Angle:forward():toAngle()
        return ang(mod(Angle:pitch() + 90, 180) - 90, mod(Angle:yaw() + 180, 360) - 180, mod(Angle:roll() + 180, 360) - 180)
    }
}

if(Rocket:isValid()){
    # Cam controller's HitPos doesn't filter rocket
    rangerFilter(Rocket)
    HitPos = rangerOffset(56755, CamPos, CamDir):position()
    
    # Activate camera
    if(owner():keyDuck()){
        Activated = 1
        Parent = Rocket
        Position = Rocket:pos()
        
        # Launch rocket then check for freecam
        if(owner():keySprint()){
            if(!Arm){
                Arm = 1
                
                # Align and put the rocket in a favorable position
                rangerFilter(Rocket)
                BoxSize = Rocket:boxSize()
                Rocket:propFreeze(1)
                Rocket:setAng(ang(-90, CamAng:yaw(), 0))
                Rocket:setPos(rangerOffset(1024, Rocket:boxCenterW(), vec(0, 0, -1)):position() + vec(0, 0, max(BoxSize:x(), max(BoxSize:y(), BoxSize:z()))))
                timer("launchRocket", 100)
            }
        }else{
            # If we're not in freecam then set variables
            OldHitPos = HitPos  
        }
        
        # Start timer
        timer("refreshLockOnTargets", 0)
    }elseif(Activated){
        EGP:egpClear()
        Activated = 0
    }
    
    if(Arm){
        # Lock on target system
        if(LockEntity:isAlive()){
            OldHitPos = LockEntity:boxCenterW()
            EGP:egpColor(2, vec(0, 255, 0))
        }else{
            EGP:egpColor(2, vec(0, 0, 255))
        }
        
        # Negate spin first
        RocketAngles = Rocket:angles()
        Rocket:applyAngForce((Rocket:angVel() + ang(0, 0, RocketAngles:roll())) * Rocket:mass() * -4)
        
        # Calculate angular force to rotate towards point without overshooting
        Mass = Rocket:mass()
        AimDirection = angleNormalize((OldHitPos - Rocket:massCenter()):toAngle())
        Angle = angleNormalize(AimDirection - RocketAngles) * Mass * 128
        AngVel = Rocket:angVel() * ang(1, 1, 0) * Mass * 2
        Rocket:applyAngForce(Angle - (AngVel + $AngVel * 10))
        
        # Show where the rocket is aiming at
        EGP:egp3DTracker(1, OldHitPos)
        EGP:egpBoxOutline(2, vec2(), vec2(20))
        EGP:egpParent(2, 1)
        
        if(AnimStage == 1){
            # Accelerate rocket
            Rocket:applyForce(Rocket:forward() * Mass * 1000)
            
            # Airburst mode
            if(owner():keyUse()){
                Detonate = 1
            }
            
        }
    }
}else{
    # Null variables out
    Activated = 0
    Arm = 0
    Detonate = 0
    AnimStage = 0
    Parent = noentity()
    EGP:egpClear()
    
    # Find explosive entities
    findByClass("gb5_*")
    foreach(K, V:entity = findToArray()){
        if(V:owner() == owner()){
            Rocket = V
            Rocket:createWire(entity(), "Arm", "Arm")
            Rocket:createWire(entity(), "Detonate", "Detonate")
            break
        }
    }
    
    # If we didn't find a GB5 entity, find a HB entity
    if(!Rocket:isValid()){
        findByClass("gw_*")
        foreach(K, V:entity = findToArray()){
            if(V:owner() == owner()){
                Rocket = V
                Rocket:createWire(entity(), "Arm", "Arm")
                Rocket:createWire(entity(), "Detonate", "Detonate")
                break
            }
        }
    }
}

# Timers
if(Arm){
    switch(AnimStage){
        case 0,
        if(Rocket:vel():z() < 0){
            AnimStage = 1
            
            # Turn off gravity because it's easier to disable than to calculate in applyForce
            Rocket:propGravity(0)
            Rocket:soundPlay(1, 0, "PropAPC.FireRocket")
            timer("soundLoop1", 100)
        }
        break
    }
    
    switch(clkName()){
        case "launchRocket",
        # Unfreeze, set trails, and play sound effects
        Rocket:propFreeze(0)
        Rocket:propGravity(1)
        Rocket:applyForce(Rocket:forward() * Rocket:mass() * 1000)
        Rocket:setTrails(40, 30, 0.3, "effects/beam_generic01", vec(255, 0, 0), 127)
        Rocket:soundPlay(1, 0, "NPC_Combine.GrenadeLaunch")
        break
        
        case "soundLoop1",
        Rocket:soundPlay(2, 0, "k_lab2.DropshipRotorLoop")
        timer("soundLoop1", soundDuration("k_lab2.DropshipRotorLoop") * 1000)
        break
        
        # EGP UI for lock on targets
        case "refreshLockOnTargets",
        
        # Only show when we're in camera
        if(Activated){
            findInSphere(Rocket:pos(), 4096)
            LockOnTargets:clear()
            
            # Only get targets with HP
            foreach(K, V:entity = findToArray()){
                if(V:isAlive()){
                    LockOnTargets:pushEntity(V)
                }
            }
            
            # Draw information and position of targets
            #rangerFilter(Rocket)
            #Pos = rangerOffset(Rocket:pos(), Rocket:pos() + Rocket:vel() * 0.5):position() # Detonate is too slow
            Count = LockOnTargets:count() + 10
            foreach(K, V:entity = LockOnTargets){
                Index = K + Count
                EGP:egp3DTracker(Index, vec(0, 0, V:height() * 0.5))
                EGP:egpParent(Index, V)
                
                Index = K + Count * 2
                BoxSizeScaled = V:boxSize() / (Position:distance(V:pos()) * 0.00135)
                EGP:egpBoxOutline(Index, vec2(), vec2((BoxSizeScaled:x() + BoxSizeScaled:y()) * 0.5, BoxSizeScaled:z()))
                EGP:egpColor(Index, vec(255, 0, 0))
                EGP:egpParent(Index, K + Count)
                
                #[
                if(V != owner() && Pos:distance(V:pos()) < 200){
                    Detonate = 1
                }
                ]#
            }
            
            # Lock on code, basically find neareast to aim point
            findInSphere(HitPos, 512)
            findSortByDistance(HitPos)
            
            # Make sure we don't use a random entity inside the search sphere
            LockEntity = noentity()
            foreach(K, V:entity = findToArray()){
                if(V:isAlive() && V != Rocket){
                    LockEntity = V
                    break
                }
            }
            
            # Loop every 100ms
            timer("refreshLockOnTargets", 100)
        }
        break
    }
}
