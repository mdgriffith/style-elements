module Element.Border
    exposing
        ( color
        , dashed
        , dotted
        , glow
        , innerGlow
        , innerShadow
        , roundEach
        , rounded
        , shadow
        , solid
        , width
        , widthEach
        , widthXY
        )

{-| Border Properties

@docs color


# Border Widths

@docs width, widthXY, widthEach


# Border Styles

@docs solid, dashed, dotted


# Rounded Corners

@docs rounded, roundEach


# Shadows

@docs glow, innerGlow, shadow, innerShadow

-}

import Color exposing (Color)
import Element exposing (Attr, Attribute)
import Internal.Model as Internal
import Internal.Style as Style exposing (classes)


{-| -}
color : Color -> Attr decorative msg
color clr =
    Internal.StyleClass (Internal.Colored ("border-color-" ++ Internal.formatColorClass clr) "border-color" clr)


{-| -}
width : Int -> Attribute msg
width v =
    Internal.StyleClass (Internal.Single ("border-" ++ toString v) "border-width" (toString v ++ "px"))


{-| Set horizontal and vertical borders.
-}
widthXY : Int -> Int -> Attribute msg
widthXY x y =
    Internal.StyleClass (Internal.Single ("border-" ++ toString x ++ "-" ++ toString y) "border-width" (toString y ++ "px " ++ toString x ++ "px"))


{-| -}
widthEach : { bottom : Int, left : Int, right : Int, top : Int } -> Attribute msg
widthEach { bottom, top, left, right } =
    Internal.StyleClass
        (Internal.Single ("border-" ++ toString top ++ "-" ++ toString right ++ toString bottom ++ "-" ++ toString left)
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



-- {-| No Borders
-- -}
-- none : Attribute msg
-- none =
--     Class "border" "border-none"


{-| -}
solid : Attribute msg
solid =
    Internal.Class "border" classes.borderSolid


{-| -}
dashed : Attribute msg
dashed =
    Internal.Class "border" classes.borderDashed


{-| -}
dotted : Attribute msg
dotted =
    Internal.Class "border" classes.borderDotted


{-| Round all corners.
-}
rounded : Int -> Attribute msg
rounded radius =
    Internal.StyleClass (Internal.Single ("border-radius-" ++ toString radius) "border-radius" (toString radius ++ "px"))


{-| -}
roundEach : { topLeft : Int, topRight : Int, bottomLeft : Int, bottomRight : Int } -> Attribute msg
roundEach { topLeft, topRight, bottomLeft, bottomRight } =
    Internal.StyleClass
        (Internal.Single ("border-radius-" ++ toString topLeft ++ "-" ++ toString topRight ++ toString bottomLeft ++ "-" ++ toString bottomRight)
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
glow : Color -> Float -> Attr decorative msg
glow color size =
    box
        { offset = ( 0, 0 )
        , size = size
        , blur = size * 2
        , color = color
        }


{-| -}
innerGlow : Color -> Float -> Attr decorative msg
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
    -> Attr decorative msg
box { offset, blur, color, size } =
    Internal.BoxShadow
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
    -> Attr decorative msg
innerShadow { offset, blur, color, size } =
    Internal.BoxShadow
        { inset = True
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }


{-| -}
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , size : Float
    , color : Color
    }
    -> Attr decorative msg
shadow { size, offset, blur, color } =
    Internal.BoxShadow
        { inset = False
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }
