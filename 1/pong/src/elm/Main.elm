module Main exposing (main)

import App as App
import Model.App exposing (App)
import Msg.App exposing (Msg)
import Browser


main : Program () App Msg
main =
    Browser.element
        { init = App.init
        , subscriptions = App.subscriptions
        , update = App.update
        , view = App.view
        }
