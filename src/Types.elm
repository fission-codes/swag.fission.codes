module Types exposing (..)

import Dict exposing (Dict)
import Http
import Pages
import Pages.ImagePath as Pages


type alias ImagePath =
    Pages.ImagePath Pages.PathKey


type alias Model =
    { formFields : Dict String FormField
    , formCheckboxes : Dict String FormCheckbox
    , submissionStatus : Status
    }


type alias FormField =
    { value : String
    , error : FieldErrorState
    }


type alias FormCheckbox =
    { value : Bool
    , error : Maybe String
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
    | OnFormSubmit { submissionUrl : String, fields : List FieldDataInfo }
    | OnFormFieldCheck { id : String, checked : Bool }
    | FocusedForm
    | GotFormSubmissionResponse (Result Http.Error ())


type FieldDataInfo
    = FieldInfoInput { id : String, validate : String -> FieldErrorState }
    | FieldInfoCheckbox { id : String, requireChecked : Maybe String }
