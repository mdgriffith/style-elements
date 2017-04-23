module Element.Style.Transitions exposing (all, performant, transitions)

{-|
@docs all, performant, transitions

-}

import Element.Style.Internal.Model as Internal
import Element.Style exposing (Property)
import Time exposing (Time)


type alias Transition =
    { delay : Time
    , duration : Time
    , easing : String
    , props : List String
    }


{-| -}
all : Property class variation animation
all =
    Internal.Transitions
        [ Internal.Transition
            { delay = 0
            , duration = 130 * Time.millisecond
            , easing = "easeInOutSine"
            , props = [ "all" ]
            }
        ]


{-| -}
performant : Property class variation animation
performant =
    Internal.Transitions
        [ Internal.Transition
            { delay = 0
            , duration = 130 * Time.millisecond
            , easing = "easeInOutSine"
            , props = [ "transform", "filter", "opacity" ]
            }
        ]


{-| -}
transitions : List Transition -> Property class variation animation
transitions trans =
    Internal.Transitions (List.map Internal.Transition trans)
