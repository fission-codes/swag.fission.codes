{-
   This module multiplexes between the various views according
   to the frontmatter.
-}


module View exposing (yamlDocument)

import Browser.Dom as Dom
import Color
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes exposing (action, autofocus, method, name, type_, value)
import Html.Extra as Html
import Json.Decode
import Metadata exposing (Frontmatter)
import MySitemap
import Page.Index
import Pages exposing (images, pages)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath exposing (PagePath)
import Pages.Platform
import Pages.StaticHttp as StaticHttp
import SwagForm.View
import Task
import Types exposing (..)


yamlDocument :
    { extension : String
    , metadata : Json.Decode.Decoder Frontmatter
    , body : String -> Result error (List (Html msg))
    }
yamlDocument =
    { extension = "yml"
    , metadata = Json.Decode.succeed Metadata.PageSwagForm
    , body =
        \body ->
            Ok <|
                SwagForm.View.swagPage
                    { form =
                        { attributes =
                            [ method "POST"
                            , action "https://5d04d668.sibforms.com/serve/MUIEAAsJdB5yz-qPvb7s1V1ZJkwH7-LtSYPVg5IsKwQ6GxB2ivvxOo_DZgeaAiAb7k0KfeW8zh2FmedZJL-1fYaQxFOB0cqtEkOA2WkHJC6qjv3_UblKbZ0tq0MeIU3v_JsBmfSs8-B0YbOfm294bCWV2Fu7Cum5t6DAT6Ga7j8SDuLc7DZHIDETwR94aeWQNfsCAnYZsB14A4fN"
                            ]
                        , content =
                            [ SwagForm.View.textInput
                                { attributes =
                                    [ -- Not sufficient. Loses focus on hydration :/ Need to Dom.focus on init
                                      autofocus True
                                    , name "FIRSTNAME"
                                    ]
                                , column = { start = SwagForm.View.First, end = SwagForm.View.Middle }
                                , id = "FIRSTNAME"
                                , title = "Your first name"
                                , subtext = Html.nothing
                                , error = Nothing
                                }
                            , SwagForm.View.textInput
                                { attributes =
                                    [ name "LASTNAME"
                                    ]
                                , column = { start = SwagForm.View.Middle, end = SwagForm.View.Last }
                                , id = "LASTNAME"
                                , title = "Your last name"
                                , subtext = Html.nothing
                                , error = Nothing
                                }
                            , SwagForm.View.textInput
                                { attributes =
                                    [ name "EMAIL"
                                    ]
                                , column = { start = SwagForm.View.First, end = SwagForm.View.Last }
                                , id = "EMAIL"
                                , title = "Email"
                                , subtext = Html.nothing
                                , error = Nothing
                                }
                            , SwagForm.View.textInput
                                { attributes =
                                    [ name "COMPANY"
                                    ]
                                , column = { start = SwagForm.View.First, end = SwagForm.View.Last }
                                , id = "COMPANY"
                                , title = "Company name"
                                , subtext = SwagForm.View.helpSubtext [] "Company or business name if this mailing address goes to an office"
                                , error = Nothing
                                }
                            , SwagForm.View.textInput
                                { attributes =
                                    [ name "ADDRESS_STREET"
                                    ]
                                , column = { start = SwagForm.View.First, end = SwagForm.View.Column5 }
                                , id = "ADDRESS_STREET"
                                , title = "Street Address"
                                , subtext = Html.nothing
                                , error = Nothing
                                }
                            , SwagForm.View.textInput
                                { attributes =
                                    [ name "ADDRESS_CITYSTATE"
                                    ]
                                , column = { start = SwagForm.View.Column5, end = SwagForm.View.Last }
                                , id = "ADDRESS_CITYSTATE"
                                , title = "City and State"
                                , subtext = SwagForm.View.helpSubtext [] "e.g. “Vancour, BC”, or “Nixa, Missouri”"
                                , error = Nothing
                                }
                            , SwagForm.View.textInput
                                { attributes =
                                    [ name "ADDRESS_POSTAL"
                                    ]
                                , column = { start = SwagForm.View.First, end = SwagForm.View.Column4 }
                                , id = "ADDRESS_POSTAL"
                                , title = "Postal / ZIP Code"
                                , subtext = Html.nothing
                                , error = Nothing
                                }
                            , SwagForm.View.textInput
                                { attributes =
                                    [ name "ADDRESS_COUNTRY"
                                    ]
                                , column = { start = SwagForm.View.Column4, end = SwagForm.View.Last }
                                , id = "ADDRESS_COUNTRY"
                                , title = "Country"
                                , subtext = Html.nothing
                                , error = Nothing
                                }
                            , Html.input [ type_ "hidden", name "locale", value "en" ] []
                            , Html.input [ type_ "hidden", name "html_type", value "simple" ] []
                            , SwagForm.View.callToActionButton [] "Get some stickers!"
                            ]
                        }
                    }
    }
