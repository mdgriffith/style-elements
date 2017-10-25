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
all : Float -> Attribute msg
all v =
    StyleProperty "border-width" (toString v ++ "px")


{-| -}
left : Float -> Attribute msg
left l =
    StyleProperty "border-left-width" (toString l ++ "px")


{-| -}
right : Float -> Attribute msg
right l =
    StyleProperty "border-right-width" (toString l ++ "px")


{-| -}
top : Float -> Attribute msg
top l =
    StyleProperty "border-top-width" (toString l ++ "px")


{-| -}
bottom : Float -> Attribute msg
bottom l =
    StyleProperty "border-bottom-width" (toString l ++ "px")


{-| No Borders
-}
none : Attribute msg
none =
    StyleProperty "border-width" "0"


{-| -}
solid : Attribute msg
solid =
    StyleProperty "border-style" "solid"


{-| -}
dashed : Attribute msg
dashed =
    StyleProperty "border-style" "dashed"


{-| -}
dotted : Attribute msg
dotted =
    StyleProperty "border-style" "dotted"


{-| Round all corners.
-}
rounded : Float -> Attribute msg
rounded box =
    StyleProperty "border-radius" (toString box ++ "px")


{-| -}
roundTopLeft : Float -> Attribute msg
roundTopLeft x =
    StyleProperty "border-top-left-radius" (toString x ++ "px")


{-| -}
roundTopRight : Float -> Attribute msg
roundTopRight x =
    StyleProperty "border-top-right-radius" (toString x ++ "px")


{-| -}
roundBottomRight : Float -> Attribute msg
roundBottomRight x =
    StyleProperty "border-bottom-right-radius" (toString x ++ "px")


{-| -}
roundBottomLeft : Float -> Attribute msg
roundBottomLeft x =
    StyleProperty "border-bottom-left-radius" (toString x ++ "px")
