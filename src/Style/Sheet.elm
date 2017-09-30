module Style.Sheet exposing (ChildSheet, map, merge, mix)

{-| Combine and mix child stylesheets.

@docs ChildSheet, merge, map, mix

-}

import Style exposing (Style)
import Style.Internal.Batchable as Batchable
import Style.Internal.Model as Internal exposing (StyleSheet)


{-| -}
type ChildSheet class variation
    = ChildSheet (List (Style class variation))


{-| -}
map : (class -> parent) -> (variation -> parentVariation) -> List (Style class variation) -> ChildSheet parent parentVariation
map toParent toParentVariation styles =
    ChildSheet (List.map (Batchable.map (Internal.mapClassAndVar toParent toParentVariation)) styles)


{-| Merge a child stylesheet into a parent.
-}
merge : ChildSheet class variation -> Style class variation
merge (ChildSheet styles) =
    Batchable.many (Batchable.toList styles)


{-| -}
mix : List (Style class variation) -> Style class variation
mix =
    Batchable.batch
