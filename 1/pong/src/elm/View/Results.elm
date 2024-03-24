module View.Results exposing (view)

import Html exposing (Html, main_, h1, button, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
import Model.Court as Court exposing (Side)
import Msg.App exposing (Msg)
import String.Extra as String 

view : Side -> Html Msg
view side =
    main_
        [ id "results-menu" ]
        [ h1 
            [] 
            [ text 
                ((Court.toString side |> String.toSentenceCase) ++ " Wins") 
            ]
        , button
            [ onClick Msg.App.RestartGame ]
            [ text "Restart Game" ]
        , button
            [ onClick Msg.App.QuitGame ]
            [ text "Quit" ]
        ]
