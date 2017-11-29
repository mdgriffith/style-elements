module Element.Border
    exposing
        ( all
        , dashed
        , dotted
        , each
        , none
        , roundEach
        , rounded
        , solid
        )

{-| Border Properties


# Border Widths

@docs none, all, xy, each


# Border Styles

@docs solid, dashed, dotted


# Rounded Border

@docs rounded, roundEach

-}

import Internal.Model exposing (..)


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


{-| -}
dashed : Attribute msg
dashed =
    Class "border" "border-dashed"


{-| -}
dotted : Attribute msg
dotted =
    Class "border" "border-dotted"


{-| Round all corners.
-}
rounded : Float -> Attribute msg
rounded radius =
    StyleClass (Single ("border-radius" ++ toString radius) "border-radius" (toString radius ++ "px"))


{-| -}
roundEach : { topLeft : Float, topRight : Float, bottomLeft : Float, bottomRight : Float } -> Attribute msg
roundEach { topLeft, topRight, bottomLeft, bottomRight } =
    -- StyleClass (Single ("border-top-left-radius" ++ toString radius) "border-radius" (toString radius ++ "px"))
    StyleClass
        (Single ("border-radius-" ++ toString topLeft ++ "-" ++ toString topRight ++ toString bottomLeft ++ "-" ++ toString bottomRight)
            "border-radius"
            (toString topLeft
                ++ "px "
                ++ toString topRight
                ++ "px "
                ++ toString bottomRight
                ++ "px "
                ++ toString bottomLeft
                ++ "px"
            )
        )
