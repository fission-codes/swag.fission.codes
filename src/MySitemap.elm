module MySitemap exposing (build, path)

import Metadata exposing (Frontmatter(..))
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Sitemap


build :
    { siteUrl : String }
    ->
        List
            { path : PagePath Pages.PathKey
            , frontmatter : Frontmatter
            , body : String
            }
    ->
        { path : List String
        , content : String
        }
build config siteMetadata =
    { path = path
    , content =
        Sitemap.build config
            (siteMetadata
                |> List.map
                    (\page ->
                        { path = PagePath.toString page.path
                        , lastMod = Nothing
                        }
                    )
            )
    }


path : List String
path =
    [ "sitemap.xml" ]
