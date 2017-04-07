module Style.Position exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property, PositionElement(..), PositionParent(..), Floating(..))
import Style exposing (Position)


{-| -}
screen : Position
screen =
    RelativeTo Screen


{-| -}
parent : Position
parent =
    RelativeTo Parent


{-| -}
relative : Position
relative =
    RelativeTo Current


{-| -}
zIndex : Int -> Position
zIndex i =
    ZIndex i


{-| -}
left : Float -> Position
left i =
    PosLeft i


{-| -}
right : Float -> Position
right i =
    PosRight i


{-| -}
top : Float -> Position
top i =
    PosTop i


{-| -}
bottom : Float -> Position
bottom i =
    PosBottom i


{-| -}
inline : Position
inline =
    Inline


{-| -}
floatLeft : Position
floatLeft =
    Internal.Float FloatLeft


{-| -}
floatRight : Position
floatRight =
    Internal.Float FloatRight


{-| -}
floatTopRight : Position
floatTopRight =
    Internal.Float FloatTopRight


{-| -}
floatTopLeft : Position
floatTopLeft =
    Internal.Float FloatTopLeft
