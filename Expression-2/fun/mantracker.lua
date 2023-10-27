@persist Target:entity
runOnTick(1)
if(first()){
    Target = findPlayerBySteamID64("")
    holoCreate(1)
    holoScaleUnits(1, vec(100, 1, 1))
    holoVisible(1, players(), 0)
    holoVisible(1, owner(), 1)
    print(Target:name())
}
Ang = (Target:pos() - owner():pos()):toAngle()
holoPos(1, owner():boxCenterW() + Ang:forward() * 50)
holoAng(1, Ang)
