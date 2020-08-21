module State exposing (init, subscriptions, update)

import Browser.Dom as Dom
import Dict exposing (Dict)
import Email
import Task
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { swagForm = Dict.empty
      }
    , Dom.focus "FIRSTNAME" |> Task.attempt (\_ -> FocusedForm)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
