@name ElevatorGithub
@inputs Up Down
@outputs Floors N X Y Z Dir:string
@persist Base:entity Angles:angle Results:array Dir:string
@persist Floors N X Y Z

if( first() ) {
    runOnTick(1)
    dsJoinGroup( "Elevator.Master" )
    
    Base = entity():isWeldedTo()
    
    Base:setMass( 50000 )
    Base:setMaterial( "Models/XQM/LightLinesRed" )
    
    BP = Base:pos()
    X = BP:x()
    Y = BP:y()
    Z = BP:z()
    Angles = Base:angles()
}

if( dsClk( "Call" ) ) {
    Z = dsGetNumber()
}

if( ( ~Up & Up ) | ( ~Down & Down ) ) {
    Floors = dsProbe( "Elevator.Floors" ):count()
    Results = array()
    N = 0
    Dir = ""
    
    if( Up ) { Dir = "Up" } else { Dir = "Down" }
    
    dsSend( Dir, "Elevator.Floors", Base:pos():z() )
}

if( dsClk( "Z" ) ) {
    N++
    
    if( dsGetType() == "number" ) { Results:pushNumber( dsGetNumber() ) }
    
    if( N == Floors & Results:count() > 0 ) {
        if( Dir == "Up" ) {
            Min = Results:popNumber()
            for( I = 1, Results:count() ) {
                Min = min( Min, Results[I, number] )
            }
            Z = Min
        } else {
            Max = Results:popNumber()
            for( I = 1, Results:count() ) {
               Max = max( Max, Results[I, number] )
            }
            Z = Max
        }
    }
}

if( tickClk() ) {
    BasePos = Base:pos()
    
    TarQ = quat( Angles )
    CurQ = quat( Base )
    
    Q = TarQ/CurQ
    V = Base:toLocal( rotationVector( Q ) + BasePos )
    Base:applyTorque( ( 150 * V - 12 * Base:angVelVector() ) * Base:inertia() )
    
    CurrentZ = BasePos:z()
    Diff = CurrentZ - Z
    
    if( Diff < 0 ) {
        if( abs( Diff ) > 5 ) { NextZ = CurrentZ + 3 } else { NextZ = Z }
    } elseif( Diff > 0 ) {
        if( Diff > 5 ) { NextZ = CurrentZ - 1 } else { NextZ = Z }
    } else {
        NextZ = Z
    }
    
    Base:applyForce( ( ( vec( X, Y, NextZ ) - Base:massCenter() ) * 10 - Base:vel() ) * Base:mass() )
}
