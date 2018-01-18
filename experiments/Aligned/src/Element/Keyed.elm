module Element.Keyed exposing (column, el, row)

{-|

@docs el, column, row

-}

import Element exposing (Attribute, Element, fill, height, width)
import Internal.Model as Internal


{-| -}
el : List (Attribute msg) -> ( String, Element msg ) -> Element msg
el attrs child =
    Internal.element Internal.NoStyleSheet
        Internal.asEl
        Nothing
        (width Element.shrink
            :: height Element.shrink
            -- :: centerY
            :: Element.center
            :: Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: attrs
        )
        (Internal.Keyed [ child ])


{-| -}
row : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
row attrs children =
    Internal.element
        Internal.NoStyleSheet
        Internal.asRow
        Nothing
        (Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: width fill
            :: attrs
        )
        (Internal.Keyed <| Internal.keyedRowEdgeFillers children)


{-| -}
column : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
column attrs children =
    Internal.element Internal.NoStyleSheet
        Internal.asColumn
        Nothing
        (Internal.Class "y-content-align" "content-top"
            :: Internal.Class "x-content-align" "content-center-x"
            :: height fill
            :: width fill
            :: attrs
        )
        (Internal.Keyed <| Internal.keyedColumnEdgeFillers children)
