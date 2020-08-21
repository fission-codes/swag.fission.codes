module State exposing (init, subscriptions, update)

import Browser.Dom as Dom
import Task
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( Model
    , Dom.focus "first-name" |> Task.attempt (\_ -> ())
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
