module FormField exposing (..)

import Http
import Types exposing (..)


init : FormField
init =
    { value = ""
    , error = Nothing
    }


submissionPart : ( String, FormField ) -> Http.Part
submissionPart ( fieldId, { value } ) =
    Http.stringPart fieldId value


onInput : String -> FormField -> FormField
onInput value field =
    { field
        | value = value
        , error =
            if value /= field.value then
                Nothing

            else
                field.error
    }


checkValidation : (String -> FieldErrorState) -> FormField -> FormField
checkValidation validate field =
    { field
        | error = validate field.value
    }
