@name 
@persist DoOnce OldValue1 OldValue2 OldPos:vector TestIndex Force:vector
@persist PTime PDist PHeight

interval(0)
if(first()){
    Force = (owner():boxCenterW() - owner():aimPos()):toAngle():forward() * 1000
    owner():plyApplyForce(Force)
}

switch(TestIndex){
case 0,
if(owner():vel():z() > 0 && !DoOnce){
    DoOnce = 1
    OldValue1 = curtime()
    OldValue2 = owner():pos():z()
    OldPos = owner():pos()
    
    Vo = owner():vel():length()
    VelPitch = owner():vel():toAngle():pitch()
    PHeight = (Vo ^ 2 * sin(VelPitch) ^ 2) / (2 * gravity())
    PTime = (2 * Vo * -sin(VelPitch)) / gravity()
    PDist = (Vo ^ 2 * -sin(VelPitch * 2)) / gravity()
    
    print("Predict H:" + round(PHeight, 3))
    print("Predict T:" + round(PTime, 3))
    print("Predict D:" + round(PDist, 3))
    
    HoloIndex = 2
    SinY = sin(owner():vel():toAngle():yaw() + 90)
    CosY = cos(owner():vel():toAngle():yaw() + 90)
    
    holoCreate(1, OldPos + vec(PDist * SinY, PDist * -CosY, 0))
    holoColor(1, vec4(randvec(0, 255), 200))
    holoScale(1, vec(1.5))
    
    for(I = 0, PTime, PTime / 10){
        holoCreate(HoloIndex, OldPos + vec(PDist * (I / PTime) * SinY, PDist * (I / PTime) * -CosY, 0) + vec(0, 0, 0))
        HoloIndex++
    }
    
}elseif(owner():vel():z() <= 0 && DoOnce){
    print("Got H:" + round(owner():pos():z() - OldValue2, 3))
    TestIndex++
}
break

case 1,
if(!owner():vel():z() && DoOnce){
    TestIndex++
    print("Got T:" + round(curtime() - OldValue1, 3))
    print("Got D:" + round(owner():pos():distance(OldPos), 3))
}
break
}
