@name Battleship
@inputs EGP1:wirelink [EGPEnt1 Player1]:entity EGP2:wirelink [EGPEnt2 Player2]:entity
@persist [CurrentPly1 CurrentPly2]:entity [RandCol]:array EGPStage1 EGPStage2 Stage:string CoinStopTime PlayerTurn
@persist [Ply1Ships Ply2Ships Ply1Grid Ply2Grid]:array Ply1Rot Ply2Rot Ply1Sel Ply2Sel Ply1LastSel Ply2LastSel
#shove info in a vec4(x, y, z.ang/up/down, w.egpindex)
@persist DebugOps

# TODO List
# - Cooldown list
# - Polygons to make server happy

Ops = ops()
if(Ops > DebugOps){
    DebugOps = Ops
    print(DebugOps, "Fops")
}

if(first()){
    function number isClicked(EGP:wirelink, Index, Ent:entity, TopLeft){
        if(Ent == Player1 || Ent == Player2){
            #egp:egpDrawTopLeft(1) is fucking gay and breaks this thing below
            #return EGP:egpObjectContainsPoint(Index, EGP:egpCursor(Ent))
            
            EGPPos = EGP:egpPos(Index)
            if(TopLeft){
                EGPSize = EGP:egpSize(Index)
                return inrange(EGP:egpCursor(Ent), EGPPos, EGPPos + EGPSize)
            }
            
            EGPSize = EGP:egpSize(Index) / 2
            return inrange(EGP:egpCursor(Ent), EGPPos - EGPSize, EGPPos + EGPSize)
        }
        return 0
    }
    
    function egpCreateCursor(EGP:wirelink){
        EGP:egpCircle(1, vec2(), vec2(2))
        EGP:egpColor(1, vec(255, 0, 0))
        EGP:egpParentToCursor(1)
    }
    
    function egpOrderCursor(EGP:wirelink){
        EGPIndexes = EGP:egpObjectIndexes()
        EGP:egpOrderAbove(1, EGPIndexes[EGPIndexes:count(), number])
    }
    
    function egpWelcomeScreen(EGP:wirelink){
        EGP:egpClear()
        egpCreateCursor(EGP)
        EGP:egpBox(2, vec2(256), vec2(512))
        EGP:egpColor(2, vec(50))
        
        EGP:egpText(3, "Battleship", vec2(256, 120))
        EGP:egpAlign(3, 1, 1)
        EGP:egpSize(3, 60)
        
        EGP:egpBox(4, vec2(256), vec2(250, 100))
        EGP:egpColor(4, vec(100))
        
        EGP:egpText(5, "Prese [Use] to play", vec2(256, 256))
        EGP:egpAlign(5, 1, 1)
        EGP:egpSize(5, 20)
        egpOrderCursor(EGP)
    }
    
    function egpWaitingScreen(EGP:wirelink){
        EGP:egpClear()
        egpCreateCursor(EGP)
        EGP:egpBox(2, vec2(256), vec2(512))
        EGP:egpColor(2, vec(50))
        
        EGP:egpText(3, "Battleship", vec2(256, 120))
        EGP:egpAlign(3, 1, 1)
        EGP:egpSize(3, 60)
        
        EGP:egpText(4, "Waiting for other player...", vec2(256, 256))
        EGP:egpAlign(4, 1, 1)
        EGP:egpSize(4, 20)
        
        EGP:egpText(5, "Move away to stop playing", vec2(256, 276))
        EGP:egpAlign(5, 1, 1)
        EGP:egpSize(5, 20)
        
        egpOrderCursor(EGP)
    }
    
    function number egpDrawGrid(EGP:wirelink, StartIndex, Labels, GridSize, Offset:vector2){
        Amount = 10 + Labels
        Size = GridSize / Amount
        HalfSize = Size / 2
        Scale = GridSize / 512 * 40
        for(X = 0, Amount - 1, 1){
            for(Y = 0, Amount - 1, 1){
                if(X != 0 && Y != 0 || !Labels){
                    if(EGP == EGP1){
                        Ply1Grid:pushVector(vec(X, Y, StartIndex))
                    }else{
                        Ply2Grid:pushVector(vec(X, Y, StartIndex))
                    }
                }
            
                EGP:egpBoxOutline(StartIndex, vec2(X * Size, Y * Size) + Offset, vec2(Size + 1))
                StartIndex++
            }
        }
        
        if(Labels){
            Arr = array("A","B","C","D","E","F","G","H","I","J")
            for(A = 1, 10, 1){
                EGP:egpText(StartIndex, Arr[A, string], vec2(A * Size + HalfSize, HalfSize) + Offset)
                EGP:egpSize(StartIndex, Scale)
                EGP:egpAlign(StartIndex, 1, 1)
                StartIndex++
            }
            
            for(A = 1, 10, 1){
                EGP:egpText(StartIndex, A:toString(), vec2(HalfSize, A * Size + HalfSize) + Offset)
                EGP:egpSize(StartIndex, Scale)
                EGP:egpAlign(StartIndex, 1, 1)
                StartIndex++
            }
        }
        
        return StartIndex
    }
    
    function egpDrawBattleShipGrid(EGP:wirelink){
        EGP:egpClear()
        EGP:egpBox(1, vec2(256), vec2(512))
        EGP:egpColor(1, vec(50))
        
        EGP:egpDrawTopLeft(1)
        Index = egpDrawGrid(EGP, 2, 1, 384, vec2(128))
        Index = egpDrawGrid(EGP, Index, 0, 127, vec2(1))
        EGP:egpDrawTopLeft(0)
    }
    
    # 5 4 3 3 2
    function egpDrawShipPlacement(EGP:wirelink){
        EGP:egpClear()
        egpCreateCursor(EGP)
        
        EGP:egpBox(2, vec2(256), vec2(512))
        EGP:egpColor(2, vec(50))
        
        EGP:egpText(3, "Place your battleships", vec2(256, 16))
        EGP:egpAlign(3, 1, 1)
        EGP:egpSize(3, 20)
        
        EGP:egpDrawTopLeft(1)
        Index = egpDrawGrid(EGP, 4, 1, 384, vec2(64, 128))
        
        Size = 384 / 11
        Offset = vec2(64, 128)
        Ships = Ply1Ships
        if(EGP == EGP2){
            Ships = Ply2Ships
        }
        
        foreach(K, V:vector4 = Ships){   
            XDir = 1
            YDir = 0
            Length = K
            if(Length > 2){
                Length = Length - 1
            }
            
            if(V:z() == 2){
                XDir = 0
                YDir = 1
            }
            
            if(EGP == EGP1){
                Ply1Ships[K, vector4] = Ply1Ships[K, vector4]:setW(Index)
            }else{
                Ply2Ships[K, vector4] = Ply2Ships[K, vector4]:setW(Index)
            }
            EGP:egpBox(Index, vec2(V:x() * Size, V:y() * Size) + Offset, vec2(Size + XDir * Length * Size, Size + YDir * Length * Size))
            EGP:egpColor(Index, RandCol[K, vector])
            Index++
        }
        
        if(EGP == EGP1){
            Ply1Rot = Index
        }else{
            Ply2Rot = Index
        }
        EGP:egpRoundedBox(Index, vec2(0), vec2(Size * 2, Size))
        EGP:egpColor(Index, vec(100))
        Index++
        
        EGP:egpText(Index, "Rotate", vec2())
        EGP:egpSize(Index, 14)
        EGP:egpAlign(Index, 1, 1)
        EGP:egpParent(Index, Index - 1)
        EGP:egpPos(Index - 1, vec2(9 * Size, -1.25 * Size) + Offset)
        
        EGP:egpDrawTopLeft(0)
        egpOrderCursor(EGP)
    }
    
    function egpFlipCoin(){
        EGP1:egpClear()
        EGP1:egpBox(1, vec2(256), vec2(512))
        EGP1:egpColor(1, vec(50))
        EGP1:egpText(2, "Flipping coin...", vec2(256, 100))
        EGP1:egpAlign(2, 1, 1)
        EGP1:egpSize(2, 40)
        EGP1:egpCircle(3, vec2(256, 300), vec2())
        EGP1:egpCircleOutline(4, vec2(256, 300), vec2(128))
        
        EGP2:egpClear()
        EGP2:egpBox(1, vec2(256), vec2(512))
        EGP2:egpColor(1, vec(50))
        EGP2:egpText(2, "Flipping coin...", vec2(256, 100))
        EGP2:egpAlign(2, 1, 1)
        EGP2:egpSize(2, 40)
        EGP2:egpCircle(3, vec2(256, 300), vec2())
        EGP2:egpCircleOutline(4, vec2(256, 300), vec2(128))
        
        CoinStopTime = curtime() + random(2, 6)
        timer("flipCoinAnim", 0)
    }
    
    function updateShips(Ply:entity){
        if(Ply == Player1){
            if(Ply1Sel){
                foreach(K, V:vector = Ply1Grid){
                    if(isClicked(EGP1, V:z(), Ply, 1)){
                        OldVec4 = Ply1Ships[Ply1Sel, vector4]
                        Ply1Ships[Ply1Sel, vector4] = vec4(V:x(), V:y(), OldVec4:z(), OldVec4:w())
                        Ply1Sel = 0
                        egpDrawShipPlacement(EGP1)
                        break
                    }
                }
            }else{
                foreach(K, V:vector4 = Ply1Ships){
                    if(isClicked(EGP1, V:w(), Ply, 1)){
                        Ply1LastSel = Ply1Sel = K
                        break
                    }
                }
            }
            
            if(Ply1LastSel != 0 && isClicked(EGP1, Ply1Rot, Ply, 1)){
                OldVec4 = Ply1Ships[Ply1LastSel, vector4]
                Ply1Ships[Ply1LastSel, vector4] = OldVec4:setZ(OldVec4:z() % 2 + 1)
                egpDrawShipPlacement(EGP1)
            }
        }
        
        if(Ply == Player2){
            if(Ply2Sel){
                foreach(K, V:vector = Ply2Grid){
                    if(isClicked(EGP2, V:z(), Ply, 1)){
                        OldVec4 = Ply2Ships[Ply2Sel, vector4]
                        Ply2Ships[Ply2Sel, vector4] = vec4(V:x(), V:y(), OldVec4:z(), OldVec4:w())
                        Ply2Sel = 0
                        egpDrawShipPlacement(EGP2)
                        break
                    }
                }
            }else{
                foreach(K, V:vector4 = Ply2Ships){
                    if(isClicked(EGP2, V:w(), Ply, 1)){
                        Ply2LastSel = Ply2Sel = K
                        break
                    }
                }
            }
            
            if(Ply2LastSel != 0 && isClicked(EGP2, Ply2Rot, Ply, 1)){
                OldVec4 = Ply2Ships[Ply2LastSel, vector4]
                Ply2Ships[Ply2LastSel, vector4] = OldVec4:setZ(OldVec4:z() % 2 + 1)
                egpDrawShipPlacement(EGP2)
            }
        }
    }
    
    runOnChat(1)
    Stage = "Waiting"
    
    Ply1Ships = array(vec4(0, -2.5, 0, 0), vec4(0, -1.25, 0, 0), vec4(2.5, -2.5, 0, 0), vec4(3.5, -1.25, 0, 0), vec4(6, -2.5, 0, 0))
    Ply2Ships = array(vec4(0, -2.5, 0, 0), vec4(0, -1.25, 0, 0), vec4(2.5, -2.5, 0, 0), vec4(3.5, -1.25, 0, 0), vec4(6, -2.5, 0, 0))
    
    for(I = 1, 10, 1){
        RandCol:pushVector(randvec(0, 255))
    }
    
    egpWelcomeScreen(EGP1)
    egpWelcomeScreen(EGP2)
}

if(Player1:isAlive() || Player2:isAlive() || chatClk(Player1) || chatClk(Player2)){
    if(!CurrentPly1:isValid() && Player1:isAlive()){
        CurrentPly1 = Player1
        egpWaitingScreen(EGP1)
        timer("afkCheck1", 200)
    }
    
    if(!CurrentPly2:isValid() && Player2:isAlive()){
        CurrentPly2 = Player2
        egpWaitingScreen(EGP2)
        timer("afkCheck2", 200)
    }
    
    if(CurrentPly1:isValid() && CurrentPly2:isValid() && Stage == "Waiting"){
        Stage = "Placing"
        egpDrawShipPlacement(EGP1)
        egpDrawShipPlacement(EGP2)
    }
    
    if(Player1:isAlive() && Player1 == CurrentPly1){
        switch(Stage){
            case "Placing",
            updateShips(Player1)
            break
        }
    }
    
    if(Player2:isAlive() && Player2 == CurrentPly2){
        switch(Stage){
            case "Placing",
            updateShips(Player2)
            break
        }
    }
}

switch(clkName()){
    case "afkTimer1",
        CurrentPly1 = noentity()
        egpWelcomeScreen(EGP1)
    break
    case "afkTimer2",
        CurrentPly2 = noentity()
        egpWelcomeScreen(EGP2)
    break
    case "afkCheck1",
        if(Stage == "Waiting"){
            if(CurrentPly1:pos():distance(EGPEnt1:pos()) > 200 || !CurrentPly1:isAlive()){
                CurrentPly1 = noentity()
                egpWelcomeScreen(EGP1)
            }else{
                timer("afkCheck1", 200)
            }
        }
    break
    case "afkCheck2",
        if(Stage == "Waiting"){
            if(CurrentPly2:pos():distance(EGPEnt2:pos()) > 200 || !CurrentPly2:isAlive()){
                CurrentPly2 = noentity()
                egpWelcomeScreen(EGP2)
            }else{
                timer("afkCheck2", 200)
            }
        }
    break
    
    case "flipCoinAnim",
        Curtime = curtime() * 8
        Cos = cosr(Curtime)    
        if(curtime() < CoinStopTime){
            Scale = 128 * Cos ^ 2 
            
            EGP1:egpSize(3, vec2(Scale, 128))
            EGP2:egpSize(3, vec2(Scale, 128))
            EGP1:egpSize(4, vec2(Scale, 128))
            EGP2:egpSize(4, vec2(Scale, 128))
            
            if(Cos > 0){
                EGP1:egpColor(3, vec(0, 0, 200))
                EGP2:egpColor(3, vec(0, 0, 200))
            }elseif(Cos < 0){
                EGP1:egpColor(3, vec(200, 0, 0))
                EGP2:egpColor(3, vec(200, 0, 0))
            }
            
            timer("flipCoinAnim", 50)
        }else{
            EGP1:egpSize(3, vec2(128))
            EGP2:egpSize(3, vec2(128))
            EGP1:egpSize(4, vec2(128))
            EGP2:egpSize(4, vec2(128))
            
            if(Cos > 0){
                PlayerTurn = 1
            }elseif(Cos < 0){
                PlayerTurn = 2
            }else{
                CoinStopTime = curtime() + random(2, 6)
                print("Someone's coin stopped at the middle!")
            }
            
            print(PlayerTurn)
        }
    break
}

if(changed(CurrentPly1) || changed(CurrentPly2)){
    print("Players:", CurrentPly1, CurrentPly2)
}

Ops = ops()
if(Ops > DebugOps){
    DebugOps = Ops
    print(DebugOps, "Lops")
}
