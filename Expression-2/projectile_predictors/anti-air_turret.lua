@name Anti-Air Turret
@inputs EGP:wirelink
@persist Proj:entity OldVel:vector MaxHolos

runOnTick(1)
if(first() || MaxHolos < holoMaxAmount()){
    EGP:egpClear()
    Index = 1
    if(holoCanCreate()){
        while(perf()){
            holoCreate(Index)
            Index++
            MaxHolos++
        }
    }
}else{
    findByClass("gb5*")
    findSortByDistance(owner():pos())
    Proj = find()
    
    if(Proj:vel():length() < 100){
        Pos = Proj:pos()
        Velocity = Proj:forward() * 5025
        
        Time = 0
        Step = tickInterval() * 2
        Index = 1
        while(perf()){
            HoloPos = Pos + Velocity * Time - vec(0, 0, gravity() * Time * Time * 0.5)
            holoPos(Index, HoloPos)
            
            Index++
            Time += Step
        }
    }
    
    Vel = Proj:vel()
    Delta = (Vel - OldVel) / tickInterval()
    OldVel = Vel
    X = egpScrW(owner()) / 2
    Y = egpScrH(owner()) / 2
    EGP:egpText(1, round(Vel:length()) + " u/s, " + round(vec2(Vel):length()) + " u/s", vec2(X, Y))
    EGP:egpText(2, round(Vel) + "", vec2(X, Y + 14))
    EGP:egpText(3, round(Delta) + "", vec2(X, Y + 14 * 2))
    EGP:egpText(4, "Tick: " + round(curtime()/tickInterval()), vec2(X, Y + 14 * 3))
    EGP:egpColor(1, vec(0, 255, 0))
    EGP:egpColor(2, vec(0, 255, 0))
    EGP:egpColor(3, vec(0, 255, 0))
    EGP:egpColor(4, vec(0, 255, 0))
}
