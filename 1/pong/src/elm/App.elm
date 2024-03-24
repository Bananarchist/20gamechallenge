module App exposing (init, subscriptions, update, view)

import Model.App as App exposing (App(..))
import Model.Game as Game 
import Model.Court exposing (Side(..))
import Model.Config as Config 
import Model.Audio as Audio
import Msg.App exposing (Msg(..))
import Game
import Cmd.Extra as Cmd
import Browser.Dom
import Tuple.Extra as Tuple
import Html exposing (Html)
import Task
import Pixels
import Duration 
import View.Configuration
import View.Game
import View.MainMenu
import View.Pause
import View.Results
import Msg.Ports as JS
import Msg.Ports as Ports
import Model.Config as Config


init : () -> ( App, Cmd Msg )
init =
    always 
        ( App.init
        , Cmd.batch
            [ Task.perform 
                 ( Tuple.from
                 >> Tuple.map .scene
                 >> Tuple.mapBoth .width .height
                 >> Tuple.map Pixels.float
                 >> ScreenSizeUpdated
                 )
                 Browser.Dom.getViewport
            , JS.initializeAudioContext ()
            ]
        )


update : Msg -> App -> ( App, Cmd Msg )
update msg model =
    case (model, msg) of
        (Initializing, ScreenSizeUpdated size) ->
            ( MainMenu (App.appState size (Duration.seconds 0))
            , Cmd.none
            )
        (MainMenu appState, StartGame) ->
            ( Play 
                (appState)
                (Game.init)
            , Cmd.none
            )
        (MainMenu appState, ConfigureGame) ->
            ( ConfigurationMenu appState
            , Cmd.none
            )
        (ConfigurationMenu appState, StartRemapping keyType) ->
            appState.config
                |> Config.remap keyType Nothing
                |> Remapping appState
                |> Cmd.pure
        (Remapping appState c, KeyboardConfigInput (Just k)) ->
            Config.setRemappedKey k c
            |> ConfirmingRemapping appState
            |> Cmd.pure
        (Remapping appState _, CancelRemapping) ->
            (ConfigurationMenu appState, Cmd.none)
        (ConfirmingRemapping appState c, ConfirmRemapping) ->
            (ConfigurationMenu (App.updateConfig (Config.executeRemapping c) appState), Cmd.none)
        (ConfirmingRemapping appState _, CancelRemapping) ->
            (ConfigurationMenu appState, Cmd.none)
        (ConfigurationMenu appState, ToggleAudio) ->
            (ConfigurationMenu 
                (App.updateConfig 
                    (Config.toggleAudio appState.config) 
                    appState)
            , Cmd.none)
        (ConfigurationMenu appState, StopConfiguring) ->
            (MainMenu appState, Cmd.none)
        (Play app game, ScreenSizeUpdated size) ->
            ( Play (App.updateScreenSize size app) game
            , Cmd.none
            )
        (Play app game, KeyboardInput keyMsg) ->
            let
                newAppState = 
                    App.updateKeys keyMsg app
            in 
            if Config.pauseKeyPressedか newAppState.config newAppState.keys then
                (Pause newAppState game, Cmd.none)
            else
                Config.kbGameMessages newAppState.config newAppState.keys 
                    |> List.foldl Game.update game
                    |> Play newAppState
                    |> Cmd.pure
        (Play app game, Tick δ) ->
            let 
                (updatedGame, audioQueues) = 
                    Game.updateGameTick δ game
                updatedApp = 
                    App.newTick δ app
                playAudioIfEnabled p =
                    if Config.audioEnabledか app.config then
                        p
                    else
                        Cmd.none
            in
            case audioQueues of
                Nothing -> 
                    (Play updatedApp updatedGame
                    , Cmd.none)
                Just Audio.GoalScored ->
                    (Play updatedApp updatedGame
                    , playAudioIfEnabled (Ports.playGoalScoreSFX ())
                    )
                Just Audio.PaddleHit ->
                    (Play updatedApp updatedGame
                    , playAudioIfEnabled (Ports.playPaddleBounceSFX ())
                    )
                Just Audio.WallHit ->
                    (Play updatedApp updatedGame
                    , playAudioIfEnabled (Ports.playWallBounceSFX ())
                    )
                Just Audio.GameOver -> -- this is not a great way to do this because if logic works and audio fails...
                    (App.endGame updatedApp updatedGame
                    , playAudioIfEnabled (Ports.playGameOverSFX ())
                    )

        (Results side app game, ScreenSizeUpdated size) ->
            ( Results side (App.updateScreenSize size app) game
            , Cmd.none
            )
        (Results side app game, RestartGame) ->
            ( Play 
                app
                Game.init
            , Cmd.none
            )
        (Results side app game, QuitGame) ->
            ( MainMenu app
            , Cmd.none
            )
        (Pause app game, ScreenSizeUpdated size) ->
            ( Pause (App.updateScreenSize size app) game
            , Cmd.none
            )
        (Pause app game, ResumeGame) ->
            ( Play app game
            , Cmd.none
            )
        (Pause app _, QuitGame) ->
            ( MainMenu app
            , Cmd.none
            )
        (Pause app _, RestartGame) ->
            ( Play 
                app
                Game.init
            , Cmd.none
            )

        _ -> (model, Cmd.none)


subscriptions : App -> Sub Msg
subscriptions app =
    let 
        gameSubs = 
            case app of
                Play _ _ -> 
                    Sub.batch
                        [ Msg.App.tickSub ]
                _ -> Sub.none
        appSubs = 
            case app of
                Play _ _ -> 
                    Sub.batch
                        [ Msg.App.kbSub
                        , Msg.App.screenSizeSub 
                        ]
                Initializing ->
                    Sub.batch
                        [ Msg.App.screenSizeSub
                        ]
                Remapping _ _ ->
                    Sub.batch
                        [ Msg.App.kbConfigSub
                        , Msg.App.screenSizeSub
                        ]
                _ -> Sub.none
    in
    Sub.batch [ gameSubs, appSubs ]



view : App -> Html Msg
view app =
    case app of
        Initializing -> Html.text ""
        MainMenu _ ->
            View.MainMenu.view app
        ConfigurationMenu state ->
            View.Configuration.view state.config 
        Remapping appState config ->
            View.Configuration.view config 
        ConfirmingRemapping appState config ->
            View.Configuration.view config
        Play state gameState -> 
            View.Game.view state.screen gameState
        Pause _ _ ->
            View.Pause.view app
        Results side _ _ ->
            View.Results.view side 
                    
