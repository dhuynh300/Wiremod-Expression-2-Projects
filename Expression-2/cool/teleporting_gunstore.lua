@name Teleporting Gunstore
@inputs EGP:wirelink Output:entity
@outputs 
@persist [InputMin InputMax]:vector

interval(100)

if(first()){
    EGP:egpClear()
}
