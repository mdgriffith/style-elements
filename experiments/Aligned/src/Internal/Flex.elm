module Internal.Flex exposing (..)

{-| Generate guarantees around Flexbox.

This is mostly because flexbox makes everything relative, but style elements and humans think in absolute terms.

Column -> Width Content ->

-}


type Flex
    = FlexRow
    | FlexColumn


{-| Generate the css properties that should be on the container
-}
container : Flex -> List ( String, String )
container flex =
    []


childAlignment : Flex -> Aligment -> List ( String, String )
childAlignment flex alignment =
    []


childWidth : Flex -> Length -> List ( String, String )
childWidth flex alignment =
    []


childHeight : Flex -> Length -> List ( String, String )
childHeight flex alignment =
    []
