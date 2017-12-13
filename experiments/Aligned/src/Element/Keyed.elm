module Element.Keyed exposing (column, row)

{-|

@docs column, row

-}

import Element exposing (Attribute, Element, fill, height, width)
import Internal.Model as Internal


{-| -}
row : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
row attrs children =
    Internal.row
        (Internal.Class "x-content-align" "content-center-x"
            :: width fill
            :: attrs
        )
        (Internal.Keyed <| Internal.keyedRowEdgeFillers children)


{-| -}
column : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
column attrs children =
    Internal.column
        (Internal.Class "y-content-align" "content-top"
            :: height fill
            :: width fill
            :: attrs
        )
        (Internal.Keyed <| Internal.keyedColumnEdgeFillers children)
