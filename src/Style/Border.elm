module Style.Border exposing (all, left, right, top, bottom, none, solid, dashed, dotted)

{-| Border Properties


# Border Widths

@docs none, all, left, right, top, bottom


# Border Styles

@docs solid, dashed, dotted

-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Render
import Style exposing (Property)


{-| -}
all : Float -> Property class variation animation
all v =
    Internal.Exact "border-width" (Render.box ( v, v, v, v ))


{-| -}
left : Float -> Property class variation animation
left l =
    Internal.Exact "border-left-width" (toString l ++ "px")


{-| -}
right : Float -> Property class variation animation
right l =
    Internal.Exact "border-right-width" (toString l ++ "px")


{-| -}
top : Float -> Property class variation animation
top l =
    Internal.Exact "border-top-width" (toString l ++ "px")


{-| -}
bottom : Float -> Property class variation animation
bottom l =
    Internal.Exact "border-bottom-width" (toString l ++ "px")


{-| -}
none : Float -> Property class variation animation
none l =
    Internal.Exact "border-width" "0"


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
