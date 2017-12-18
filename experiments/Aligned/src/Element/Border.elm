module Element.Border
    exposing
        ( all
        , color
        , dashed
        , dotted
        , each
        , glow
        , innerGlow
        , innerShadow
        , none
        , roundEach
        , rounded
        , shadow
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

import Color exposing (Color)
import Internal.Model exposing (..)


{-| -}
color : Color -> Attribute msg
color clr =
    StyleClass (Colored ("border-color-" ++ formatColorClass clr) "border-color" clr)


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


{-| A simple glow by specifying the color and size.
-}
glow : Color -> Float -> Attribute msg
glow color size =
    box
        { offset = ( 0, 0 )
        , size = size
        , blur = size * 2
        , color = color
        }


{-| -}
innerGlow : Color -> Float -> Attribute msg
innerGlow color size =
    innerShadow
        { offset = ( 0, 0 )
        , size = size
        , blur = size * 2
        , color = color
        }


{-| -}
box :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Attribute msg
box { offset, blur, color, size } =
    BoxShadow
        { inset = False
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }


{-| -}
innerShadow :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Attribute msg
innerShadow { offset, blur, color, size } =
    BoxShadow
        { inset = True
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }


{-| A drop shadow will add a shadow to whatever shape you give it.
So, if you apply a drop shadow to an image with an alpha channel, the shadow will appear around the eges.
-}
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Attribute msg
shadow { offset, blur, color } =
    Filter <|
        DropShadow
            { offset = offset
            , size = 0
            , blur = blur
            , color = color
            }
