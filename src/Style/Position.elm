module Style.Position exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property)


type alias Position =
    Internal.PositionModel


{-| -}
screen : Position -> Position
screen pos =
    { pos | relativeTo = Just "fixed" }


{-| -}
parent : Position -> Position
parent pos =
    { pos | relativeTo = Just "absolute" }


{-| -}
relative : Position -> Position
relative pos =
    { pos | relativeTo = Just "relative" }


{-| -}
zIndex : Int -> Position -> Position
zIndex i pos =
    { pos | zIndex = Just i }


{-| -}
left : Float -> Position -> Position
left i pos =
    { pos | left = Just i }


{-| -}
right : Float -> Position -> Position
right i pos =
    { pos | right = Just i }


{-| -}
top : Float -> Position -> Position
top i pos =
    { pos | top = Just i }


{-| -}
bottom : Float -> Position -> Position
bottom i pos =
    { pos | bottom = Just i }


{-| -}
inline : Position -> Position
inline pos =
    { pos | inline = True }


{-| -}
floatLeft : Position -> Position
floatLeft pos =
    { pos | float = Internal.FloatLeft }


{-| -}
floatRight : Position -> Position
floatRight pos =
    { pos | float = Internal.FloatRight }


{-| -}
floatTopRight : Position -> Position
floatTopRight pos =
    { pos | float = Internal.FloatTopRight }


{-| -}
floatTopLeft : Position -> Position
floatTopLeft pos =
    { pos | float = Internal.FloatTopLeft }
