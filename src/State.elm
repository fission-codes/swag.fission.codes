module State exposing
    ( getFormFieldState
    , init
    , subscriptions
    , update
    )

import Browser.Dom as Dom
import Dict exposing (Dict)
import FormField
import Http
import Maybe.Extra as Maybe
import Task
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { formFields = Dict.empty
      , submissionStatus = Waiting
      , checkbox = False
      }
      -- We also need to focus the first form field here
      -- setting 'autofocus' on the input is not sufficient:
      -- It blurs when the content is hydrated.
    , Dom.focus "FIRSTNAME" |> Task.attempt (\_ -> FocusedForm)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FocusedForm ->
            ( model, Cmd.none )

        OnFormFieldInput { id, value } ->
            ( updateFormField model id (FormField.onInput value)
            , Cmd.none
            )

        OnFormFieldBlur { id, validate } ->
            ( updateFormField model id (FormField.checkValidation validate)
            , Cmd.none
            )

        OnFormFieldCheck { checked } ->
            ( { model | checkbox = checked }
            , Cmd.none
            )

        OnFormSubmit { submissionUrl, fields } ->
            -- Don't send multiple submissions when the user clicks multiple times.
            if model.submissionStatus == Submitting then
                ( model
                , Cmd.none
                )

            else
                case formFieldErrors model fields of
                    Nothing ->
                        ( { model | submissionStatus = Submitting }
                        , sendSubmit submissionUrl model
                        )

                    Just modelWithErrors ->
                        ( modelWithErrors
                        , Cmd.none
                        )

        GotFormSubmissionResponse response ->
            case response of
                Ok () ->
                    ( submitSuccessful model
                    , Cmd.none
                    )

                Err (Http.BadStatus status) ->
                    -- A statuscode of 3xx is only a redirect,
                    -- the request has been successfull anyway.
                    if 200 <= status && status < 400 then
                        ( submitSuccessful model
                        , Cmd.none
                        )

                    else
                        ( submitUnsuccessful model
                        , Cmd.none
                        )

                Err _ ->
                    -- We don't inform the user about the exact error that happened.
                    ( submitUnsuccessful model
                    , Cmd.none
                    )


updateFormField : Model -> String -> (FormField -> FormField) -> Model
updateFormField model fieldId updater =
    { model
        | formFields =
            model.formFields
                |> Dict.update fieldId
                    (Maybe.withDefault FormField.init
                        >> updater
                        >> Just
                    )
    }


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
                |> Maybe.withDefault FormField.init
    in
    { value = formFieldModel.value
    , error = formFieldModel.error
    , onInput = \value -> OnFormFieldInput { id = fieldId, value = value }
    , onBlur = OnFormFieldBlur { id = fieldId, validate = validate }
    }


formFieldErrors : Model -> List { id : String, validate : String -> FieldErrorState } -> Maybe Model
formFieldErrors model fields =
    fields
        |> List.foldl
            (\field modelWithErrors ->
                let
                    updatedField =
                        model.formFields
                            |> Dict.get field.id
                            |> Maybe.withDefault FormField.init
                            |> FormField.checkValidation field.validate

                    updatedModel =
                        Maybe.withDefault model modelWithErrors
                in
                if Maybe.isJust updatedField.error then
                    Just
                        { updatedModel
                            | formFields =
                                updatedModel.formFields
                                    |> Dict.insert field.id updatedField
                        }

                else
                    modelWithErrors
            )
            Nothing


sendSubmit : String -> Model -> Cmd Msg
sendSubmit submissionUrl model =
    Http.post
        { url = submissionUrl
        , body =
            Http.multipartBody
                (List.append
                    (model.formFields
                        |> Dict.toList
                        |> List.map FormField.submissionPart
                    )
                    [ Http.stringPart "html_type" "simple"
                    , Http.stringPart "locale" "en"
                    ]
                )
        , expect =
            Http.expectWhatever GotFormSubmissionResponse
        }


submitSuccessful : Model -> Model
submitSuccessful model =
    { model
      -- this resets all form field states
        | formFields = Dict.empty
        , submissionStatus = Submitted
    }


submitUnsuccessful : Model -> Model
submitUnsuccessful model =
    { model
        | submissionStatus = Error
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
