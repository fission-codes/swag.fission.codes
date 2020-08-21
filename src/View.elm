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
import Types exposing (..)
import View.SwagForm


yamlDocument :
    { extension : String
    , metadata : Json.Decode.Decoder Frontmatter
    , body : String -> Result error (Html Msg)
    }
yamlDocument =
    { extension = "yml"
    , metadata = Json.Decode.succeed Metadata.PageSwagForm
    , body =
        \body ->
            -- TODO: Parse forms out of yaml
            Ok <|
                View.SwagForm.swagPage
                    { form =
                        { attributes = []

                        -- [ method "POST"
                        -- , action "https://5d04d668.sibforms.com/serve/MUIEAAsJdB5yz-qPvb7s1V1ZJkwH7-LtSYPVg5IsKwQ6GxB2ivvxOo_DZgeaAiAb7k0KfeW8zh2FmedZJL-1fYaQxFOB0cqtEkOA2WkHJC6qjv3_UblKbZ0tq0MeIU3v_JsBmfSs8-B0YbOfm294bCWV2Fu7Cum5t6DAT6Ga7j8SDuLc7DZHIDETwR94aeWQNfsCAnYZsB14A4fN"
                        -- ]
                        , onSubmit = OnFormSubmit
                        , content =
                            [ View.SwagForm.textInput
                                { attributes =
                                    [ -- Not sufficient. Loses focus on hydration :/ Need to Dom.focus on init
                                      autofocus True
                                    , name "FIRSTNAME"
                                    ]
                                , column = { start = View.SwagForm.First, end = View.SwagForm.Middle }
                                , id = "FIRSTNAME"
                                , title = "Your first name"
                                , subtext = Html.nothing
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "FIRSTNAME", value = value }
                                }
                            , View.SwagForm.textInput
                                { attributes =
                                    [ name "LASTNAME"
                                    ]
                                , column = { start = View.SwagForm.Middle, end = View.SwagForm.Last }
                                , id = "LASTNAME"
                                , title = "Your last name"
                                , subtext = Html.nothing
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "LASTNAME", value = value }
                                }
                            , View.SwagForm.textInput
                                { attributes =
                                    [ name "EMAIL"
                                    ]
                                , column = { start = View.SwagForm.First, end = View.SwagForm.Last }
                                , id = "EMAIL"
                                , title = "Email"
                                , subtext = Html.nothing
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "EMAIL", value = value }
                                }
                            , View.SwagForm.textInput
                                { attributes =
                                    [ name "COMPANY"
                                    ]
                                , column = { start = View.SwagForm.First, end = View.SwagForm.Last }
                                , id = "COMPANY"
                                , title = "Company name"
                                , subtext = View.SwagForm.helpSubtext [] "Company or business name if this mailing address goes to an office"
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "COMPANY", value = value }
                                }
                            , View.SwagForm.textInput
                                { attributes =
                                    [ name "ADDRESS_STREET"
                                    ]
                                , column = { start = View.SwagForm.First, end = View.SwagForm.Column5 }
                                , id = "ADDRESS_STREET"
                                , title = "Street Address"
                                , subtext = Html.nothing
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "ADDRESS_STREET", value = value }
                                }
                            , View.SwagForm.textInput
                                { attributes =
                                    [ name "ADDRESS_CITYSTATE"
                                    ]
                                , column = { start = View.SwagForm.Column5, end = View.SwagForm.Last }
                                , id = "ADDRESS_CITYSTATE"
                                , title = "City and State"
                                , subtext = View.SwagForm.helpSubtext [] "e.g. “Vancour, BC”, or “Nixa, Missouri”"
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "ADDRESS_CITYSTATE", value = value }
                                }
                            , View.SwagForm.textInput
                                { attributes =
                                    [ name "ADDRESS_POSTAL"
                                    ]
                                , column = { start = View.SwagForm.First, end = View.SwagForm.Column4 }
                                , id = "ADDRESS_POSTAL"
                                , title = "Postal / ZIP Code"
                                , subtext = Html.nothing
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "ADDRESS_POSTAL", value = value }
                                }
                            , View.SwagForm.textInput
                                { attributes =
                                    [ name "ADDRESS_COUNTRY"
                                    ]
                                , column = { start = View.SwagForm.Column4, end = View.SwagForm.Last }
                                , id = "ADDRESS_COUNTRY"
                                , title = "Country"
                                , subtext = Html.nothing
                                }
                                { value = ""
                                , error = Nothing
                                , onInput = \value -> OnFormFieldInput { id = "ADDRESS_COUNTRY", value = value }
                                }
                            , Html.input [ type_ "hidden", name "locale", value "en" ] []
                            , Html.input [ type_ "hidden", name "html_type", value "simple" ] []
                            , View.SwagForm.callToActionButton
                                { attributes = []
                                , message = "Get some stickers!"
                                }
                            ]
                        }
                    }
    }
