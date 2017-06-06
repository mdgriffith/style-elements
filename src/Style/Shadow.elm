module Style.Shadow exposing (simple, deep, glow, innerGlow, textGlow, box, drop, inset, text)

{-| Shadows


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

These are for when you want to specify shadows manually. They're meant to be specified in a shadow stack using `Style.shadows`:

    import Color
    import Style exposing (..)
    import Style.Shadow as Shadow

    style MyStyleWithShadow
        [ Style.shadows
            [ Shadow.inset
                { offset = ( 0, 0 )
                , size = 5
                , blur = 2
                , color = Color.blue
                }
            ]
        ]

@docs box, drop, inset, text

-}

import Color exposing (Color)
import Style.Internal.Model as Internal
import Style exposing (Shadow, Property)


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
    Style.shadows
        [ box
            { color = Color.rgba 0 0 0 0.5
            , offset = ( 0, 29 )
            , blur = 32
            , size = -20
            }
        , box
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
    Style.shadows
        [ box
            { color = Color.rgba 0 0 0 0.2
            , offset = ( 0, 14 )
            , blur = 20
            , size = -12
            }
        ]


{-| -}
box :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Shadow
box { offset, size, blur, color } =
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
    -> Shadow
inset { offset, blur, color, size } =
    Internal.ShadowModel
        { kind = "inset"
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
    -> Shadow
text { offset, blur, color } =
    Internal.ShadowModel
        { kind = "text"
        , offset = offset
        , size = 0
        , blur = blur
        , color = color
        }


{-| -}
drop :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Shadow
drop { offset, blur, color } =
    Internal.ShadowModel
        { kind = "drop"
        , offset = offset
        , size = 0
        , blur = blur
        , color = color
        }
