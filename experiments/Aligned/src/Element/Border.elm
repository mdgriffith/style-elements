module Element.Border
    exposing
        ( color
        , dashed
        , dotted
        , glow
        , innerGlow
        , innerShadow
        , mouseOverColor
        , roundEach
        , rounded
        , shadow
        , solid
        , width
        , widthEach
        , widthXY
        )

{-| Border Properties

@docs color, mouseOverColor


# Border Widths

@docs width, widthXY, widthEach


# Border Styles

@docs solid, dashed, dotted


# Rounded Border

@docs rounded, roundEach

@docs glow, innerGlow, shadow, innerShadow

-}

import Color exposing (Color)
import Internal.Model exposing (..)


{-| -}
color : Color -> Attribute msg
color clr =
    StyleClass (Colored ("border-color-" ++ formatColorClass clr) "border-color" clr)


{-| -}
mouseOverColor : Color -> Attribute msg
mouseOverColor clr =
    hover (Colored ("hover-border-color-" ++ formatColorClass clr) "border-color" clr)


{-| -}
width : Int -> Attribute msg
width v =
    StyleClass (Single ("border-" ++ toString v) "border-width" (toString v ++ "px"))


{-| Set horizontal and vertical borders.
-}
widthXY : Int -> Int -> Attribute msg
widthXY x y =
    StyleClass (Single ("border-" ++ toString x ++ "-" ++ toString y) "border-width" (toString y ++ "px " ++ toString x ++ "px"))


{-| -}
widthEach : { bottom : Int, left : Int, right : Int, top : Int } -> Attribute msg
widthEach { bottom, top, left, right } =
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



-- {-| No Borders
-- -}
-- none : Attribute msg
-- none =
--     Class "border" "border-none"


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
rounded : Int -> Attribute msg
rounded radius =
    StyleClass (Single ("border-radius-" ++ toString radius) "border-radius" (toString radius ++ "px"))


{-| -}
roundEach : { topLeft : Int, topRight : Int, bottomLeft : Int, bottomRight : Int } -> Attribute msg
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


{-| -}
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , size : Float
    , color : Color
    }
    -> Attribute msg
shadow { size, offset, blur, color } =
    BoxShadow
        { inset = True
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }
