module Style.Background exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property)
import Color exposing (Color)


type alias Background =
    Internal.BackgroundModel


background : (Background -> Background) -> Property class variation animation
background update =
    Internal.Background <| update Internal.emptyBackground


{-| -}
color : Color -> Background -> Background
color bgColor bg =
    { bg | color = Just bgColor }


{-| -}
image : String -> Background -> Background
image src bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | src = src }
    in
        { bg | image = Just newImage }


position : Float -> Float -> Background -> Background
position x y bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | position = ( x, y ) }
    in
        { bg | image = Just newImage }


{-| -}
repeatX : Background -> Background
repeatX bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | repeat = Internal.RepeatX }
    in
        { bg | image = Just newImage }


{-| -}
repeatY : Background -> Background
repeatY bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | repeat = Internal.RepeatY }
    in
        { bg | image = Just newImage }


{-| -}
repeat : Background -> Background
repeat bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | repeat = Internal.Repeat }
    in
        { bg | image = Just newImage }


{-| -}
space : Background -> Background
space bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | repeat = Internal.Space }
    in
        { bg | image = Just newImage }


{-| -}
round : Background -> Background
round bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | repeat = Internal.Round }
    in
        { bg | image = Just newImage }


{-| -}
noRepeat : Background -> Background
noRepeat bg =
    let
        existing =
            Maybe.withDefault Internal.emptyImage bg.image

        newImage =
            { existing | repeat = Internal.NoRepeat }
    in
        { bg | image = Just newImage }
