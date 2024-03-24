module BallTests exposing (suite)

import Test exposing (Test, test, fuzz, skip, describe)
import Expect
import Fuzz
import Model.Court as Court
import Model.Ball as Ball
import Model.Paddle as Paddle
import Length
import Tuple.Extra as Tuple
import Constants as C
import Point2d
import Vector2d
import Quantity
import Duration
import Direction2d
import Basics.Extra exposing (uncurry)
import Units.Pong
import Rectangle2d exposing (Rectangle2d)
import Model.Paddle as Paddle
import BoundingBox2d exposing (BoundingBox2d)

suite : Test
suite =
  describe "Ball collision tests"
    [ describe "Ball-Wall collision tests" wallCollisionTests
    , describe "Ball-Paddle collision tests" paddleCollisionTests
    , describe "Ball-Goal collision tests" goalCollisionTests
    ]

goalCollisionTests : List Test
goalCollisionTests =
  [ fuzz sideFuzzer "Ball colliding with goal results in a Score test result" <|
    \s ->
      let
          b = goalBall s
          testContext =
            { defaultTestContext
            | ball = (timeReversedBall frameDuration b, b)
            }
      in
      testContext
      |> Court.scored
      |> Expect.equal (Court.Scored (Court.opposite s))
  ] 


wallCollisionTests : List Test
wallCollisionTests = 
  [ test "Ball colliding with top wall results a reflected angle" <|
    \() ->
      let
          newBall = 
            Ball.init 
              (Point2d.xy 
                (Length.meters 0) 
                (Quantity.negate (Quantity.minus C.ballRadius C.halfCourtHeight)) )
              (Direction2d.degrees 45)
          oldBall = timeReversedBall frameDuration newBall
          testContext =
            { defaultTestContext
            | ball = (oldBall, newBall)
            }
          expectedBall =
            Ball.update frameDuration (Ball.init (Ball.coords oldBall) (Direction2d.degrees -45))
      in
      testContext
      |> Court.redirectAfterWallStrike
      |> Expect.equal (Court.Done expectedBall)
  ]

paddleCollisionTests : List Test
paddleCollisionTests = 
  [ test "Ball colliding with paddle results in reflected angle" <|
    \() ->
      let
          defender = defaultPaddle Court.Right
          newBall = 
            Ball.init 
              (Point2d.xy 
                ( Paddle.boundingBox defender 
                  |> BoundingBox2d.minX
                  |> Quantity.plus C.ballRadius) 
                (Length.meters 0)) 
              (Direction2d.degrees 45)
          oldBall = timeReversedBall (Quantity.multiplyBy 6.0 frameDuration) newBall
          testContext =
            { defaultTestContext
            | ball = (oldBall, newBall)
            , rightPaddle = (defender, defender)
            }
          expectedBall =
            Ball.update frameDuration (Ball.init (Ball.coords oldBall) (Direction2d.degrees -45))
      in
      testContext
      |> Court.redirectAfterPaddleStrike
      |> Expect.equal (Court.Done expectedBall)
  ]

{- Fuzzers -}
sideFuzzer : Fuzz.Fuzzer Court.Side
sideFuzzer =
  Fuzz.oneOfValues [Court.Left, Court.Right]


{- Helpful constants -}
frameDuration : Duration.Duration
frameDuration =
  Duration.seconds (1.0 / 60.0)


{- Utility functions -}

defaultBall : Ball.Ball
defaultBall =
  Ball.init Point2d.origin (Direction2d.degrees 45)

defaultTestContext : Court.TestContext
defaultTestContext = 
    { ball = (timeReversedBall frameDuration defaultBall, defaultBall)
    , leftPaddle = (defaultPaddle Court.Left, defaultPaddle Court.Left)
    , rightPaddle = (defaultPaddle Court.Right, defaultPaddle Court.Right)
    , courtBoundingBox = C.courtBoundingBox
    }

goalBall : Court.Side -> Ball.Ball
goalBall side =
  let
      x =
        if side == Court.Right then
          C.halfCourtWidth
        else
          Quantity.negate C.halfCourtWidth
      y = Quantity.plus (Length.meters 10) C.halfCourtHeight
  in
  Ball.init (Point2d.xy x y) (Direction2d.degrees 45)

timeReversedBall : Units.Pong.Time -> Ball.Ball -> Ball.Ball
timeReversedBall time ball =
  let
      newlyHistoricalPosition = 
        ball
        |> Tuple.from
        |> Tuple.mapBoth Ball.direction Ball.coords
        |> Tuple.mapFirst (Vector2d.withLength (Quantity.at C.ballSpeed time))
        |> uncurry Point2d.translateBy
  in
  Ball.init newlyHistoricalPosition (Ball.direction ball)

defaultPaddle : Court.Side -> Paddle.Paddle
defaultPaddle side =
  let
      x =
        if side == Court.Right then
          C.paddleX
        else
          Quantity.negate C.paddleX
  in
  Paddle.init (Point2d.xy x (Length.meters 0))
