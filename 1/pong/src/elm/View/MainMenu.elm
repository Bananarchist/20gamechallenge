module View.MainMenu exposing (view)

import Model.App exposing (App)
import Msg.App
import Html exposing (main_, text, button, h1, Html)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)


view : App -> Html Msg.App.Msg
view _ =
    main_ 
        [ id "main-menu" ]
        [ h1 [] [ text "PONG" ]
        , button
            [ onClick Msg.App.StartGame ]
            [ text "2P Local" ]
        , button
            [ onClick Msg.App.StartAIGame ]
            [ text "1P vs AI" ]
        , button
            [ onClick Msg.App.ConfigureGame ]
            [ text "Settings" ]
        ]
