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
row style attrs children =
    Internal.Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.GoRight []
        , attrs = attrs
        , children = Keyed children
        , absolutelyPositioned = Nothing
        }


{-| -}
column : style -> List (Attribute variation msg) -> List ( String, Element style variation msg ) -> Element style variation msg
column style attrs children =
    Internal.Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.Down []
        , attrs = attrs
        , children = Keyed children
        , absolutelyPositioned = Nothing
        }


{-| -}
wrappedRow : style -> List (Attribute variation msg) -> List ( String, Element style variation msg ) -> Element style variation msg
wrappedRow style attrs children =
    Internal.Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.GoRight [ Style.Wrap True ]
        , attrs = attrs
        , children = Keyed children
        , absolutelyPositioned = Nothing
        }


{-| -}
wrappedColumn : style -> List (Attribute variation msg) -> List ( String, Element style variation msg ) -> Element style variation msg
wrappedColumn style attrs children =
    Internal.Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.Down [ Style.Wrap True ]
        , attrs = attrs
        , children = Keyed children
        , absolutelyPositioned = Nothing
        }


{-| -}
grid : style -> Grid -> List (Attribute variation msg) -> List (OnGrid ( String, Element style variation msg )) -> Element style variation msg
grid style template attrs children =
    let
        prepare el =
            Keyed <| List.map (\(Internal.OnGrid x) -> x) el

        ( spacing, notSpacingAttrs ) =
            List.partition forSpacing attrs

        forSpacing attr =
            case attr of
                Internal.Spacing _ _ ->
                    True

                _ ->
                    False

        gridAttributes =
            case List.head <| List.reverse spacing of
                Nothing ->
                    []

                Just (Internal.Spacing x y) ->
                    [ Style.GridGap x y ]

                _ ->
                    []
    in
        Internal.Layout
            { node = "div"
            , style = Just style
            , layout = Style.Grid (Style.GridTemplate template) gridAttributes
            , attrs = notSpacingAttrs
            , children = prepare children
            , absolutelyPositioned = Nothing
            }


{-| -}
namedGrid : style -> NamedGrid -> List (Attribute variation msg) -> List (NamedOnGrid ( String, Element style variation msg )) -> Element style variation msg
namedGrid style template attrs children =
    let
        prepare el =
            Keyed <| List.map (\(Internal.NamedOnGrid x) -> x) el

        ( spacing, notSpacingAttrs ) =
            List.partition forSpacing attrs

        forSpacing attr =
            case attr of
                Internal.Spacing _ _ ->
                    True

                _ ->
                    False

        gridAttributes =
            case List.head <| List.reverse spacing of
                Nothing ->
                    []

                Just (Internal.Spacing x y) ->
                    [ Style.GridGap x y ]

                _ ->
                    []
    in
        Internal.Layout
            { node = "div"
            , style = Just style
            , layout = Style.Grid (Style.NamedGridTemplate template) gridAttributes
            , attrs = notSpacingAttrs
            , children = (prepare children)
            , absolutelyPositioned = Nothing
            }
