module Style.Internal.Batchable exposing (..)

{-| -}


type Batchable thing
    = One thing
    | Many (List thing)


one : thing -> Batchable thing
one =
    One


many : List thing -> Batchable thing
many =
    Many


toList : List (Batchable thing) -> List thing
toList batchables =
    let
        flatten batch =
            case batch of
                One thing ->
                    [ thing ]

                Many things ->
                    things
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
