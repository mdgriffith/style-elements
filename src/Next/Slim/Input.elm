module Next.Slim.Input exposing (..)

{-| -}

import Next.Slim.Element as Element
import Next.Slim.Internal.Model exposing (..)


type Error msg
    = ErrorBelow (Element msg)
    | ErrorAbove (Element msg)


type Label msg
    = LabelBelow (Element msg)
    | LabelAbove (Element msg)
    | LabelOnRight (Element msg)
    | LabelOnLeft (Element msg)
    | HiddenLabel String
    | PlaceHolder String (Label msg)


{-| -}
type Option msg
    = ErrorOpt (Error msg)
    | Disabled
    | FocusOnLoad
    | AutoFill String


{-| -}
type alias Checkbox msg =
    { onChange : Bool -> msg
    , label : Element msg
    , checked : Bool
    , options : List (Option msg)
    }


{-| Your basic checkbox

    Input.checkbox  []
        { onChange = Check
        , checked = model.checkbox
        , label = text "hello!"
        }

-}
checkbox : List (Attribute msg) -> Checkbox msg -> Element msg
checkbox attrs checkbox =
    Element.empty



-- {-| -}
-- text : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- text =
--     textHelper Plain []
-- {-| -}
-- search : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- search =
--     textHelper Search []
-- {-| A password input that allows the browser to autofill.
-- It's `newPassword` instead of just `password` because it gives the browser a hint on what type of password input it is.
-- -}
-- newPassword : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- newPassword =
--     textHelper Password [ AutoFill "new-password" ]
-- {-| -}
-- currentPassword : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- currentPassword =
--     textHelper Password [ AutoFill "current-password" ]
-- {-| -}
-- username : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- username =
--     textHelper Plain [ AutoFill "username" ]
-- {-| -}
-- email : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- email =
--     textHelper Email [ AutoFill "email" ]
-- {-| -}
-- multiline : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- multiline =
--     textHelper TextArea []
-- {-| -}
-- spellchecked : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- spellchecked =
--     textHelper TextArea []
