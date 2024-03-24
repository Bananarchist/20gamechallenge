module Units exposing (..)

import Units.Screen as Screen
import Units.Pong as Pong
import Frame2d exposing (Frame2d)
import Constants as C
import Pixels exposing (Pixels)
import Direction2d
import Point2d
import Quantity exposing (Quantity, Rate)
import Length exposing (Meters)
import Tuple.Extra as Tuple
import Basics.Extra exposing (uncurry)


type alias Frame = Frame2d Pixels Pong.PongCoordinateSystem { defines : Screen.ScreenCoordinateSystem }
{-
frame : Frame2d Pixels Pong.PongCoordinateSystem { defines : Screen.ScreenCoordinateSystem }
frame =
    Frame2d.atOrigin
    |> Frame2d.translateIn Direction2d.negativeX C.halfCourtWidth
    |> Frame2d.translateIn Direction2d.positiveY C.halfCourtHeight
-}

screenHeightRate : Screen.Length -> Quantity Float (Rate Pixels Meters)
screenHeightRate screenHeight =
    Quantity.rate screenHeight C.courtHeight
    
screenWidthRate : Screen.Length -> Quantity Float (Rate Pixels Meters)
screenWidthRate screenWidth =
    Quantity.rate screenWidth C.courtWidth

pongPointToScreenPoint : Screen.Length -> Screen.Length -> Pong.Coords -> Screen.Coords
pongPointToScreenPoint screenWidth screenHeight =
    Point2d.coordinates
    >> Tuple.mapBoth 
        (Quantity.at (screenWidthRate screenWidth)) 
        (Quantity.at (screenHeightRate screenHeight))
    >> uncurry Point2d.xy
    -->> Point2d.relativeTo frame

px : Quantity Float (Rate Pixels Meters) -> Quantity Float Meters -> String
px rate length =
    Quantity.at rate length 
    |> Pixels.toFloat
    |> String.fromFloat


