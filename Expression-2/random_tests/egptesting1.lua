@inputs EGP:wirelink
@persist MaxPlayers Players:array

if(first()){
    EGP:egpClear()
    timer("CheckPlayers", 0)
    timer("UpdateBBox", 0)
}

switch(clkName()){
    case "CheckPlayers",
    
    #[
    findExcludeClass("func_*")
    findExcludeClass("env_*")
    findExcludeClass("weapon_*")
    findExcludeClass("prop_*")
    findExcludeClass("gmod_*")
    findExcludeClass("trigger_*")
    findExcludeClass("path_*")
    findExcludeClass("logic_*")
    findExcludeClass("ai_hint")
    findExcludeClass("info_*")
    findExcludeClass("light*")
    ]#
    findExcludeClass("func_*")
    findExcludeClass("env_*")
    findExcludeClass("trigger_*")
    findExcludeClass("info_*")
    findExcludeClass("light")
    findExcludeClass("path_*")
    findInSphere(owner():pos(), 16384)
    if(changed(findToArray():count())){
        EGP:egpClear()
        Players = findToArray()
        MaxPlayers = Players:count()
        #printTable(Players)
        foreach(K, V:entity = Players){
            EGP:egp3DTracker(K, vec())
            EGP:egpParent(K, V)
            
            EGP:egpBoxOutline(K + MaxPlayers, vec2(0, -V:boxSize():z() * 0.5), vec2((V:boxSize():x() + V:boxSize():y()) * 0.5, V:boxSize():z()))
            EGP:egpParent(K + MaxPlayers, K)
            
            EGP:egpText(K + MaxPlayers * 2, V:type(), vec2())
            EGP:egpParent(K  + MaxPlayers * 2, K + MaxPlayers)
        }
    }

    timer("CheckPlayers", 400)
    break
    
    case "UpdateBBox",
    
    foreach(K, V:entity = Players){
        BoxSizeScaled = V:boxSize() / ((owner():pos():distance(V:pos()) * 0.00135))
        EGP:egpPos(K + MaxPlayers, vec2(0, -BoxSizeScaled:z() * 0.4))
        EGP:egpSize(K + MaxPlayers, vec2((BoxSizeScaled:x() + BoxSizeScaled:y()) * 0.5, BoxSizeScaled:z() * 0.8))
    }
    
    timer("UpdateBBox", 200)
    break
}
