module Model.Ball exposing (Ball, init, position, update, direction, boundingBox, coords, circle)

import Units.Pong as Units
import Point2d
import Vector2d
import Constants as C
import Quantity
import Circle2d 

type Ball 
    = Ball Units.Circle Units.Direction

init : Units.Coords -> Units.Direction -> Ball
init coord dir = 
    Ball (Circle2d.withRadius C.ballRadius coord) dir

circle : Ball -> Units.Circle
circle (Ball c _) = c

coords : Ball -> Units.Coords
coords = circle >> Circle2d.centerPoint

position : Ball -> (Units.Length, Units.Length)
position = coords >> Point2d.coordinates

direction : Ball -> Units.Direction
direction (Ball _ d) = d

boundingBox : Ball -> Units.BoundingBox
boundingBox = 
    circle >> Circle2d.boundingBox

-- Uses time delta to calculate the new position of the ball
update : Units.Time -> Ball -> Ball
update δ (Ball c dir) =
    Ball
        (Circle2d.translateBy 
            (Vector2d.withLength (Quantity.at C.ballSpeed δ) dir) 
            c
        )
        dir
 
