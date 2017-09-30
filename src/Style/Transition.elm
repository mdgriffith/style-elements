module Style.Transition exposing (Transition, all, performant, transitions)

{-| Transitions

@docs all, performant, transitions, Transition

-}

import Style exposing (Property)
import Style.Internal.Model as Internal
import Time exposing (Time)


{-| -}
type alias Transition =
    { delay : Time
    , duration : Time
    , easing : String
    , props : List String
    }


{-| Sets transitions on all properties.

It defaults to:

    - 130ms duration
    - "ease" easing.

-}
all : Property class variation
all =
    Internal.Transitions
        [ Internal.Transition
            { delay = 0
            , duration = 130 * Time.millisecond
            , easing = "ease"
            , props = [ "all" ]
            }
        ]


{-| This enables transitions on properties that will be GPU accelerated: `transform`, `filter`, and `opacity`.

It defaults to:

    - 130ms duration
    - "ease" easing.

-}
performant : Property class variation
performant =
    Internal.Transitions
        [ Internal.Transition
            { delay = 0
            , duration = 130 * Time.millisecond
            , easing = "ease"
            , props = [ "transform", "filter", "opacity" ]
            }
        ]


{-| Create a set of transitions manually.
-}
transitions : List Transition -> Property class variation
transitions trans =
    Internal.Transitions (List.map Internal.Transition trans)
