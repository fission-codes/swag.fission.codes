module State exposing
    ( getFormFieldState
    , init
    , subscriptions
    , update
    )

import Browser.Dom as Dom
import Dict exposing (Dict)
import Http
import Maybe.Extra as Maybe
import Task
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { formFields = Dict.empty
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
                | formFields =
                    model.formFields
                        |> Dict.update id
                            (Maybe.withDefault formFieldInit
                                >> updateFieldValue value
                                >> Just
                            )
              }
            , Cmd.none
            )

        OnFormFieldBlur { id, validate } ->
            ( { model
                | formFields =
                    model.formFields
                        |> Dict.update id
                            (Maybe.withDefault formFieldInit
                                >> updateFieldBlur validate
                                >> Just
                            )
              }
            , Cmd.none
            )

        OnFormSubmit { submissionUrl } ->
            -- TODO Make sure there are no errors in the form (also disable the submission button)
            ( model
            , Http.post
                { url = submissionUrl
                , body =
                    Http.multipartBody
                        (List.append
                            (model.formFields
                                |> Dict.toList
                                |> List.map formFieldSubmissionPart
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
            ( { model | formFields = clearFields model.formFields }
            , Cmd.none
            )

        FocusedForm ->
            ( model, Cmd.none )


formFieldInit : FormField
formFieldInit =
    { value = ""
    , error = Nothing
    }


formFieldSubmissionPart : ( String, FormField ) -> Http.Part
formFieldSubmissionPart ( fieldId, { value } ) =
    Http.stringPart fieldId value


updateFieldValue : String -> FormField -> FormField
updateFieldValue value formField =
    { formField | value = value }


updateFieldBlur : (String -> FieldErrorState) -> FormField -> FormField
updateFieldBlur validate formField =
    { formField
        | error = validate formField.value
    }


clearFields : Dict String FormField -> Dict String FormField
clearFields fields =
    fields
        |> Dict.map (\_ _ -> formFieldInit)


getFormFieldState :
    Model
    -> String
    -> (String -> FieldErrorState)
    ->
        { value : String
        , error : FieldErrorState
        , onInput : String -> Msg
        , onBlur : Msg
        }
getFormFieldState model fieldId validate =
    let
        formFieldModel =
            model.formFields
                |> Dict.get fieldId
                |> Maybe.withDefault formFieldInit
    in
    { value = formFieldModel.value
    , error = formFieldModel.error
    , onInput = \value -> OnFormFieldInput { id = fieldId, value = value }
    , onBlur = OnFormFieldBlur { id = fieldId, validate = validate }
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
