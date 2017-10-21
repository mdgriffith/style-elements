module Style.Shadow exposing (box, deep, drop, glow, innerGlow, inset, simple, text, textGlow)

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
import Style exposing (Property)
import Style.Internal.Model as Internal


{-| A simple glow by specifying the color and size.
-}
glow : Color -> Float -> Property class variation
glow color size =
    Internal.Shadows
        [ Internal.ShadowModel
            { kind = "box"
            , offset = ( 0, 0 )
            , size = size
            , blur = size * 2
            , color = color
            }
        ]


{-| -}
innerGlow : Color -> Float -> Property class variation
innerGlow color size =
    Internal.Shadows
        [ Internal.ShadowModel
            { kind = "inset"
            , offset = ( 0, 0 )
            , size = size
            , blur = size * 2
            , color = color
            }
        ]


{-| -}
textGlow : Color -> Float -> Property class variation
textGlow color size =
    Internal.Shadows
        [ Internal.ShadowModel
            { kind = "text"
            , offset = ( 0, 0 )
            , size = size
            , blur = size * 2
            , color = color
            }
        ]


{-| A nice preset box shadow.
-}
simple : Property class variation
simple =
    Internal.Shadows
        [ boxHelper
            { color = Color.rgba 0 0 0 0.5
            , offset = ( 0, 29 )
            , blur = 32
            , size = -20
            }
        , boxHelper
            { color = Color.rgba 0 0 0 0.25
            , offset = ( 0, 4 )
            , blur = 11
            , size = -3
            }
        ]


{-| A nice preset box shadow that's deeper than `simple`.
-}
deep : Property class variation
deep =
    box
        { color = Color.rgba 0 0 0 0.2
        , offset = ( 0, 14 )
        , blur = 20
        , size = -12
        }


{-| -}
box :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Property class variation
box shadow =
    Internal.Shadows
        [ boxHelper shadow
        ]


boxHelper : { a | blur : Float, color : Color, offset : ( Float, Float ), size : Float } -> Internal.ShadowModel
boxHelper { offset, size, blur, color } =
    Internal.ShadowModel
        { kind = "box"
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
    -> Property class variation
inset { offset, blur, color, size } =
    Internal.Shadows
        [ Internal.ShadowModel
            { kind = "inset"
            , offset = offset
            , size = size
            , blur = blur
            , color = color
            }
        ]


{-| -}
text :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Property class variation
text { offset, blur, color } =
    Internal.Shadows
        [ Internal.ShadowModel
            { kind = "text"
            , offset = offset
            , size = 0
            , blur = blur
            , color = color
            }
        ]


{-| A drop shadow will add a shadow to whatever shape you give it.

So, if you apply a drop shadow to an image with an alpha channel, the shadow will appear around the eges.

-}
drop :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Property class variation
drop { offset, blur, color } =
    Internal.Filters
        [ Internal.DropShadow
            { offset = offset
            , size = 0
            , blur = blur
            , color = color
            }
        ]
