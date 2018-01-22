module Internal.Grid exposing (..)

{-| Relative positioning within a grid.

A relatively positioned grid, means a 3x3 grid with the primary element in the center.

-}

import Element
import Internal.Model as Internal


type RelativePosition
    = OnRight
    | OnLeft
    | Above
    | Below


type Layout
    = GridElement
    | Row
    | Column


type alias Around msg =
    { right : Maybe (PositionedElement msg)
    , left : Maybe (PositionedElement msg)
    , primary : Internal.Element msg
    , primaryWidth : Internal.Length
    , defaultWidth : Internal.Length
    , below : Maybe (PositionedElement msg)
    , above : Maybe (PositionedElement msg)
    }


type alias PositionedElement msg =
    { layout : Layout
    , child : List (Internal.Element msg)
    , attrs : List (Internal.Attribute msg)
    , width : Int
    , height : Int
    }


relative : Maybe String -> List (Internal.Attribute msg) -> Around msg -> Internal.Element msg
relative node attributes around =
    let
        ( sX, sY ) =
            Internal.getSpacing attributes ( 5, 5 )

        make positioned =
            Internal.element Internal.noStyleSheet
                Internal.asEl
                Nothing
                positioned.attrs
                (Internal.Unkeyed positioned.child)

        ( template, children ) =
            createGrid ( sX, sY ) around
    in
    Internal.element Internal.noStyleSheet
        Internal.asGrid
        node
        (-- :: Element.width Element.shrink
         -- :: Element.height Element.shrink
         -- :: Internal.Class "y-content-align" "content-top"
         Element.center
            :: (template ++ attributes)
        )
        (Internal.Unkeyed
            children
        )


createGrid : ( Int, Int ) -> Around msg -> ( List (Internal.Attribute msg1), List (Element.Element msg) )
createGrid ( spacingX, spacingY ) nearby =
    let
        rowCount =
            List.sum
                [ 1
                , if Nothing == nearby.above then
                    0
                  else
                    1
                , if Nothing == nearby.below then
                    0
                  else
                    1
                ]

        colCount =
            List.sum
                [ 1
                , if Nothing == nearby.left then
                    0
                  else
                    1
                , if Nothing == nearby.right then
                    0
                  else
                    1
                ]

        rows =
            if nearby.above == Nothing then
                { above = 0
                , primary = 1
                , below = 2
                }
            else
                { above = 1
                , primary = 2
                , below = 3
                }

        columns =
            if Nothing == nearby.left then
                { left = 0
                , primary = 1
                , right = 2
                }
            else
                { left = 1
                , primary = 2
                , right = 3
                }

        rowCoord pos =
            case pos of
                Above ->
                    rows.above

                Below ->
                    rows.below

                OnRight ->
                    rows.primary

                OnLeft ->
                    rows.primary

        colCoord pos =
            case pos of
                Above ->
                    columns.primary

                Below ->
                    columns.primary

                OnRight ->
                    columns.right

                OnLeft ->
                    columns.left

        place pos el =
            build (rowCoord pos) (colCoord pos) spacingX spacingY el
    in
    ( [ Internal.StyleClass
            (Internal.GridTemplateStyle
                { spacing = ( Internal.Px spacingX, Internal.Px spacingY )
                , columns =
                    List.filterMap identity
                        [ Maybe.map (always nearby.defaultWidth) nearby.left
                        , Just nearby.primaryWidth
                        , Maybe.map (always nearby.defaultWidth) nearby.right
                        ]
                , rows = List.map (always Internal.Content) (List.range 1 rowCount)
                }
            )
      ]
    , List.filterMap identity
        [ Just <|
            Internal.element Internal.noStyleSheet
                Internal.asEl
                Nothing
                [ Internal.StyleClass
                    (Internal.GridPosition
                        { row = rows.primary
                        , col = columns.primary
                        , width = 1
                        , height = 1
                        }
                    )
                ]
                (Internal.Unkeyed [ nearby.primary ])
        , Maybe.map (place OnLeft) nearby.left
        , Maybe.map (place OnRight) nearby.right
        , Maybe.map (place Above) nearby.above
        , Maybe.map (place Below) nearby.below
        ]
    )


build : Int -> Int -> Int -> Int -> { a | attrs : List (Internal.Attribute msg), height : Int, layout : Layout, width : Int, child : List (Internal.Element msg) } -> Internal.Element msg
build rowCoord colCoord spacingX spacingY positioned =
    let
        attributes =
            Internal.StyleClass
                (Internal.GridPosition
                    { row = rowCoord
                    , col = colCoord
                    , width = positioned.width
                    , height = positioned.height
                    }
                )
                :: Internal.StyleClass (Internal.SpacingStyle spacingX spacingY)
                :: positioned.attrs
    in
    case positioned.layout of
        GridElement ->
            Internal.element Internal.noStyleSheet
                Internal.asColumn
                Nothing
                attributes
                (Internal.Unkeyed <| Internal.columnEdgeFillers positioned.child)

        Row ->
            Internal.element Internal.noStyleSheet
                Internal.asRow
                Nothing
                attributes
                (Internal.Unkeyed <| Internal.rowEdgeFillers positioned.child)

        Column ->
            Internal.element Internal.noStyleSheet
                Internal.asColumn
                Nothing
                attributes
                (Internal.Unkeyed <| Internal.columnEdgeFillers positioned.child)
