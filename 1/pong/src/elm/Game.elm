module Game exposing (update, subscriptions, updateGameTick)

import Model.Game as Game exposing (Game, movePlayer)
import Model.Paddle as Paddle 
import Model.Ball as Ball
import Model.Court as Court exposing (Side(..), UpdateResult(..))
import Model.Player as Player exposing (Impulse(..))
import Model.Audio as Audio
import Msg.Game exposing (Msg(..))
import Basics.Extra as Basics exposing (flip, uncurry)
import Tuple.Extra as Tuple
import Constants as C
import Units.Pong as Units
import Quantity
import Model.Game as Game
import Maybe.Extra as Maybe


{- Updates game state on new frames -}
updateGameTick : Units.Time -> Game -> (Game, Maybe Audio.SFX)
updateGameTick δ state =
    let 
        paddleMoveAmt = Quantity.at C.paddleSpeed δ
        translatedPaddle side = 
            (Game.player side state |> Player.direction
            , Game.court state |> Court.paddle side
            )
            |> Maybe.combineFirst
            |> Maybe.map (uncurry (Paddle.update δ))
            |> Maybe.withDefault (Game.court state |> Court.paddle side)
        translatedBall =
            Game.court state 
            |> Court.ball
            |> Ball.update δ
        courtUpdateResult = 
            Court.update 
                ( Court.Update
                    (translatedPaddle Left)
                    (translatedPaddle Right)
                    translatedBall
                )
                (Game.court state)
        handleResult result = 
            case result of
                Court.PlaySFX audio next ->
                    handleResult next
                    |> Tuple.mapSecond (flip Maybe.or (Just audio))
                Court.Continue newCourt ->
                    ( Game.mapCourt (always newCourt) state
                    , Nothing
                    )
                Court.Score side newCourt ->
                    let 
                        gameWithCourt = Game.mapCourt (always newCourt) state 
                    in
                    case Game.player side state |> Player.incrScore of
                        Player.Continue newPlayer ->
                            ( gameWithCourt
                                |> Game.mapPlayer side (always newPlayer)
                            , Just Audio.GoalScored
                            )
                        Player.Victorious newPlayer ->
                            ( gameWithCourt 
                                |> Game.mapPlayer side (always newPlayer)
                                |> Game.endGame side
                            , Just Audio.GameOver
                            )
    in
    handleResult courtUpdateResult


{- Handles updating game state from Msg.Game Msg type -}
update : Msg -> Game -> Game
update msg state = 
    case msg of
        MovePlayerOneUp ->
            movePlayer Left Up state
        MovePlayerOneDown ->
            movePlayer Left Down state
        MovePlayerTwoUp ->
            movePlayer Right Up state
        StillPlayerOne ->
            movePlayer Left Still state
        MovePlayerTwoDown ->
            movePlayer Right Down state
        StillPlayerTwo ->
            movePlayer Right Still state

subscriptions : Game -> Sub Msg
subscriptions _ = 
    Sub.none 
