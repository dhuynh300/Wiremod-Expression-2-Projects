@name Wolfinstein Engine v1
@inputs Grid:wirelink Screen:wirelink
@persist Walls:array PlayerPos:vector2 PlayerDirection:angle Color:vector RayDist FOV Index Toggle W Mul Mul2

interval(0)
runOnKeys(owner(), 1)

# hi admins

if(first()){
    Grid:egpClear()
    Screen:egpClear()
    
    # Z = Color
    Walls:pushVector(vec(2, 2, 255010010))
    Walls:pushVector(vec(3, 2, 124174117))
    Walls:pushVector(vec(4, 2, 246251157))
    Walls:pushVector(vec(5, 2, 124255001))
    Walls:pushVector(vec(6, 6, 100000000))
    Walls:pushVector(vec(6, 5, 100255255))
    Walls:pushVector(vec(6, 4, 255255255))
    Walls:pushVector(vec(6, 3, 105255000))
    Walls:pushVector(vec(6, 2, 251124163))
    #Walls:pushVector(vec(3, 5, 124123212))
    
    FOV = 70
    PlayerPos = vec2(3.5, 5.25)
    PlayerDirection = ang(0, -45, 0)
    
    Mul = 512 / 9
    Mul2 = 512 / 64
    
    Grid:egpDrawTopLeft(1)
    foreach(K, V:vector = Walls){
        Grid:egpBox(K, vec2(V * Mul), vec2(Mul - 0.5))
    }
    Grid:egpDrawTopLeft(0)
    
    Grid:egpBox(10, PlayerPos * Mul, vec2(Mul * 2 - 0.5))
    Grid:egpColor(10, vec(50))
    
    Grid:egpLine(11, PlayerPos * Mul, PlayerPos * Mul + vec2(PlayerDirection:forward() * 512))
    Grid:egpColor(11, vec(255, 0, 0))
    
    Grid:egpLine(12, PlayerPos * Mul, PlayerPos * Mul + vec2((PlayerDirection - ang(0, FOV * 0.5, 0)):forward() * 512))
    Grid:egpColor(12, vec(0, 255, 0))
    
    Grid:egpLine(13, PlayerPos * Mul, PlayerPos * Mul + vec2((PlayerDirection + ang(0, FOV * 0.5, 0)):forward() * 512))
    Grid:egpColor(13, vec(0, 255, 0))
    
    function number decimalOnly(Number){
        return Number - floor(Number)
    }
    
    function vector2 rayCast(Pos:vector2, Direction:angle){
        End = Pos + vec2(Direction:forward() * 1024)
        DX = End:x() - Pos:x()
        DY = End:y() - Pos:y()
        RayDist = 0
        
        Steps = (abs(DX) > abs(DY) ? abs(DX) : abs(DY)) * 10
        
        Xinc = DX / Steps
        Yinc = DY / Steps
        
        X = Pos:x()
        Y = Pos:y()
        I = 0
        while (I < Steps && perf(100)){
            foreach(K, V:vector = Walls){
                Pos2 = vec2(X, Y)
                if(inrange(Pos2, vec2(V), vec2(V) + vec2(1))){
                    DeltaX = X - Pos:x()
                    DeltaY = Y - Pos:y()
                    RayDist = DeltaX * cos(PlayerDirection:yaw()) + DeltaY * sin(PlayerDirection:yaw())#vec2(DeltaX, DeltaY):length() * cos(Direction:yaw() - PlayerDirection:yaw())
                    R = floor(V:z() * 0.000001)
                    G = floor(V:z() * 0.001) - R * 1000
                    B = V:z() - floor(V:z() * 0.001) * 1000
                    Color = vec(R, G, B) * clamp(1 / (RayDist / 3), 0, 1)
                    return Pos2
                }
            }
            X += Xinc
            Y += Yinc
            I++
        }
        return vec2(0, 0)
    }
    
    Grid:egpBox(14, rayCast(PlayerPos, PlayerDirection) * Mul, vec2(8))
    Grid:egpColor(14, vec(0, 0, 255))
    
    Index = 20
    FOV *= 0.5
    W = -32
}
PlayerPosMul = PlayerPos * Mul

if(!Toggle){
    while(W <= 32 && perf(80)){
        Yaw = W / 32 * -FOV
        RayCast = rayCast(PlayerPos, PlayerDirection - ang(0, Yaw, 0))
        Grid:egpBox(14, RayCast * Mul, vec2(8))
        Grid:egpLine(15, PlayerPosMul, PlayerPosMul + vec2((PlayerDirection - ang(0, Yaw, 0)):forward() * 512))
    
        if(RayCast){
            Screen:egpBox(Index, vec2((W + 32) * Mul2, 256), vec2(Mul2, 512 / RayDist))
            Screen:egpColor(Index, Color)
            Index++
        }
        W++
    }
}

Grid:egpBox(10, PlayerPosMul, vec2(Mul - 0.5))
Grid:egpLine(11, PlayerPosMul, PlayerPosMul + vec2(PlayerDirection:forward() * 512))
Grid:egpLine(12, PlayerPosMul, PlayerPosMul + vec2((PlayerDirection - ang(0, FOV, 0)):forward() * 512))
Grid:egpLine(13, PlayerPosMul, PlayerPosMul + vec2((PlayerDirection + ang(0, FOV, 0)):forward() * 512))

if(keyClk(owner()) || Toggle){
    Toggle = 1
    if(owner():keyPressed("pad_7")){
        PlayerDirection -= ang(0, 1, 0)
        Screen:egpClear()
        W = -32
    }elseif(owner():keyPressed("pad_9")){
        PlayerDirection += ang(0, 1, 0)
        Screen:egpClear()
        W = -32
    }elseif(owner():keyPressed("pad_8")){
        PlayerPos += vec2(PlayerDirection:forward() * vec(0.05, 0.05, 0))
        Screen:egpClear()
        W = -32
    }elseif(owner():keyPressed("pad_5")){
        PlayerPos += vec2(PlayerDirection:forward() * -vec(0.05, 0.05, 0))
        Screen:egpClear()
        W = -32
    }elseif(owner():keyPressed("pad_4")){
        PlayerPos += vec2((PlayerDirection - ang(0, 90, 0)):forward() * vec(0.05, 0.05, 0))
        Screen:egpClear()
        W = -32
    }elseif(owner():keyPressed("pad_6")){
        PlayerPos += vec2((PlayerDirection + ang(0, 90, 0)):forward() * vec(0.05, 0.05, 0))
        Screen:egpClear()
        W = -32
    }
}
if(keyClk(owner()) == -1){
    Toggle = 0
}
