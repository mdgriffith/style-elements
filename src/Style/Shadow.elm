module Style.Shadow exposing (glow, innerGlow, box, drop, inset, text)

{-|

@docs glow, innerGlow, box, drop, inset, text

-}

import Color exposing (Color)
import Style.Internal.Model as Internal
import Style exposing (Shadow, Property)


{-| A simple glow by specifying the color and size.
-}
glow : Color -> Float -> Property class variation animation
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


{-| A simple glow by specifying the color and size.
-}
innerGlow : Color -> Float -> Property class variation animation
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


{-|
-}
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
