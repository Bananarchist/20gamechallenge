module Msg.App exposing (Msg(..), kbSub, screenSizeSub, tickSub, kbConfigSub)

import Browser.Events
import Msg.Game as Game
import Keyboard
import Duration exposing (Duration)
import Units.Screen as Units
import Pixels
import Tuple.Extra as Tuple
import Model.Config as Config

type Msg 
    = GameUpdates Game.Msg
    | ScreenSizeUpdated (Units.Length, Units.Length)
    | Tick Duration
    | KeyboardInput Keyboard.Msg
    | StartGame
    | StartAIGame
    | PauseGame
    | ResumeGame
    | RestartGame
    | ConfigureGame
    | QuitGame
    | StartRemapping Config.KeyType
    | ConfirmRemapping
    | CancelRemapping
    | StopConfiguring
    | ToggleAudio
    | KeyboardConfigInput (Maybe Keyboard.Key)

kbSub : Sub Msg
kbSub = Sub.map KeyboardInput Keyboard.subscriptions

kbConfigSub : Sub Msg
kbConfigSub = 
    Sub.map 
        KeyboardConfigInput
        ( Keyboard.downs 
            ( Keyboard.oneOf 
                [ Keyboard.anyKeyUpper
                ] 
            )
        )

screenSizeSub : Sub Msg
screenSizeSub =
    Sub.map 
        (Tuple.map (toFloat >> Pixels.float)
            >> ScreenSizeUpdated
        )
        (Browser.Events.onResize Tuple.pair)

tickSub : Sub Msg
tickSub =
    Sub.map Tick (Browser.Events.onAnimationFrameDelta Duration.milliseconds) 
