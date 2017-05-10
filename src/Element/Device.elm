module Element.Device exposing (..)

{-| -}

import Window


type alias Device =
    { width : Int
    , height : Int
    , phone : Bool
    , tablet : Bool
    , desktop : Bool
    , bigDesktop : Bool
    , portrait : Bool
    }


match : Window.Size -> Device
match { width, height } =
    { width = width
    , height = height
    , phone = width <= 600
    , tablet = width > 600 && width <= 1200
    , desktop = width > 1200 && width <= 1800
    , bigDesktop = width > 1800
    , portrait = width > height
    }


{-|
Define two ranges that should linearly match up with each other.

Provide a value for the first and receive the calculated value for the second.

  fontsize = responsive (600, 1200) (16, 20) device.width

Will set the font-size between 16 and 20 when the device width is between 600 and 1200, using a linear scale.

-}
responsive : ( Float, Float ) -> ( Float, Float ) -> Float -> Float
responsive ( aMin, aMax ) ( bMin, bMax ) a =
    if a < aMin then
        bMin
    else if a > aMax then
        bMax
    else
        let
            deltaA =
                (a - aMin) / (aMax - aMin)
        in
            (deltaA * (bMax - bMin)) + bMin
