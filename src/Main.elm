module Main exposing (main)

import Browser.Dom as Dom
import Color
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Metadata exposing (Frontmatter)
import MySitemap
import Pages exposing (images, pages)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath exposing (PagePath)
import Pages.Platform
import Pages.StaticHttp as StaticHttp
import State
import Types exposing (..)
import View


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.utilities ]
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
        { init = \_ -> State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = view
        , documents = [ View.yamlDocument ]
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
                { title = Metadata.pageTitle page.frontmatter
                , body =
                    Html.div [] viewForPage
                }
        , head =
            List.concat
                [ commonHeadTags
                , Metadata.head page.frontmatter
                ]
        }


commonHeadTags : List (Head.Tag Pages.PathKey)
commonHeadTags =
    [ Head.sitemapLink ("/" ++ String.join "/" MySitemap.path)
    ]
