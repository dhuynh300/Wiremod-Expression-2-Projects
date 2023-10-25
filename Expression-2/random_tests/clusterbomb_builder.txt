@name ClusterBomb Builder
@inputs Center:entity
@persist R

interval(1000)

if(first()){
    R = 30
}

if(Center:isValid()){
    Center:setAng(ang(0))
    
    findByClass("gw_*")
    Arr = findToArray()
    N = Arr:count() - 1
    
    Ang = 360 / N
    
    P = Center:boxCenterW()
    
    foreach(K, V:entity = Arr){    
        if(V == Center){
            continue
        }
        
        A = K * Ang
        V:noCollideAll(1)
        V:propFreeze(1)
        V:setAng(ang(-90, A, 0))
        V:setPos(P + vec(cos(A) * R, sin(A) * R, 0))
    }
}
