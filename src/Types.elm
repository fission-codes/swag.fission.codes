module Types exposing (..)

import Dict exposing (Dict)
import Pages
import Pages.ImagePath as Pages


type alias ImagePath =
    Pages.ImagePath Pages.PathKey


type alias Model =
    { swagForm :
        { firstname : FormField
        , lastname : FormField
        , email : FormField
        , company : FormField
        , addressStreet : FormField
        , addressCitystate : FormField
        , addressPostal : FormField
        , addressCountry : FormField
        }
    }


type alias FormField =
    String


type alias Msg =
    ()
