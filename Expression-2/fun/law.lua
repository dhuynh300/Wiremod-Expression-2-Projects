@name LAW
@inputs EGP:wirelink
@persist [Target Holo]:entity Progress NextLockTimer LockedOnTimer NextFireTimer
@persist Rocket:entity AimPos:vector InFlight LaunchType SoundLoopTimer
@persist TicksToLock NextLockDelay LockedOnDelay NextFireDelay
runOnTick(1)
#TODO: Variable turn speed & speed
# hud
if(first()){
    holoCreate(1)
    Holo = holoEntity(1)   
    Target = noentity()
    Progress = 0
    
    TicksToLock = 8
    NextLockDelay = 0.2
    LockedOnDelay = 0.1
    NextFireDelay = 1
    
    EGP:egpClear()
    propSpawnEffect(0)
    function shootProjectile(){
        Angle = owner():eyeAngles()
        ShootPos = toWorld(vec(0, -20, 10), ang(0), owner():shootPos(), Angle)
        
        if(!LaunchType){
            Angle = ang(-60, Angle:yaw(), 0)
        }else{
            Angle = Angle - ang(5, 0, 0)
        }
        Rocket = propSpawn("models/weapons/w_models/w_rocket.mdl", ShootPos, Angle, 0)
        Rocket:propSetVelocity(Angle:forward() * 1000)
        Rocket:setMass(200)
        
        Rocket:soundPlay(1, 0, "PropAPC.FireRocket")
        timer("IgniteRocket", 200)
        print("FIRING.")
    }
}

CurTime = curtime()
if(tickClk()){
    KeyLock = owner():keyReload()
    KeyLaunchType = owner():keyUse()
    if(changed(KeyLock) && KeyLock){
        TempTarget = owner():aimEntity()
        if(TempTarget != Target && (TempTarget:health() > 0 || TempTarget:isVehicle())){
            Target = TempTarget
            Progress = 0
            
            EGP:egp3DTracker(1, Target:massCenter() - Target:pos())
            EGP:egpBoxOutline(2, vec2(), vec2())
            EGP:egpAngle(2, 45)
            EGP:egpParent(1, Target)
            EGP:egpParent(2, 1)
            
            Distance = owner():aimPos():distance(owner():shootPos())
            print("TARGET: " + Target:type() + ", " + round(toUnit("m", Distance)) + " METERS.")
        }elseif(!TempTarget){
            EGP:egpClear()
            Target = noentity()
            Progress = 0
            print("NO TARGET.")
        }
    }elseif(changed(KeyLaunchType) && KeyLaunchType){
        LaunchType = !LaunchType
        owner():soundPlay(1, 0, "k_lab.switch")
        if(LaunchType){
            print("DIRECT FIRE.")
        }else{
            print("ELEVATED FIRE.")
        }
    }
    
    if(CurTime > NextFireTimer){
        if(CurTime > NextLockTimer && (Target:health() > 0 || Target:isVehicle())){
            BoxCenter = Target:massCenter()
            ShootPos = owner():shootPos()
            Delta = toLocalAng(vec(), (BoxCenter - ShootPos):toAngle(), ShootPos, owner():eyeAngles())
            if(vec(Delta):length() < 360#[10]#){
                rangerFilter(array(owner(), Target))
                Ranger = rangerOffsetHull(ShootPos, BoxCenter, vec(10))
                if(!Ranger:hit()){
                    if(Progress < TicksToLock){
                        if(!Progress){
                            print("LOCKING ON.")
                        }
                        owner():soundPlay(1, 0, "Streetwar.d3_C17_13_beep")
                        soundPitch(1, 160, 0)
                        soundVolume(1, 0.25)
                        
                        EGP:egpSize(2, vec2((1 - Progress / TicksToLock) * 50))
                        print(Progress)
                        
                        NextLockTimer = CurTime + NextLockDelay
                        Progress++
                    }elseif(CurTime > LockedOnTimer){
                        if(Progress == TicksToLock){
                            print("LOCKED ON. READY TO FIRE.")
                            Progress++
                        }
                        #owner():soundPlay(1, 0, "Streetwar.d3_C17_13_beep")
                        soundPitch(1, 255, 0)
                        soundVolume(1, 0.25)
                        
                        LockedOnTimer = CurTime + LockedOnDelay
                    }
                }
            }
        }
        
        KeyFire = owner():keyWalk()
        if(changed(KeyFire) && KeyFire && Progress >= TicksToLock){
            AimPos = owner():aimPos()
            timer("LaunchRocket", 0)
            NextFireTimer = inf()
            Progress = 0
        }
    }
    
    if(InFlight){
        BoxCenter = Rocket:massCenter()
        RocketVel = Rocket:vel()
        rangerFilter(Rocket)
        Ranger = rangerOffsetHull(Rocket, BoxCenter, BoxCenter + RocketVel * tickInterval())
        if(Ranger:hit()){
            stoptimer("DestroyRocket")
            timer("DestroyRocket", 0)
            InFlight = 0
        }else{
            RocketMass = Rocket:mass()
            TargetPos = AimPos
            if(Target:isValid()){
                TargetPos = Target:massCenter()
            }
            
            Angle = (TargetPos - BoxCenter):toAngle()
            Diff = Rocket:toLocal(Angle)
            #print(Diff)
            AngForce = Diff * 0.8 - Rocket:angVel() * 0.2
            #AngForce = Diff * 40 - Rocket:angVel()
            Rocket:applyAngForce(AngForce * RocketMass * ang(1, 1, 1))
            
            Force = Rocket:forward() * (RocketVel:length() + 400) - RocketVel
            Rocket:applyForce(Force * RocketMass)
            
            if(CurTime > SoundLoopTimer){
                Rocket:soundPlay(1, 0, "weapons/flame_thrower_loop.wav")
                SoundLoopTimer = CurTime + 0.5
            }
        }
    }
}elseif(clk("IgniteRocket")){
    InFlight = 1
    Rocket:setTrails(10, 10, 0.1, "effects/beam_generic01", vec(255, 0, 0), 255)
    timer("DestroyRocket", 10000)
}elseif(clk("DestroyRocket")){
    BoxCenter = Rocket:massCenter()
    holoPos(1, BoxCenter)
    Holo:soundPlay(2, 0, "explode_3")
    
    blastDamage(owner(), owner(), BoxCenter, 1000, 1000)
    propDeleteAll()
    
    NextFireTimer = CurTime + NextFireDelay
    stoptimer("DestroyRocket")
    print("IMPACT.")
}elseif(clk("LaunchRocket")){
    if(propCanCreate()){
        shootProjectile()
    }else{
        timer("LaunchRocket", 50)
    }
}
