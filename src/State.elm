module State exposing
    ( getFormFieldState
    , init
    , subscriptions
    , update
    )

import Browser.Dom as Dom
import Browser.Events
import Dict exposing (Dict)
import FormField
import Http
import Maybe.Extra as Maybe
import Task
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { formFields = Dict.empty
      , blurToDebounce = Nothing
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
            ( updateFormField model id (FormField.onInput value)
            , Cmd.none
            )

        OnFormFieldBlur info ->
            ( { model | blurToDebounce = Just info }
            , Cmd.none
            )

        OnDebouncedFieldBlur { id, validate } ->
            ( updateFormField model id (FormField.checkValidation validate)
                |> clearDebounce
            , Cmd.none
            )

        OnFormSubmit { submissionUrl, fields } ->
            case formFieldErrors model fields of
                Nothing ->
                    ( model
                    , Http.post
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
                    )

                Just modelWithErrors ->
                    ( modelWithErrors
                    , Cmd.none
                    )

        GotFormSubmissionResponse response ->
            -- TODO handle errors
            -- TODO handle success: show 'thank you'
            ( { model
                -- this resets all form field states
                | formFields = Dict.empty
              }
            , Cmd.none
            )

        FocusedForm ->
            ( model, Cmd.none )


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


clearDebounce : Model -> Model
clearDebounce model =
    { model | blurToDebounce = Nothing }


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


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.blurToDebounce of
        Just info ->
            Browser.Events.onAnimationFrame (\_ -> OnDebouncedFieldBlur info)

        Nothing ->
            Sub.none
