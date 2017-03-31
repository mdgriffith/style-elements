module Style.Shadow exposing (..)

{-|




class ShadowExample
    [ Style.shadows
        |^ Shadow.box
            { offset = (0,0)
            , size = 5
            , blur = 0
            , color = Color.black
            }
        |- Shadow.inset
            { offset = (0,0)
            , size = 5
            , blur = 0
            , color = Color.black
            }

    ]



-}

import Color exposing (Color)
import Style.Internal.Model as Internal
import Style exposing (Shadow)


{-| -}
box :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Shadow
    -> Shadow
box { offset, size, blur, color } shadows =
    (Internal.ShadowModel
        { kind = "box"
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }
    )
        :: shadows


{-| -}
inset :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Shadow
    -> Shadow
inset { offset, blur, color, size } shadows =
    (Internal.ShadowModel
        { kind = "inset"
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }
    )
        :: shadows


{-| -}
text :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Shadow
    -> Shadow
text { offset, blur, color } shadows =
    (Internal.ShadowModel
        { kind = "text"
        , offset = offset
        , size = 0
        , blur = blur
        , color = color
        }
    )
        :: shadows


{-|
-}
drop :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Shadow
    -> Shadow
drop { offset, blur, color } shadows =
    (Internal.ShadowModel
        { kind = "drop"
        , offset = offset
        , size = 0
        , blur = blur
        , color = color
        }
    )
        :: shadows
