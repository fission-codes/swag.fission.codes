module Metadata exposing
    ( Frontmatter(..)
    , canonicalSiteUrl
    , decoder
    , head
    , pageTitle
    )

import Head
import Head.Seo as Seo
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import List.Extra
import Pages
import Pages.ImagePath as ImagePath
import Types exposing (..)



-- FRONTMATTER


type Frontmatter
    = PageSwagForm MetaInfo


type alias MetaInfo =
    { title : String
    , siteName : String
    , description : String
    , image : ImagePath
    , imageAlt : String
    , summaryType : SummaryType
    }


type SummaryType
    = SummaryLarge
    | SummaryNormal


decoder : Decoder Frontmatter
decoder =
    Decode.map PageSwagForm decoderMetaInfo


decoderMetaInfo : Decoder MetaInfo
decoderMetaInfo =
    Decode.succeed MetaInfo
        |> Decode.andMap (Decode.field "title" Decode.string)
        |> Decode.andMap (Decode.field "site_name" Decode.string)
        |> Decode.andMap (Decode.field "description" Decode.string)
        |> Decode.andMap (Decode.field "image" imageDecoder)
        |> Decode.andMap (Decode.field "image_alt" Decode.string)
        |> Decode.andMap (Decode.field "summary_type" decodeSummaryType)


decodeSummaryType : Decoder SummaryType
decodeSummaryType =
    Decode.string
        |> Decode.andThen
            (\summary ->
                case summary of
                    "normal" ->
                        Decode.succeed SummaryNormal

                    "large" ->
                        Decode.succeed SummaryLarge

                    other ->
                        Decode.fail ("Unrecognized summary_type: " ++ other ++ ".")
            )


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


pageTitle : Frontmatter -> String
pageTitle (PageSwagForm { title }) =
    title



-- HEAD METADATA


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://swag.fission.codes"



{- Read more about the metadata specs:

   <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
   <https://htmlhead.dev>
   <https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
   <https://ogp.me/>
-}


head : Frontmatter -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        PageSwagForm metaInfo ->
            let
                summary =
                    case metaInfo.summaryType of
                        SummaryNormal ->
                            Seo.summary

                        SummaryLarge ->
                            Seo.summaryLarge
            in
            summary
                { canonicalUrlOverride = Nothing
                , siteName = metaInfo.siteName
                , title = metaInfo.title
                , description = metaInfo.description
                , image =
                    { url = metaInfo.image
                    , alt = metaInfo.imageAlt
                    , dimensions = ImagePath.dimensions metaInfo.image
                    , mimeType = Nothing
                    }
                , locale = Nothing
                }
                |> Seo.website
