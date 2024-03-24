module Constants exposing (..)

import Units.Pong
import Units.Screen
import Duration
import Quantity
import Length
import BoundingBox2d
import Point2d
import Pixels

paddleSpeed : Units.Pong.Speed
paddleSpeed = Quantity.rate (Length.meters 35.0) (Duration.seconds 1.0)

ballSpeed : Units.Pong.Speed
ballSpeed = Quantity.rate (Length.meters 25.0) (Duration.seconds 1.0)

ballRadius : Units.Pong.Length
ballRadius = Length.meters 1

ballDiameter : Units.Pong.Length
ballDiameter = Quantity.multiplyBy 2 ballRadius

paddleWidth : Units.Pong.Length
paddleWidth = Length.meters 1.5 

paddleHeight : Units.Pong.Length
paddleHeight = Length.meters 9 

paddleX : Units.Pong.Length
paddleX = Length.meters 45

courtHeight : Units.Pong.Length
courtHeight = Length.meters 70

courtWidth : Units.Pong.Length
courtWidth = Length.meters 100

halfCourtWidth : Units.Pong.Length
halfCourtWidth = Quantity.half courtWidth

halfCourtHeight : Units.Pong.Length
halfCourtHeight = Quantity.half courtHeight

courtRatio : Float
courtRatio = Quantity.ratio courtWidth courtHeight

courtBoundingBox : Units.Pong.BoundingBox
courtBoundingBox = 
    BoundingBox2d.from 
        (Point2d.xy (Quantity.negate halfCourtWidth) (Quantity.negate halfCourtHeight))
        (Point2d.xy halfCourtWidth halfCourtHeight)

hudHeight : Units.Screen.Length
hudHeight = Pixels.pixels 25
