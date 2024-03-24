module Model.Config exposing (Config(..), KeyType(..), ConfigOptions, init, pause, p1Up, p1Down, p2Up, p2Down, kbGameMessages, audioEnabledか, remap, executeRemapping, setRemappedKey, pauseKeyPressedか, toggleAudio)

import Keyboard exposing (Key)
import Msg.Game exposing (Msg(..))
import Basics.Extra exposing (flip)

type alias Options =
    { player1Keys : (Key, Key)
    , player2Keys : (Key, Key)
    , pauseKey : Key
    , audioEnabled : Bool
    }

type ConfigOptions = ConfigOptions Options

type Config 
    = Config ConfigOptions
    | Remapping KeyType (Maybe Key) ConfigOptions

type KeyType 
    = LeftPaddleUp 
    | LeftPaddleDown  
    | RightPaddleUp 
    | RightPaddleDown 
    | PauseKey


remap : KeyType -> Maybe Key -> Config -> Config
remap keyType key conf =
    case conf of
        Config opts -> Remapping keyType key opts
        Remapping _ _ opts -> Remapping keyType key opts

setRemappedKey : Key -> Config -> Config
setRemappedKey key conf =
    case conf of
        Config _ -> conf
        Remapping keyType _ opts -> Remapping keyType (Just key) opts


executeRemapping : Config -> Config
executeRemapping conf =
    case conf of
        Remapping LeftPaddleDown (Just k) (ConfigOptions opts) -> 
            Config <|
                ConfigOptions { opts 
                | player1Keys = Tuple.mapSecond (always k) opts.player1Keys
                }
        Remapping LeftPaddleUp (Just k) (ConfigOptions opts) ->
            Config <|
                ConfigOptions { opts 
                | player1Keys = Tuple.mapFirst (always k) opts.player1Keys
                }
        Remapping RightPaddleDown (Just k) (ConfigOptions opts) ->
            Config <|
                ConfigOptions { opts 
                | player2Keys = Tuple.mapSecond (always k) opts.player2Keys
                }
        Remapping RightPaddleUp (Just k) (ConfigOptions opts) ->
            Config <|
                ConfigOptions { opts 
                | player2Keys = Tuple.mapFirst (always k) opts.player2Keys
                }
        Remapping PauseKey (Just k) (ConfigOptions opts) ->
            Config <|
                ConfigOptions { opts 
                | pauseKey = k
                }
        _ -> conf


toggleAudio : Config -> Config
toggleAudio conf =
    case conf of
        Config (ConfigOptions opts) -> 
            Config <|
                ConfigOptions { opts 
                | audioEnabled = not opts.audioEnabled
                }
        _ -> conf




init : Config
init =
    Config <|
        ConfigOptions
            { player1Keys = (Keyboard.Character "W", Keyboard.Character "S")
            , player2Keys = (Keyboard.ArrowUp, Keyboard.ArrowDown)
            , pauseKey = Keyboard.Escape
            , audioEnabled = True
            }

p1Up : Config -> Key
p1Up =
    configOptions >> options >> .player1Keys >> Tuple.first

p1Down : Config -> Key
p1Down =
    configOptions >> options >> .player1Keys >> Tuple.second


p2Up : Config -> Key
p2Up = 
    configOptions >> options >> .player2Keys >> Tuple.first


p2Down : Config -> Key
p2Down =
    configOptions >> options >> .player2Keys >> Tuple.second

pause : Config -> Key
pause =
    configOptions >> options >> .pauseKey

configOptions : Config -> ConfigOptions
configOptions conf = 
    case conf of
        Config opts -> opts
        Remapping _ _ opts -> opts

options : ConfigOptions -> Options
options (ConfigOptions opts) = opts

pauseKeyPressedか : Config -> List Key -> Bool
pauseKeyPressedか config keys =
    pause config |> flip List.member keys

kbGameMessages : Config -> List Key -> List Msg.Game.Msg
kbGameMessages config keys =
    [ (p1Up, MovePlayerOneUp)
    , (p1Down, MovePlayerOneDown)
    , (p2Up, MovePlayerTwoUp)
    , (p2Down, MovePlayerTwoDown)
    ]
        |> List.map (Tuple.mapFirst ((|>) config))
        |> List.filter (Tuple.first >> flip List.member keys)
        |> List.map Tuple.second
        |> (++) [ StillPlayerOne, StillPlayerTwo ]

audioEnabledか : Config -> Bool
audioEnabledか =
    configOptions >> options >> .audioEnabled
