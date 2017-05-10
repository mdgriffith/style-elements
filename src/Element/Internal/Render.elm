module Element.Internal.Render exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Element.Internal.Model exposing (..)
import Style.Internal.Model as Internal exposing (Length)
import Style.Internal.Render.Value as Value
import Style.Internal.Render.Property as Property


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


root : Internal.StyleSheet elem variation animation msg -> Element elem variation msg -> Html msg
root stylesheet elm =
    Html.div [ Html.Attributes.class "style-elements-root" ]
        [ embed stylesheet
        , render stylesheet elm
        ]


embed : Internal.StyleSheet elem variation animation msg -> Html msg
embed stylesheet =
    Html.node "style" [] [ Html.text stylesheet.css ]


render : Internal.StyleSheet elem variation animation msg -> Element elem variation msg -> Html msg
render stylesheet elm =
    elm
        |> adjustStructure Nothing
        |> renderElement Nothing stylesheet FirstAndLast


type alias Parent =
    { parentSpecifiedSpacing : Maybe ( Float, Float, Float, Float )
    , layout : Internal.LayoutModel
    , parentPadding : ( Float, Float, Float, Float )
    }


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

        Spacer x ->
            Spacer x

        Text dec str ->
            Text dec str

        Element node element position child otherChildren ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) position

                skipAdjustment bool =
                    Element node
                        element
                        position
                        (adjustStructure Nothing child)
                        (Maybe.map (List.map (adjustStructure Nothing)) otherChildren)
            in
                if not <| List.isEmpty centeredProps then
                    case parent of
                        Nothing ->
                            -- use Flexbox to center single elements
                            -- The flexbox element should pass through events to the parent.
                            -- elm
                            Layout Html.div
                                (Internal.FlexLayout Internal.GoRight [])
                                Nothing
                                (PointerEvents False
                                    :: PositionFrame Positioned
                                    :: Height (Internal.Percent 100)
                                    :: Width (Internal.Percent 100)
                                    :: centeredProps
                                )
                                [ Element node
                                    element
                                    (PointerEvents True :: others)
                                    (adjustStructure Nothing child)
                                    -- child
                                    (Maybe.map (List.map (adjustStructure Nothing)) otherChildren)
                                ]

                        Just Internal.TextLayout ->
                            Layout Html.div
                                (Internal.FlexLayout Internal.GoRight [])
                                Nothing
                                centeredProps
                                [ Element node
                                    element
                                    others
                                    (adjustStructure Nothing child)
                                    (Maybe.map (List.map (adjustStructure Nothing)) otherChildren)
                                ]

                        _ ->
                            skipAdjustment True
                else
                    skipAdjustment True

        Layout node layout element position children ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) position

                isFlex =
                    case layout of
                        Internal.FlexLayout _ _ ->
                            True

                        _ ->
                            False

                spacing =
                    List.filterMap forSpacing position
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
            in
                case layout of
                    Internal.TextLayout ->
                        if not <| List.isEmpty centeredProps then
                            Layout
                                Html.div
                                (Internal.FlexLayout Internal.GoRight [])
                                Nothing
                                centeredProps
                                [ Layout node layout element others (List.map (adjustStructure (Just layout)) children) ]
                        else
                            Layout node layout element position (List.map (adjustStructure (Just layout)) children)

                    Internal.FlexLayout _ _ ->
                        if hasSpacing then
                            let
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
                            in
                                Layout
                                    Html.div
                                    (Internal.FlexLayout Internal.GoRight [])
                                    element
                                    position
                                    [ Layout
                                        node
                                        layout
                                        Nothing
                                        (Margin negativeMargin :: spacingAttr :: Width (Internal.Calc 100 totalHSpacing) :: [])
                                        (List.map (adjustStructure (Just layout)) children)
                                    ]
                        else
                            Layout node layout element position (List.map (adjustStructure (Just layout)) children)

                    _ ->
                        Layout node layout element position (List.map (adjustStructure (Just layout)) children)


renderElement : Maybe Parent -> Internal.StyleSheet elem variation animation msg -> Order -> Element elem variation msg -> Html msg
renderElement parent stylesheet order elm =
    case elm of
        Empty ->
            Html.text ""

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

        Element node element position child otherChildren ->
            let
                childHtml =
                    case otherChildren of
                        Nothing ->
                            [ renderElement Nothing stylesheet FirstAndLast child ]

                        Just others ->
                            List.map (renderElement Nothing stylesheet FirstAndLast) (child :: others)

                attributes =
                    case parent of
                        Nothing ->
                            spacingToMargin position

                        Just ctxt ->
                            case ctxt.parentSpecifiedSpacing of
                                Nothing ->
                                    spacingToMargin position

                                Just ( top, right, bottom, left ) ->
                                    Margin ( top, right, bottom, left ) :: spacingToMargin position

                htmlAttrs =
                    renderAttributes Single order element parent stylesheet (gather attributes)
            in
                node htmlAttrs childHtml

        Layout node layout element position children ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) position

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
                        Internal.TextLayout ->
                            Html.Attributes.class "clearfix" :: attrs

                        _ ->
                            attrs

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

                findSpacing posAttr =
                    case posAttr of
                        Spacing x y ->
                            Just ( y, x, y, x )

                        _ ->
                            Nothing

                forSpacing =
                    (\x -> x /= Nothing) << findSpacing

                ( spacing, attrs ) =
                    List.partition forSpacing position

                inherit =
                    { parentSpecifiedSpacing =
                        List.filterMap findSpacing position
                            |> List.head
                    , layout = layout
                    , parentPadding = padding
                    }

                childHtml =
                    List.indexedMap
                        (\i child ->
                            renderElement
                                (Just inherit)
                                stylesheet
                                (detectOrder children i)
                                child
                        )
                        children

                htmlAttrs =
                    renderAttributes (LayoutElement layout) order element parent stylesheet (gather attributes)
                        |> clearfix
            in
                node (htmlAttrs) childHtml


type alias Positionable variation msg =
    { inline : Bool
    , horizontal : Maybe HorizontalAlignment
    , vertical : Maybe VerticalAlignment
    , frame : Maybe Frame
    , expand : Bool
    , hidden : Bool
    , width : Maybe Internal.Length
    , height : Maybe Internal.Length
    , positioned : ( Maybe Float, Maybe Float, Maybe Float )
    , margin : Maybe ( Float, Float, Float, Float )
    , padding : Maybe ( Float, Float, Float, Float )
    , variations : List ( variation, Bool )
    , transparency : Maybe Int
    , gridPosition : Maybe String
    , pointerevents : Maybe Bool
    , attrs : List (Html.Attribute msg)
    }


emptyPositionable : Positionable variation msg
emptyPositionable =
    { inline = False
    , horizontal = Nothing
    , vertical = Nothing
    , frame = Nothing
    , expand = False
    , hidden = False
    , width = Nothing
    , height = Nothing
    , positioned = ( Nothing, Nothing, Nothing )
    , margin = Nothing
    , padding = Nothing
    , variations = []
    , transparency = Nothing
    , gridPosition = Nothing
    , pointerevents = Nothing
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

        Padding box ->
            { pos | padding = Just box }

        Hidden ->
            { pos | hidden = True }

        Transparency t ->
            { pos | transparency = Just t }

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
            Internal.TextLayout ->
                Internal.TextLayout

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


renderAttributes : ElementType -> Order -> Maybe elem -> Maybe Parent -> Internal.StyleSheet elem variation animation msg -> Positionable variation msg -> List (Html.Attribute msg)
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
                                    Internal.TextLayout ->
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
                        Just { layout } ->
                            case layout of
                                Internal.FlexLayout Internal.GoRight _ ->
                                    Property.flexWidth len :: attrs

                                Internal.FlexLayout Internal.GoLeft _ ->
                                    Property.flexWidth len :: attrs

                                _ ->
                                    ( "width", Value.length len ) :: attrs

                        Nothing ->
                            ( "width", Value.length len ) :: attrs

        height attrs =
            case elem.height of
                Nothing ->
                    attrs

                Just len ->
                    case parent of
                        Just { layout } ->
                            case layout of
                                Internal.FlexLayout Internal.Down _ ->
                                    Property.flexHeight len :: attrs

                                Internal.FlexLayout Internal.Up _ ->
                                    Property.flexHeight len :: attrs

                                _ ->
                                    ( "height", Value.length len ) :: attrs

                        Nothing ->
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
            let
                ( x, y, z ) =
                    elem.positioned
            in
                case elem.positioned of
                    ( Nothing, Nothing, Nothing ) ->
                        attrs

                    ( x, y, Nothing ) ->
                        ( "transform"
                        , ("translate("
                            ++ toString (Maybe.withDefault 0 x)
                            ++ "px, "
                            ++ toString (Maybe.withDefault 0 y)
                            ++ "px)"
                          )
                        )
                            :: attrs

                    ( x, y, z ) ->
                        ( "transform"
                        , ("translate3d("
                            ++ toString (Maybe.withDefault 0 x)
                            ++ "px, "
                            ++ toString (Maybe.withDefault 0 y)
                            ++ "px, "
                            ++ toString (Maybe.withDefault 0 z)
                            ++ "px)"
                          )
                        )
                            :: attrs

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
                        halved

                    Just { layout } ->
                        case layout of
                            Internal.TextLayout ->
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
                                                        ( top, right, 0, 0 )
                                                    else
                                                        ( top, right, bottom, 0 )

                                                Right ->
                                                    if order == First then
                                                        ( 0, 0, bottom, left )
                                                    else if order == FirstAndLast then
                                                        ( 0, 0, 0, left )
                                                    else if order == Last then
                                                        ( top, 0, 0, left )
                                                    else
                                                        ( top, 0, bottom, left )

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
                                Screen ->
                                    [ ( "position", "fixed" ) ]

                                Positioned ->
                                    [ ( "position", "absolute" ) ]

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
                        :: (passthrough <| gridPos <| layout <| spacing <| transparency <| width <| height <| positionAdjustment <| padding <| horizontal <| vertical <| frame)
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
                                , case elem.padding of
                                    Nothing ->
                                        ( "padding", Value.box parentPadding )

                                    Just pad ->
                                        ( "padding", Value.box pad )
                                ]
                                    ++ borders
            in
                (Html.Attributes.style
                    (("box-sizing" => "border-box") :: (passthrough <| gridPos <| layout <| spacing <| transparency <| positionAdjustment <| expandedProps))
                )
                    :: attributes
        else
            (Html.Attributes.style
                (passthrough <| gridPos <| layout <| spacing <| transparency <| width <| height <| positionAdjustment <| padding <| horizontal <| vertical <| defaults)
            )
                :: attributes
