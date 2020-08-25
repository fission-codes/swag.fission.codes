{-
   This module multiplexes between the various views according
   to the frontmatter.
-}


module View exposing (yamlDocument)

import Browser.Dom as Dom
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes exposing (action, autofocus, method, name, type_, value)
import Html.Extra as Html
import Json.Decode
import Metadata exposing (Frontmatter)
import Pages.Manifest as Manifest
import Pages.StaticHttp as StaticHttp
import Result.Extra as Result
import State
import Types exposing (..)
import Validate
import View.SwagForm
import Yaml.Decode as Yaml
import Yaml.Extra as Yaml


yamlDocument :
    { extension : String
    , metadata : Json.Decode.Decoder Frontmatter
    , body : String -> Result String (Model -> Html Msg)
    }
yamlDocument =
    { extension = "yml"
    , metadata = Json.Decode.succeed Metadata.PageSwagForm
    , body =
        \body ->
            Yaml.fromString decodeData body
                |> Result.mapError Yaml.errorToString
                |> Result.map view
    }



-- DATA DEFINITIONS


type alias Data =
    { hero : HeroData
    , form : FormData
    }


type alias HeroData =
    { message : List (Html Msg)
    }


type alias FormData =
    { submissionUrl : String
    , callToAction : CallToActionData
    , autofocus : String
    , fields : List FieldData
    }


type alias FieldData =
    { id : String
    , title : String
    , column : { start : View.SwagForm.Alignment, end : View.SwagForm.Alignment }
    , subtext : Maybe String
    , validation : String -> FieldErrorState
    }


type alias CallToActionData =
    { waiting : String
    , submitting : String
    , error : String
    , submitted : String
    }



-- VIEWS


view : Data -> Model -> Html Msg
view data model =
    View.SwagForm.swagPage
        { hero = data.hero.message
        , form =
            -- The hidden inputs and method + action attributes make it possible to submit with javascript turned off
            { attributes =
                [ method "POST"
                , action data.form.submissionUrl
                ]
            , onSubmit =
                OnFormSubmit
                    { submissionUrl = data.form.submissionUrl
                    , fields =
                        data.form.fields
                            |> List.map
                                (\field -> { id = field.id, validate = field.validation })
                    }
            , content =
                List.concat
                    [ [ Html.input [ type_ "hidden", name "locale", value "en" ] []
                      , Html.input [ type_ "hidden", name "html_type", value "simple" ] []
                      ]
                    , List.map (viewField model data.form.autofocus) data.form.fields
                    , [ View.SwagForm.checkbox
                            { column = { start = View.SwagForm.First, end = View.SwagForm.Last }
                            , checked = model.checkbox
                            , onCheck = \checked -> OnFormFieldCheck { checked = checked }
                            , description = [] -- [ Html.Styled.text "Yes, I understand that I'm opting in to sign up for the Fission product email list. Send me stickers!" ]
                            }
                      , View.SwagForm.callToActionButton
                            { attributes = []
                            , message =
                                case model.submissionStatus of
                                    Waiting ->
                                        data.form.callToAction.waiting

                                    Submitting ->
                                        data.form.callToAction.submitting

                                    Error ->
                                        data.form.callToAction.error

                                    Submitted ->
                                        data.form.callToAction.submitted
                            }
                      ]
                    ]
            }
        }


viewField : Model -> String -> FieldData -> Html Msg
viewField model autofocusId { id, title, column, subtext, validation } =
    View.SwagForm.textInput
        { attributes =
            [ autofocus (id == autofocusId)
            , name id
            ]
        , column = column
        , id = id
        , title = title
        , subtext =
            case subtext of
                Just text ->
                    View.SwagForm.helpSubtext [] text

                Nothing ->
                    Html.nothing
        }
        (State.getFormFieldState model id validation)



-- DECODERS


decodeData : Yaml.Decoder Data
decodeData =
    Yaml.succeed Data
        |> Yaml.andMap (Yaml.field "hero" decodeHeroData)
        |> Yaml.andMap (Yaml.field "form" decodeFormData)


decodeHeroData : Yaml.Decoder HeroData
decodeHeroData =
    Yaml.succeed HeroData
        |> Yaml.andMap (Yaml.field "message" Yaml.markdownString)


decodeFormData : Yaml.Decoder FormData
decodeFormData =
    Yaml.succeed FormData
        |> Yaml.andMap (Yaml.field "submission_url" Yaml.string)
        |> Yaml.andMap (Yaml.field "call_to_action" callToActionData)
        |> Yaml.andMap (Yaml.field "autofocus" Yaml.string)
        |> Yaml.andMap (Yaml.field "fields" (Yaml.list decodeFieldData))


callToActionData : Yaml.Decoder CallToActionData
callToActionData =
    Yaml.succeed CallToActionData
        |> Yaml.andMap (Yaml.field "waiting" Yaml.string)
        |> Yaml.andMap (Yaml.field "submitting" Yaml.string)
        |> Yaml.andMap (Yaml.field "error" Yaml.string)
        |> Yaml.andMap (Yaml.field "submitted" Yaml.string)


decodeFieldData : Yaml.Decoder FieldData
decodeFieldData =
    -- Let's hope this style gets fixed in elm-format 1.0.0
    Yaml.field "id" Yaml.string
        |> Yaml.andThen
            (\id ->
                Yaml.field "title" Yaml.string
                    |> Yaml.andThen
                        (\title ->
                            decodeSubtext
                                |> Yaml.andThen
                                    (\subtext ->
                                        Yaml.field "column_start" decodeAlignment
                                            |> Yaml.andThen
                                                (\start ->
                                                    Yaml.field "column_end" decodeAlignment
                                                        |> Yaml.andThen
                                                            (\end ->
                                                                Yaml.field "validation" decodeValidation
                                                                    |> Yaml.andThen
                                                                        (\validation ->
                                                                            Yaml.succeed
                                                                                { id = id
                                                                                , title = title
                                                                                , column = { start = start, end = end }
                                                                                , subtext = subtext
                                                                                , validation = validation
                                                                                }
                                                                        )
                                                            )
                                                )
                                    )
                        )
            )


decodeSubtext : Yaml.Decoder (Maybe String)
decodeSubtext =
    Yaml.oneOf
        [ Yaml.field "subtext" (Yaml.map Just Yaml.string)
        , Yaml.succeed Nothing
        ]


decodeAlignment : Yaml.Decoder View.SwagForm.Alignment
decodeAlignment =
    let
        errorText =
            "This value must be a number between 1 and 8, or 'first', 'last' or 'middle'."
    in
    Yaml.oneOf
        [ Yaml.int
            |> Yaml.andThen
                (\col ->
                    case col of
                        1 ->
                            Yaml.succeed View.SwagForm.First

                        2 ->
                            Yaml.succeed View.SwagForm.Column2

                        3 ->
                            Yaml.succeed View.SwagForm.Column3

                        4 ->
                            Yaml.succeed View.SwagForm.Column4

                        5 ->
                            Yaml.succeed View.SwagForm.Column5

                        6 ->
                            Yaml.succeed View.SwagForm.Column6

                        7 ->
                            Yaml.succeed View.SwagForm.Column7

                        8 ->
                            Yaml.succeed View.SwagForm.Last

                        _ ->
                            Yaml.fail errorText
                )
        , Yaml.string
            |> Yaml.andThen
                (\str ->
                    case str of
                        "first" ->
                            Yaml.succeed View.SwagForm.First

                        "middle" ->
                            Yaml.succeed View.SwagForm.Middle

                        "last" ->
                            Yaml.succeed View.SwagForm.Last

                        _ ->
                            Yaml.fail errorText
                )
        , Yaml.fail errorText
        ]


decodeValidation : Yaml.Decoder (String -> FieldErrorState)
decodeValidation =
    Yaml.list decodeValidationItem |> Yaml.map Validate.all


decodeValidationItem : Yaml.Decoder (String -> FieldErrorState)
decodeValidationItem =
    let
        errorText =
            "Invalid validation test. Only 'email' and 'filled' are available at the moment."
    in
    Yaml.oneOf
        [ decodeValidationFilled
        , Yaml.string
            |> Yaml.andThen
                (\str ->
                    case str of
                        "email" ->
                            Yaml.succeed Validate.email

                        _ ->
                            Yaml.fail errorText
                )
        , Yaml.fail errorText
        ]


decodeValidationFilled : Yaml.Decoder (String -> FieldErrorState)
decodeValidationFilled =
    Yaml.field "filled" (Yaml.field "description" Yaml.string)
        |> Yaml.map Validate.filled
