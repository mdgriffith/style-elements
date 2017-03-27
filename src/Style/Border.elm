module Style.Border exposing (..)

{-| -}

import Style.Internal.Model exposing (Property(..))
import Style.Render
import Color exposing (Color)


{-| -}
color : Color -> Property animation variation msg
color color =
    ColorProp "border-color" color


{-| -}
width : ( Float, Float, Float, Float ) -> Property animation variation msg
width value =
    Box "border-width" value


{-| -}
radius : ( Float, Float, Float, Float ) -> Property animation variation msg
radius value =
    Box "border-radius" value


{-| -}
solid : BorderStyle
solid =
    Property "border-style" "solid"


{-| -}
dashed : BorderStyle
dashed =
    Property "border-style" "dashed"


{-| -}
dotted : BorderStyle
dotted =
    Property "border-style" "dotted"
