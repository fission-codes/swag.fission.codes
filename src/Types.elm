module Types exposing (..)

import Dict exposing (Dict)
import Http
import Pages
import Pages.ImagePath as Pages


type alias ImagePath =
    Pages.ImagePath Pages.PathKey


type alias Model =
    { formFields : Dict String FormField
    , submissionStatus : Status
    , checkbox : Bool
    }


type alias FormField =
    { value : String
    , error : FieldErrorState
    }


type Status
    = Waiting
    | Submitting
    | Submitted
    | Error


type alias FieldErrorState =
    Maybe { id : String, description : String }


type Msg
    = OnFormFieldInput { id : String, value : String }
    | OnFormFieldBlur { id : String, validate : String -> FieldErrorState }
    | OnFormSubmit { submissionUrl : String, fields : List { id : String, validate : String -> FieldErrorState } }
    | OnFormFieldCheck { checked : Bool }
    | FocusedForm
    | GotFormSubmissionResponse (Result Http.Error ())
