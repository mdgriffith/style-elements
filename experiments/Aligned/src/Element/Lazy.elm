module Element.Lazy exposing (lazy)

{-| Same as `Html.lazy`. In case you're unfamiliar, here's a note from the `Html` library!

    Since all Elm functions are pure we have a guarantee that the same input
    will always result in the same output. This module gives us tools to be lazy
    about building `Html` that utilize this fact.

    Rather than immediately applying functions to their arguments, the `lazy`
    functions just bundle the function and arguments up for later. When diffing
    the old and new virtual DOM, it checks to see if all the arguments are equal
    by reference. If so, it skips calling the function!

    This is a really cheap test and often makes things a lot faster, but definitely
    benchmark to be sure!

@docs lazy

_Note:_ For now only `lazy` that covers one argument can be provided. In `0.19` this will change!

-}

import Internal.Model exposing (..)
import VirtualDom


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy fn a =
    Unstyled <| VirtualDom.lazy3 embed fn a



-- {-| -}
-- lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
-- lazy2 fn a b =
--     Unstyled <| VirtualDom.lazy3 embed2 fn a b
