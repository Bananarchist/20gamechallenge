module View.Pause exposing (view)


import Model.App exposing (App)
import Msg.App exposing (Msg)
import Html exposing (Html, main_, button, h1, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)

view : App -> Html Msg
view _ =
    main_ 
        [ id "pause-menu" ]
        [ h1 [] [ text "Paused" ]
        , button 
            [ onClick Msg.App.ResumeGame ]
            [ text "Resume" ]
        , button
            [ onClick Msg.App.RestartGame ]
            [ text "Restart Game" ]
        , button
            [ onClick Msg.App.QuitGame ]
            [ text "Quit" ]
        ]

