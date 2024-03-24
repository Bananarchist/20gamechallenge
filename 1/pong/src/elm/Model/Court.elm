module Model.Court exposing (Court, Side(..), UpdateResult(..), init, toString, paddle, ball, Update, update, TestContext, BallTest(..), completeTest, redirectAfterWallStrike, redirectAfterPaddleStrike, scored, yCoourdinateExceedsCourtHeight, ballAndBaddleCollide, ballContainedWithinCourt, testIsDoneか, scoredか, opposite)

import Model.Ball as Ball exposing (Ball)
import Model.Paddle as Paddle exposing (Paddle)
import Constants as C
import Basics.Extra exposing (uncurry)
import Units.Pong as Units
import Quantity
import Circle2d
import Rectangle2d
import Length
import Result.Extra as Result
import Point2d
import Direction2d
import Tuple.Extra as Tuple
import BoundingBox2d
import Axis2d
import Model.Audio exposing (SFX(..))

type Court = Court Paddle Paddle Ball
type Side = Left | Right

type UpdateResult
    = Continue Court
    | PlaySFX SFX UpdateResult
    | Score Side Court

toString : Side -> String
toString side =
    case side of
        Left ->
            "left"

        Right ->
            "right"

opposite : Side -> Side
opposite side =
    case side of
        Left ->
            Right

        Right ->
            Left

init : Court
init =
    Court
        (Paddle.init (Point2d.xy (Quantity.negate C.paddleX) (Length.meters 0)))
        (Paddle.init (Point2d.xy C.paddleX (Length.meters 0)))
        (Ball.init (Point2d.xy (Length.meters 0) (Length.meters 0)) (Direction2d.degrees 45))

paddle : Side -> Court -> Paddle
paddle side (Court left right _) =
    case side of
        Left ->
            left

        Right ->
            right

ball : Court -> Ball
ball (Court _ _ b) =
    b

type alias Update
    = { suggestedLeftPaddle : Paddle
      , suggestedRightPaddle : Paddle
      , newBall : Ball
      }

yCoourdinateExceedsCourtHeight : Paddle -> Bool
yCoourdinateExceedsCourtHeight p =
    let
        y = Paddle.coords p |> Point2d.yCoordinate
    in
    (Quantity.plus y (Quantity.half C.paddleHeight)) 
    |> Quantity.greaterThan C.courtHeight

ballAndBaddleCollide : Ball -> Paddle -> Bool
ballAndBaddleCollide b p =
    (Ball.boundingBox b, Paddle.boundingBox p)
    |> uncurry BoundingBox2d.intersects

ballContainedWithinCourt : Ball -> Bool
ballContainedWithinCourt b =
    (C.courtBoundingBox, Ball.boundingBox b)
    |> uncurry BoundingBox2d.isContainedIn

update : Update -> Court -> UpdateResult
update  { suggestedLeftPaddle, suggestedRightPaddle, newBall } (Court ogLeftPaddle ogRightPaddle oldBall ) =
    let
        borderMinusHalfPaddle =
            Quantity.minus (Quantity.half C.paddleHeight) C.halfCourtHeight
        clampPaddle side =
            Paddle.coords 
            >> Point2d.yCoordinate
            >> Quantity.clamp 
                (Quantity.negate borderMinusHalfPaddle)
                (borderMinusHalfPaddle)
            >> Point2d.xy 
                (if side == Left then 
                    Quantity.negate C.paddleX 
                else C.paddleX)
            >> Paddle.init

        newLeftPaddle = clampPaddle Left suggestedLeftPaddle
        newRightPaddle = clampPaddle Right suggestedRightPaddle

        (nb, result) =
            { leftPaddle = (ogLeftPaddle, newLeftPaddle)
            , rightPaddle = (ogRightPaddle, newRightPaddle)
            , ball = (oldBall, newBall)
            , courtBoundingBox = C.courtBoundingBox
            }
            |> redirectAfterWallStrike 
            |> andThen redirectAfterPaddleStrike
            |> andThen scored
            |> completeTest
    in
    result
        (Court
            (clampPaddle Left suggestedLeftPaddle)
            (clampPaddle Right suggestedRightPaddle)
            (nb)
        )

type BallTest
    = Proceed TestContext
    | Scored Side
    | Paddled Ball
    | Walled Ball

type alias TestContext =
    { leftPaddle : (Paddle, Paddle)
    , rightPaddle : (Paddle, Paddle)
    , ball : (Ball, Ball)
    , courtBoundingBox : Units.BoundingBox
    }

testIsDoneか : BallTest -> Bool
testIsDoneか test =
    case test of
        Proceed _ ->
            False

        _ -> 
            True


scoredか : BallTest -> Bool
scoredか test =
    case test of
        Scored _ -> 
            True

        _ ->
            False

andThen : (TestContext -> BallTest) -> BallTest -> BallTest
andThen f test =
    case test of
        Proceed b ->
            f b

        Scored side ->
            Scored side

        Paddled b ->
            Paddled b

        Walled b ->
            Walled b

completeTest : BallTest -> (Ball, Court -> UpdateResult)
completeTest test =
    case test of
        Proceed context ->
            (context.ball |> Tuple.second, Continue)

        Scored side ->
            ( Ball.init 
                (Point2d.xy (Length.meters 0) (Length.meters 0))
                (Direction2d.degrees (if side == Left then -45 else 135))     
            , Score side >> PlaySFX GoalScored)

        Paddled b ->
            (b, Continue >> PlaySFX PaddleHit)

        Walled b ->
            (b, Continue >> PlaySFX WallHit)


redirectAfterWallStrike : TestContext -> BallTest
redirectAfterWallStrike context =
    let 
        {minX, maxX, minY, maxY} = BoundingBox2d.extrema context.courtBoundingBox
        topBB = BoundingBox2d.from 
            (Point2d.xy minX minY) 
            (Point2d.xy maxX (Quantity.plus (Length.meters 0.1) minY))
        bottomBB = BoundingBox2d.from 
            (Point2d.xy minX maxY) 
            (Point2d.xy maxX (Quantity.minus (Length.meters 0.1) maxY))
    in
    if 
        context.ball
        |> Tuple.map (Ball.circle >> Circle2d.intersectsBoundingBox topBB)
        |> Tuple.mapFirst not
        |> uncurry (&&)
    then
        Ball.init 
            (Ball.coords (Tuple.second context.ball))
            (Direction2d.mirrorAcross 
                Axis2d.x
                (Ball.direction (Tuple.second context.ball)))
        |> Walled
    else
        if 
            context.ball
            |> Tuple.map (Ball.circle >> Circle2d.intersectsBoundingBox bottomBB)
            |> Tuple.mapFirst not
            |> uncurry (&&)
        then
            Ball.init 
                (Ball.coords (Tuple.second context.ball))
                (Direction2d.mirrorAcross 
                    Axis2d.x
                    (Ball.direction (Tuple.second context.ball)))
            |> Walled
        else
            Proceed context
        
redirectAfterPaddleStrike : TestContext -> BallTest
redirectAfterPaddleStrike context =
    if context.ball
        |> Tuple.map Ball.circle
            |> Tuple.mapBoth 
            (Circle2d.intersectsBoundingBox (Paddle.boundingBox (context.leftPaddle |> Tuple.first))) 
            (Circle2d.intersectsBoundingBox (Paddle.boundingBox (context.leftPaddle |> Tuple.second)))
        |> Tuple.mapFirst not
        |> uncurry (&&)
    then
        Ball.init 
            (Ball.coords (Tuple.second context.ball))
            (Direction2d.mirrorAcross 
                Axis2d.y
                (Ball.direction (Tuple.first context.ball)))
        |> Paddled
    else
        if context.ball
            |> Tuple.map Ball.circle
            |> Tuple.mapBoth 
                (Circle2d.intersectsBoundingBox (Paddle.boundingBox (context.rightPaddle |> Tuple.first))) 
                (Circle2d.intersectsBoundingBox (Paddle.boundingBox (context.rightPaddle |> Tuple.second)))
            |> Tuple.mapFirst not
            |> uncurry (&&)
        then
            Ball.init 
                (Ball.coords (Tuple.second context.ball))
                (Direction2d.mirrorAcross 
                    Axis2d.y
                    (Ball.direction (Tuple.first context.ball)))
            |> Paddled
        else
            Proceed context


scored : TestContext -> BallTest
scored context =
    let (bx, by) = Ball.coords (Tuple.second context.ball) |> Point2d.coordinates
        borderMinusHalfBall =
            Quantity.minus C.ballRadius C.halfCourtWidth
    in
    if Quantity.lessThan (Quantity.negate borderMinusHalfBall) bx then
        Scored Right
    else 
        if Quantity.greaterThan borderMinusHalfBall bx then
           Scored Left 
        else
            Proceed context
        


