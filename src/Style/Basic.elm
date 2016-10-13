module Style.Basic exposing (..)

{-|

# A Collection of Common Styles and Animations

@docs centered, completelyCentered, split, fontSizes


@docs rotating, reverseRotating


-}

import Style exposing (..)
import Time exposing (Time)


{-| Flow child elements horizontally.

Center them horizontally, but align them to the top.

-}
centered : Style.Model
centered =
    { empty
        | layout =
            flowRight
                { wrap = True
                , horizontal = alignCenter
                , vertical = alignTop
                }
    }


{-| Flow child elements horizontally.

Center them horizontally and vertically

-}
completelyCentered : Style.Model
completelyCentered =
    { empty
        | layout =
            flowRight
                { wrap = True
                , horizontal = alignCenter
                , vertical = verticalCenter
                }
    }


{-| Flow child elements horizontally, but have them keep to the edges.
-}
split : Style.Model
split =
    { empty
        | layout =
            flowRight
                { wrap = False
                , horizontal = justify
                , vertical = verticalCenter
                }
    }


{-| Standard font sizes so you don't have to look them up.
-}
fontSizes : { standard : Float, h1 : Float, h2 : Float, h3 : Float }
fontSizes =
    { standard = 16
    , h3 = 18
    , h2 = 24
    , h1 = 32
    }


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


{-| Rotate an element clockwise, forever.

Provide the duration for one revolution.

-}
rotating : Time -> Animation
rotating durationForOneRevolution =
    Style.animation
        { duration = durationForOneRevolution
        , easing = "linear"
        , repeat = forever
        , steps =
            [ 0 => { variation | transforms = [ rotate 0 0 0 ] }
            , 100 => { variation | transforms = [ rotate 0 0 (2 * pi) ] }
            ]
        }


{-| Rotate an element counterclockwise, forever.

Provide the duration for one revolution.

-}
reverseRotating : Time -> Animation
reverseRotating durationForOneRevolution =
    Style.animation
        { duration = durationForOneRevolution
        , easing = "linear"
        , repeat = forever
        , steps =
            [ 0 => { variation | transforms = [ rotate 0 0 (2 * pi) ] }
            , 100 => { variation | transforms = [ rotate 0 0 0 ] }
            ]
        }


{-| -}
forever : Float
forever =
    1.0 / 0
