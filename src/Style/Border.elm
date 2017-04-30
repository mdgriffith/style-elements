module Style.Border exposing (width, rounded, solid, dashed, dotted)

{-|
@docs color, width, rounded, solid, dashed, dotted
-}

import Style.Internal.Model as Internal exposing (Property(..))
import Style.Internal.Render.Value as Render
import Style exposing (Border, Corners)


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
