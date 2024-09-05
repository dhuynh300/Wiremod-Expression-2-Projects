@name PigeonArtillery
@persist Pigeons:array DoOnce

interval(100)

if(first()){
    findByModel("models/pigeon.mdl")
    Pigeons = findToArray()
}elseif(!DoOnce){
    DoOnce = 1
    
    EntPos = owner():pos()
    foreach(K, V:entity = Pigeons){
        V:setPos(EntPos)
    }
}
