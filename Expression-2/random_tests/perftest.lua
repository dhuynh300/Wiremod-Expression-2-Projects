@persist 
@trigger 

interval(100)

Count = 1
Entity = noentity()
while(perf()){
    Entity = noentity()
    Count++
}
setName((Count - 1):toString())
