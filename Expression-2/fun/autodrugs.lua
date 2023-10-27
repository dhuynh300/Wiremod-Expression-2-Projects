@name AutoDrugs
@inputs 
@outputs 
@persist 
@trigger 
@strict

runOnKeys(players(), 1)
E = keyClk()
if(E:keyUse()){
    B = sentSpawn("durgz_cigarette", E:shootPos() + E:eyeAngles():forward() * 20, E:eyeAngles(), 0)
}
