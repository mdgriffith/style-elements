module Element.Internal.Render exposing (..)

{-| -}

import Html exposing (Html)
import Html.Keyed
import Html.Attributes
import Element.Internal.Model exposing (..)
import Style.Internal.Model as Internal exposing (Length)
import Style.Internal.Render.Value as Value
import Style.Internal.Render.Property as Property
import Internal.Utils exposing ((=>))


root : Internal.StyleSheet elem variation -> Element elem variation msg -> Html msg
root stylesheet elm =
    Html.div [ Html.Attributes.class "style-elements-root" ]
        [ embed stylesheet
        , render stylesheet elm
        ]


embed : Internal.StyleSheet elem variation -> Html msg
embed stylesheet =
    Html.node "style" [] [ Html.text stylesheet.css ]


render : Internal.StyleSheet elem variation -> Element elem variation msg -> Html msg
render stylesheet elm =
    elm
        |> adjustStructure Nothing
        |> renderElement Nothing stylesheet FirstAndLast


detectOrder : List a -> number -> Order
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


spacingToMargin : List (Attribute variation msg) -> List (Attribute variation msg)
spacingToMargin attrs =
    let
        spaceToMarg a =
            case a of
                Spacing x y ->
                    Margin ( y, x, y, x )

                a ->
                    a
    in
        List.map spaceToMarg attrs


{-| Certain situations require html structure adjustment
-}
adjustStructure : Maybe Internal.LayoutModel -> Element elem variation msg -> Element elem variation msg
adjustStructure parent elm =
    case elm of
        Empty ->
            Empty

        Raw html ->
            Raw html

        Spacer x ->
            Spacer x

        Text dec str ->
            Text dec str

        Element node element position child otherChildren ->
            let
                ( aligned, unaligned ) =
                    List.partition forAlignment position

                forAlignment attr =
                    case attr of
                        HAlign _ ->
                            True

                        VAlign _ ->
                            True

                        _ ->
                            False

                forSpacing attr =
                    case attr of
                        Spacing _ _ ->
                            True

                        _ ->
                            False

                skipAdjustment bool =
                    Element node
                        element
                        (PointerEvents True :: position)
                        (adjustStructure Nothing child)
                        (Maybe.map (List.map (adjustStructure Nothing)) otherChildren)
            in
                if not <| List.isEmpty aligned then
                    case parent of
                        Nothing ->
                            -- use Flexbox to center single elements
                            -- The flexbox element should pass through events to the parent.
                            let
                                properChild =
                                    Element node
                                        element
                                        (PointerEvents True :: PositionFrame Positioned :: Position (Just 0) (Just 0) Nothing :: unaligned)
                                        (adjustStructure Nothing child)
                                        (Maybe.map (List.map (adjustStructure Nothing)) otherChildren)

                                noColor =
                                    Html.Attributes.style
                                        [ ( "background-color"
                                          , "rgba(0,0,0,0)"
                                          )
                                        , ( "color"
                                          , "rgba(0,0,0,0)"
                                          )
                                        , ( "border-color"
                                          , "rgba(0,0,0,0)"
                                          )
                                        , ( "transform", "none" )
                                        , ( "opacity", "1" )
                                        ]

                                nearbyToAlignment attr =
                                    case attr of
                                        PositionFrame (Nearby Above) ->
                                            Just (VAlign Top)

                                        PositionFrame (Nearby Below) ->
                                            Just (VAlign Bottom)

                                        PositionFrame (Nearby OnRight) ->
                                            Just (HAlign Right)

                                        PositionFrame (Nearby OnLeft) ->
                                            Just (HAlign Left)

                                        _ ->
                                            Nothing

                                adjustedAligned =
                                    List.filterMap nearbyToAlignment unaligned
                            in
                                Layout "div"
                                    (Internal.FlexLayout Internal.GoRight [])
                                    Nothing
                                    (PointerEvents False
                                        :: PositionFrame Positioned
                                        :: Height (Internal.Percent 100)
                                        :: Width (Internal.Percent 100)
                                        :: (adjustedAligned ++ aligned)
                                    )
                                    (Normal
                                        [ Element "div"
                                            element
                                            ((PointerEvents False :: unaligned ++ [ PositionFrame Relative, Position (Just 0) (Just 0) Nothing ]) ++ [ Attr <| noColor ])
                                            properChild
                                            Nothing
                                        ]
                                    )

                        Just (Internal.TextLayout _) ->
                            let
                                ( spaced, unspaced ) =
                                    List.partition forSpacing unaligned
                            in
                                Layout "div"
                                    (Internal.FlexLayout Internal.GoRight [])
                                    Nothing
                                    ((PointerEvents False :: aligned) ++ spacingToMargin spaced)
                                    (Normal
                                        [ Element node
                                            element
                                            (PointerEvents True :: unspaced)
                                            (adjustStructure Nothing child)
                                            (Maybe.map (List.map (adjustStructure Nothing)) otherChildren)
                                        ]
                                    )

                        _ ->
                            skipAdjustment True
                else
                    skipAdjustment True

        Layout node layout element attrs children ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) attrs

                isFlex =
                    case layout of
                        Internal.FlexLayout _ _ ->
                            True

                        _ ->
                            False

                spacing =
                    List.filterMap forSpacing attrs
                        |> List.reverse
                        |> List.head

                padding =
                    List.filterMap forPadding attrs
                        |> List.reverse
                        |> List.head

                hasSpacing =
                    case spacing of
                        Nothing ->
                            False

                        _ ->
                            True

                forSpacing posAttr =
                    case posAttr of
                        Spacing x y ->
                            Just ( y, x, y, x )

                        _ ->
                            Nothing

                forPadding posAttr =
                    case posAttr of
                        Padding t r b l ->
                            Just <| defaultPadding ( t, r, b, l ) ( 0, 0, 0, 0 )

                        _ ->
                            Nothing
            in
                case layout of
                    Internal.TextLayout _ ->
                        if not <| List.isEmpty centeredProps then
                            Layout
                                "div"
                                (Internal.FlexLayout Internal.GoRight [])
                                Nothing
                                (PointerEvents False :: centeredProps)
                                (Normal
                                    [ Layout node layout element (PointerEvents True :: others) (mapChildren (adjustStructure (Just layout)) children) ]
                                )
                        else
                            Layout node
                                layout
                                element
                                (PointerEvents True :: attrs)
                                (mapChildren (adjustStructure (Just layout)) children)

                    Internal.FlexLayout _ _ ->
                        if hasSpacing then
                            let
                                ( aligned, unaligned ) =
                                    List.partition forAlignment attrs

                                forAlignment attr =
                                    case attr of
                                        HAlign _ ->
                                            True

                                        VAlign _ ->
                                            True

                                        _ ->
                                            False

                                -- Container
                                -- FlexLayout on counter-element
                                -- negative margin on counter-element
                                ( negativeMargin, spacingAttr, totalHSpacing ) =
                                    case spacing of
                                        Nothing ->
                                            ( ( 0, 0, 0, 0 )
                                            , Spacing 0 0
                                            , 0
                                            )

                                        Just ( top, right, bottom, left ) ->
                                            ( ( -1 * top, -1 * right, -1 * bottom, -1 * left )
                                            , Spacing right bottom
                                            , right + left
                                            )

                                phantomPadding =
                                    PhantomPadding
                                        (Maybe.withDefault ( 0, 0, 0, 0 ) padding)
                            in
                                Layout
                                    "div"
                                    (Internal.FlexLayout Internal.GoRight [])
                                    element
                                    (PointerEvents True :: unaligned)
                                    (Normal
                                        [ Layout
                                            node
                                            layout
                                            Nothing
                                            (PointerEvents False
                                                :: phantomPadding
                                                :: Margin negativeMargin
                                                :: spacingAttr
                                                :: Width (Internal.Calc 100 totalHSpacing)
                                                :: aligned
                                            )
                                            (mapChildren (adjustStructure (Just layout)) children)
                                        ]
                                    )
                        else
                            Layout node layout element (PointerEvents True :: attrs) (mapChildren (adjustStructure (Just layout)) children)

                    _ ->
                        Layout node layout element attrs (mapChildren (adjustStructure (Just layout)) children)


calcPosition : Frame -> ( Maybe Float, Maybe Float, Maybe Float ) -> List ( String, String )
calcPosition frame ( mx, my, mz ) =
    let
        x =
            Maybe.withDefault 0 mx

        y =
            Maybe.withDefault 0 my

        z =
            Maybe.withDefault 0 mz
    in
        case frame of
            Relative ->
                [ "position" => "relative"
                , "left" => (toString x ++ "px")
                , "top" => (toString y ++ "px")
                ]

            Screen ->
                [ "position" => "fixed"
                , "left" => (toString x ++ "px")
                , "top" => (toString y ++ "px")
                ]

            Positioned ->
                List.filterMap identity
                    [ Just ("position" => "absolute")
                    , case mx of
                        Just x ->
                            Just ("left" => (toString x ++ "px"))

                        Nothing ->
                            Nothing
                    , case my of
                        Just y ->
                            Just ("top" => (toString y ++ "px"))

                        Nothing ->
                            Nothing
                    ]

            Nearby Above ->
                [ "position" => "absolute"
                , "bottom" => ("calc(100% - " ++ toString y ++ "px)")
                , "left" => (toString x ++ "px")
                ]

            Nearby Below ->
                [ "position" => "absolute"
                , "top" => ("calc(100% + " ++ toString y ++ "px)")
                , "left" => (toString x ++ "px")
                ]

            Nearby OnLeft ->
                [ "position" => "absolute"
                , "right" => ("calc(100% - " ++ toString x ++ "px)")
                , "top" => (toString y ++ "px")
                ]

            Nearby OnRight ->
                [ "position" => "absolute"
                , "left" => ("calc(100% + " ++ toString x ++ "px)")
                , "top" => (toString y ++ "px")
                ]


defaultPadding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float ) -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
defaultPadding ( mW, mX, mY, mZ ) ( w, x, y, z ) =
    ( Maybe.withDefault w mW
    , Maybe.withDefault x mX
    , Maybe.withDefault y mY
    , Maybe.withDefault z mZ
    )


renderElement : Maybe Parent -> Internal.StyleSheet elem variation -> Order -> Element elem variation msg -> Html msg
renderElement parent stylesheet order elm =
    case elm of
        Empty ->
            Html.text ""

        Raw html ->
            html

        Spacer x ->
            let
                ( spacingX, spacingY, _, _ ) =
                    case parent of
                        Just ctxt ->
                            ctxt.parentSpecifiedSpacing
                                |> Maybe.withDefault ( 0, 0, 0, 0 )

                        Nothing ->
                            ( 0, 0, 0, 0 )

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

        Element node element attrs child otherChildren ->
            let
                childHtml =
                    case otherChildren of
                        Nothing ->
                            [ renderElement Nothing stylesheet FirstAndLast child ]

                        Just others ->
                            List.map (renderElement Nothing stylesheet FirstAndLast) (child :: others)

                parentTextLayout layout =
                    case layout of
                        Internal.TextLayout _ ->
                            True

                        _ ->
                            False

                attributes =
                    case parent of
                        Nothing ->
                            spacingToMargin attrs

                        Just ctxt ->
                            case ctxt.parentSpecifiedSpacing of
                                Nothing ->
                                    if parentTextLayout ctxt.layout || List.any ((==) Inline) attrs then
                                        spacingToMargin attrs
                                    else
                                        attrs

                                Just ( top, right, bottom, left ) ->
                                    if parentTextLayout ctxt.layout || List.any ((==) Inline) attrs then
                                        Margin ( top, right, bottom, left ) :: spacingToMargin attrs
                                    else
                                        Margin ( top, right, bottom, left ) :: attrs

                htmlAttrs =
                    renderAttributes Single order element parent stylesheet (gather attributes)
            in
                Html.node node htmlAttrs childHtml

        Layout node layout element attrs children ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) attrs

                attributes =
                    case parent of
                        Nothing ->
                            attrs

                        Just ctxt ->
                            case ctxt.parentSpecifiedSpacing of
                                Nothing ->
                                    attrs

                                Just spacing ->
                                    Margin spacing :: attrs

                clearfix attrs =
                    case layout of
                        Internal.TextLayout clearfix ->
                            if clearfix then
                                Html.Attributes.class "clearfix" :: attrs
                            else
                                attrs

                        _ ->
                            attrs

                forPadding posAttr =
                    case posAttr of
                        Padding t r b l ->
                            Just <| defaultPadding ( t, r, b, l ) ( 0, 0, 0, 0 )

                        PhantomPadding box ->
                            Just box

                        _ ->
                            Nothing

                padding =
                    case List.head (List.filterMap forPadding attributes) of
                        Nothing ->
                            ( 0, 0, 0, 0 )

                        Just pad ->
                            pad

                findSpacing posAttr =
                    case posAttr of
                        Spacing x y ->
                            Just ( y, x, y, x )

                        _ ->
                            Nothing

                forSpacing =
                    (\x -> x /= Nothing) << findSpacing

                ( spacing, _ ) =
                    List.partition forSpacing attrs

                inherit =
                    { parentSpecifiedSpacing =
                        List.filterMap findSpacing attrs
                            |> List.head
                    , layout = layout
                    , parentPadding = padding
                    }

                htmlAttrs =
                    renderAttributes (LayoutElement layout) order element parent stylesheet (gather attributes)
                        |> clearfix
            in
                case children of
                    Normal childList ->
                        let
                            childHtml =
                                List.indexedMap
                                    (\i child ->
                                        renderElement
                                            (Just inherit)
                                            stylesheet
                                            (detectOrder childList i)
                                            child
                                    )
                                    childList
                        in
                            Html.node node htmlAttrs childHtml

                    Keyed keyed ->
                        let
                            childHtml =
                                List.indexedMap
                                    (\i ( key, child ) ->
                                        ( key
                                        , renderElement
                                            (Just inherit)
                                            stylesheet
                                            (detectOrder keyed i)
                                            child
                                        )
                                    )
                                    keyed
                        in
                            Html.Keyed.node node htmlAttrs childHtml


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

        Position x y z ->
            let
                ( currentX, currentY, currentZ ) =
                    pos.positioned

                newX =
                    case x of
                        Nothing ->
                            currentX

                        Just a ->
                            Just a

                newY =
                    case y of
                        Nothing ->
                            currentY

                        Just a ->
                            Just a

                newZ =
                    case z of
                        Nothing ->
                            currentZ

                        Just a ->
                            Just a
            in
                { pos | positioned = ( newX, newY, newZ ) }

        PositionFrame frame ->
            { pos | frame = Just frame }

        HAlign alignment ->
            { pos | horizontal = Just alignment }

        VAlign alignment ->
            { pos | vertical = Just alignment }

        Spacing spaceX spaceY ->
            -- Spacing is converted into Margin to be rendered
            pos

        Margin box ->
            { pos | margin = Just box }

        PhantomPadding _ ->
            pos

        Padding top right bottom left ->
            let
                ( currentTop, currentRight, currentBottom, currentLeft ) =
                    pos.padding

                newTop =
                    case top of
                        Nothing ->
                            currentTop

                        Just a ->
                            Just a

                newRight =
                    case right of
                        Nothing ->
                            currentRight

                        Just a ->
                            Just a

                newBottom =
                    case bottom of
                        Nothing ->
                            currentBottom

                        Just a ->
                            Just a

                newLeft =
                    case left of
                        Nothing ->
                            currentLeft

                        Just a ->
                            Just a
            in
                { pos | padding = ( newTop, newRight, newBottom, newLeft ) }

        Hidden ->
            { pos | hidden = True }

        Opacity t ->
            { pos | opacity = Just t }

        Event ev ->
            { pos | attrs = ev :: pos.attrs }

        InputEvent ev ->
            { pos | attrs = ev :: pos.attrs }

        Attr attr ->
            { pos | attrs = attr :: pos.attrs }

        PointerEvents on ->
            { pos | pointerevents = Just on }

        GridArea name ->
            { pos | gridPosition = Just name }

        GridCoords coords ->
            case Value.gridPosition coords of
                Nothing ->
                    -- Invalid grid position like width = 0, so element should be hidden
                    { pos | hidden = True }

                Just xy ->
                    { pos | gridPosition = Just <| xy }


type Order
    = First
    | Middle Int
    | Last
    | FirstAndLast


type ElementType
    = Single
    | LayoutElement Internal.LayoutModel


alignLayout : Maybe HorizontalAlignment -> Maybe VerticalAlignment -> Internal.LayoutModel -> Internal.LayoutModel
alignLayout maybeHorizontal maybeVertical layout =
    let
        alignFlexboxHorizontal align =
            case align of
                Left ->
                    Internal.Horz (Internal.Other Internal.Left)

                Right ->
                    Internal.Horz (Internal.Other Internal.Right)

                Center ->
                    Internal.Horz (Internal.Center)

                Justify ->
                    Internal.Horz (Internal.Justify)

        alignFlexboxVertical align =
            case align of
                Top ->
                    Internal.Vert (Internal.Other Internal.Top)

                Bottom ->
                    Internal.Vert (Internal.Other Internal.Bottom)

                VerticalCenter ->
                    Internal.Vert (Internal.Center)

        alignGridHorizontal align =
            case align of
                Left ->
                    Internal.GridH (Internal.Other Internal.Left)

                Right ->
                    Internal.GridH (Internal.Other Internal.Right)

                Center ->
                    Internal.GridH (Internal.Center)

                Justify ->
                    Internal.GridH (Internal.Justify)

        alignGridVertical align =
            case align of
                Top ->
                    Internal.GridV (Internal.Other Internal.Top)

                Bottom ->
                    Internal.GridV (Internal.Other Internal.Bottom)

                VerticalCenter ->
                    Internal.GridV (Internal.Center)
    in
        case layout of
            Internal.TextLayout clearfix ->
                Internal.TextLayout clearfix

            Internal.FlexLayout dir els ->
                case ( maybeHorizontal, maybeVertical ) of
                    ( Nothing, Nothing ) ->
                        Internal.FlexLayout dir els

                    ( Just h, Nothing ) ->
                        Internal.FlexLayout dir (alignFlexboxHorizontal h :: els)

                    ( Nothing, Just v ) ->
                        Internal.FlexLayout dir (alignFlexboxVertical v :: els)

                    ( Just h, Just v ) ->
                        Internal.FlexLayout dir (alignFlexboxHorizontal h :: alignFlexboxVertical v :: els)

            Internal.Grid template els ->
                case ( maybeHorizontal, maybeVertical ) of
                    ( Nothing, Nothing ) ->
                        Internal.Grid template els

                    ( Just h, Nothing ) ->
                        Internal.Grid template (alignGridHorizontal h :: els)

                    ( Nothing, Just v ) ->
                        Internal.Grid template (alignGridVertical v :: els)

                    ( Just h, Just v ) ->
                        Internal.Grid template (alignGridHorizontal h :: alignGridVertical v :: els)


flexboxHorizontalIndividualAlignment :
    Internal.Direction
    -> HorizontalAlignment
    -> Maybe ( String, String )
flexboxHorizontalIndividualAlignment direction alignment =
    case direction of
        Internal.GoRight ->
            case alignment of
                Left ->
                    Nothing

                Right ->
                    Nothing

                Center ->
                    Nothing

                Justify ->
                    Nothing

        Internal.GoLeft ->
            case alignment of
                Left ->
                    Nothing

                Right ->
                    Nothing

                Center ->
                    Nothing

                Justify ->
                    Nothing

        Internal.Down ->
            case alignment of
                Left ->
                    Just <| "align-self" => "flex-start"

                Right ->
                    Just <| "align-self" => "flex-end"

                Center ->
                    Just <| "align-self" => "center"

                Justify ->
                    Just <| "align-self" => "stretch"

        Internal.Up ->
            case alignment of
                Left ->
                    Just <| "align-self" => "flex-start"

                Right ->
                    Just <| "align-self" => "flex-end"

                Center ->
                    Just <| "align-self" => "center"

                Justify ->
                    Just <| "align-self" => "stretch"


flexboxVerticalIndividualAlignment :
    Internal.Direction
    -> VerticalAlignment
    -> Maybe ( String, String )
flexboxVerticalIndividualAlignment direction alignment =
    case direction of
        Internal.GoRight ->
            case alignment of
                Top ->
                    Just <| "align-self" => "flex-start"

                Bottom ->
                    Just <| "align-self" => "flex-end"

                VerticalCenter ->
                    Just <| "align-self" => "center"

        Internal.GoLeft ->
            case alignment of
                Top ->
                    Just <| "align-self" => "flex-start"

                Bottom ->
                    Just <| "align-self" => "flex-end"

                VerticalCenter ->
                    Just <| "align-self" => "center"

        Internal.Down ->
            case alignment of
                Top ->
                    Nothing

                Bottom ->
                    Nothing

                VerticalCenter ->
                    Nothing

        Internal.Up ->
            case alignment of
                Top ->
                    Nothing

                Bottom ->
                    Nothing

                VerticalCenter ->
                    Nothing


renderAttributes : ElementType -> Order -> Maybe elem -> Maybe Parent -> Internal.StyleSheet elem variation -> Positionable variation msg -> List (Html.Attribute msg)
renderAttributes elType order maybeElemID parent stylesheet elem =
    let
        layout attrs =
            case elType of
                Single ->
                    if elem.inline then
                        ( "display", "inline" ) :: attrs
                    else
                        ( "display", "block" ) :: attrs

                LayoutElement lay ->
                    Property.layout elem.inline (alignLayout elem.horizontal elem.vertical lay) ++ attrs

        position attrs =
            (calcPosition (Maybe.withDefault Relative elem.frame) elem.positioned) ++ attrs

        passthrough attrs =
            case elem.pointerevents of
                Nothing ->
                    attrs

                Just False ->
                    ( "pointer-events", "none" ) :: attrs

                Just True ->
                    ( "pointer-events", "auto" ) :: attrs

        vertical attrs =
            case elem.vertical of
                Nothing ->
                    attrs

                Just align ->
                    if elem.inline && elType == Single then
                        attrs
                    else if elem.inline then
                        attrs
                    else if elem.frame /= Nothing then
                        case align of
                            Top ->
                                ( "top", "0" ) :: attrs

                            Bottom ->
                                ( "bottom", "0" ) :: attrs

                            VerticalCenter ->
                                -- If an element is centered,
                                -- it would be transformed to a single element centered layout before hitting here
                                attrs
                    else
                        case parent of
                            Nothing ->
                                attrs

                            Just { layout } ->
                                case layout of
                                    Internal.FlexLayout dir _ ->
                                        case flexboxVerticalIndividualAlignment dir align of
                                            Nothing ->
                                                attrs

                                            Just a ->
                                                a :: attrs

                                    _ ->
                                        attrs

        horizontal attrs =
            case elem.horizontal of
                Nothing ->
                    attrs

                Just align ->
                    if elem.inline && elType == Single then
                        case align of
                            Left ->
                                ( "z-index", "1" ) :: ( "float", "left" ) :: attrs

                            Right ->
                                ( "z-index", "1" ) :: ( "float", "right" ) :: attrs

                            Center ->
                                attrs

                            Justify ->
                                attrs
                    else if elem.inline then
                        attrs
                    else if elem.frame /= Nothing then
                        case align of
                            Left ->
                                ( "left", "0" ) :: attrs

                            Right ->
                                ( "right", "0" ) :: attrs

                            Center ->
                                -- If an element is centered,
                                -- it would be transformed to a single element centered layout before hitting here
                                attrs

                            Justify ->
                                attrs
                    else
                        case parent of
                            Nothing ->
                                attrs

                            Just { layout } ->
                                case layout of
                                    Internal.TextLayout _ ->
                                        case align of
                                            Left ->
                                                ( "z-index", "1" ) :: ( "float", "left" ) :: attrs

                                            Right ->
                                                ( "z-index", "1" ) :: ( "float", "right" ) :: attrs

                                            Center ->
                                                attrs

                                            Justify ->
                                                attrs

                                    Internal.FlexLayout dir _ ->
                                        case flexboxHorizontalIndividualAlignment dir align of
                                            Nothing ->
                                                attrs

                                            Just a ->
                                                a :: attrs

                                    _ ->
                                        attrs

        width attrs =
            case elem.width of
                Nothing ->
                    attrs

                Just len ->
                    case parent of
                        Just { layout, parentPadding, parentSpecifiedSpacing } ->
                            let
                                ( _, rightPad, _, leftPad ) =
                                    Maybe.withDefault ( 0, 0, 0, 0 ) parentSpecifiedSpacing

                                paddingAdjustment =
                                    (rightPad + leftPad) / 2
                            in
                                case layout of
                                    Internal.FlexLayout Internal.GoRight _ ->
                                        Property.flexWidth len paddingAdjustment :: attrs

                                    Internal.FlexLayout Internal.GoLeft _ ->
                                        Property.flexWidth len paddingAdjustment :: attrs

                                    _ ->
                                        ( "width", Value.parentAdjustedLength len paddingAdjustment ) :: attrs

                        Nothing ->
                            ( "width", Value.length len ) :: attrs

        height attrs =
            case elem.height of
                Nothing ->
                    attrs

                Just len ->
                    case parent of
                        Just { layout, parentSpecifiedSpacing } ->
                            let
                                ( topPad, _, bottomPad, _ ) =
                                    Maybe.withDefault ( 0, 0, 0, 0 ) parentSpecifiedSpacing

                                paddingAdjustment =
                                    (topPad + bottomPad) / 2
                            in
                                case layout of
                                    Internal.FlexLayout Internal.Down _ ->
                                        Property.flexHeight len :: attrs

                                    Internal.FlexLayout Internal.Up _ ->
                                        Property.flexHeight len :: attrs

                                    _ ->
                                        ( "height", Value.parentAdjustedLength len paddingAdjustment ) :: attrs

                        Nothing ->
                            ( "height", Value.length len ) :: attrs

        flexShrink attrs =
            Property.flexShrink elem parent
                |> Maybe.map (\flexShrink -> flexShrink :: attrs)
                |> Maybe.withDefault attrs

        opacity attrs =
            case elem.opacity of
                Nothing ->
                    attrs

                Just o ->
                    ( "opacity", toString o ) :: attrs

        padding attrs =
            let
                paddings =
                    renderPadding elem.padding
            in
                if List.length paddings > 0 then
                    paddings ++ attrs
                else
                    attrs

        gridPos attrs =
            case elem.gridPosition of
                Nothing ->
                    attrs

                Just area ->
                    ( "grid-area", area ) :: attrs

        spacing attrs =
            case elem.margin of
                Nothing ->
                    attrs

                Just space ->
                    ( "margin", Value.box <| adjustspacing space ) :: attrs

        -- When an element is floated, it's spacing is affected
        adjustspacing ( top, right, bottom, left ) =
            let
                halved =
                    ( top / 2
                    , right / 2
                    , bottom / 2
                    , left / 2
                    )
            in
                case parent of
                    Nothing ->
                        ( top, right, bottom, left )

                    Just { layout } ->
                        case layout of
                            Internal.TextLayout _ ->
                                case elem.horizontal of
                                    Nothing ->
                                        if order == Last || order == FirstAndLast then
                                            ( 0, 0, 0, 0 )
                                        else
                                            ( 0, 0, bottom, 0 )

                                    Just align ->
                                        if not elem.inline && elem.frame == Nothing then
                                            case align of
                                                Left ->
                                                    if order == First then
                                                        ( 0, right, bottom, 0 )
                                                    else if order == FirstAndLast then
                                                        ( 0, right, 0, 0 )
                                                    else if order == Last then
                                                        ( 0, right, 0, 0 )
                                                    else
                                                        ( 0, right, bottom, 0 )

                                                Right ->
                                                    if order == First then
                                                        ( 0, 0, bottom, left )
                                                    else if order == FirstAndLast then
                                                        ( 0, 0, 0, left )
                                                    else if order == Last then
                                                        ( 0, 0, 0, left )
                                                    else
                                                        ( 0, 0, bottom, left )

                                                _ ->
                                                    if order == Last || order == FirstAndLast then
                                                        ( 0, 0, 0, 0 )
                                                    else
                                                        ( 0, 0, bottom, 0 )
                                        else
                                            ( top
                                            , right
                                            , bottom
                                            , left
                                            )

                            _ ->
                                halved

        defaults =
            [ "box-sizing" => "border-box"
            ]

        attributes =
            case maybeElemID of
                Nothing ->
                    elem.attrs

                Just elemID ->
                    if List.length elem.variations > 0 then
                        Html.Attributes.classList (stylesheet.variations elemID elem.variations) :: elem.attrs
                    else
                        Html.Attributes.class (stylesheet.style elemID) :: elem.attrs
    in
        if elem.hidden then
            Html.Attributes.style [ ( "display", "none" ) ] :: attributes
        else if elem.expand then
            let
                expandedProps =
                    case parent of
                        Nothing ->
                            [ "width" => "100%"
                            , "height" => "100%"
                            , "margin" => "0"
                            ]

                        Just { layout, parentPadding, parentSpecifiedSpacing } ->
                            case layout of
                                Internal.TextLayout _ ->
                                    let
                                        ( top, right, bottom, left ) =
                                            parentPadding

                                        borders =
                                            List.concat
                                                [ if order == Last then
                                                    [ "border-top-right-radius" => "0"
                                                    , "border-top-left-radius" => "0"
                                                    ]
                                                  else if order == First then
                                                    [ "border-bottom-right-radius" => "0"
                                                    , "border-bottom-left-radius" => "0"
                                                    ]
                                                  else if order == FirstAndLast then
                                                    [ "border-top-right-radius" => "0"
                                                    , "border-top-left-radius" => "0"
                                                    , "border-bottom-right-radius" => "0"
                                                    , "border-bottom-left-radius" => "0"
                                                    ]
                                                  else
                                                    []
                                                ]
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
                                        , "padding" => (Value.box <| defaultPadding elem.padding parentPadding)
                                        ]
                                            ++ borders

                                Internal.FlexLayout dir flex ->
                                    let
                                        ( top, right, bottom, left ) =
                                            parentPadding

                                        ( parentSpaceTop, parentSpaceRight, parentSpaceBottom, parentSpaceLeft ) =
                                            case parentSpecifiedSpacing of
                                                Nothing ->
                                                    ( 0, 0, 0, 0 )

                                                Just p ->
                                                    p
                                    in
                                        case dir of
                                            Internal.GoRight ->
                                                width
                                                    [ "height" => ("calc(100% + " ++ toString (top + bottom - ((parentSpaceTop + parentSpaceBottom) / 2)) ++ "px")
                                                    , "margin" => "0"
                                                    , "margin-top" => (toString ((-1 * top) + (parentSpaceTop / 2)) ++ "px")
                                                    , if order == First || order == FirstAndLast then
                                                        "margin-left" => (toString (-1 * left) ++ "px")
                                                      else
                                                        "margin-left" => (toString (parentSpaceLeft / 2) ++ "px")
                                                    , if order == Last || order == FirstAndLast then
                                                        "margin-right" => (toString (-1 * right) ++ "px")
                                                      else
                                                        "margin-right" => (toString (parentSpaceRight / 2) ++ "px")
                                                    ]

                                            Internal.GoLeft ->
                                                width
                                                    [ "height" => ("calc(100% + " ++ toString (top + bottom - ((parentSpaceTop + parentSpaceBottom) / 2)) ++ "px")
                                                    , "margin" => "0"
                                                    , "margin-top" => (toString ((-1 * top) + (parentSpaceTop / 2)) ++ "px")
                                                    , if order == First || order == FirstAndLast then
                                                        "margin-right" => (toString (-1 * right) ++ "px")
                                                      else
                                                        "margin-right" => (toString (parentSpaceRight / 2) ++ "px")
                                                    , if order == Last || order == FirstAndLast then
                                                        "margin-left" => (toString (-1 * left) ++ "px")
                                                      else
                                                        "margin-left" => (toString (parentSpaceLeft / 2) ++ "px")
                                                    ]

                                            Internal.Up ->
                                                height
                                                    [ "width" => ("calc(100% + " ++ toString (left + right - ((parentSpaceLeft + parentSpaceRight) / 2)) ++ "px")
                                                    , "margin" => "0"
                                                    , "margin-left" => (toString ((-1 * left) + (parentSpaceLeft / 2)) ++ "px")
                                                    , if order == First || order == FirstAndLast then
                                                        "margin-bottom" => (toString (-1 * top) ++ "px")
                                                      else
                                                        "margin-bottom" => (toString (parentSpaceBottom / 2) ++ "px")
                                                    , if order == Last || order == FirstAndLast then
                                                        "margin-top" => (toString (-1 * bottom) ++ "px")
                                                      else
                                                        "margin-top" => (toString (parentSpaceTop / 2) ++ "px")
                                                    ]

                                            Internal.Down ->
                                                height
                                                    [ "width" => ("calc(100% + " ++ toString (left + right - ((parentSpaceLeft + parentSpaceRight) / 2)) ++ "px")
                                                    , "margin" => "0"
                                                    , "margin-left" => (toString ((-1 * left) + (parentSpaceLeft / 2)) ++ "px")
                                                    , if order == First || order == FirstAndLast then
                                                        "margin-top" => (toString (-1 * top) ++ "px")
                                                      else
                                                        "margin-top" => (toString (parentSpaceTop / 2) ++ "px")
                                                    , if order == Last || order == FirstAndLast then
                                                        "margin-bottom" => (toString (-1 * bottom) ++ "px")
                                                      else
                                                        "margin-bottom" => (toString (parentSpaceBottom / 2) ++ "px")
                                                    ]

                                _ ->
                                    []
            in
                (Html.Attributes.style
                    (("box-sizing" => "border-box") :: (passthrough <| gridPos <| layout <| spacing <| opacity <| padding <| position <| expandedProps))
                )
                    :: attributes
        else
            (Html.Attributes.style
                (passthrough <| gridPos <| layout <| spacing <| opacity <| width <| height <| padding <| horizontal <| vertical <| position <| flexShrink <| defaults)
            )
                :: attributes


renderPadding ( top, right, bottom, left ) =
    let
        format name x =
            ( name, toString x ++ "px" )
    in
        List.filterMap identity
            [ Maybe.map (format "padding-top") top
            , Maybe.map (format "padding-bottom") bottom
            , Maybe.map (format "padding-left") left
            , Maybe.map (format "padding-right") right
            ]
