# Black and White Camera Developed by on 5/1/2019
#
# Point E2, Connect EGP, and thats it! Make sure "wire_egp_max_objects" is
# really high for it to work like 262144 (Resolution of the EGP which is 512x512)
# Quotqa needs to be high for this to work fast
#
# Reload E2 ( Shoot E2 gun at the chip ) to get another image!
# Darker something is, the farther it is! Related to Distance variable.
#

@name Camera
@inputs EGP:wirelink
@persist X Y Index EntPos:vector EntAng:angle [Pixels Colors]:array #Globals
@persist DataIndex TempArray:array #Compression
@persist Res FOV World Distance TRes Video#Settings

# You can make this any model like the camera
# but I choosed block because of Smart Snap addon.
@model models/maxofs2d/camera.mdl

interval(0)

#Do we have a screen connected?
if(EGP){
    #Initializing!
    if(first()){
        EGP:egpClear()
        EGP:egpDrawTopLeft(1)
        
        #Higher = Better but laggy. Lower = JPEG, Max Res is 512x512 because of EGP Resolution
        Res = 0.6
        
        #Show World / Buildings
        World = 1
        
        #FOV, but not accurate
        FOV = 70
        
        #Distance! 8192 is golden!
        Distance = 8192
        
        #Video mode
        Video = 1
        
        # Dont Touch!
        FOV /= 2
        Index = 0
        DataIndex = 0
        TRes = clamp(FOV * Res, 0, 256)
        X = -TRes
        Y = -TRes
        
        EntPos = entity():pos()
        EntAng = entity():angles()
    }
    
    #Capture the scene
    while( Y < TRes && perf() ){
        while( X < TRes && perf() ){
            Ranger = rangerOffset( Distance, EntPos, (EntAng + ang( Y / Res, X / Res, 0 )):forward() )
            
            #Ingore sky, weird shit happens
            if( Ranger:hit() && !Ranger:hitSky() ){
                if( World || !World && Ranger:entity() != world() ){
                    Pixels:pushVector2( vec2( TRes - X - 1, Y + TRes ) )
                    #Colors:pushNumber( 255 )
                    #Colors:pushNumber( randint(100, 255) )
                    Colors:pushNumber( round( ( Distance - Ranger:distance() ) / Distance * 255 ) )
                }
            }
            X++
        }
        
        if(X >= TRes){
            X = -TRes
            Y++
        }
    }
    
    #After Capturing Image Draw it.
    if( Y >= TRes ){
        StreachRes = 256 / TRes
        
        while( DataIndex <= Pixels:count() && perf() ){
            if( DataIndex > 0 ){
                Check = Pixels:vector2( DataIndex - 1 ):y() == Pixels:vector2( DataIndex ):y() &&
                    Colors:number( DataIndex - 1 ) == Colors:number( DataIndex )
                
                if( Check ){
                    while( Check && perf() ){
                        TempArray:pushVector( vec( Pixels:vector2( DataIndex ), Colors:number( DataIndex ) ) )
                        
                        DataIndex++
                        Check = Pixels:vector2( DataIndex - 1 ):y() == Pixels:vector2( DataIndex ):y() &&
                            Colors:number( DataIndex - 1 ) == Colors:number( DataIndex )
                    }
                    
                    if(!Check){
                        DataIndex--
                        EGP:egpBox(Index, vec2(TempArray[TempArray:count(), vector] * StreachRes), vec2(StreachRes * TempArray:count() + 1, StreachRes + 1))
                        EGP:egpColor(Index, vec(TempArray[TempArray:count(), vector]:z()))
                        Index++
                    
                        DataIndex++
                        TempArray:clear()
                        TempArray:pushVector( vec( Pixels:vector2( DataIndex ), Colors:number( DataIndex ) ) )
                    }
                }else{
                    EGP:egpBox(Index, vec2(TempArray[TempArray:count(), vector] * StreachRes), vec2(StreachRes * TempArray:count() + 1, StreachRes + 1))
                    EGP:egpColor(Index, vec(TempArray[TempArray:count(), vector]:z()))
                    Index++
                    
                    DataIndex++
                    TempArray:clear()
                    TempArray:pushVector( vec( Pixels:vector2( DataIndex ), Colors:number( DataIndex ) ) )
                }
            } else {
                TempArray:pushVector( vec( Pixels:vector2( DataIndex ), Colors:number( DataIndex ) ) )
                DataIndex++
            }
        }
        
        if(Video && DataIndex > Pixels:count()){
            Index = 0
            DataIndex = 0
            X = -TRes
            Y = -TRes
            EntPos = entity():pos()
            EntAng = entity():angles()
            Pixels:clear()
            Colors:clear()
            TempArray:clear()
        }
    }
}

