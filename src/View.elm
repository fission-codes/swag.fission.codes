module View exposing (swagPage)

import Html exposing (..)
import Html.Attributes exposing (alt, class, for, height, href, id, src, style, title, type_, value, width)
import Pages exposing (images, pages)
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath


swagPage : List (Html msg)
swagPage =
    [ div
        [ class "bg-gray-600 flex flex-col overflow-hidden px-8 pb-16 md:pb-24 md:min-h-screen"
        ]
        [ header []
        , image [ class "mt-6" ]
            { src = images.headerIllustration
            , alt = "Swag Stickers Illustration"
            , title = "Swag Stickers Illustration"
            }
        , image
            [ class "mt-6 w-48 mx-auto"
            ]
            { src = images.swagLogoVertical
            , alt = "Swag Logo"
            , title = "Swag Logo"
            }
        , p
            [ class "mt-6 text-center text-gray-300 font-body text-md leading-relaxed"
            ]
            [ text "We've had fun creating some developer-centric memes, characters, and illustrations. Fill out your postal mail address below and we'll send you some stickers... plus we're going to sign you up for our Fission Product Updates newsletter :)" ]
        ]
    , div
        [ class "bg-white flex flex-col overflow-hidden px-8 pt-12 pb-16 md:pb-24"
        ]
        [ form
            []
            (List.concat
                [ textInput []
                    { id = "first-name"
                    , title = "Your first name"
                    , subtext = []
                    }
                , textInput []
                    { id = "last-name"
                    , title = "Your last name"
                    , subtext = []
                    }
                , textInput []
                    { id = "company-name"
                    , title = "Company name"
                    , subtext = [ subtextHelp [] "Company or business name if this mailing address goes to an office" ]
                    }
                , textInput []
                    { id = "street-address"
                    , title = "Street Address"
                    , subtext = []
                    }
                , textInput []
                    { id = "city-and-state"
                    , title = "City and State"
                    , subtext = [ subtextHelp [] "e.g. “Vancour, BC”, or “Nixa, Missouri”" ]
                    }
                , textInput []
                    { id = "postal-code"
                    , title = "Postal / ZIP Code"
                    , subtext = []
                    }
                , textInput []
                    { id = "country"
                    , title = "Country"
                    , subtext = []
                    }
                , [ callToActionButton [] "Get some stickers!" ]
                ]
            )
        ]
    ]


header : List (Attribute msg) -> Html msg
header attributes =
    div
        ([ style "border-bottom-color" "rgba(165, 167, 184, 0.5)"
         , class "border-b container flex items-center mx-auto py-6"
         ]
            ++ attributes
        )
        [ a
            [ href (PagePath.toString pages.index) ]
            [ fissionLogo ]
        , div
            [ class "ml-auto" ]
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


textInput :
    List (Attribute msg)
    ->
        { id : String
        , title : String
        , subtext : List (Html msg)
        }
    -> List (Html msg)
textInput attributes info =
    [ label
        [ for info.id
        , class "block font-body text-md text-gray-300 mt-2"
        ]
        [ text info.title ]
    , div [ class "mt-2 relative rounded-md shadow-sm" ]
        (input
            [ id info.id
            , class "form-input block w-full sm:text-sm sm:leading-5"
            ]
            []
            :: info.subtext
        )
    ]


subtextHelp : List (Attribute msg) -> String -> Html msg
subtextHelp attributes content =
    p
        (class "mt-2 text-mds text-gray-300"
            :: attributes
        )
        [ text content ]


callToActionButton : List (Attribute msg) -> String -> Html msg
callToActionButton attributes content =
    div [ class "my-10 flex flex-col" ]
        [ input
            (class "mx-auto px-4 py-1 appearance-none bg-gray-200 cursor-pointer text-lg font-display font-medium leading-relaxed rounded-lg text-gray-600"
                :: type_ "submit"
                :: value content
                :: attributes
            )
            []
        ]
