module Model.Player exposing (Player, Impulse(..), Score, Status(..), init, incrScore, moveUp, moveDown, stop, score, impulse, move, direction)

import Units.Pong as Units
import Direction2d

{-| A player is a score and an impulse. -}

type Player 
    = Player Score Impulse

type Impulse 
    = Up
    | Down
    | Still

type Score = Score Int

type Status 
    = Continue Player
    | Victorious Player

init : Player
init = 
    Player (initScore) Still

initScore : Score
initScore = 
    Score 0

score : Player -> Int
score (Player (Score s) _) = 
    s

impulse : Player -> Impulse
impulse (Player _ i) = 
    i

direction : Player -> Maybe Units.Direction
direction p = 
    case impulse p of 
        Up -> 
            Just Direction2d.positiveY
        Down -> 
            Just Direction2d.negativeY
        Still -> 
            Nothing

incrScore : Player -> Status
incrScore (Player (Score s) i) = 
    let newScore = s + 1 in
    Player (Score newScore) i
    |> (if newScore == 10 then Victorious else Continue)

move : Impulse -> Player -> Player
move i (Player s _) = 
    Player s i

moveUp : Player -> Player
moveUp = 
    move Up

moveDown : Player -> Player
moveDown =
    move Down

stop : Player -> Player
stop =
    move Still

