module Msg.Game exposing (Msg(..))

import Browser.Events
import Duration exposing (Duration)
import Units.Pong as Units
import Duration

-- Msgs for updating game model
-- Moving player one and two, updating time, updating the score, and deciding if the game has ended
type Msg
    = MovePlayerOneUp
    | MovePlayerOneDown
    | StillPlayerOne
    | MovePlayerTwoUp
    | MovePlayerTwoDown
    | StillPlayerTwo

