module Next.Style.Shadow exposing (..)

{-| Shadows

If multiple shadows are set, they will stack.


# Easy Presets

These can be used directly as properties.

    import Color
    import Style exposing (..)
    import Style.Shadow as Shadow

    style MyStyleWithShadow
        [ Shadow.glow Color.red 5
        ]

@docs simple, deep, glow, innerGlow, textGlow


# Advanced Shadows

You can also have more control over the paraters of the shadow, such as the `Shadow.box` shown below.

    import Color
    import Style exposing (..)
    import Style.Shadow as Shadow

    style MyStyleWithShadow
        [ Shadow.box
            { offset = ( 0, 0 )
            , size = 5
            , blur = 2
            , color = Color.blue
            }

        ]

@docs box, drop, inset, text

-}

import Color exposing (Color)
import Next.Internal.Model as Internal


{-| A simple glow by specifying the color and size.
-}
glow : Color -> Float -> Internal.Attribute msg
glow color size =
    box
        { offset = ( 0, 0 )
        , size = size
        , blur = size * 2
        , color = color
        }


{-| -}
innerGlow : Color -> Float -> Internal.Attribute msg
innerGlow color size =
    inset
        { offset = ( 0, 0 )
        , size = size
        , blur = size * 2
        , color = color
        }


{-| -}
textGlow : Color -> Float -> Internal.Attribute msg
textGlow color size =
    Internal.TextShadow
        { offset = ( 0, 0 )
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
    -> Internal.Attribute msg
box { offset, blur, color, size } =
    Internal.BoxShadow
        { inset = False
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }


{-| -}
inset :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Internal.Attribute msg
inset { offset, blur, color, size } =
    Internal.BoxShadow
        { inset = True
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }


{-| -}
text :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Internal.Attribute msg
text { offset, blur, color } =
    Internal.TextShadow
        { offset = offset
        , blur = blur
        , color = color
        }


{-| A drop shadow will add a shadow to whatever shape you give it.
So, if you apply a drop shadow to an image with an alpha channel, the shadow will appear around the eges.
-}
drop :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Internal.Attribute msg
drop { offset, blur, color } =
    Internal.Filter <|
        Internal.DropShadow
            { offset = offset
            , size = 0
            , blur = blur
            , color = color
            }
