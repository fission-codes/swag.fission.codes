module Validate exposing (..)

import Email
import Maybe.Extra as Maybe
import Types exposing (..)


email : String -> FieldErrorState
email value =
    if Email.isValid value then
        Nothing

    else
        Just
            { id = "invalid"
            , description = "Please enter a valid email address."
            }


filled : String -> String -> FieldErrorState
filled description value =
    if String.isEmpty value then
        Just { id = "required", description = description }

    else
        Nothing


all : List (String -> FieldErrorState) -> String -> FieldErrorState
all validators value =
    List.foldl
        (\validator errorState ->
            errorState
                |> Maybe.orElse (validator value)
        )
        Nothing
        validators
