module Style.Border
    exposing
        ( all
        , bottom
        , dashed
        , dotted
        , left
        , none
        , right
        , roundBottomLeft
        , roundBottomRight
        , roundTopLeft
        , roundTopRight
        , rounded
        , solid
        , top
        )

{-| Border Properties


# Border Widths

@docs none, all, left, right, top, bottom


# Border Styles

@docs solid, dashed, dotted


# Rounded Border

@docs rounded, roundTopLeft, roundTopRight, roundBottomRight, roundBottomLeft

-}

import Style exposing (Property)
import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Render


{-| -}
all : Float -> Property class variation
all v =
    Internal.Exact "border-width" (Render.box ( v, v, v, v ))


{-| -}
left : Float -> Property class variation
left l =
    Internal.Exact "border-left-width" (toString l ++ "px")


{-| -}
right : Float -> Property class variation
right l =
    Internal.Exact "border-right-width" (toString l ++ "px")


{-| -}
top : Float -> Property class variation
top l =
    Internal.Exact "border-top-width" (toString l ++ "px")


{-| -}
bottom : Float -> Property class variation
bottom l =
    Internal.Exact "border-bottom-width" (toString l ++ "px")


{-| No Borders
-}
none : Property class variation
none =
    Internal.Exact "border-width" "0"


{-| -}
solid : Property class variation
solid =
    Internal.Exact "border-style" "solid"


{-| -}
dashed : Property class variation
dashed =
    Internal.Exact "border-style" "dashed"


{-| -}
dotted : Property class variation
dotted =
    Internal.Exact "border-style" "dotted"


{-| Round all corners.
-}
rounded : Float -> Property class variation
rounded box =
    Internal.Exact "border-radius" (toString box ++ "px")


{-| -}
roundTopLeft : Float -> Property class variation
roundTopLeft x =
    Internal.Exact "border-top-left-radius" (toString x ++ "px")


{-| -}
roundTopRight : Float -> Property class variation
roundTopRight x =
    Internal.Exact "border-top-right-radius" (toString x ++ "px")


{-| -}
roundBottomRight : Float -> Property class variation
roundBottomRight x =
    Internal.Exact "border-bottom-right-radius" (toString x ++ "px")


{-| -}
roundBottomLeft : Float -> Property class variation
roundBottomLeft x =
    Internal.Exact "border-bottom-left-radius" (toString x ++ "px")
