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
import View.SwagForm


yamlDocument :
    { extension : String
    , metadata : Json.Decode.Decoder Frontmatter
    , body : String -> Result error (Model -> Html Msg)
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
                                [ Html.input [ type_ "hidden", name "locale", value "en" ] []
                                , Html.input [ type_ "hidden", name "html_type", value "simple" ] []
                                , View.SwagForm.textInput
                                    { attributes =
                                        [ autofocus True
                                        , name "FIRSTNAME"
                                        ]
                                    , column = { start = View.SwagForm.First, end = View.SwagForm.Middle }
                                    , id = "FIRSTNAME"
                                    , title = "Your first name"
                                    , subtext = Html.nothing
                                    }
                                    (State.getFormFieldState model "FIRSTNAME")
                                , View.SwagForm.textInput
                                    { attributes = [ name "LASTNAME" ]
                                    , column = { start = View.SwagForm.Middle, end = View.SwagForm.Last }
                                    , id = "LASTNAME"
                                    , title = "Your last name"
                                    , subtext = Html.nothing
                                    }
                                    (State.getFormFieldState model "LASTNAME")
                                , View.SwagForm.textInput
                                    { attributes = [ name "EMAIL" ]
                                    , column = { start = View.SwagForm.First, end = View.SwagForm.Last }
                                    , id = "EMAIL"
                                    , title = "Email"
                                    , subtext = Html.nothing
                                    }
                                    (State.getFormFieldState model "EMAIL")
                                , View.SwagForm.textInput
                                    { attributes = [ name "COMPANY" ]
                                    , column = { start = View.SwagForm.First, end = View.SwagForm.Last }
                                    , id = "COMPANY"
                                    , title = "Company name"
                                    , subtext = View.SwagForm.helpSubtext [] "Company or business name if this mailing address goes to an office"
                                    }
                                    (State.getFormFieldState model "COMPANY")
                                , View.SwagForm.textInput
                                    { attributes = [ name "ADDRESS_STREET" ]
                                    , column = { start = View.SwagForm.First, end = View.SwagForm.Column5 }
                                    , id = "ADDRESS_STREET"
                                    , title = "Street Address"
                                    , subtext = Html.nothing
                                    }
                                    (State.getFormFieldState model "ADDRESS_STREET")
                                , View.SwagForm.textInput
                                    { attributes = [ name "ADDRESS_CITYSTATE" ]
                                    , column = { start = View.SwagForm.Column5, end = View.SwagForm.Last }
                                    , id = "ADDRESS_CITYSTATE"
                                    , title = "City and State"
                                    , subtext = View.SwagForm.helpSubtext [] "e.g. “Vancour, BC”, or “Nixa, Missouri”"
                                    }
                                    (State.getFormFieldState model "ADDRESS_CITYSTATE")
                                , View.SwagForm.textInput
                                    { attributes = [ name "ADDRESS_POSTAL" ]
                                    , column = { start = View.SwagForm.First, end = View.SwagForm.Column4 }
                                    , id = "ADDRESS_POSTAL"
                                    , title = "Postal / ZIP Code"
                                    , subtext = Html.nothing
                                    }
                                    (State.getFormFieldState model "ADDRESS_POSTAL")
                                , View.SwagForm.textInput
                                    { attributes = [ name "ADDRESS_COUNTRY" ]
                                    , column = { start = View.SwagForm.Column4, end = View.SwagForm.Last }
                                    , id = "ADDRESS_COUNTRY"
                                    , title = "Country"
                                    , subtext = Html.nothing
                                    }
                                    (State.getFormFieldState model "ADDRESS_COUNTRY")
                                , View.SwagForm.callToActionButton
                                    { attributes = []
                                    , message = "Get some stickers!"
                                    }
                                ]
                            }
                        }
    }
