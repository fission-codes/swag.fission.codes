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
                |> Result.map
                    (\data model ->
                        let
                            submissionUrl =
                                "https://5d04d668.sibforms.com/serve/MUIEAE1F1kMPvB_leq-apIe4FvZagp1EgtljkIf1EQ-BDERfIN98YQhjbWjdTi-2eKy9IPUovj6kMItaZTVAodVJlyoTX8BPhS0LjzVaP6XSMnXu6Xey9Ez4VGzSV62IuIsnDS55QQiwcA7oRtB8aPU0EQ3AJG0dyICWT82taqDKeisgU1jdlnvk2Fj5oRFUiwsqYVIsHCL5ASEN"
                        in
                        View.SwagForm.swagPage
                            { form =
                                -- The hidden inputs and method + action attributes make it possible to submit with javascript turned off
                                { attributes =
                                    [ method "POST"
                                    , action submissionUrl
                                    ]
                                , onSubmit = OnFormSubmit { submissionUrl = submissionUrl }
                                , content =
                                    List.concat
                                        [ [ Html.input [ type_ "hidden", name "locale", value "en" ] []
                                          , Html.input [ type_ "hidden", name "html_type", value "simple" ] []
                                          ]
                                        , List.map (viewField model) data
                                        , [ View.SwagForm.callToActionButton
                                                { attributes = []
                                                , message = "Get some stickers!"
                                                }
                                          ]
                                        ]
                                }
                            }
                    )
    }


type alias FieldData =
    { id : String
    , title : String
    , column : { start : View.SwagForm.Alignment, end : View.SwagForm.Alignment }
    , subtext : Maybe String
    , validation : String -> FieldErrorState
    }


type alias Data =
    List FieldData


decodeData : Yaml.Decoder Data
decodeData =
    Yaml.field "form" (Yaml.field "fields" (Yaml.list decodeFieldData))


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
                                                                Yaml.succeed
                                                                    { id = id
                                                                    , title = title
                                                                    , column = { start = start, end = end }
                                                                    , subtext = subtext
                                                                    , validation = Validate.all []
                                                                    }
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


viewField : Model -> FieldData -> Html Msg
viewField model { id, title, column, subtext, validation } =
    View.SwagForm.textInput
        { attributes =
            [ autofocus (id == "FIRSTNAME")
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
