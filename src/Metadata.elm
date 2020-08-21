module Metadata exposing
    ( Frontmatter(..)
    , canonicalSiteUrl
    , decoder
    , head
    )

import Head
import Head.Seo as Seo
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages exposing (images)
import Pages.ImagePath as ImagePath
import Types exposing (..)



-- FRONTMATTER


type Frontmatter
    = LandingPage


decoder : Decoder Frontmatter
decoder =
    Decode.succeed LandingPage


imageDecoder : Decoder ImagePath
imageDecoder =
    Decode.string
        |> Decode.andThen
            (\imageAssetPath ->
                case findMatchingImage imageAssetPath of
                    Nothing ->
                        "I couldn't find that. Available images are:\n"
                            :: List.map
                                ((\x -> "\t\"" ++ x ++ "\"") << ImagePath.toString)
                                Pages.allImages
                            |> String.join "\n"
                            |> Decode.fail

                    Just imagePath ->
                        Decode.succeed imagePath
            )


findMatchingImage : String -> Maybe ImagePath
findMatchingImage imageAssetPath =
    Pages.allImages
        |> List.Extra.find
            (\image ->
                ImagePath.toString image
                    == imageAssetPath
            )



-- HEAD METADATA


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://swag.fission.codes"


siteTagline : String
siteTagline =
    "Order swag from Fission"



{- Read more about the metadata specs:

   <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
   <https://htmlhead.dev>
   <https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
   <https://ogp.me/>
-}


head : Frontmatter -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        LandingPage ->
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
