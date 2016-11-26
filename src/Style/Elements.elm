module Style.Elements
    exposing
        ( centered
        , completelyCentered
        , split
        , flowRight
        , flowLeft
        , flowDown
        , flowUp
        , SpacedFlow
        , Spacing
        , table
        , row
        , cell
        , tableHeader
        , column
        , floatRight
        , floatLeft
        , floatTopRight
        , floatTopLeft
        )

{-|

Elements that are conveneient for layout.

You can use these directly in your view function.

@docs centered, completelyCentered, split, flowRight, flowLeft, flowDown, flowUp, Flow, Spacing, table, row, column, floatRight, floatLeft, floatTopRight, floatTopLeft

-}

import Style
import Html exposing (Html)
import Html.Attributes
import Style.Render
import Style.Model exposing (VerticalAlignment, Alignment)


{-| -}
centered : Spacing -> List (Html msg) -> Html msg
centered spacing nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (centeredStyle |> Style.spacing (spacing.spacing))
        ]
        nodes


{-| -}
completelyCentered : Spacing -> List (Html msg) -> Html msg
completelyCentered spacing nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (completelyCenteredStyle |> Style.spacing (spacing.spacing))
        ]
        nodes


{-| -}
split : Spacing -> List (Html msg) -> Html msg
split spacing nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (splitStyle |> Style.spacing (spacing.spacing))
        ]
        nodes


{-| -}
flowRight : SpacedFlow -> List (Html msg) -> Html msg
flowRight flow nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (flowRightStyle flow)
        ]
        nodes


{-| -}
flowLeft : SpacedFlow -> List (Html msg) -> Html msg
flowLeft flow nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (flowLeftStyle flow)
        ]
        nodes


{-| -}
flowUp : SpacedFlow -> List (Html msg) -> Html msg
flowUp flow nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (flowUpStyle flow)
        ]
        nodes


{-| -}
flowDown : SpacedFlow -> List (Html msg) -> Html msg
flowDown flow nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (flowDownStyle flow)
        ]
        nodes


{-| -}
table : Spacing -> List (Html msg) -> Html msg
table spacing nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (tableStyle |> Style.spacing (spacing.spacing))
        ]
        nodes


{-| -}
row : List (Html msg) -> Html msg
row nodes =
    Html.div
        [ Html.Attributes.style <|
            Style.Render.renderInline rowStyle
        ]
        nodes


{-| -}
tableHeader : List (Html msg) -> Html msg
tableHeader nodes =
    Html.div
        [ Html.Attributes.style <|
            Style.Render.renderInline tableHeaderStyle
        ]
        nodes


{-| -}
column : List (Html msg) -> Html msg
column nodes =
    Html.div
        [ Html.Attributes.style <|
            Style.Render.renderInline columnStyle
        ]
        nodes


{-| -}
cell : List (Html msg) -> Html msg
cell nodes =
    Html.div
        [ Html.Attributes.style <|
            Style.Render.renderInline cellStyle
        ]
        nodes


{-| -}
floatRight : List (Html msg) -> Html msg
floatRight nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (Style.floatRight Style.empty)
        ]
        nodes


{-| -}
floatLeft : List (Html msg) -> Html msg
floatLeft nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (Style.floatLeft Style.empty)
        ]
        nodes


{-| -}
floatTopLeft : List (Html msg) -> Html msg
floatTopLeft nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (Style.floatTopLeft Style.empty)
        ]
        nodes


{-| -}
floatTopRight : List (Html msg) -> Html msg
floatTopRight nodes =
    Html.div
        [ Html.Attributes.class "pos"
        , Html.Attributes.style <|
            Style.Render.renderInline (Style.floatTopRight Style.empty)
        ]
        nodes



---------------
-- Styles
---------------


{-| -}
type alias Spacing =
    { spacing : ( Float, Float, Float, Float ) }


{-|

-}
type alias SpacedFlow =
    { wrap : Bool
    , horizontal : Alignment
    , vertical : VerticalAlignment
    , spacing : ( Float, Float, Float, Float )
    }


centeredStyle : Style.Model
centeredStyle =
    Style.empty
        |> Style.flowRight
            { wrap = True
            , horizontal = Style.alignCenter
            , vertical = Style.alignTop
            }


completelyCenteredStyle : Style.Model
completelyCenteredStyle =
    Style.empty
        |> Style.flowRight
            { wrap = True
            , horizontal = Style.alignCenter
            , vertical = Style.verticalCenter
            }


splitStyle : Style.Model
splitStyle =
    Style.empty
        |> Style.flowRight
            { wrap = False
            , horizontal =
                Style.justify
                -- this makes it so the children elements hug the sides.
                -- Perfect for a nav with a right and left section
            , vertical = Style.verticalCenter
            }


tableStyle : Style.Model
tableStyle =
    Style.empty
        |> Style.tableLayout


rowStyle : Style.Model
rowStyle =
    Style.empty
        |> Style.property "display" "table-row"


columnStyle : Style.Model
columnStyle =
    Style.empty
        |> Style.property "display" "table-column"


tableHeaderStyle : Style.Model
tableHeaderStyle =
    Style.empty
        |> Style.property "display" "table-column"


cellStyle : Style.Model
cellStyle =
    Style.empty
        |> Style.property "display" "table-cell"


flowRightStyle : SpacedFlow -> Style.Model
flowRightStyle flow =
    Style.empty
        |> Style.flowRight
            { wrap = flow.wrap
            , horizontal = flow.horizontal
            , vertical = flow.vertical
            }
        |> Style.spacing flow.spacing


flowLeftStyle : SpacedFlow -> Style.Model
flowLeftStyle flow =
    Style.empty
        |> Style.flowLeft
            { wrap = flow.wrap
            , horizontal = flow.horizontal
            , vertical = flow.vertical
            }
        |> Style.spacing flow.spacing


flowUpStyle : SpacedFlow -> Style.Model
flowUpStyle flow =
    Style.empty
        |> Style.flowUp
            { wrap = flow.wrap
            , horizontal = flow.horizontal
            , vertical = flow.vertical
            }
        |> Style.spacing flow.spacing


flowDownStyle : SpacedFlow -> Style.Model
flowDownStyle flow =
    Style.empty
        |> Style.flowDown
            { wrap = flow.wrap
            , horizontal = flow.horizontal
            , vertical = flow.vertical
            }
        |> Style.spacing flow.spacing
