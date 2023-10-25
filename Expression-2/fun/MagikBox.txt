@name 
@persist Target:entity Owner:entity Ignore:entity Max Index

interval(0)

if(first()){
    Index = 0
    Max = 1
    Target = owner()#findPlayerBySteamID64("")
    Ignore = findPlayerBySteamID64("")
    
    # Potental problem, players disconnecting and reconnecting etc.
    
    List = players()
    Owner = owner()
    while(Max < 8){holoCreate(Max) holoVisible(Max, List, 0) Max++}
    print(Max)
}

if(perf()){
    if(Index < 10){
        switch(Index){
        case 0,
            for(I = 1, Max, 1){
                holoScale(I, vec(-I - 1) * 0.5)
                holoDisableShading(I, 1)
            }
        break
        case 1,
            for(I = 1, Max, 1){
                holoVisible(I, Ignore, 1)
                holoVisible(I, Target, 1)
            }
        break
        case 2,
            for(I = 1, Max, 1){
                holoParentAttachment(I, Target, "forward")
                holoVisible(I, Owner, 1)
            }
        break
        }
        Index++
    } else {
        Vector = Target:shootPos()
        
        Color = vec(cos(curtime() ^ 2) ^ 2 * 255)
        
        for(I = 1, Max, 1){
            holoPos(I, Vector + randvec(-1, 1))
            holoColor(I, Color)
        }
    }
}
