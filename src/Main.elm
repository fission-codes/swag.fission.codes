module Main exposing (main)

import Browser.Dom as Dom
import Color
import Head
import Head.Seo as Seo
import Html exposing (Html)
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


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "Order some swag from Fission"
    , iarcRatingId = Nothing
    , name = "swag.fission.codes"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just "swag.fission.codes"
    , sourceIcon = images.logoIconColoredBordered
    }


main : Pages.Platform.Program Model Msg Frontmatter (List (Html Msg))
main =
    Pages.Platform.init
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ yamlDocument ]
        , manifest = manifest
        , canonicalSiteUrl = Metadata.canonicalSiteUrl
        , onPageChange = Nothing
        , internals = Pages.internals
        }
        |> Pages.Platform.withFileGenerator generateFiles
        |> Pages.Platform.toProgram


generateFiles :
    List
        { path : PagePath Pages.PathKey
        , frontmatter : Frontmatter
        , body : String
        }
    ->
        StaticHttp.Request
            (List
                (Result String
                    { path : List String
                    , content : String
                    }
                )
            )
generateFiles siteMetadata =
    StaticHttp.succeed
        [ MySitemap.build
            { siteUrl = Metadata.canonicalSiteUrl }
            siteMetadata
            |> Ok
        ]


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
            Ok SwagForm.View.swagPage
    }


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model
    , Dom.focus "first-name" |> Task.attempt (\_ -> ())
    )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view :
    List ( PagePath Pages.PathKey, Frontmatter )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Frontmatter
        }
    ->
        StaticHttp.Request
            { view : Model -> List (Html Msg) -> { title : String, body : Html Msg }
            , head : List (Head.Tag Pages.PathKey)
            }
view siteMetadata page =
    StaticHttp.succeed
        { view =
            \model viewForPage ->
                let
                    rendered =
                        Page.Index.view page.frontmatter viewForPage
                in
                { title = rendered.title
                , body = Html.div [] rendered.body
                }
        , head =
            List.concat
                [ commonHeadTags
                , Metadata.head page.frontmatter
                ]
        }


commonHeadTags : List (Head.Tag Pages.PathKey)
commonHeadTags =
    [ Head.sitemapLink "/sitemap.xml"
    ]
