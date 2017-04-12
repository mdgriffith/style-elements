module Style.Border exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property(..))
import Style.Internal.Render.Value as Render
import Style exposing (Border)
import Color exposing (Color)


{-| -}
color : Color -> Border
color borderColor =
    Internal.BorderElement "border-color" (Render.color borderColor)


{-| -}
width : ( Float, Float, Float, Float ) -> Border
width box =
    Internal.BorderElement "border-width" (Render.box box)


{-| -}
radius : ( Float, Float, Float, Float ) -> Border
radius box =
    Internal.BorderElement "border-radius" (Render.box box)


{-| -}
solid : Border
solid =
    Internal.BorderElement "border-style" "solid"


{-| -}
dashed : Border
dashed =
    Internal.BorderElement "border-style" "dashed"


{-| -}
dotted : Border
dotted =
    Internal.BorderElement "border-style" "dotted"
