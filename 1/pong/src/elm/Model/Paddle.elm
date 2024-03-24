module Model.Paddle exposing (Paddle, init, update, boundingBox, coords, rect)

import Units.Pong as Units
import Point2d
import BoundingBox2d
import Constants as C
import Rectangle2d
import Vector2d 
import Quantity


{-| The model of the paddle
-}
type Paddle =
    Paddle Units.Rect

init : Units.Coords -> Paddle
init =
    BoundingBox2d.withDimensions (C.paddleWidth, C.paddleHeight)
    >> Rectangle2d.fromBoundingBox
    >> Paddle

rect : Paddle -> Units.Rect
rect (Paddle r) = r

coords : Paddle -> Units.Coords
coords = rect >> Rectangle2d.centerPoint

position : Paddle -> (Units.Length, Units.Length)
position = coords >> Point2d.coordinates

update : Units.Time -> Units.Direction -> Paddle -> Paddle
update δ direction =
    rect
    >> (Rectangle2d.translateBy
            (Vector2d.withLength (Quantity.at C.paddleSpeed δ) direction))
    >> Paddle

boundingBox : Paddle -> Units.BoundingBox
boundingBox = 
    rect >> Rectangle2d.boundingBox
