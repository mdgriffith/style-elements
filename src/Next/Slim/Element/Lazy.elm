module Next.Slim.Element.Lazy exposing (lazy, lazy2, lazy3)

{-| -}

import Next.Slim.Internal.Model exposing (..)


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy fn a =
    case fn a of
        Unstyled _ ->
            Unstyled
                (VirtualDom.lazy (asHtml << fn) a)

        Styled styles _ ->
            Styled styles
                (VirtualDom.lazy (asHtml << fn) a)


{-| -}
lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
lazy2 fn a b =
    Unstyled
        (VirtualDom.lazy2 (\x y -> asHtml <| fn x y) a b)


{-| -}
lazy3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Element msg
lazy3 fn a b c =
    Unstyled
        (VirtualDom.lazy3 (\x y z -> asHtml <| fn x y z) a b c)
