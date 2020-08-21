module View.SwagForm exposing (Alignment(..), callToActionButton, helpSubtext, swagPage, textInput)

import Html exposing (..)
import Html.Attributes exposing (action, alt, attribute, autofocus, class, for, height, href, id, method, name, placeholder, required, src, style, title, type_, value, width)
import Html.Extra exposing (..)
import Pages exposing (images, pages)
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath
import Svg
import Svg.Attributes as SvgA


swagPage :
    { form :
        { attributes : List (Attribute msg)
        , content : List (Html msg)
        }
    }
    -> List (Html msg)
swagPage element =
    [ hero
    , formSection element.form
    , footer [] []
    ]



-- HEADER


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



-- FOOTER


footer : List (Attribute msg) -> List (Html msg) -> Html msg
footer attributes content =
    div
        [ class "bg-white px-6" ]
        [ div
            [ id "footer"
            , class "border-t border-gray-500 container flex items-center mx-auto py-8"
            ]
            [ fissionBadge
            , div
                [ class "block w-full text-center text-gray-300 ml-4 sm:text-left"
                ]
                [ text "Fission Internet Software" ]
            , div [ class "ml-auto" ] content
            ]
        ]


fissionBadge : Html msg
fissionBadge =
    img
        [ src (ImagePath.toString images.badgeSolidFaded)
        , title "FISSION"
        , width 30
        ]
        []


footerLink : String -> String -> Html msg
footerLink label url =
    a
        [ href url
        , title (label ++ " Link")
        , class "ml-4 text-gray-300 underline"
        ]
        [ text label ]



-- HERO


hero : Html msg
hero =
    div
        [ class "bg-gray-600 flex flex-col overflow-hidden px-8 pb-16"
        , class "lg:pb-24"
        ]
        [ header []
        , div
            [ class "flex flex-col container mx-auto"
            , class "lg:grid lg:grid-cols-11 lg:gap-3 lg:mt-10"
            ]
            [ image
                [ class "mt-6"
                , class "lg:col-start-1 lg:col-end-7 lg:row-span-2"
                ]
                { src = images.headerIllustration
                , alt = "Swag Stickers Illustration"
                , title = "Swag Stickers Illustration"
                }
            , image
                [ class "mt-6 w-48 mx-auto"
                , class "lg:col-start-7 lg:col-end-10 lg:self-end lg:ml-0 lg:w-full"
                ]
                { src = images.swagLogoVertical
                , alt = "Swag Logo"
                , title = "Swag Logo"
                }
            , p
                [ class "mt-6 text-center text-gray-300 font-body text-lg leading-relaxed"
                , class "lg:col-start-7 lg:col-end-11 lg:text-left lg:text-lg"
                ]
                [ text "We've had fun creating some developer-centric memes, characters, and illustrations. Fill out your postal mail address below and we'll send you some stickers... plus we're going to sign you up for our Fission Product Updates newsletter :)" ]
            ]
        ]



-- FORM SECTION


formSection :
    { attributes : List (Attribute msg)
    , content : List (Html msg)
    }
    -> Html msg
formSection element =
    div
        [ class "bg-white flex flex-col overflow-hidden px-8 py-10"
        , class "lg:py-24"
        ]
        [ form
            ([ class "flex flex-col container mx-auto"
             , class "lg:grid lg:grid-cols-22 lg:gap-3"
             ]
                ++ element.attributes
            )
            element.content
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


type Alignment
    = First
    | Column2
    | Column3
    | Column4
    | Column5
    | Column6
    | Column7
    | Last
    | Middle


type StartOrEnd
    = Start
    | End


alignmentToGridColumn : Alignment -> Int
alignmentToGridColumn alignment =
    let
        -- The design is 11-column based, with 2 columns padding
        -- (resulting in the 7 columns)
        columnPadding =
            2

        -- converts from a 11-based grid to a 22-based grid
        convert11ColumnTo22Column n =
            -- start indices work differently,
            -- they start at "1".
            -- column 1 in 11-based should be the same in 22-based
            (n - 1) * 2 + 1

        computeFromColumn n =
            columnPadding
                + n
                |> convert11ColumnTo22Column
    in
    case alignment of
        First ->
            computeFromColumn 1

        Column2 ->
            computeFromColumn 2

        Column3 ->
            computeFromColumn 3

        Column4 ->
            computeFromColumn 4

        Column5 ->
            computeFromColumn 5

        Column6 ->
            computeFromColumn 6

        Column7 ->
            computeFromColumn 7

        Last ->
            computeFromColumn 8

        Middle ->
            12


gridColumnStyle : { start : Alignment, end : Alignment } -> Attribute msg
gridColumnStyle { start, end } =
    -- Using string manipulation with tailwind class names wouldn't play well with purging
    [ start, end ]
        |> List.map (alignmentToGridColumn >> String.fromInt)
        |> String.join " / "
        |> style "grid-column"


textInput :
    { column : { start : Alignment, end : Alignment }
    , attributes : List (Attribute msg)
    , id : String
    , title : String
    , subtext : Html msg
    , error : Maybe { id : String, description : String }
    }
    -> Html msg
textInput info =
    let
        warningIcon =
            Svg.svg [ attribute "class" "h-5 w-5 text-red", SvgA.fill "currentColor", SvgA.viewBox "0 0 20 20" ]
                [ Svg.path [ attribute "clip-rule" "evenodd", SvgA.d "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z", attribute "fill-rule" "evenodd" ]
                    []
                ]

        { errorInputAttributes, errorIcon, errorSubtext } =
            case info.error of
                Just error ->
                    { errorInputAttributes =
                        [ attribute "aria-describedby" error.id
                        , attribute "aria-invalid" "true"
                        , class "pr-10 border-red text-red placeholder-red focus:border-red focus:shadow-outline-red"
                        ]
                    , errorIcon =
                        div [ class "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none" ]
                            [ warningIcon ]
                    , errorSubtext =
                        p [ class "mt-2 text-mds text-red", id error.id ]
                            [ text error.description ]
                    }

                Nothing ->
                    { errorInputAttributes = []
                    , errorIcon = nothing
                    , errorSubtext = nothing
                    }
    in
    div [ gridColumnStyle info.column ]
        [ label
            [ for info.id
            , class "block font-body text-md text-gray-300 mt-2"
            ]
            [ text info.title ]
        , div [ class "mt-2 relative rounded-md shadow-sm" ]
            [ input
                (List.concat
                    [ [ id info.id
                      , class "form-input block w-full text-xl text-gray-200 sm:text-lg sm:leading-5"
                      ]
                    , info.attributes
                    , errorInputAttributes
                    ]
                )
                []
            , errorIcon
            ]
        , errorSubtext
        , info.subtext
        ]


helpSubtext : List (Attribute msg) -> String -> Html msg
helpSubtext attributes content =
    p
        (class "mt-2 text-mds text-gray-300"
            :: attributes
        )
        [ text content ]


callToActionButton : List (Attribute msg) -> String -> Html msg
callToActionButton attributes content =
    div
        [ class "mt-10 flex flex-col"
        , gridColumnStyle { start = First, end = Last }
        ]
        [ input
            (class "mx-auto px-4 py-1 rounded-lg"
                :: class "appearance-none bg-gray-200 cursor-pointer"
                :: class "text-lg font-display font-medium leading-relaxed text-gray-600"
                :: class "hover:bg-gray-300 focus:bg-gray-300 active:bg-gray-300"
                :: type_ "submit"
                :: value content
                :: attributes
            )
            []
        ]
