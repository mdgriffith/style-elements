module Style.Sheet exposing (ChildSheet, merge, map, mix)

{-| @docs ChildSheet, merge, map, mix
-}

import Style.Internal.Model as Internal exposing (StyleSheet)
import Style.Internal.Batchable as Batchable
import Style exposing (Style)


{-| -}
type ChildSheet class variation
    = ChildSheet (List (Style class variation))


{-| -}
map : (class -> parent) -> List (Style class variation) -> ChildSheet parent variation
map toParent styles =
    ChildSheet (List.map (Batchable.map (Internal.mapClass toParent)) styles)


{-| Merge a child stylesheet into a parent.
-}
merge : ChildSheet class variation -> Style class variation
merge (ChildSheet styles) =
    Batchable.many (Batchable.toList styles)


{-| -}
mix : List (Style class variation) -> Style class variation
mix =
    Batchable.batch
