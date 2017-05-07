module Style.Border exposing (width, rounded, solid, dashed, dotted)

{-|
@docs  width, rounded, solid, dashed, dotted
-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Render
import Style exposing (Corners, Property)


{-| -}
width : ( Float, Float, Float, Float ) -> Property class variation animation
width box =
    Internal.Exact "border-width" (Render.box box)


{-| -}
rounded : Corners -> Property class variation animation
rounded box =
    Internal.Exact "border-radius" (Render.box box)


{-| -}
solid : Property class variation animation
solid =
    Internal.Exact "border-style" "solid"


{-| -}
dashed : Property class variation animation
dashed =
    Internal.Exact "border-style" "dashed"


{-| -}
dotted : Property class variation animation
dotted =
    Internal.Exact "border-style" "dotted"
