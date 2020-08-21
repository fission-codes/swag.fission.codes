module Metadata exposing (Frontmatter(..), decoder)

import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath
import Types exposing (..)


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
