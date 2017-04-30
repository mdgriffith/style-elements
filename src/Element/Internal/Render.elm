module Element.Internal.Render exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Element.Style.Internal.Model as Internal exposing (Length)
import Element.Style.Internal.Render.Value as Value
import Element.Style.Internal.Render.Property as Property
import Element.Internal.Model exposing (..)


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


render : Internal.StyleSheet elem variation animation msg -> Element elem variation msg -> Html msg
render stylesheet elm =
    let
        html =
            renderElement Nothing stylesheet FirstAndLast elm

        -- defaultTypeface =
        --     (Render.class "default-typeface"
        --         [ "font-family"
        --             => (defaults.typeface
        --                     |> List.map (\fam -> "\"" ++ fam ++ "\"")
        --                     |> String.join ", "
        --                )
        --         , "color" => Value.color defaults.textColor
        --         , "line-height" => toString defaults.lineHeight
        --         , "font-size" => (toString defaults.fontSize ++ "px")
        --         ]
        --     )
        -- withDefaults =
        --     stylecache
        --         |> StyleCache.embed "default-typeface"
        --             (Render.class "default-typeface"
        --                 [ "font-family"
        --                     => (defaults.typeface
        --                             |> List.map (\fam -> "\"" ++ fam ++ "\"")
        --                             |> String.join ", "
        --                        )
        --                 , "color" => Value.color defaults.textColor
        --                 , "line-height" => toString defaults.lineHeight
        --                 , "font-size" => (toString defaults.fontSize ++ "px")
        --                 ]
        --             )
        --         |> StyleCache.embed "default-spacing"
        --             (Render.class "default-spacing > *:not(.nospacing)"
        --                 [ "margin" => Value.box defaults.spacing
        --                 ]
        --             )
    in
        Html.div [ Html.Attributes.class "default-typeface" ]
            [ Html.node "style" [] [ Html.text stylesheet.css ]
            , html
            ]


type alias Parent variation msg =
    { inherited : List (Attribute variation msg)
    , layout : Internal.LayoutModel
    , parentPadding : ( Float, Float, Float, Float )
    }


detectOrder list i =
    let
        len =
            List.length list
    in
        if i == 0 && len == 1 then
            FirstAndLast
        else if i == 0 then
            First
        else if i == len - 1 then
            Last
        else
            Middle i


renderElement : Maybe (Parent variation msg) -> Internal.StyleSheet elem variation animation msg -> Order -> Element elem variation msg -> Html msg
renderElement parent stylesheet order elm =
    case elm of
        Empty ->
            Html.text ""

        Spacer x ->
            let
                ( spacingX, spacingY ) =
                    case parent of
                        Just ctxt ->
                            List.filterMap forSpacing ctxt.inherited
                                |> List.head
                                |> Maybe.withDefault ( 5, 5 )

                        Nothing ->
                            ( 5, 5 )

                forSpacing posAttr =
                    case posAttr of
                        Spacing spaceX spaceY ->
                            Just ( spaceX, spaceY )

                        _ ->
                            Nothing

                inline =
                    [ "width" => (toString (x * spacingX) ++ "px")
                    , "height" => (toString (x * spacingY) ++ "px")
                    , "visibility" => "hidden"
                    ]
            in
                Html.div [ Html.Attributes.style inline ] []

        Text dec str ->
            case dec of
                NoDecoration ->
                    Html.text str

                Bold ->
                    Html.strong [] [ Html.text str ]

                Italic ->
                    Html.em [] [ Html.text str ]

                Underline ->
                    Html.u [] [ Html.text str ]

                Strike ->
                    Html.s [] [ Html.text str ]

                Super ->
                    Html.sup [] [ Html.text str ]

                Sub ->
                    Html.sub [] [ Html.text str ]

        Element node element position child otherChildren ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == Align Center || attr == Align VerticalCenter) position
            in
                if not <| List.isEmpty centeredProps then
                    let
                        centered =
                            case otherChildren of
                                Nothing ->
                                    Layout Html.div (Internal.FlexLayout Internal.GoRight []) Nothing centeredProps [ Element node element others child otherChildren ]

                                Just children ->
                                    Layout Html.div (Internal.FlexLayout Internal.GoRight []) Nothing centeredProps [ Element node element others child otherChildren ]
                    in
                        renderElement parent stylesheet order centered
                else
                    let
                        childHtml =
                            case otherChildren of
                                Nothing ->
                                    let
                                        chil =
                                            renderElement Nothing stylesheet FirstAndLast child
                                    in
                                        [ chil ]

                                Just others ->
                                    List.map (renderElement Nothing stylesheet FirstAndLast) (child :: others)

                        attributes =
                            case parent of
                                Nothing ->
                                    position

                                Just ctxt ->
                                    ctxt.inherited ++ position

                        htmlAttrs =
                            renderPositioned Single order element parent stylesheet (gather attributes)
                    in
                        node htmlAttrs childHtml

        Layout node layout element position children ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == Align Center || attr == Align VerticalCenter) position
            in
                if layout == Internal.TextLayout && (not <| List.isEmpty centeredProps) then
                    let
                        centered =
                            Layout Html.div (Internal.FlexLayout Internal.GoRight []) Nothing centeredProps [ Layout node layout element others children ]
                    in
                        renderElement parent stylesheet order centered
                else
                    let
                        ( spacing, attrs ) =
                            List.partition forSpacing position

                        attributes =
                            case parent of
                                Nothing ->
                                    attrs

                                Just ctxt ->
                                    ctxt.inherited ++ attrs

                        clearfix attrs =
                            case layout of
                                Internal.TextLayout ->
                                    Html.Attributes.class "clearfix" :: attrs

                                _ ->
                                    attrs

                        forSpacing posAttr =
                            case posAttr of
                                Spacing _ _ ->
                                    True

                                _ ->
                                    False

                        forPadding posAttr =
                            case posAttr of
                                Padding box ->
                                    Just box

                                _ ->
                                    Nothing

                        padding =
                            case List.head (List.filterMap forPadding attributes) of
                                Nothing ->
                                    ( 0, 0, 0, 0 )

                                Just pad ->
                                    pad

                        childHtml =
                            List.indexedMap
                                (\i child ->
                                    renderElement
                                        (Just
                                            { inherited = spacing
                                            , layout = layout
                                            , parentPadding = padding
                                            }
                                        )
                                        stylesheet
                                        (detectOrder children i)
                                        child
                                )
                                children

                        htmlAttrs =
                            renderPositioned (LayoutElement layout) order element parent stylesheet (gather attributes)
                                |> clearfix
                    in
                        node (htmlAttrs) childHtml


renderAnchor : Anchor -> List ( String, String )
renderAnchor anchor =
    case anchor of
        TopRight ->
            [ ( "top", "0" )
            , ( "right", "0" )
            ]

        TopLeft ->
            [ ( "top", "0" )
            , ( "left", "0" )
            ]

        BottomRight ->
            [ ( "bottom", "0" )
            , ( "right", "0" )
            ]

        BottomLeft ->
            [ ( "bottom", "0" )
            , ( "left", "0" )
            ]


type alias Positionable variation msg =
    { inline : Bool
    , alignment : Maybe Alignment
    , frame : Maybe Frame
    , expand : Bool
    , hidden : Bool
    , width : Maybe Internal.Length
    , height : Maybe Internal.Length
    , positioned : Maybe ( Int, Int )
    , spacing : Maybe ( Float, Float )
    , padding : Maybe ( Float, Float, Float, Float )
    , variations : List ( variation, Bool )
    , transparency : Maybe Int
    , gridPosition : Maybe String
    , attrs : List (Html.Attribute msg)
    }


emptyPositionable : Positionable variation msg
emptyPositionable =
    { inline = False
    , alignment = Nothing
    , frame = Nothing
    , expand = False
    , hidden = False
    , width = Nothing
    , height = Nothing
    , positioned = Nothing
    , spacing = Nothing
    , padding = Nothing
    , variations = []
    , transparency = Nothing
    , gridPosition = Nothing
    , attrs = []
    }


gather : List (Attribute variation msg) -> Positionable variation msg
gather attrs =
    List.foldl makePositionable emptyPositionable attrs


makePositionable : Attribute variation msg -> Positionable variation msg -> Positionable variation msg
makePositionable attr pos =
    case attr of
        Inline ->
            { pos | inline = True }

        Expand ->
            { pos | expand = True }

        Vary vary on ->
            { pos
                | variations = ( vary, on ) :: pos.variations
            }

        Height len ->
            { pos | height = Just len }

        Width len ->
            { pos | width = Just len }

        Position x y ->
            { pos | positioned = Just ( x, y ) }

        PositionFrame frame ->
            { pos | frame = Just frame }

        Align alignment ->
            { pos | alignment = Just alignment }

        Spacing spaceX spaceY ->
            { pos | spacing = Just ( spaceX, spaceY ) }

        Padding box ->
            { pos | padding = Just box }

        Hidden ->
            { pos | hidden = True }

        Transparency t ->
            { pos | transparency = Just t }

        Event ev ->
            { pos | attrs = ev :: pos.attrs }

        Attr attr ->
            { pos | attrs = attr :: pos.attrs }

        GridArea name ->
            { pos | gridPosition = Just name }

        GridCoords coords ->
            { pos | gridPosition = Just <| Value.gridPosition coords }


type Order
    = First
    | Middle Int
    | Last
    | FirstAndLast


type ElementType
    = Single
    | LayoutElement Internal.LayoutModel


alignLayout : Alignment -> Internal.LayoutModel -> Internal.LayoutModel
alignLayout alignment layout =
    let
        alignFlexbox align =
            case align of
                Left ->
                    Internal.Horz (Internal.Other Internal.Left)

                Right ->
                    Internal.Horz (Internal.Other Internal.Right)

                Top ->
                    Internal.Vert (Internal.Other Internal.Top)

                Bottom ->
                    Internal.Vert (Internal.Other Internal.Bottom)

                Center ->
                    Internal.Horz (Internal.Center)

                VerticalCenter ->
                    Internal.Vert (Internal.Center)

        alignGrid align =
            case align of
                Left ->
                    Internal.GridH (Internal.Other Internal.Left)

                Right ->
                    Internal.GridH (Internal.Other Internal.Right)

                Top ->
                    Internal.GridV (Internal.Other Internal.Top)

                Bottom ->
                    Internal.GridV (Internal.Other Internal.Bottom)

                Center ->
                    Internal.GridH (Internal.Center)

                VerticalCenter ->
                    Internal.GridV (Internal.Center)
    in
        case layout of
            Internal.TextLayout ->
                Internal.TextLayout

            Internal.FlexLayout dir els ->
                Internal.FlexLayout dir (alignFlexbox alignment :: els)

            Internal.Grid template els ->
                Internal.Grid template (alignGrid alignment :: els)


renderPositioned : ElementType -> Order -> Maybe elem -> Maybe (Parent variation msg) -> Internal.StyleSheet elem variation animation msg -> Positionable variation msg -> List (Html.Attribute msg)
renderPositioned elType order maybeElemID parent stylesheet elem =
    let
        layout attrs =
            case elType of
                Single ->
                    if elem.inline then
                        ( "display", "inline" ) :: attrs
                    else
                        ( "display", "block" ) :: attrs

                LayoutElement lay ->
                    case elem.alignment of
                        Nothing ->
                            Property.layout elem.inline lay ++ attrs

                        Just align ->
                            Property.layout elem.inline (alignLayout align lay) ++ attrs

        alignment attrs =
            case elem.alignment of
                Nothing ->
                    attrs

                Just align ->
                    if elem.inline then
                        attrs
                    else if elem.frame /= Nothing then
                        case align of
                            Top ->
                                ( "top", "0" ) :: attrs

                            Bottom ->
                                ( "bottom", "0" ) :: attrs

                            Left ->
                                ( "left", "0" ) :: attrs

                            Right ->
                                ( "right", "0" ) :: attrs

                            Center ->
                                -- If an element is centered,
                                -- it would be transformed to a single element centered layout before hitting here
                                attrs

                            VerticalCenter ->
                                -- If an element is centered,
                                -- it would be transformed to a single element centered layout before hitting here
                                attrs
                    else
                        case align of
                            Top ->
                                attrs

                            Bottom ->
                                attrs

                            Left ->
                                case parent of
                                    Just { layout } ->
                                        case layout of
                                            Internal.TextLayout ->
                                                ( "float", "left" ) :: attrs

                                            _ ->
                                                attrs

                                    _ ->
                                        attrs

                            Right ->
                                case parent of
                                    Just { layout } ->
                                        case layout of
                                            Internal.TextLayout ->
                                                ( "float", "right" ) :: attrs

                                            _ ->
                                                attrs

                                    _ ->
                                        attrs

                            Center ->
                                attrs

                            VerticalCenter ->
                                attrs

        width attrs =
            case elem.width of
                Nothing ->
                    attrs

                Just len ->
                    ( "width", Value.length len ) :: attrs

        height attrs =
            case elem.height of
                Nothing ->
                    attrs

                Just len ->
                    ( "height", Value.length len ) :: attrs

        transparency attrs =
            case elem.transparency of
                Nothing ->
                    attrs

                Just t ->
                    ( "opacity", (toString <| 1 - t) ) :: attrs

        padding attrs =
            case elem.padding of
                Nothing ->
                    attrs

                Just pad ->
                    ( "padding", Value.box pad ) :: attrs

        positionAdjustment attrs =
            case elem.positioned of
                Nothing ->
                    attrs

                Just ( x, y ) ->
                    ( "transform"
                    , ("translate(" ++ toString x ++ "px, " ++ toString y ++ "px)")
                    )
                        :: attrs

        gridPos attrs =
            case elem.gridPosition of
                Nothing ->
                    attrs

                Just area ->
                    ( "grid-area", area ) :: attrs

        spacing attrs =
            case elem.spacing of
                Nothing ->
                    attrs

                Just space ->
                    ( "margin", Value.box <| adjustspacing space ) :: attrs

        -- When an element is floated, it's spacing is affected
        adjustspacing ( spaceX, spaceY ) =
            let
                unchanged =
                    ( spaceY, spaceX, spaceY, spaceX )
            in
                case parent of
                    Nothing ->
                        unchanged

                    Just { layout } ->
                        case layout of
                            Internal.TextLayout ->
                                case elem.alignment of
                                    Nothing ->
                                        if order == Last || order == FirstAndLast then
                                            ( 0, 0, 0, 0 )
                                        else
                                            ( 0, 0, spaceY, 0 )

                                    Just align ->
                                        if not elem.inline && elem.frame == Nothing then
                                            case align of
                                                Left ->
                                                    if order == First then
                                                        ( 0, spaceX, spaceY, 0 )
                                                    else if order == FirstAndLast then
                                                        ( 0, spaceX, 0, 0 )
                                                    else if order == Last then
                                                        ( spaceY, spaceX, 0, 0 )
                                                    else
                                                        ( spaceY, spaceX, spaceY, 0 )

                                                Right ->
                                                    if order == First then
                                                        ( 0, 0, spaceY, spaceX )
                                                    else if order == FirstAndLast then
                                                        ( 0, 0, 0, spaceX )
                                                    else if order == Last then
                                                        ( spaceY, 0, 0, spaceX )
                                                    else
                                                        ( spaceY, 0, spaceY, spaceX )

                                                _ ->
                                                    if order == Last || order == FirstAndLast then
                                                        ( 0, 0, 0, 0 )
                                                    else
                                                        ( 0, 0, spaceY, 0 )
                                        else
                                            unchanged

                            _ ->
                                unchanged

        defaults =
            [ "position" => "relative"
            , "box-sizing" => "border-box"
            ]

        attributes =
            case maybeElemID of
                Nothing ->
                    elem.attrs

                Just elemID ->
                    if List.length elem.variations > 0 then
                        stylesheet.variations elemID elem.variations :: elem.attrs
                    else
                        stylesheet.style elemID :: elem.attrs
    in
        if elem.hidden then
            Html.Attributes.style [ ( "display", "none" ) ] :: attributes
        else if elem.frame /= Nothing then
            let
                frame =
                    case elem.frame of
                        Nothing ->
                            []

                        Just frm ->
                            case frm of
                                Screen anchor ->
                                    ( "position", "fixed" ) :: renderAnchor anchor

                                Within anchor ->
                                    ( "position", "absolute" ) :: renderAnchor anchor

                                Nearby Above ->
                                    [ "position" => "absolute"
                                    , "bottom" => "100%"
                                    ]

                                Nearby Below ->
                                    [ "position" => "absolute"
                                    , "top" => "100%"
                                    ]

                                Nearby OnLeft ->
                                    [ "position" => "absolute"
                                    , "right" => "100%"
                                    ]

                                Nearby OnRight ->
                                    [ "position" => "absolute"
                                    , "left" => "100%"
                                    ]
            in
                (Html.Attributes.style
                    (("box-sizing" => "border-box")
                        :: (gridPos <| layout <| spacing <| transparency <| width <| height <| positionAdjustment <| padding <| alignment <| frame)
                    )
                )
                    :: attributes
        else if elem.expand then
            let
                expandedProps =
                    case parent of
                        Nothing ->
                            [ "width" => "100%"
                            , "height" => "100%"
                            , "margin" => "0"
                            ]

                        Just { parentPadding } ->
                            let
                                ( top, right, bottom, left ) =
                                    parentPadding
                            in
                                [ "width" => ("calc(100% + " ++ toString (right + left) ++ "px")
                                , "margin" => "0"
                                , "margin-left" => (toString (-1 * left) ++ "px")
                                , if order == First || order == FirstAndLast then
                                    "margin-top" => (toString (-1 * top) ++ "px")
                                  else
                                    "margin-top" => "0"
                                , if order == Last || order == FirstAndLast then
                                    "margin-bottom" => (toString (-1 * bottom) ++ "px")
                                  else
                                    "margin-bottom" => "0"
                                ]
            in
                (Html.Attributes.style
                    (("box-sizing" => "border-box") :: (gridPos <| layout <| spacing <| transparency <| positionAdjustment <| padding <| expandedProps))
                )
                    :: attributes
        else
            (Html.Attributes.style
                (gridPos <| layout <| spacing <| transparency <| width <| height <| positionAdjustment <| padding <| alignment <| defaults)
            )
                :: attributes
