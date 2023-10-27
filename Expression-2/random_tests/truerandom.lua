@name TrueRandom
@persist Tries

runOnKeys(owner(), 1)
if(first()){
    Tries = 0
    
    function number trueRand(Min, Max, TriesValue, MaxTries){
        Tries++
        Random = randint(Min, Max)
        if (Random == TriesValue || Tries >= MaxTries) {
            Tries = 0
            return TriesValue
        }
        return Random
    }
}

if(changed(owner():keyUse()) && owner():keyUse()){
    print(trueRand(0, 4, 2, 10) + ", " + Tries)
}
