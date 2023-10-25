@name Vending Machine
@inputs EGP:wirelink Grabber:entity [Plate1 Plate2 Plate3 Home]:entity
@outputs Grab
@persist HomePos:vector Row Column ColumnOffset ColumnStepSize
@persist GrabberMoving OldGrabberPos:vector CurrentPosGoal:vector OldPosCurtime PosAnimIndex PosAnimIndexMax
@persist GrabberRotating OldGrabberAng:angle CurrentAngGoal:angle OldAngCurtime AngAnimIndex AngAnimIndexMax

interval(0)

if(first()){
    function moveGrabber(Goal:vector, Time){
        if(!GrabberMoving){
            CurrentPosGoal = Goal
            OldGrabberPos = Grabber:pos()
            OldPosCurtime = curtime()
            GrabberMoving = 1
        }
        
        if(GrabberMoving){
            Progress = min((curtime() - OldPosCurtime) / Time, 1)
            GrabberPos = CurrentPosGoal * Progress + OldGrabberPos * (1 - Progress)
            Grabber:setPos(GrabberPos)
            
            if(Progress >= 1){
                GrabberMoving = 0
                PosAnimIndex++
                if(PosAnimIndex > PosAnimIndexMax){
                    PosAnimIndex = 0
                }
                
                print("PosAnimIndex:", PosAnimIndex)
            }
        }
    }
    
    function rotateGrabber(Goal:angle, Time){
        if(!GrabberRotating){
            CurrentAngGoal = Goal
            OldGrabberAng = Grabber:angles()
            OldAngCurtime = curtime()
            GrabberRotating = 1
        }
        
        if(GrabberRotating){
            Progress = min((curtime() - OldAngCurtime) / Time, 1)
            GrabberAng = nlerp(quat(OldGrabberAng), quat(CurrentAngGoal), Progress):toAngle()
            Grabber:setAng(GrabberAng)
            
            if(Progress >= 1){
                GrabberRotating = 0
                AngAnimIndex++
                if(AngAnimIndex > AngAnimIndexMax){
                    AngAnimIndex = 0
                }
                
                #print("AngAnimIndex:", AngAnimIndex)
            }
        }
    }
    
    function moveToInventory(PlateRow, PlateColumn, NoDepth){
        PlateEntity = Plate1
        switch(PlateRow){
            case 1,
            PlateEntity = Plate2
            break
            case 2,
            PlateEntity = Plate3
            break
        }
        
        MovePos = vec()
        if(NoDepth){
            MovePos = (toLocal(PlateEntity:boxCenterW(), PlateEntity:angles(),
                vec(18, ColumnOffset + ColumnStepSize * PlateColumn, -5), ang()) - HomePos)
                * vec(0, 1, 1) + HomePos
        }else{
            MovePos = toLocal(PlateEntity:boxCenterW(), PlateEntity:angles(),
                vec(18, ColumnOffset + ColumnStepSize * PlateColumn, -5), ang())
        }
        
        moveGrabber(MovePos, 0.1)
    }
    
    function vector calcLocalHomeOffset(Offset:vector){
        return toLocal(Home:boxCenterW(), Home:angles(), Offset + vec(0, -1.5, 25), ang())
    }
    
    ##########
    
    EGP:egpClear()
    
    HomePos = calcLocalHomeOffset(vec())
    
    noCollideAll(Grabber, 1)
    Grabber:constraintBreak()
    Grabber:propFreeze(1)
    Grabber:setAng(ang(180, 0, 0))
    Grabber:setPos(HomePos)
    
    holoCreate(1, Grabber:pos())
    holoParent(1, Grabber)
    holoScale(1, vec(0.1))
    
    PosAnimIndexMax = 8
    AngAnimIndexMax = 5
    GrabberMoving = 0
    GrabberRotating = 0
    
    ColumnOffset = -Plate1:boxSize():x() / 8 * 3
    ColumnStepSize = Plate1:boxSize():x() / 4
    
    PosAnimIndex = 1
}

switch(PosAnimIndex){
    case 1,
    moveGrabber(calcLocalHomeOffset(vec(0, -10, 0)), 0.1)
    break
    
    case 2,
    moveToInventory(Row, Column, 1)
    break
    
    case 3,
    moveToInventory(Row, Column, 0)
    break
    
    case 4,
    moveGrabber(Grabber:pos() - vec(0, 0, 5), 0.1)
    break
    
    case 5,
    Grab = 1
    moveGrabber(Grabber:pos() + vec(0, 0, 5), 0.1)
    break
    
    case 6,
    moveToInventory(Row, Column, 1)
    break
    
    case 7,
    moveGrabber(calcLocalHomeOffset(vec(0, -10, 0)), 0.1)
    break
    
    case 8,
    moveGrabber(HomePos, 0.1)
    break
    
    default,
    Grab = 0
    moveGrabber(HomePos, 0.1)
    Row = 0
    Column = 0
    break
}
