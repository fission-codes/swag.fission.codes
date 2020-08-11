module Main exposing (main)

import Color
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Json.Decode
import Metadata exposing (Metadata)
import MySitemap
import Page.Index
import Pages exposing (images, pages)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath exposing (PagePath)
import Pages.Platform
import Pages.StaticHttp as StaticHttp


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


main : Pages.Platform.Program Model Msg Metadata (Html Msg)
main =
    Pages.Platform.init
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ yamlDocument ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = Nothing
        , internals = Pages.internals
        }
        |> Pages.Platform.withFileGenerator generateFiles
        |> Pages.Platform.toProgram


generateFiles :
    List
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
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
            { siteUrl = canonicalSiteUrl }
            siteMetadata
            |> Ok
        ]


yamlDocument : { extension : String, metadata : Json.Decode.Decoder Metadata, body : String -> Result error (Html msg) }
yamlDocument =
    { extension = "yml"
    , metadata = Json.Decode.succeed Metadata.LandingPage
    , body =
        \body ->
            Ok (Html.pre [] [ Html.text body ])
    }


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


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
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Html Msg -> { title : String, body : Html Msg }
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
        , head = head page.frontmatter
        }


commonHeadTags : List (Head.Tag Pages.PathKey)
commonHeadTags =
    [ Head.sitemapLink "/sitemap.xml"
    ]



{- Read more about the metadata specs:

   <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
   <https://htmlhead.dev>
   <https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
   <https://ogp.me/>
-}


head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    commonHeadTags
        ++ (case metadata of
                Metadata.LandingPage ->
                    Seo.summaryLarge
                        { canonicalUrlOverride = Nothing
                        , siteName = siteTagline
                        , image =
                            { url = images.swagLogoVertical
                            , alt = "Fission Logo"
                            , dimensions = Just { width = 390, height = 183 }
                            , mimeType = Nothing
                            }
                        , description = siteTagline
                        , locale = Nothing
                        , title = "Get Fission Swag"
                        }
                        |> Seo.website
           )


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://swag.fission.codes"


siteTagline : String
siteTagline =
    "Order some swag from Fission"
