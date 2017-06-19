module Element.Keyed exposing (row, column, wrappedRow, wrappedColumn, grid, namedGrid)

{-| Keyed Layouts

@docs row, column, wrappedRow, wrappedColumn, grid, namedGrid

-}

import Element exposing (Attribute, Element, OnGrid, Grid, NamedOnGrid, NamedGrid)
import Element.Internal.Model exposing (Children(..))
import Element.Internal.Model as Internal
import Style.Internal.Model as Style exposing (Length)


{-| -}
row : style -> List (Attribute variation msg) -> List ( String, Element style variation msg ) -> Element style variation msg
row elem attrs children =
    Internal.Layout "div" (Style.FlexLayout Style.GoRight []) (Just elem) attrs (Keyed children)


{-| -}
column : style -> List (Attribute variation msg) -> List ( String, Element style variation msg ) -> Element style variation msg
column elem attrs children =
    Internal.Layout "div" (Style.FlexLayout Style.Down []) (Just elem) attrs (Keyed children)


{-| -}
wrappedRow : style -> List (Attribute variation msg) -> List ( String, Element style variation msg ) -> Element style variation msg
wrappedRow elem attrs children =
    Internal.Layout "div" (Style.FlexLayout Style.GoRight [ Style.Wrap True ]) (Just elem) attrs (Keyed children)


{-| -}
wrappedColumn : style -> List (Attribute variation msg) -> List ( String, Element style variation msg ) -> Element style variation msg
wrappedColumn elem attrs children =
    Internal.Layout "div" (Style.FlexLayout Style.Down [ Style.Wrap True ]) (Just elem) attrs (Keyed children)


{-| -}
grid : style -> Grid -> List (Attribute variation msg) -> List (OnGrid ( String, Element style variation msg )) -> Element style variation msg
grid elem template attrs children =
    let
        prepare el =
            Keyed <| List.map (\(Internal.OnGrid x) -> x) el
    in
        Internal.Layout "div" (Style.Grid (Style.GridTemplate template) []) (Just elem) attrs (prepare children)


{-| -}
namedGrid : style -> NamedGrid -> List (Attribute variation msg) -> List (NamedOnGrid ( String, Element style variation msg )) -> Element style variation msg
namedGrid elem template attrs children =
    let
        prepare el =
            Keyed <| List.map (\(Internal.NamedOnGrid x) -> x) el
    in
        Internal.Layout "div" (Style.Grid (Style.NamedGridTemplate template) []) (Just elem) attrs (prepare children)
