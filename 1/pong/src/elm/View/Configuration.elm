module View.Configuration exposing (view)

import Html exposing (Html, div, main_, button, text, h1, h2, input, label, span)
import Html.Attributes exposing (class, id, checked, for, type_)
import Html.Events exposing (onClick, onInput)
import Model.Config as Config exposing (Config(..), KeyType(..))
import Msg.App as Msg exposing (Msg(..))
import Keyboard

view : Config -> Html Msg
view conf =
    case conf of
        Config opts ->
            viewMenu conf 
                |> main_ [ id "config-menu" ]
        Remapping keyType mbMap opts ->
            viewConfiguring keyType mbMap opts
            |> main_ [ id "config-menu" ]


viewConfiguring : KeyType -> Maybe Keyboard.Key -> Config.ConfigOptions -> List (Html Msg)
viewConfiguring keyType mbKey confOpts =
    let
        actionName =
            case keyType of
                RightPaddleUp -> "Right Paddle Up"
                RightPaddleDown -> "Right Paddle Down"
                LeftPaddleUp -> "Left Paddle Up"
                LeftPaddleDown -> "Left Paddle Down"
                PauseKey -> "Pause"
    in
    case mbKey of
        Just key ->
            [ h1 [] [ "Confirmed?" |> text ]
            , span [] [ "Remap " ++ actionName ++ " to " ++ (keyName key) ++ "?" |> text ]
            , button [ onClick Msg.ConfirmRemapping ] [ "Yes" |> text ]
            , button [ onClick Msg.CancelRemapping ] [ "No" |> text ]
            ]
        Nothing ->
            [ h1 [] [ "Remap " ++ actionName |> text ]
            , span [] [ "(Press desired key)" |> text ]
            ]

viewMenu : Config -> List (Html Msg)
viewMenu conf =
    let
        p1Up = Config.p1Up conf
        p1Down = Config.p1Down conf
        p2Up = Config.p2Up conf
        p2Down = Config.p2Down conf
        pause = Config.pause conf
    in
    [ h1 [] [ text "Settings" ]
    , h2 [] [ text "Controls" ]
    ]
    ++ viewKeySettingStatus "Pause Game" pause (PauseKey)
    ++ viewKeySettingStatus "Left Paddle Up" p1Up (LeftPaddleUp)
    ++ viewKeySettingStatus "Left Paddle Down" p1Down (LeftPaddleDown)
    ++ viewKeySettingStatus "Right Paddle Up" p2Up (RightPaddleUp)
    ++ viewKeySettingStatus "Right Paddle Down" p2Down (RightPaddleDown)
    ++ [ h2 [] [ text "Audio" ]
        , div [] 
        [ label
            [ for "audio-switch" ]
            [ text "Enabled: " ]
        , input
            [ type_ "checkbox"
            , onInput (always Msg.ToggleAudio)
            , checked (Config.audioEnabledか conf)
            ]
            []
        ]
        , button 
            [ onClick Msg.StopConfiguring ]
            [ text "Return to Menu" ]
        ]

viewKeySettingStatus : String -> Keyboard.Key -> KeyType -> List (Html Msg)
viewKeySettingStatus actionName key keyType  =
    [ [ actionName
        , ": "
        , keyName key
        ]
        |> String.join ""
        |> text
        |> List.singleton
        |> span []
    , button 
        [ Msg.StartRemapping keyType
            |> onClick
        , class "remap-button"
        ]
        [ text "Remap" ]
    ]
    |> div []
    |> List.singleton


keyName : Keyboard.Key -> String
keyName k =
    case k of
        Keyboard.Character s -> s
        Keyboard.Alt -> "Alt"
        Keyboard.AltGraph -> "AltGraph"
        Keyboard.CapsLock -> "CapsLock"
        Keyboard.Control -> "Control"
        Keyboard.Fn -> "Fn"
        Keyboard.FnLock -> "FnLock"
        Keyboard.Hyper -> "Hyper"
        Keyboard.Meta -> "Meta"
        Keyboard.NumLock -> "NumLock"
        Keyboard.ScrollLock -> "ScrollLock"
        Keyboard.Shift -> "Shift"
        Keyboard.Super -> "Super"
        Keyboard.Symbol -> "Symbol"
        Keyboard.SymbolLock -> "SymbolLock"
        Keyboard.Enter -> "Enter"
        Keyboard.Tab -> "Tab"
        Keyboard.Spacebar -> "Spacebar"
        Keyboard.ArrowDown -> "ArrowDown"
        Keyboard.ArrowLeft -> "ArrowLeft"
        Keyboard.ArrowRight -> "ArrowRight"
        Keyboard.ArrowUp -> "ArrowUp"
        Keyboard.End -> "End"
        Keyboard.Home -> "Home"
        Keyboard.PageDown -> "PageDown"
        Keyboard.PageUp -> "PageUp"
        Keyboard.Backspace -> "Backspace"
        Keyboard.Clear -> "Clear"
        Keyboard.Copy -> "Copy"
        Keyboard.CrSel -> "CrSel"
        Keyboard.Cut -> "Cut"
        Keyboard.Delete -> "Delete"
        Keyboard.EraseEof -> "EraseEof"
        Keyboard.ExSel -> "ExSel"
        Keyboard.Insert -> "Insert"
        Keyboard.Paste -> "Paste"
        Keyboard.Redo -> "Redo"
        Keyboard.Undo -> "Undo"
        Keyboard.F1 -> "F1"
        Keyboard.F2 -> "F2"
        Keyboard.F3 -> "F3"
        Keyboard.F4 -> "F4"
        Keyboard.F5 -> "F5"
        Keyboard.F6 -> "F6"
        Keyboard.F7 -> "F7"
        Keyboard.F8 -> "F8"
        Keyboard.F9 -> "F9"
        Keyboard.F10 -> "F10"
        Keyboard.F11 -> "F11"
        Keyboard.F12 -> "F12"
        Keyboard.F13 -> "F13"
        Keyboard.F14 -> "F14"
        Keyboard.F15 -> "F15"
        Keyboard.F16 -> "F16"
        Keyboard.F17 -> "F17"
        Keyboard.F18 -> "F18"
        Keyboard.F19 -> "F19"
        Keyboard.F20 -> "F20"
        Keyboard.Again -> "Again"
        Keyboard.Attn -> "Attn"
        Keyboard.Cancel -> "Cancel"
        Keyboard.ContextMenu -> "ContextMenu"
        Keyboard.Escape -> "Escape"
        Keyboard.Execute -> "Execute"
        Keyboard.Find -> "Find"
        Keyboard.Finish -> "Finish"
        Keyboard.Help -> "Help"
        Keyboard.Pause -> "Pause"
        Keyboard.Play -> "Play"
        Keyboard.Props -> "Props"
        Keyboard.Select -> "Select"
        Keyboard.ZoomIn -> "ZoomIn"
        Keyboard.ZoomOut -> "ZoomOut"
        Keyboard.AppSwitch -> "AppSwitch"
        Keyboard.Call -> "Call"
        Keyboard.Camera -> "Camera"
        Keyboard.CameraFocus -> "CameraFocus"
        Keyboard.EndCall -> "EndCall"
        Keyboard.GoBack -> "GoBack"
        Keyboard.GoHome -> "GoHome"
        Keyboard.HeadsetHook -> "HeadsetHook"
        Keyboard.LastNumberRedial -> "LastNumberRedial"
        Keyboard.Notification -> "Notification"
        Keyboard.MannerMode -> "MannerMode"
        Keyboard.VoiceDial -> "VoiceDial"
        Keyboard.ChannelDown -> "ChannelDown"
        Keyboard.ChannelUp -> "ChannelUp"
        Keyboard.MediaFastForward -> "MediaFastForward"
        Keyboard.MediaPause -> "MediaPause"
        Keyboard.MediaPlay -> "MediaPlay"
        Keyboard.MediaPlayPause -> "MediaPlayPause"
        Keyboard.MediaRecord -> "MediaRecord"
        Keyboard.MediaRewind -> "MediaRewind"
        Keyboard.MediaStop -> "MediaStop"
        Keyboard.MediaTrackNext -> "MediaTrackNext"
        Keyboard.MediaTrackPrevious -> "MediaTrackPrevious"
