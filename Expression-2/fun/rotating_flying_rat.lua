@name rotating flying rat
@persist Array:array Spacing Tick ZMul
interval(0)

if(first() || clk("update")){
    findByModel("models/pigeon.mdl")
    Array = findToArray()
    Spacing = 360 / Array:count()
    foreach(K, V:entity = Array){
        V:propGravity(0)
        V:propDrag(0)
        #V:propInertia(vec(10000))
        V:setTrails(2, 1, 0.5, "effects/beam_generic01", vec(255, 0, 0), 255)
        V:removeTrails()
    }
    print(Array:count())
    timer("update", 1000)
}else{
    OwnerPos = owner():pos()
    OwnerYaw = ((owner():eyeAngles():yaw() + 180) % 360)
    ZMul = 200
    SpinSpeed = 1
    FlySpeed = max(200, owner():vel():length())
    
    if(owner():keyDuck()){
        ZMul = 200
        SpinSpeed = 30
        FlySpeed = 4000
    }
    
    foreach(K, V:entity = Array){
        #print(V:vel():length())
        
        VPos = V:pos()
        Delta = abs(((OwnerPos - VPos):toAngle():yaw() % 360) - OwnerYaw) * 2
        
        #[
        if(OwnerPos:distance(VPos) > ZMul * 2){
            FlySpeed = 2000
        }
        ]#
        
        if(owner():keyUse() && Delta <= Spacing){  
            if(OwnerPos:distance(VPos) <= ZMul + 100 && V:vel():length() <= FlySpeed + 100){
                V:soundPlay(K % 4, 0, "Airboat.FireGunHeavy")
            }
            
            V:setMass(5000)
            V:applyForce((owner():aimPos() - VPos):toAngle():forward() * V:mass() * 10000)
        }else{
            Ang = Spacing * K + Tick
            V:setMass(5000)
            V:applyForce(((OwnerPos + vec(cos(Ang), sin(Ang), 0) * ZMul + vec(0, 0, 100) - VPos):toAngle():forward() * FlySpeed - V:vel()) * V:mass())
        }
    }
    
    Tick += SpinSpeed
}
