module Style.Transition exposing (Transition, all, performant, transitions)

{-| Transitions

@docs all, performant, transitions, Transition

-}

import Style.Internal.Model as Internal
import Style exposing (Property)
import Time exposing (Time)


{-| -}
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
            , easing = "ease"
            , props = [ "all" ]
            }
        ]


{-| This enables transitions on proeprties that will be GPU accelerated: `transform`, `filter`, and `opacity`.
-}
performant : Property class variation animation
performant =
    Internal.Transitions
        [ Internal.Transition
            { delay = 0
            , duration = 130 * Time.millisecond
            , easing = "ease"
            , props = [ "transform", "filter", "opacity" ]
            }
        ]


{-| -}
transitions : List Transition -> Property class variation animation
transitions trans =
    Internal.Transitions (List.map Internal.Transition trans)
