module State exposing (init, subscriptions, update)

import Browser.Dom as Dom
import Dict exposing (Dict)
import Email
import Http
import Task
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { swagForm = Dict.empty
      }
      -- We also need to focus the first form field here
      -- setting 'autofocus' on the input is not sufficient:
      -- It blurs when the content is hydrated.
    , Dom.focus "FIRSTNAME" |> Task.attempt (\_ -> FocusedForm)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnFormFieldInput { id, value } ->
            ( { model
                | swagForm =
                    model.swagForm
                        |> Dict.update id
                            (Maybe.withDefault formFieldInit
                                >> updateFieldValue value
                                >> Just
                            )
              }
            , Cmd.none
            )

        OnFormSubmit { submissionUrl } ->
            ( model
            , Http.post
                { url = submissionUrl
                , body =
                    Http.multipartBody
                        (List.append
                            (model.swagForm
                                |> Dict.toList
                                |> List.map (\( id, value ) -> Http.stringPart id value)
                            )
                            [ Http.stringPart "html_type" "simple"
                            , Http.stringPart "locale" "en"
                            ]
                        )
                , expect =
                    Http.expectWhatever GotFormSubmissionResponse
                }
            )

        GotFormSubmissionResponse response ->
            -- TODO handle errors
            -- TODO handle success: show 'thank you'
            ( { model | swagForm = clearFields model.swagForm }
            , Cmd.none
            )

        FocusedForm ->
            ( model, Cmd.none )


formFieldInit : FormField
formFieldInit =
    ""


updateFieldValue : String -> FormField -> FormField
updateFieldValue value formField =
    value


clearFields : Dict String FormField -> Dict String FormField
clearFields fields =
    fields
        |> Dict.map (\_ _ -> "")


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
