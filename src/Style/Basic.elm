module Style.Basic exposing (..)

{-|

# A Collection of Common Styles and Animations

@docs centered, completelyCentered, split, fontSizes


@docs rotating, reverseRotating, levitate


-}

import Style exposing (..)
import Time exposing (Time)
import Color


{-| Flow child elements horizontally.

Center them horizontally, but align them to the top.

-}
centered : Style.Layout
centered =
    flowRight
        { wrap = True
        , horizontal = alignCenter
        , vertical = alignTop
        }


{-| Flow child elements horizontally.

Center them horizontally and vertically

-}
completelyCentered : Style.Layout
completelyCentered =
    flowRight
        { wrap = True
        , horizontal = alignCenter
        , vertical = verticalCenter
        }


{-| Flow child elements horizontally, but have them keep to the edges.
-}
split : Style.Layout
split =
    flowRight
        { wrap = False
        , horizontal = justify
        , vertical = verticalCenter
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
    Style.animate
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
    Style.animate
        { duration = durationForOneRevolution
        , easing = "linear"
        , repeat = forever
        , steps =
            [ 0 => { variation | transforms = [ rotate 0 0 (2 * pi) ] }
            , 100 => { variation | transforms = [ rotate 0 0 0 ] }
            ]
        }



-- Common variations


levitate : Variation
levitate =
    { variation
        | shadows =
            [ shadow
                { offset = ( 0, 5 )
                , blur = 5
                , size = 0
                , color = Color.rgba 0 0 0 0.26
                }
            ]
        , transforms =
            [ translate 0 -2 0
            ]
    }


{-| -}
forever : Float
forever =
    1.0 / 0
