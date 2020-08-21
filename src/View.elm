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
import State
import Types exposing (..)
import Validate
import View.SwagForm
import Yaml.Decode as Yaml


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
            -- TODO: Parse forms out of yaml
            let
                submissionUrl =
                    "https://5d04d668.sibforms.com/serve/MUIEAE1F1kMPvB_leq-apIe4FvZagp1EgtljkIf1EQ-BDERfIN98YQhjbWjdTi-2eKy9IPUovj6kMItaZTVAodVJlyoTX8BPhS0LjzVaP6XSMnXu6Xey9Ez4VGzSV62IuIsnDS55QQiwcA7oRtB8aPU0EQ3AJG0dyICWT82taqDKeisgU1jdlnvk2Fj5oRFUiwsqYVIsHCL5ASEN"
            in
            Ok <|
                \model ->
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
                                    , List.map
                                        (\{ id, title, column, subtext, validation } ->
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
                                        )
                                        [ { column = { start = View.SwagForm.First, end = View.SwagForm.Middle }
                                          , id = "FIRSTNAME"
                                          , title = "Your first name"
                                          , subtext = Nothing
                                          , validation = Validate.filled "Please fill in this field"
                                          }
                                        , { id = "LASTNAME"
                                          , title = "Your last name"
                                          , column = { start = View.SwagForm.Middle, end = View.SwagForm.Last }
                                          , subtext = Nothing
                                          , validation =
                                                Validate.filled "Please fill in this field"
                                          }
                                        , { id = "EMAIL"
                                          , title = "Email"
                                          , column = { start = View.SwagForm.First, end = View.SwagForm.Last }
                                          , subtext = Nothing
                                          , validation =
                                                Validate.email
                                          }
                                        , { id = "COMPANY"
                                          , title = "Company name"
                                          , column = { start = View.SwagForm.First, end = View.SwagForm.Last }
                                          , subtext = Just "Company or business name if this mailing address goes to an office"
                                          , validation = Validate.all []
                                          }
                                        , { id = "ADDRESS_STREET"
                                          , title = "Street Address"
                                          , column = { start = View.SwagForm.First, end = View.SwagForm.Column5 }
                                          , subtext = Nothing
                                          , validation =
                                                Validate.filled "Please fill in this field"
                                          }
                                        , { id = "ADDRESS_CITYSTATE"
                                          , title = "City and State"
                                          , column = { start = View.SwagForm.Column5, end = View.SwagForm.Last }
                                          , subtext = Just "e.g. “Vancour, BC”, or “Nixa, Missouri”"
                                          , validation =
                                                Validate.filled "Please fill in this field"
                                          }
                                        , { id = "ADDRESS_POSTAL"
                                          , title = "Postal / ZIP Code"
                                          , column = { start = View.SwagForm.First, end = View.SwagForm.Column4 }
                                          , subtext = Nothing
                                          , validation =
                                                Validate.filled "Please fill in this field"
                                          }
                                        , { id = "ADDRESS_COUNTRY"
                                          , title = "Country"
                                          , column = { start = View.SwagForm.Column4, end = View.SwagForm.Last }
                                          , subtext = Nothing
                                          , validation =
                                                Validate.filled "Please fill in this field"
                                          }
                                        ]
                                    , [ View.SwagForm.callToActionButton
                                            { attributes = []
                                            , message = "Get some stickers!"
                                            }
                                      ]
                                    ]
                            }
                        }
    }
