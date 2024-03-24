module View.Game exposing (view)

import Model.Game as Game exposing (Game)
import Model.Paddle as Paddle
import Model.Player as Player
import Model.Ball as Ball
import Model.Court as Court exposing (Side(..))
import Msg.App exposing (Msg(..))
import Game
import String.Extra as String
import Point2d
import Rectangle2d
import Circle2d
import Direction2d
import Tuple.Extra as Tuple
import Html exposing (Html)
import Html.Attributes as Hats
import Svg 
import Svg.Attributes as Gats
import Geometry.Svg as Svg
import Units
import Constants as C
import Pixels
import Quantity
import Units.Screen as Units
import Frame2d
import Model.Court as Court

view : (Units.Length, Units.Length) -> Game -> Html Msg
view (w, h) game =
    let
        score side = 
            Game.player side game 
                |> Player.score
                --|> View.Score side
        ballCoords = 
            Game.court game 
            |> Court.ball 
            |> Ball.coords
        leftPaddleCoords =
            Game.court game
            |> Court.paddle Left
            |> Paddle.coords
        rightPaddleCoords =
            Game.court game
            |> Court.paddle Right
            |> Paddle.coords
        widthRatio = Quantity.rate w C.courtWidth
        heightRatio = 
            Quantity.rate 
                (Quantity.minus (Quantity.plus (Pixels.float 10.0) (C.hudHeight)) h) 
                C.courtHeight
        metersToPixels = Quantity.min widthRatio heightRatio 
        frame =
            Frame2d.atOrigin
                |> Frame2d.translateIn Direction2d.negativeX (Quantity.at metersToPixels C.halfCourtWidth)
                |> Frame2d.translateIn Direction2d.y (Quantity.at metersToPixels C.halfCourtHeight)
                |> Frame2d.reverseY
        translate point =
            let
                (xStr, yStr) =
                    Point2d.at metersToPixels point
                        |> Point2d.relativeTo frame
                        |> Point2d.coordinates
                        |> Tuple.map (Pixels.toFloat >> String.fromFloat)
            in
            String.join "" 
                [ "translate(" 
                , xStr
                , "px, "
                , yStr
                , "px)"
                ]
        (ballCx, ballCy) =
            Point2d.at metersToPixels ballCoords
                |> Point2d.relativeTo frame
                |> Point2d.coordinates
                |> Tuple.map (Pixels.toFloat >> String.fromFloat)
        ballRadius = 
            C.ballRadius
                |> Quantity.at metersToPixels
                |> Pixels.toFloat
                |> String.fromFloat
        (leftPaddleX, leftPaddleY) = 
            Point2d.at metersToPixels leftPaddleCoords
                |> Point2d.relativeTo frame
                |> Point2d.coordinates
                |> Tuple.map (Pixels.toFloat >> String.fromFloat)
        (rightPaddleX, rightPaddleY) =
            rightPaddleCoords
                |> Point2d.at metersToPixels 
                |> Point2d.relativeTo frame
                |> Point2d.coordinates
                |> Tuple.map (Pixels.toFloat >> String.fromFloat)
        paddleWidth = 
            C.paddleWidth
                |> Quantity.at metersToPixels
                |> Pixels.toFloat
                |> String.fromFloat
        paddleHeight =
            C.paddleHeight
                |> Quantity.at metersToPixels
                |> Pixels.toFloat
                |> String.fromFloat

        leftPaddle =
            Game.court game
            |> Court.paddle Left
            |> Paddle.rect
            |> Rectangle2d.at metersToPixels
            |> Rectangle2d.relativeTo frame

        rightPaddle =
            Game.court game
            |> Court.paddle Right
            |> Paddle.rect
            |> Rectangle2d.at metersToPixels
            |> Rectangle2d.relativeTo frame

        ball =
            Game.court game
            |> Court.ball
            |> Ball.circle
            |> Circle2d.at metersToPixels
            |> Circle2d.relativeTo frame

        {-playCourtWidth =
            C.courtWidth
                |> Quantity.at metersToPixels
                |> Quantity.minus (Quantity.plus (Pixels.float 5.0) C.hudHeight)
                |> Pixels.toFloat
                |> String.fromFloat
        playCourtHeight =
            C.courtHeight
                |> Quantity.at metersToPixels
                |> Pixels.toFloat
                |> String.fromFloat
        -}

    in
    [ Html.div
        [ Hats.id "hud" 
        , Hats.style "height" ((String.fromFloat (Pixels.toFloat C.hudHeight)) ++ "px")
        ]
        [ Html.span 
            [ Hats.class "score"
            , Hats.class (Court.toString Left)
            ]
            [ Html.text (String.fromInt (score Left)) ]
        , Html.span 
            [ Hats.class "score"
            , Hats.class (Court.toString Right)
            ]
            [ Html.text (String.fromInt (score Right)) ]
        ] 
    , Svg.svg 
        [ Gats.width (Units.px metersToPixels C.courtWidth)
        , Gats.height (Units.px metersToPixels C.courtHeight)
        , Gats.id "court"
        ]
        [ Svg.circle2d
            [ Gats.id "ball"
            , Gats.fill "white"
            ]
            ball
        , Svg.rectangle2d
            [ Gats.fill "white"
            --, Gats.class "paddle"
            --, Gats.class "left"
            ]
            leftPaddle
        , Svg.rectangle2d
            [ Gats.fill "white"
            --, Gats.class "paddle"
            --, Gats.class "right"
            ]
            rightPaddle
        ]
    ]
    |> Html.main_ [ Hats.id "game" ]
