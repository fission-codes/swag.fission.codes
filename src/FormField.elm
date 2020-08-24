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
onInput value formField =
    { formField | value = value }


checkValidation : (String -> FieldErrorState) -> FormField -> FormField
checkValidation validate formField =
    { formField
        | error = validate formField.value
    }
