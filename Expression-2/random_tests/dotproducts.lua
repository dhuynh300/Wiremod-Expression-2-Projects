@name DotProducts
@persist Default HoloCount MinHoloCount CurrentIndex Recording Timer InAir:array JumpArray:array OldZVel Applied

interval(0)
runOnKeys(owner(), 1)

if(first()){
    Default = 100
    HoloCount = Default
    MinHoloCount = HoloCount
    holoCreate(1)
    holoColor(1, vec(0, 0, 255))
    holoDisableShading(1, 1)
    print(owner():plyGetJumpPower())
}

if(owner():keyUse()){
    Jumped = (owner():vel():z() > 0 && OldZVel <= 0)
    if(curtime() > Timer || Jumped){
        CurrentPos = owner():pos()
        holoCreate(HoloCount, CurrentPos, vec(0.5))
        holoDisableShading(HoloCount, 1)
        
        rangerHitEntities(0)
        InAir[HoloCount, number] = Jumped || !rangerOffsetHull(10, CurrentPos, vec(0, 0, -1), owner():boxSize() * vec(1, 1, 0)):hitWorld()
        JumpArray[HoloCount, number] = Jumped
        
        if(InAir[HoloCount, number]){
            holoColor(HoloCount, vec(255, 0, 0))
        }else{
            holoColor(HoloCount, vec(0, 255, 0))
        }
        
        if(HoloCount > MinHoloCount){
            PreviousPos = holoEntity(HoloCount - 2):pos()
            Delta = CurrentPos - PreviousPos
            holoCreate(HoloCount - 1, (PreviousPos + CurrentPos) / 2, vec(Delta:length(), 1, 1) / 12, Delta:toAngle())
            holoDisableShading(HoloCount - 1, 1)
        }
        HoloCount += 2
        Timer = curtime() + 0.2
    }
    OldZVel = owner():vel():z()
}elseif(changed(owner():keyDuck()) && owner():keyDuck()){
    holoDelete(MinHoloCount)
    holoDelete(MinHoloCount + 1)
    MinHoloCount = clamp(MinHoloCount + 2, 0, HoloCount)
}elseif(HoloCount == MinHoloCount && HoloCount != Default){
    HoloCount = Default
    MinHoloCount = HoloCount
}elseif(HoloCount != MinHoloCount){
    if(CurrentIndex < MinHoloCount){
        CurrentIndex = MinHoloCount
    }
    holoPos(1, holoEntity(CurrentIndex):pos())
    if(HoloCount > MinHoloCount + 2){
        # Do distance if on floor, else do dot product if in air or something like that
        ToPlayerDelta = owner():pos() - holoEntity(CurrentIndex):pos()
        
        if(InAir[CurrentIndex, number]){
            Delta = holoEntity(CurrentIndex + 2):pos() - holoEntity(CurrentIndex):pos()
            if(Delta:dot(ToPlayerDelta) > 0){
                CurrentIndex = clamp((CurrentIndex + 2) % HoloCount, MinHoloCount, HoloCount)
            }
        }else{
            while(ToPlayerDelta:length() <= max(vec2(owner():vel()):length() * 0.1, 16) && perf()){
                CurrentIndex = clamp((CurrentIndex + 2) % HoloCount, MinHoloCount, HoloCount)
                ToPlayerDelta = owner():pos() - holoEntity(CurrentIndex):pos()
            }
        }
    }
}else{
    holoPos(1, entity():pos())
}

if(owner():keySprint()){
    if(!InAir[CurrentIndex, number]){
        owner():plySetAng((holoEntity(CurrentIndex):pos() - owner():pos()):toAngle())
    }else{
        owner():plySetAng((holoEntity(CurrentIndex + 2):pos() - owner():pos()):toAngle())
    }
    
    if(JumpArray[CurrentIndex, number]){
        if(!Applied){
            owner():plyApplyForce(vec(0, 0, owner():plyGetJumpPower() + 100))
            print(owner():vel())
            Applied = 1
        }
    }else{
        Applied = 0
    }
}
