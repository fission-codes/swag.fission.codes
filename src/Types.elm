module Types exposing (..)

import Dict exposing (Dict)
import Http
import Pages
import Pages.ImagePath as Pages


type alias ImagePath =
    Pages.ImagePath Pages.PathKey


type alias Model =
    { swagForm : Dict String FormField
    }


type alias FormField =
    String


type Msg
    = OnFormFieldInput { id : String, value : String }
    | OnFormSubmit { submissionUrl : String }
    | FocusedForm
    | GotFormSubmissionResponse (Result Http.Error ())
