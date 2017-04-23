module Element.Attributes exposing (..)

{-| -}

import Element.Internal.Model as Internal exposing (StyleAttribute(..))
import Element.Style exposing (Property)
import Html


attributes : List (Html.Attribute msg) -> StyleAttribute elem variation animation msg
attributes =
    Attr


style : List (Property elem variation animation) -> StyleAttribute elem variation animation msg
style =
    Style
