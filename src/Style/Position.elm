module Style.Position exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property, PositionElement(..), PositionParent(..), Floating(..))


type alias Position =
    List Internal.PositionElement


{-| -}
screen : Position -> Position
screen pos =
    RelativeTo Screen :: pos


{-| -}
parent : Position -> Position
parent pos =
    RelativeTo Parent :: pos


{-| -}
relative : Position -> Position
relative pos =
    RelativeTo Current :: pos


{-| -}
zIndex : Int -> Position -> Position
zIndex i pos =
    ZIndex i :: pos


{-| -}
left : Float -> Position -> Position
left i pos =
    PosLeft i :: pos


{-| -}
right : Float -> Position -> Position
right i pos =
    PosRight i :: pos


{-| -}
top : Float -> Position -> Position
top i pos =
    PosTop i :: pos


{-| -}
bottom : Float -> Position -> Position
bottom i pos =
    PosBottom i :: pos


{-| -}
inline : Position -> Position
inline pos =
    Inline :: pos


{-| -}
floatLeft : Position -> Position
floatLeft pos =
    Internal.Float FloatLeft :: pos


{-| -}
floatRight : Position -> Position
floatRight pos =
    Internal.Float FloatRight :: pos


{-| -}
floatTopRight : Position -> Position
floatTopRight pos =
    Internal.Float FloatTopRight :: pos


{-| -}
floatTopLeft : Position -> Position
floatTopLeft pos =
    Internal.Float FloatTopLeft :: pos
