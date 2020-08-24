module Types exposing (..)

import Dict exposing (Dict)
import Http
import Pages
import Pages.ImagePath as Pages


type alias ImagePath =
    Pages.ImagePath Pages.PathKey


type alias Model =
    { formFields : Dict String FormField
    , blurToDebounce : Maybe { id : String, validate : String -> FieldErrorState }
    }


type alias FormField =
    { value : String
    , error : FieldErrorState
    }


type alias FieldErrorState =
    Maybe { id : String, description : String }


type Msg
    = OnFormFieldInput { id : String, value : String }
    | OnFormSubmit { submissionUrl : String, fields : List { id : String, validate : String -> FieldErrorState } }
    | FocusedForm
    | GotFormSubmissionResponse (Result Http.Error ())
    | OnFormFieldBlur { id : String, validate : String -> FieldErrorState }
    | OnDebouncedFieldBlur { id : String, validate : String -> FieldErrorState }
