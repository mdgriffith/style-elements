module Next.Style.Border
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

import Next.Internal.Model exposing (..)


{-| -}
all : Float -> Property
all v =
    Property "border-width" (toString v ++ "px")


{-| -}
left : Float -> Property
left l =
    Property "border-left-width" (toString l ++ "px")


{-| -}
right : Float -> Property
right l =
    Property "border-right-width" (toString l ++ "px")


{-| -}
top : Float -> Property
top l =
    Property "border-top-width" (toString l ++ "px")


{-| -}
bottom : Float -> Property
bottom l =
    Property "border-bottom-width" (toString l ++ "px")


{-| No Borders
-}
none : Property
none =
    Property "border-width" "0"


{-| -}
solid : Property
solid =
    Property "border-style" "solid"


{-| -}
dashed : Property
dashed =
    Property "border-style" "dashed"


{-| -}
dotted : Property
dotted =
    Property "border-style" "dotted"


{-| Round all corners.
-}
rounded : Float -> Property
rounded box =
    Property "border-radius" (toString box ++ "px")


{-| -}
roundTopLeft : Float -> Property
roundTopLeft x =
    Property "border-top-left-radius" (toString x ++ "px")


{-| -}
roundTopRight : Float -> Property
roundTopRight x =
    Property "border-top-right-radius" (toString x ++ "px")


{-| -}
roundBottomRight : Float -> Property
roundBottomRight x =
    Property "border-bottom-right-radius" (toString x ++ "px")


{-| -}
roundBottomLeft : Float -> Property
roundBottomLeft x =
    Property "border-bottom-left-radius" (toString x ++ "px")
