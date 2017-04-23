module Element.Style.Border exposing (color, width, rounded, solid, dashed, dotted)

{-|
@docs color, width, rounded, solid, dashed, dotted
-}

import Element.Style.Internal.Model as Internal exposing (Property(..))
import Element.Style.Internal.Render.Value as Render
import Element.Style exposing (Border, Corners)
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
rounded : Corners -> Border
rounded box =
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
