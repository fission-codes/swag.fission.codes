module View exposing (swagPage)

import Html exposing (..)
import Html.Attributes exposing (alt, for, height, href, id, src, style, title, type_, width)
import Pages exposing (images, pages)
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath
import Tailwind exposing (..)


swagPage : List (Html msg)
swagPage =
    [ div
        [ bg_gray_600
        , flex
        , flex_col
        , overflow_hidden
        , px_8
        , pb_16
        , md__pb_24
        , md__min_h_screen
        ]
        [ header []
        , image [ mt_6 ]
            { src = images.headerIllustration
            , alt = "Swag Stickers Illustration"
            , title = "Swag Stickers Illustration"
            }
        , image
            [ mt_6
            , w_48
            , mx_auto
            ]
            { src = images.swagLogoVertical
            , alt = "Swag Logo"
            , title = "Swag Logo"
            }
        , p
            [ mt_6
            , text_center
            , text_gray_300
            , font_body
            , text_md
            , leading_relaxed
            ]
            [ text "We've had fun creating some developer-centric memes, characters, and illustrations. Fill out your postal mail address below and we'll send you some stickers... plus we're going to sign you up for our Fission Product Updates newsletter :)" ]
        ]
    , div
        [ bg_white
        , flex
        , flex_col
        , overflow_hidden
        , px_8
        , pt_12
        , pb_16
        , md__pb_24
        ]
        [ form
            []
            (List.concat
                [ textInput []
                    { id = "first-name"
                    , title = "Your first name"
                    }
                , textInput []
                    { id = "last-name"
                    , title = "Your last name"
                    }
                , textInput []
                    { id = "company-name"
                    , title = "Company name"
                    }
                ]
            )
        ]
    ]


header : List (Attribute msg) -> Html msg
header attributes =
    div
        ([ border_b
         , style "border-bottom-color" "rgba(165, 167, 184, 0.5)"
         , container
         , flex
         , items_center
         , mx_auto
         , py_6
         ]
            ++ attributes
        )
        [ a
            [ href (PagePath.toString pages.index) ]
            [ fissionLogo ]
        , div
            [ ml_auto ]
            []
        ]



-- IMAGES


image : List (Attribute msg) -> { src : ImagePath.ImagePath pathKey, alt : String, title : String } -> Html msg
image attributes info =
    img
        ([ src (ImagePath.toString info.src)
         , alt info.alt
         , title info.title
         ]
            ++ attributes
            ++ (case ImagePath.dimensions info.src of
                    Just dimensions ->
                        [ width dimensions.width
                        , height dimensions.height
                        ]

                    Nothing ->
                        []
               )
        )
        []


imageSvg :
    List (Attribute msg)
    ->
        { src : ImagePath.ImagePath pathKey
        , alt : String
        , title : String
        , width : Int
        , height : Int
        }
    -> Html msg
imageSvg attributes info =
    img
        ([ src (ImagePath.toString info.src)
         , alt info.alt
         , title info.title
         , width info.width
         , height info.height
         ]
            ++ attributes
        )
        []


fissionLogo : Html msg
fissionLogo =
    imageSvg []
        { src = images.logoDarkColored
        , alt = "FISSION"
        , title = "FISSION"
        , width = 144
        , height = 30
        }



-- FORMS


textInput : List (Attribute msg) -> { id : String, title : String } -> List (Html msg)
textInput attributes info =
    [ label
        [ for info.id
        , font_body
        , text_md
        , text_gray_300
        ]
        [ text info.title ]
    , input
        [ id info.id
        , form_input
        , block
        , w_full
        , sm__text_sm
        , sm__leading_5
        ]
        []
    ]
