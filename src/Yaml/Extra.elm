module Yaml.Extra exposing (andMap, markdownString)

import Html exposing (Html)
import Markdown
import Markdown.Config as Markdown
import Yaml.Decode as Yaml


andMap : Yaml.Decoder a -> Yaml.Decoder (a -> b) -> Yaml.Decoder b
andMap =
    Yaml.map2 (\a f -> f a)


markdownString : Yaml.Decoder (List (Html msg))
markdownString =
    Yaml.andThen
        (process >> Yaml.succeed)
        Yaml.string


process : String -> List (Html msg)
process =
    { softAsHardLineBreak =
        False
    , rawHtml =
        Markdown.Sanitize
            { allowedHtmlElements =
                "abbr" :: Markdown.defaultSanitizeOptions.allowedHtmlElements
            , allowedHtmlAttributes =
                "title" :: Markdown.defaultSanitizeOptions.allowedHtmlAttributes
            }
    }
        |> Just
        |> Markdown.toHtml


trimAndProcess : String -> List (Html msg)
trimAndProcess =
    String.trim >> process
