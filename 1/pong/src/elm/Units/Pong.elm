module Units.Pong exposing (..)

import Quantity exposing (Quantity, Rate)
import Duration exposing (Seconds)
import Length exposing (Meters)
import Point2d exposing (Point2d)
import Direction2d exposing (Direction2d)
import BoundingBox2d exposing (BoundingBox2d)
import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Rectangle2d exposing (Rectangle2d)

{- Define pong game world coordinate system and units -}

type PongCoordinateSystem = PongCoordinateSystem
type alias Length = Quantity Float Meters
type alias Time = Quantity Float Seconds
type alias Speed = Quantity Float (Rate Meters Seconds)
type alias Coords = Point2d Meters PongCoordinateSystem
type alias Direction = Direction2d PongCoordinateSystem
type alias BoundingBox = BoundingBox2d Meters PongCoordinateSystem
type alias Axis = Axis2d Meters PongCoordinateSystem
type alias Circle = Circle2d Meters PongCoordinateSystem
type alias Rect = Rectangle2d Meters PongCoordinateSystem

