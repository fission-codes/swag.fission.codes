{-
   This module multiplexes between the various views according
   to the frontmatter.
-}


module View exposing (yamlDocument)

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
import Types exposing (..)


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
