@name FakeShipment
@inputs [EGPEnt1 EGPEnt2 CollisionEnt]:entity [EGP1 EGP2]:wirelink
@outputs Scale1 Scale2 [Angle1 Angle2]:angle [Position1 Position2]:vector
@persist Initalized ColorRed:vector4 Temp:entity Parented

#runOnTick(1)
interval(30)

if(!Initalized &&
    EGPEnt1:type() == "gmod_wire_egp_emitter" &&
    EGPEnt2:type() == "gmod_wire_egp_emitter" &&
    CollisionEnt:type() == "prop_physics"){
        
    GunModel = "models/weapons/w_m202.mdl"
    GunName = "M202"
    Amount = "20"
    
    Scale1 = 1
    Scale2 = 0.75
    Angle1 = ang()
    Angle2 = ang(0, 0, 90)
    Position1 = vec(0, 0, 5)
    Position2 = vec(0, -17, 0)
    ColorRed = vec4(140, 0, 0, 100)
    
    HoloPos = CollisionEnt:toWorld(vec(0, 0, -CollisionEnt:height() / 2))
    holoCreate(1, HoloPos, vec(1), CollisionEnt:angles(), vec(255), "models/items/item_item_crate_dynamic.mdl")
    holoCreate(2, HoloPos, vec(1), CollisionEnt:angles(), vec(255), GunModel)
    holoParent(1, CollisionEnt)
    holoParent(2, CollisionEnt)
    
    entity():createWire(EGPEnt1, "EGP1", "wirelink")
    entity():createWire(EGPEnt2, "EGP2", "wirelink")
    EGPEnt1:createWire(entity(), "Scale", "Scale1")
    EGPEnt2:createWire(entity(), "Scale", "Scale2")
    EGPEnt1:createWire(entity(), "Angle", "Angle1")
    EGPEnt2:createWire(entity(), "Angle", "Angle2")
    EGPEnt1:createWire(entity(), "Position", "Position1")
    EGPEnt2:createWire(entity(), "Position", "Position2")
    
    HoloEnt1 = holoEntity(1)
    
    EGPEnt1:deparent()
    EGPEnt1:propFreeze(1)
    EGPEnt1:setPos(HoloEnt1:boxCenterW() + vec(0, 0, 8))
    EGPEnt1:setAng(HoloEnt1:angles())
    EGP1:egpClear()
    
    EGPEnt2:deparent()
    EGPEnt2:propFreeze(1)
    EGPEnt2:setPos(HoloEnt1:pos() + vec(0, 0, 22))
    EGPEnt2:setAng(HoloEnt1:angles())
    EGP2:egpClear()
    
    CollisionEnt:deparent()
    CollisionEnt:propFreeze(1)
    CollisionEnt:propDraw(0)
    
    #EGPEnt1
    EGP1:egpRoundedBox(1, vec2(259, 241), vec2(112, 26))
    EGP1:egpColor(1, ColorRed)
    EGP1:egpRadius(1, 2)
    
    EGP1:egpText(2, "Contents: ", vec2(261, 229))
    EGP1:egpFont(2, "Verdana", 24)
    EGP1:egpAlign(2, 1, 0)
    
    TextLength = (GunName:length() + 2) * 11
    EGP1:egpRoundedBox(3, vec2(261, 280), vec2(TextLength, 26))
    EGP1:egpColor(3, ColorRed)
    EGP1:egpRadius(3, 2)
    
    EGP1:egpText(4, GunName, vec2(261, 268))
    EGP1:egpFont(4, "Verdana", 24)
    EGP1:egpAlign(4, 1, 0)
    
    #EGPEnt2
    EGP2:egpRoundedBox(1, vec2(261, 272), vec2(104, 26))
    EGP2:egpColor(1, ColorRed)
    EGP2:egpRadius(1, 2)
    
    EGP2:egpText(2, "Amount: ", vec2(261, 261))
    EGP2:egpFont(2, "Verdana", 24)
    EGP2:egpAlign(2, 1, 0)
    
    TextLength = (Amount:length() + 2) * 10 - 8
    EGP2:egpRoundedBox(3, vec2(261, 310), vec2(TextLength, 26))
    EGP2:egpColor(3, ColorRed)
    EGP2:egpRadius(3, 2)
    
    EGP2:egpText(4, Amount, vec2(261, 298))
    EGP2:egpFont(4, "Verdana", 24)
    EGP2:egpAlign(4, 1, 0)
    
    findByClass("spawned_shipment")
    findSortByDistance(entity():pos())
    Temp = find()
    
    Initalized = 1
}elseif(Initalized){
    Curtime = curtime() + 0.1 # Account for hologram interpolation
    HoloEnt1 = holoEntity(1)
    HoloPos1 = HoloEnt1:pos()
    HoloAng1 = HoloEnt1:angles()
    holoPos(2, HoloPos1 + HoloAng1:up() * 40 + HoloAng1:up() * sinr(Curtime * 3) * 8)
    holoAng(2, HoloAng1:rotateAroundAxis(HoloAng1:up(), (Curtime * 180) % 360))
    
    if(!Parented){
        EGPEnt1:parentTo(HoloEnt1)
        EGPEnt2:parentTo(HoloEnt1)
        Parented = 1
    }
}
