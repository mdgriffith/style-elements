module Element.Keyed
    exposing
        ( Grid
        , NamedGrid
        , cell
        , column
        , grid
        , named
        , namedGrid
        , row
        , wrappedColumn
        , wrappedRow
        )

{-| Keyed Layouts

@docs row, column, wrappedRow, wrappedColumn


## Grids

@docs Grid, grid, cell,NamedGrid, namedGrid, named

-}

import Element exposing (Attribute, Element, Grid, NamedGrid, NamedOnGrid, OnGrid)
import Element.Internal.Model as Internal exposing (Children(..))
import Element.Internal.Modify as Modify
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
type alias GridPosition style variation msg =
    { start : ( Int, Int )
    , width : Int
    , height : Int
    , key : String
    , content : Element style variation msg
    }


{-| A specific position on a `grid`.
-}
cell : GridPosition style variation msg -> OnGrid ( String, Element style variation msg )
cell box =
    let
        pos =
            { start = box.start
            , width = box.width
            , height = box.height
            }
    in
    Internal.OnGrid ( box.key, Modify.addAttr (Internal.GridCoords <| Style.GridPosition pos) box.content )


{-| Specify a named postion on a `namedGrid`.

The name is used as the key.

-}
named : String -> Element style variation msg -> NamedOnGrid ( String, Element style variation msg )
named name el =
    Internal.NamedOnGrid <| ( name, Modify.addAttr (Internal.GridArea name) el )


{-| -}
type alias Grid style variation msg =
    { rows : List Length
    , columns : List Length
    , cells : List (OnGrid ( String, Element style variation msg ))
    }


{-| -}
grid : style -> List (Attribute variation msg) -> Grid style variation msg -> Element style variation msg
grid style attrs config =
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
        , layout = Style.Grid (Style.GridTemplate { rows = config.rows, columns = config.columns }) gridAttributes
        , attrs = notSpacingAttrs
        , children = prepare config.cells
        , absolutelyPositioned = Nothing
        }


{-| -}
type alias NamedGrid style variation msg =
    { rows : List ( Length, List Style.NamedGridPosition )
    , columns : List Length
    , cells : List (NamedOnGrid ( String, Element style variation msg ))
    }


{-| -}
namedGrid : style -> List (Attribute variation msg) -> NamedGrid style variation msg -> Element style variation msg
namedGrid style attrs config =
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
        , layout = Style.Grid (Style.NamedGridTemplate { rows = config.rows, columns = config.columns }) gridAttributes
        , attrs = notSpacingAttrs
        , children = prepare config.cells
        , absolutelyPositioned = Nothing
        }
