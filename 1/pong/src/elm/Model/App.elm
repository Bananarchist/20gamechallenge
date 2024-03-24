module Model.App exposing (App(..), init, appState, updateKeys, p1UpPressed, p1DownPressed, p2UpPressed, p2DownPressed, newTick, updateScreenSize, endGame, updateConfig, startGame)

import Model.Game as Game exposing (Game)
import Model.Config as Config exposing (Config)
import Model.Court as Court
import Pixels exposing (Pixels)
import Quantity exposing (Quantity)
import Keyboard exposing (Key)
import Duration exposing (Duration)
import Units.Screen as Units

{- Application model for handling app state, browser information -}
type alias AppState = 
    { screen : (Units.Length, Units.Length)
    , keys : List Key
    , tick : Duration
    , config : Config
    }

type App 
    = Initializing
    | MainMenu AppState
    | ConfigurationMenu AppState
    | Remapping AppState Config
    | ConfirmingRemapping AppState Config
    | Play AppState Game
    | Results Court.Side AppState Game
    | Pause AppState Game


init : App
init =
    Initializing


appState : (Units.Length, Units.Length) -> Duration -> AppState
appState screen tick = 
    { screen = screen
    , keys = []
    , tick = tick
    , config = Config.init
    }

updateScreenSize : (Units.Length, Units.Length) -> AppState -> AppState
updateScreenSize screen state = 
    { state | screen = screen }

updateKeys : Keyboard.Msg -> AppState -> AppState
updateKeys keyMsg state = 
    { state | keys = Keyboard.update keyMsg state.keys }

updateConfig : Config -> AppState -> AppState
updateConfig config state = 
    { state | config = config }

p1UpPressed : AppState -> Bool
p1UpPressed state = 
    List.member (Config.p1Up state.config) state.keys

p1DownPressed : AppState -> Bool
p1DownPressed state = 
    List.member (Config.p1Down state.config) state.keys

p2UpPressed : AppState -> Bool
p2UpPressed state = 
    List.member (Config.p2Up state.config) state.keys

p2DownPressed : AppState -> Bool
p2DownPressed state = 
    List.member (Config.p2Down state.config) state.keys

newTick : Duration -> AppState -> AppState
newTick δ state = 
    { state | tick = Quantity.plus state.tick δ }

startGame : AppState -> Game -> App
startGame state game = 
    Play state game

endGame : AppState -> Game -> App
endGame state game = 
    case Game.winner game of
        Just side -> Results side state game
        Nothing -> Play state game

