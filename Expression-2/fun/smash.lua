@name smash
@inputs Ent:entity
@outputs 
@persist Toggle OldZ Entity:entity
@trigger 

interval(0)
if(first()){
    Entity = owner()
    if(Ent:isValid()){
        Entity = Ent
    }
    
    Toggle = 0
    OldZ = owner():pos():z()
}elseif(owner():pos():z() < OldZ){
    Toggle = 1
}elseif(owner():pos():z() > OldZ){
    OldZ = owner():pos():z()
}

if(Toggle){
    if(Entity:vel():z() == 0){
        Entity:plyApplyForce(vec(0, 0, 12345))
        Entity:applyForce(randvec(-1234567890,1234567890))
    }else{
        Entity:plyApplyForce(vec(0, 0, -12345))
        Entity:applyForce(randvec(-1234567890,1234567890))
    }
}
