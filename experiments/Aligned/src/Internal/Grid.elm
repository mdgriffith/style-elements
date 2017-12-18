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


type alias Positioned msg =
    { layout : Layout
    , child : List (Internal.Element msg)
    , attrs : List (Internal.Attribute msg)
    , position : RelativePosition
    , width : Int
    , height : Int
    }


relative : Maybe String -> List (Internal.Attribute msg) -> Internal.Element msg -> List (Positioned msg) -> Internal.Element msg
relative node attributes primary around =
    let
        ( sX, sY ) =
            Internal.getSpacing attributes ( 5, 5 )

        make positioned =
            Internal.el positioned.attrs positioned.child

        -- Internal.getSpacing attributes ( 5, 5 )
        ( template, children ) =
            createGrid ( sX, sY ) primary around
    in
    Internal.element Internal.asGrid
        node
        (Internal.htmlClass "se grid"
            -- :: Element.width Element.shrink
            -- :: Element.height Element.shrink
            -- :: Internal.Class "y-content-align" "content-top"
            :: Element.center
            :: (template ++ attributes)
        )
        (Internal.Unkeyed
            children
        )


createGrid : ( Int, Int ) -> Element.Element msg -> List (Positioned msg) -> ( List (Internal.Attribute msg1), List (Element.Element msg) )
createGrid ( spacingX, spacingY ) primary nearby =
    let
        find positioned existing =
            case positioned.position of
                Above ->
                    { existing | above = True }

                Below ->
                    { existing | below = True }

                OnRight ->
                    { existing | right = True }

                OnLeft ->
                    { existing | left = True }

        exists =
            List.foldl find
                { right = False
                , left = False
                , below = False
                , above = False
                }
                nearby

        rowCount =
            List.sum
                [ 1
                , if not exists.above then
                    0
                  else
                    1
                , if not exists.below then
                    0
                  else
                    1
                ]

        colCount =
            List.sum
                [ 1
                , if not exists.left then
                    0
                  else
                    1
                , if not exists.right then
                    0
                  else
                    1
                ]

        rows =
            { above =
                if not exists.above then
                    0
                else
                    1
            , primary =
                if not exists.above then
                    1
                else
                    2
            , below =
                if not exists.above then
                    2
                else
                    3
            }

        columns =
            { left =
                if not exists.left then
                    0
                else
                    1
            , primary =
                if not exists.left then
                    1
                else
                    2
            , right =
                if not exists.left then
                    2
                else
                    3
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
    in
    ( [ Internal.StyleClass
            (Internal.GridTemplateStyle
                { spacing = ( Internal.Px (toFloat spacingX), Internal.Px (toFloat spacingY) )
                , columns = List.map (always Internal.Content) (List.range 1 colCount)
                , rows = List.map (always Internal.Content) (List.range 1 rowCount)
                }
            )
      ]
    , Internal.gridEl Nothing
        [ Internal.StyleClass
            (Internal.GridPosition
                { row = rows.primary
                , col = columns.primary
                , width = 1
                , height = 1
                }
            )
        ]
        [ primary ]
        :: List.map (build rowCoord colCoord spacingX spacingY) (groupUp nearby)
    )


build rowCoord colCoord spacingX spacingY positioned =
    let
        attributes =
            Internal.StyleClass
                (Internal.GridPosition
                    { row = rowCoord positioned.position
                    , col = colCoord positioned.position
                    , width = positioned.width
                    , height = positioned.height
                    }
                )
                :: Internal.StyleClass (Internal.SpacingStyle spacingX spacingY)
                :: positioned.attrs
    in
    case positioned.layout of
        GridElement ->
            Internal.column
                attributes
                (Internal.Unkeyed <| Internal.columnEdgeFillers positioned.child)

        Row ->
            Internal.row
                attributes
                (Internal.Unkeyed <| Internal.rowEdgeFillers positioned.child)

        Column ->
            Internal.column
                attributes
                (Internal.Unkeyed <| Internal.columnEdgeFillers positioned.child)


groupUp positioned =
    let
        row children =
            case children of
                [] ->
                    Nothing

                el :: [] ->
                    Just <| el

                head :: _ ->
                    Just
                        { head
                            | layout = Row
                            , child = List.map (\x -> Internal.gridEl Nothing x.attrs x.child) children
                        }

        column children =
            case children of
                [] ->
                    Nothing

                el :: [] ->
                    Just <| el

                head :: _ ->
                    Just
                        { head
                            | layout = Column
                            , child = List.map (\x -> Internal.gridEl Nothing x.attrs x.child) children
                        }

        addToPosition el group =
            case el.position of
                Above ->
                    { group | above = el :: group.above }

                Below ->
                    { group | below = el :: group.below }

                OnRight ->
                    { group | right = el :: group.right }

                OnLeft ->
                    { group | left = el :: group.left }

        wrap grouped =
            List.filterMap identity
                [ row grouped.above
                , row grouped.below
                , column grouped.left
                , column grouped.right
                ]
    in
    positioned
        |> List.foldr addToPosition
            { above = []
            , below = []
            , right = []
            , left = []
            }
        |> wrap
