module Next.Slim.Style.Border
    exposing
        ( all
        , dashed
        , dotted
        , each
        , none
        , roundBottomLeft
        , roundBottomRight
        , roundTopLeft
        , roundTopRight
        , rounded
        , solid
        )

{-| Border Properties


# Border Widths

@docs none, all, xy, each


# Border Styles

@docs solid, dashed, dotted


# Rounded Border

@docs rounded, roundTopLeft, roundTopRight, roundBottomRight, roundBottomLeft

-}

import Next.Slim.Internal.Model exposing (..)


{-| -}
all : Float -> Attribute msg
all v =
    StyleClass (Single ("border-" ++ floatClass v) "border-width" (toString v ++ "px"))


{-| Set horizontal and vertical borders.
-}
xy : Float -> Float -> Attribute msg
xy x y =
    StyleClass (Single ("border-" ++ toString x ++ "-" ++ toString y) "border-width" (toString y ++ "px " ++ toString x ++ "px"))


each : { bottom : Float, left : Float, right : Float, top : Float } -> Attribute msg
each { bottom, top, left, right } =
    StyleClass
        (Single ("border-" ++ toString top ++ "-" ++ toString right ++ toString bottom ++ "-" ++ toString left)
            "border-width"
            (toString top
                ++ "px "
                ++ toString right
                ++ "px "
                ++ toString bottom
                ++ "px "
                ++ toString left
                ++ "px"
            )
        )


{-| No Borders
-}
none : Attribute msg
none =
    Class "border" "border-none"


{-| -}
solid : Attribute msg
solid =
    Class "border" "border-solid"



-- StyleProperty "border-style" "solid"


{-| -}
dashed : Attribute msg
dashed =
    Class "border" "border-dashed"



-- StyleProperty "border-style" "dashed"


{-| -}
dotted : Attribute msg
dotted =
    Class "border" "border-dotted"



-- StyleProperty "border-style" "dotted"


{-| Round all corners.
-}
rounded : Float -> Attribute msg
rounded radius =
    StyleClass (Single ("border-radius" ++ toString radius) "border-radius" (toString radius ++ "px"))


{-| -}
roundTopLeft : Float -> Attribute msg
roundTopLeft radius =
    StyleClass (Single ("border-top-left-radius" ++ toString radius) "border-top-left-radius" (toString radius ++ "px"))



-- StyleProperty "border-top-left-radius" (toString x ++ "px")


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
