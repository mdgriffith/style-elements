module Style.Internal.Batchable exposing (Batchable(..), batch, many, map, one, toList)

{-| For things that can be combined.

@docs Batchable, batch, many, map, one, toList

-}


{-| -}
type Batchable thing
    = One thing
    | Many (List thing)
    | Batch (List (Batchable thing))


{-| -}
one : thing -> Batchable thing
one =
    One


{-| -}
many : List thing -> Batchable thing
many =
    Many


{-| -}
batch : List (Batchable thing) -> Batchable thing
batch =
    Batch


{-| -}
toList : List (Batchable thing) -> List thing
toList batchables =
    let
        flatten batch =
            case batch of
                One thing ->
                    [ thing ]

                Many things ->
                    things

                Batch embedded ->
                    toList embedded
    in
    List.concatMap flatten batchables


{-| -}
map : (a -> b) -> Batchable a -> Batchable b
map fn batchable =
    case batchable of
        One internal ->
            One <| fn internal

        Many elems ->
            Many <| List.map fn elems

        Batch embedded ->
            Batch (List.map (map fn) embedded)
