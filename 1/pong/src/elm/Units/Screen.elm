module Units.Screen exposing (..)

import Quantity exposing (Quantity, Rate)
import Pixels exposing (Pixels)
import Duration exposing (Seconds)
import Point2d exposing (Point2d)

{- Define screen coordinate system and units -}


type ScreenCoordinateSystem = ScreenCoordinateSystem
type alias Length = Quantity Float Pixels
type alias Velocity = Quantity Float (Rate Pixels Seconds)
type alias Coords = Point2d Pixels ScreenCoordinateSystem
