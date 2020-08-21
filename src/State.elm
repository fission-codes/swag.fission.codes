module State exposing (init, subscriptions, update)

import Browser.Dom as Dom
import Dict exposing (Dict)
import Email
import Task
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { swagForm =
            { firstname = ""
            , lastname = ""
            , email = ""
            , company = ""
            , addressStreet = ""
            , addressCitystate = ""
            , addressPostal = ""
            , addressCountry = ""
            }
      }
    , Dom.focus "FIRSTNAME" |> Task.attempt (\_ -> ())
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
