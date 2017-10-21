module Element.Internal.Render exposing (..)

{-| -}

import Element.Internal.Adjustments as Adjustments
import Element.Internal.Model exposing (..)
import Html exposing (Html)
import Html.Attributes
import Html.Keyed
import Style.Internal.Model as Internal exposing (Length)
import Style.Internal.Render.Property as Property
import Style.Internal.Render.Value as Value


{-| A modified version of CSS normalize is used.

The unminified version lives in `references/modified-normalize.css`.

-}
qualifiedNormalize : String
qualifiedNormalize =
    """html{-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%;margin:0;padding:0;border:0}body{margin:0}.style-elements article,.style-elements aside,.style-elements footer,.style-elements header,.style-elements nav,.style-elements section{display:block}.style-elements h1{font-size:1em;margin:0}.style-elements figcaption,.style-elements figure,.style-elements main{display:block}.style-elements figure{margin:1em 40px}.style-elements hr{box-sizing:content-box;height:0;overflow:visible}.style-elements pre{font-family:monospace, monospace;font-size:1em}.style-elements a{background-color:transparent;-webkit-text-decoration-skip:objects}.style-elements abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}.style-elements b,.style-elements strong{font-weight:inherit}.style-elements b,.style-elements strong{font-weight:bolder}.style-elements code,.style-elements kbd,.style-elements samp{font-family:monospace, monospace;font-size:1em}.style-elements dfn{font-style:italic}.style-elements mark{background-color:#ff0;color:#000}.style-elements small{font-size:80%}.style-elements audio,.style-elements video{display:inline-block}.style-elements audio:not([controls]){display:none;height:0}.style-elements img{border-style:none}.style-elements svg:not(:root){overflow:hidden}.style-elements button,.style-elements input,.style-elements optgroup,.style-elements select,.style-elements textarea{font-family:sans-serif;font-size:100%;margin:0}.style-elements button,.style-elements input{overflow:visible}.style-elements button,.style-elements select{text-transform:none}.style-elements button,.style-elements html [type="button"],.style-elements [type="reset"],.style-elements [type="submit"]{-webkit-appearance:button}.style-elements [type="button"]::-moz-focus-inner,.style-elements [type="reset"]::-moz-focus-inner,.style-elements [type="submit"]::-moz-focus-inner,.style-elements button::-moz-focus-inner{border-style:none;padding:0}.style-elements [type="button"]:-moz-focusring,.style-elements [type="reset"]:-moz-focusring,.style-elements [type="submit"]:-moz-focusring,.style-elements button:-moz-focusring{outline:1px dotted ButtonText}.style-elements fieldset{padding:0.35em 0.75em 0.625em}.style-elements legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}.style-elements progress{display:inline-block;vertical-align:baseline}.style-elements textarea{overflow:auto}.style-elements [type="checkbox"],.style-elements [type="radio"]{box-sizing:border-box;padding:0}.style-elements [type="number"]::-webkit-inner-spin-button,.style-elements [type="number"]::-webkit-outer-spin-button{height:auto}.style-elements [type="search"]{-webkit-appearance:textfield;outline-offset:-2px}.style-elements [type="search"]::-webkit-search-cancel-button,.style-elements [type="search"]::-webkit-search-decoration{-webkit-appearance:none}.style-elements::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}.style-elements details,.style-elements menu{display:block}.style-elements summary{display:list-item}.style-elements canvas{display:inline-block}.style-elements template{display:none}.style-elements [hidden]{display:none}.style-elements a{text-decoration:none}.style-elements input,.style-elements textarea{border:0}.style-elements .clearfix:after{content:"";display:table;clear:both}.style-elements a,.style-elements abbr,.style-elements acronym,.style-elements address,.style-elements applet,.style-elements article,.style-elements aside,.style-elements audio,.style-elements b,.style-elements big,.style-elements blockquote,.style-elements canvas,.style-elements caption,.style-elements center,.style-elements cite,.style-elements code,.style-elements dd,.style-elements del,.style-elements details,.style-elements dfn,.style-elements div,.style-elements dl,.style-elements dt,.style-elements em,.style-elements embed,.style-elements fieldset,.style-elements figcaption,.style-elements figure,.style-elements footer,.style-elements form,.style-elements h1,.style-elements h2,.style-elements h3,.style-elements h4,.style-elements h5,.style-elements h6,.style-elements header,.style-elements hgroup,.style-elements hr,.style-elements i,.style-elements iframe,.style-elements img,.style-elements ins,.style-elements kbd,.style-elements label,.style-elements legend,.style-elements li,.style-elements mark,.style-elements menu,.style-elements nav,.style-elements object,.style-elements ol,.style-elements output,.style-elements p,.style-elements pre,.style-elements q,.style-elements ruby,.style-elements s,.style-elements samp,.style-elements section,.style-elements small,.style-elements span,.style-elements strike,.style-elements strong,.style-elements sub,.style-elements summary,.style-elements sup,.style-elements table,.style-elements tbody,.style-elements td,.style-elements tfoot,.style-elements th,.style-elements thead,.style-elements time,.style-elements tr,.style-elements tt,.style-elements u,.style-elements ul,.style-elements var,.style-elements video{margin:0;padding:0;border:0;font-size:100%;font:inherit;box-sizing:border-box}.style-elements{margin:0;padding:0;border:0;font-size:100%;font:inherit;line-height:1}.style-elements em.el{font-style:italic}.style-elements strong.el{font-weight:bold}.style-elements strike.el{text-decoration:line-through}.style-elements u.el{text-decoration:underline}.style-elements sub.el,.style-elements sup.el{font-size:75%;line-height:0;position:relative;vertical-align:baseline}.style-elements sub.el{bottom:-0.25em}.style-elements sup.el{top:-0.5em}""" ++ withFocus


miniNormalize : String
miniNormalize =
    """html{-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%;margin:0;padding:0;border:0}body{margin:0}.style-elements{display:block;position:relative;margin:0;padding:0;border:0;font-size:100%;font:inherit;box-sizing:border-box;line-height:1.2}.el{display:block;position:relative;margin:0;padding:0;border:0;border-style:solid;font-size:100%;font:inherit;box-sizing:border-box}em.el{font-style:italic}b.el,strong.el{font-weight:bolder}strike.el{text-decoration:line-through}u.el{text-decoration:underline}a.el{text-decoration:none;color:inherit}img.el{border-style:none}sub.el,sup.el{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub.el{bottom:-0.25em}sup.el{top:-0.5em}""" ++ withFocus


withFocus : String
withFocus =
    """

.style-elements em.el {
    padding: 0;
    padding-left: 0.2em;
}

.style-elements button.button-focus:focus {
   outline: none;
   box-shadow: 0 0 3px 3px rgba(155,203,255,1.0);
   border-color: rgba(155,203,255,1.0);
}

.style-elements textarea:focus, .style-elements input:focus {
   outline: none;
   box-shadow: 0 0 2px 2px rgba(155,203,255,1.0);
   border-color: rgba(155,203,255,1.0);
}
.style-elements input[type='checkbox'] {
    border-radius: 3px;
}
.style-elements input[type='radio'] {
    border-radius: 7px;
}
.style-elements input[type='radio']:focus {
    border-radius: 7px;
    box-shadow: 0 0 4px 4px rgba(155,203,255,1.0);
}

.style-elements select.focus-override:focus, .style-elements input.focus-override:focus {
    outline: none;
    box-shadow: none;
    border-color:transparent;
}
.style-elements input.focus-override:focus ~ .alt-icon {
    box-shadow: 0 0 3px 3px rgba(155,203,255,1.0);
    border-color: rgba(155,203,255,1.0);
}
.style-elements select.focus-override:focus ~ .alt-icon {
    box-shadow: 0 0 3px 3px rgba(155,203,255,1.0);
    border-color: rgba(155,203,255,1.0);
}
.style-elements .arrows {
    display:block;
    position: relative;
    height: 10px;
    width: 10px;
}
/*
.style-elements .arrows::after {
    content: " ";
    position:absolute;
    top:-2px;
    left:0;
    width: 0;
    height: 0;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    border-bottom: 5px solid black;
}
*/

.style-elements .arrows::before {
    content: " ";
    position:absolute;
    top:2px;
    left:0;
    width: 0;
    height: 0;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    border-top: 5px solid black;
}


"""


viewport : Internal.StyleSheet elem variation -> Element elem variation msg -> Html msg
viewport stylesheet elm =
    Html.div
        [ Html.Attributes.class "style-elements"
        , Html.Attributes.style
            [ ( "width", "100%" )
            , ( "height", "100%" )
            ]
        ]
        (embed True stylesheet ++ render stylesheet elm)


root : Internal.StyleSheet elem variation -> Element elem variation msg -> Html msg
root stylesheet elm =
    Html.div [ Html.Attributes.class "style-elements" ]
        (embed False stylesheet ++ render stylesheet elm)


embed : Bool -> Internal.StyleSheet elem variation -> List (Html msg)
embed full stylesheet =
    [ Html.node "style"
        []
        [ Html.text <|
            if full then
                "html,body{width:100%;height:100%;}" ++ miniNormalize
            else
                miniNormalize
        ]
    , Html.node "style"
        []
        [ Html.text
            stylesheet.css
        ]
    ]


render : Internal.StyleSheet elem variation -> Element elem variation msg -> List (Html msg)
render stylesheet elm =
    let
        ( adjusted, onScreen ) =
            Adjustments.apply elm

        fixedScreenElements =
            case onScreen of
                Nothing ->
                    []

                Just screenEls ->
                    List.map (renderElement Nothing stylesheet FirstAndLast) screenEls
    in
    renderElement Nothing stylesheet FirstAndLast adjusted
        :: fixedScreenElements


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
            [ ( "position", "relative" )
            , ( "left", toString x ++ "px" )
            , ( "top", toString y ++ "px" )
            ]

        Screen ->
            [ ( "position", "fixed" )
            , ( "left", toString x ++ "px" )
            , ( "top", toString y ++ "px" )
            , ( "z-index", "1000" )
            ]

        Absolute TopLeft ->
            List.filterMap identity
                [ Just ( "position", "absolute" )
                , case mx of
                    Just x ->
                        Just ( "left", toString x ++ "px" )

                    Nothing ->
                        Nothing
                , case my of
                    Just y ->
                        Just ( "top", toString y ++ "px" )

                    Nothing ->
                        Nothing
                ]

        Absolute BottomLeft ->
            List.filterMap identity
                [ Just ( "position", "absolute" )
                , case mx of
                    Just x ->
                        Just ( "left", toString x ++ "px" )

                    Nothing ->
                        Nothing
                , case my of
                    Just y ->
                        Just ( "bottom", toString y ++ "px" )

                    Nothing ->
                        Nothing
                ]

        Nearby Within ->
            [ ( "position", "relative" )
            , ( "top", toString y ++ "px" )
            , ( "left", toString x ++ "px" )
            ]

        Nearby Above ->
            [ ( "position", "relative" )
            , ( "top", toString y ++ "px" )
            , ( "left", toString x ++ "px" )
            ]

        Nearby Below ->
            [ ( "position", "relative" )
            , ( "top", "calc(100% + " ++ toString y ++ "px)" )
            , ( "left", toString x ++ "px" )
            ]

        Nearby OnLeft ->
            [ ( "position", "relative" )
            , ( "right", "calc(100% - " ++ toString x ++ "px)" )
            , ( "top", toString y ++ "px" )
            ]

        Nearby OnRight ->
            [ ( "position", "relative" )
            , ( "left", "calc(100% + " ++ toString x ++ "px)" )
            , ( "top", toString y ++ "px" )
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
                    [ ( "width", toString (x * spacingX) ++ "px" )
                    , ( "height", toString (x * spacingY) ++ "px" )
                    , ( "visibility", "hidden" )
                    ]
            in
            Html.div [ Html.Attributes.style inline ] []

        Text { decoration, inline } str ->
            let
                attrs =
                    if inline then
                        Html.Attributes.style
                            [ ( "display", "inline" ) ]
                    else
                        Html.Attributes.style
                            [ ( "white-space", "pre" )
                            , ( "text-overflow", "ellipsis" )
                            , ( "overflow", "hidden" )
                            , ( "display", "block" )
                            ]
            in
            case decoration of
                NoDecoration ->
                    Html.span [ Html.Attributes.class "el", attrs ] [ Html.text str ]

                RawText ->
                    Html.text str

                Bold ->
                    Html.strong [ Html.Attributes.class "el", attrs ] [ Html.text str ]

                Italic ->
                    Html.em [ Html.Attributes.class "el", attrs ] [ Html.text str ]

                Underline ->
                    Html.u [ Html.Attributes.class "el", attrs ] [ Html.text str ]

                Strike ->
                    Html.s [ Html.Attributes.class "el", attrs ] [ Html.text str ]

                Super ->
                    Html.sup [ Html.Attributes.class "el", attrs ] [ Html.text str ]

                Sub ->
                    Html.sub [ Html.Attributes.class "el", attrs ] [ Html.text str ]

        Element { node, style, attrs, child, absolutelyPositioned } ->
            let
                childHtml =
                    case absolutelyPositioned of
                        Nothing ->
                            [ renderElement Nothing stylesheet FirstAndLast child ]

                        Just absol ->
                            List.map (renderElement Nothing stylesheet FirstAndLast) (child :: absol)

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
                    renderAttributes Single order style parent stylesheet (gather attributes)
            in
            Html.node node (Html.Attributes.class "el" :: htmlAttrs) childHtml

        Layout { node, layout, style, attrs, children, absolutelyPositioned } ->
            let
                -- TODO RENDER ABSOLUTELY POSITIONED CHILDREN
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

                isFlexbox layout =
                    case layout of
                        Internal.FlexLayout _ _ ->
                            True

                        _ ->
                            False

                -- Insert intermediate div if there are two display:flex items touching.
                adjacentFlexboxCorrection htmlNode =
                    case parent of
                        Nothing ->
                            htmlNode

                        Just p ->
                            if isFlexbox p.layout && isFlexbox layout then
                                -- Html.div [] [ htmlNode ]
                                htmlNode
                            else
                                htmlNode

                htmlAttrs =
                    renderAttributes (LayoutElement layout) order style parent stylesheet (gather attributes)
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

                        allChildren =
                            case absolutelyPositioned of
                                Nothing ->
                                    childHtml

                                Just absol ->
                                    childHtml ++ List.map (renderElement Nothing stylesheet FirstAndLast) absol
                    in
                    adjacentFlexboxCorrection <| Html.node node (Html.Attributes.class "el" :: htmlAttrs) allChildren

                Keyed keyed ->
                    let
                        -- DOES NOT RENDER ABSOLUTE CHILDREN
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
                    adjacentFlexboxCorrection <| Html.Keyed.node node (Html.Attributes.class "el" :: htmlAttrs) childHtml


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
    , padding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float )
    , variations : List ( variation, Bool )
    , opacity : Maybe Float
    , gridPosition : Maybe String
    , pointerevents : Maybe Bool
    , attrs : List (Html.Attribute msg)
    , shrink : Maybe Int
    , overflow : Maybe Axis
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
    , padding = ( Nothing, Nothing, Nothing, Nothing )
    , variations = []
    , opacity = Nothing
    , gridPosition = Nothing
    , pointerevents = Nothing
    , attrs = []
    , shrink = Nothing
    , overflow = Nothing
    }


gather : List (Attribute variation msg) -> Positionable variation msg
gather attrs =
    List.foldl makePositionable emptyPositionable attrs


makePositionable : Attribute variation msg -> Positionable variation msg -> Positionable variation msg
makePositionable attr pos =
    case attr of
        Overflow x ->
            { pos | overflow = Just x }

        Shrink i ->
            { pos | shrink = Just i }

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
                    Internal.Horz Internal.Center

                Justify ->
                    Internal.Horz Internal.Justify

        alignFlexboxVertical align =
            case align of
                Top ->
                    Internal.Vert (Internal.Other Internal.Top)

                Bottom ->
                    Internal.Vert (Internal.Other Internal.Bottom)

                VerticalCenter ->
                    Internal.Vert Internal.Center

                VerticalJustify ->
                    Internal.Vert Internal.Justify

        alignGridHorizontal align =
            case align of
                Left ->
                    Internal.GridH (Internal.Other Internal.Left)

                Right ->
                    Internal.GridH (Internal.Other Internal.Right)

                Center ->
                    Internal.GridH Internal.Center

                Justify ->
                    Internal.GridH Internal.Justify

        alignGridVertical align =
            case align of
                Top ->
                    Internal.GridV (Internal.Other Internal.Top)

                Bottom ->
                    Internal.GridV (Internal.Other Internal.Bottom)

                VerticalCenter ->
                    Internal.GridV Internal.Center

                VerticalJustify ->
                    Internal.GridV Internal.Justify
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
                    Just ( "align-self", "flex-start" )

                Right ->
                    Just ( "align-self", "flex-end" )

                Center ->
                    Just ( "align-self", "center" )

                Justify ->
                    Just ( "align-self", "stretch" )

        Internal.Up ->
            case alignment of
                Left ->
                    Just ( "align-self", "flex-start" )

                Right ->
                    Just ( "align-self", "flex-end" )

                Center ->
                    Just ( "align-self", "center" )

                Justify ->
                    Just ( "align-self", "stretch" )


flexboxVerticalIndividualAlignment :
    Internal.Direction
    -> VerticalAlignment
    -> Maybe ( String, String )
flexboxVerticalIndividualAlignment direction alignment =
    case direction of
        Internal.GoRight ->
            case alignment of
                Top ->
                    Just ( "align-self", "flex-start" )

                Bottom ->
                    Just ( "align-self", "flex-end" )

                VerticalCenter ->
                    Just ( "align-self", "center" )

                VerticalJustify ->
                    Just ( "align-self", "center" )

        Internal.GoLeft ->
            case alignment of
                Top ->
                    Just ( "align-self", "flex-start" )

                Bottom ->
                    Just ( "align-self", "flex-end" )

                VerticalCenter ->
                    Just ( "align-self", "center" )

                VerticalJustify ->
                    Just ( "align-self", "center" )

        Internal.Down ->
            case alignment of
                Top ->
                    Nothing

                Bottom ->
                    Nothing

                VerticalCenter ->
                    Nothing

                VerticalJustify ->
                    Nothing

        Internal.Up ->
            case alignment of
                Top ->
                    Nothing

                Bottom ->
                    Nothing

                VerticalCenter ->
                    Nothing

                VerticalJustify ->
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
            calcPosition (Maybe.withDefault Relative elem.frame) elem.positioned ++ attrs

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

                            VerticalJustify ->
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
                        case elType of
                            LayoutElement _ ->
                                attrs

                            Single ->
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

        overflow attrs =
            case elem.overflow of
                Nothing ->
                    attrs

                Just o ->
                    case o of
                        XAxis ->
                            ( "overflow-x", "auto" ) :: attrs

                        YAxis ->
                            ( "overflow-y", "auto" ) :: attrs

                        AllAxis ->
                            ( "overflow", "auto" ) :: attrs

        shrink attrs =
            case elem.shrink of
                Just i ->
                    ( "flex-shrink", toString i ) :: attrs

                Nothing ->
                    case parent of
                        Nothing ->
                            attrs

                        Just { layout } ->
                            let
                                isPercent x =
                                    case x of
                                        Just (Internal.Percent _) ->
                                            True

                                        _ ->
                                            False

                                isPx x =
                                    case x of
                                        Just (Internal.Px _) ->
                                            True

                                        _ ->
                                            False

                                isHorizontal dir =
                                    case dir of
                                        Internal.GoRight ->
                                            True

                                        Internal.GoLeft ->
                                            True

                                        _ ->
                                            False

                                isVertical dir =
                                    case dir of
                                        Internal.Up ->
                                            True

                                        Internal.Down ->
                                            True

                                        _ ->
                                            False

                                verticalOverflow =
                                    case elem.overflow of
                                        Just XAxis ->
                                            False

                                        Just YAxis ->
                                            True

                                        Just AllAxis ->
                                            True

                                        _ ->
                                            False

                                horizontalOverflow =
                                    case elem.overflow of
                                        Just XAxis ->
                                            True

                                        Just YAxis ->
                                            False

                                        Just AllAxis ->
                                            True

                                        _ ->
                                            False
                            in
                            case layout of
                                Internal.FlexLayout dir _ ->
                                    if isHorizontal dir && isPx elem.width then
                                        ( "flex-shrink", "0" ) :: attrs
                                    else if isHorizontal dir && isPercent elem.width then
                                        ( "flex-shrink", "0" ) :: attrs
                                    else if isHorizontal dir && elem.width /= Nothing then
                                        ( "flex-shrink", "1" ) :: attrs
                                    else if isHorizontal dir && horizontalOverflow then
                                        ( "flex-shrink", "1" ) :: attrs
                                    else if isVertical dir && isPx elem.height then
                                        ( "flex-shrink", "0" ) :: attrs
                                    else if isVertical dir && isPercent elem.height then
                                        ( "flex-shrink", "0" ) :: attrs
                                    else if isVertical dir && elem.height /= Nothing then
                                        ( "flex-shrink", "1" ) :: attrs
                                    else if isVertical dir && verticalOverflow then
                                        ( "flex-shrink", "1" ) :: attrs
                                        -- If width is not set, then we want it to wrap,
                                        -- which apparently involves flex-shrink being 1
                                    else if isHorizontal dir && elem.width == Nothing then
                                        ( "flex-shrink", "1" ) :: attrs
                                    else if isVertical dir && elem.height == Nothing then
                                        case elType of
                                            Single ->
                                                ( "flex-shrink", "1" ) :: attrs

                                            LayoutElement elLayout ->
                                                ( "flex-shrink", "0" ) :: attrs
                                    else
                                        ( "flex-shrink", "0" ) :: attrs

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
                                    Property.flexWidth len paddingAdjustment ++ attrs

                                Internal.FlexLayout Internal.GoLeft _ ->
                                    Property.flexWidth len paddingAdjustment ++ attrs

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

                                hundredPercentOrFill x =
                                    case x of
                                        Internal.Percent p ->
                                            p == 100

                                        Internal.Fill _ ->
                                            True

                                        Internal.Calc perc _ ->
                                            perc == 100

                                        _ ->
                                            False
                            in
                            case layout of
                                Internal.FlexLayout Internal.Down _ ->
                                    Property.flexHeight len ++ attrs

                                Internal.FlexLayout Internal.Up _ ->
                                    Property.flexHeight len ++ attrs

                                Internal.FlexLayout Internal.GoRight _ ->
                                    if hundredPercentOrFill len then
                                        ( "height", "auto" ) :: attrs
                                    else
                                        ( "height", Value.parentAdjustedLength len paddingAdjustment ) :: attrs

                                Internal.FlexLayout Internal.GoLeft _ ->
                                    if hundredPercentOrFill len then
                                        ( "height", "auto" ) :: attrs
                                    else
                                        ( "height", Value.parentAdjustedLength len paddingAdjustment ) :: attrs

                                _ ->
                                    ( "height", Value.parentAdjustedLength len paddingAdjustment ) :: attrs

                        Nothing ->
                            ( "height", Value.length len ) :: attrs

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

                onScreen =
                    case elem.frame of
                        Just Screen ->
                            True

                        _ ->
                            False
            in
            if onScreen then
                ( 0, 0, 0, 0 )
            else
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
                                        else if elem.inline then
                                            -- If an element is inline, spacing is horizontal, otherwise it's vertical.
                                            ( 0, right, 0, 0 )
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
            [ ( "box-sizing", "border-box" )
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
                        [ ( "width", "100%" )
                        , ( "height", "100%" )
                        , ( "margin", "0" )
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
                                                [ ( "border-top-right-radius", "0" )
                                                , ( "border-top-left-radius", "0" )
                                                ]
                                              else if order == First then
                                                [ ( "border-bottom-right-radius", "0" )
                                                , ( "border-bottom-left-radius", "0" )
                                                ]
                                              else if order == FirstAndLast then
                                                [ ( "border-top-right-radius", "0" )
                                                , ( "border-top-left-radius", "0" )
                                                , ( "border-bottom-right-radius", "0" )
                                                , ( "border-bottom-left-radius", "0" )
                                                ]
                                              else
                                                []
                                            ]
                                in
                                [ ( "width", "calc(100% + " ++ toString (right + left) ++ "px" )
                                , ( "margin", "0" )
                                , ( "margin-left", toString (-1 * left) ++ "px" )
                                , if order == First || order == FirstAndLast then
                                    ( "margin-top", toString (-1 * top) ++ "px" )
                                  else
                                    ( "margin-top", "0" )
                                , if order == Last || order == FirstAndLast then
                                    ( "margin-bottom", toString (-1 * bottom) ++ "px" )
                                  else
                                    ( "margin-bottom", "0" )
                                , ( "padding", Value.box <| defaultPadding elem.padding parentPadding )
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
                                            [ ( "height", "calc(100% + " ++ toString (top + bottom - ((parentSpaceTop + parentSpaceBottom) / 2)) ++ "px" )
                                            , ( "margin", "0" )
                                            , ( "margin-top", toString ((-1 * top) + (parentSpaceTop / 2)) ++ "px" )
                                            , if order == First || order == FirstAndLast then
                                                ( "margin-left", toString (-1 * left) ++ "px" )
                                              else
                                                ( "margin-left", toString (parentSpaceLeft / 2) ++ "px" )
                                            , if order == Last || order == FirstAndLast then
                                                ( "margin-right", toString (-1 * right) ++ "px" )
                                              else
                                                ( "margin-right", toString (parentSpaceRight / 2) ++ "px" )
                                            ]

                                    Internal.GoLeft ->
                                        width
                                            [ ( "height", "calc(100% + " ++ toString (top + bottom - ((parentSpaceTop + parentSpaceBottom) / 2)) ++ "px" )
                                            , ( "margin", "0" )
                                            , ( "margin-top", toString ((-1 * top) + (parentSpaceTop / 2)) ++ "px" )
                                            , if order == First || order == FirstAndLast then
                                                ( "margin-right", toString (-1 * right) ++ "px" )
                                              else
                                                ( "margin-right", toString (parentSpaceRight / 2) ++ "px" )
                                            , if order == Last || order == FirstAndLast then
                                                ( "margin-left", toString (-1 * left) ++ "px" )
                                              else
                                                ( "margin-left", toString (parentSpaceLeft / 2) ++ "px" )
                                            ]

                                    Internal.Up ->
                                        height
                                            [ ( "width", "calc(100% + " ++ toString (left + right - ((parentSpaceLeft + parentSpaceRight) / 2)) ++ "px" )
                                            , ( "margin", "0" )
                                            , ( "margin-left", toString ((-1 * left) + (parentSpaceLeft / 2)) ++ "px" )
                                            , if order == First || order == FirstAndLast then
                                                ( "margin-bottom", toString (-1 * top) ++ "px" )
                                              else
                                                ( "margin-bottom", toString (parentSpaceBottom / 2) ++ "px" )
                                            , if order == Last || order == FirstAndLast then
                                                ( "margin-top", toString (-1 * bottom) ++ "px" )
                                              else
                                                ( "margin-top", toString (parentSpaceTop / 2) ++ "px" )
                                            ]

                                    Internal.Down ->
                                        height
                                            [ ( "width", "calc(100% + " ++ toString (left + right - ((parentSpaceLeft + parentSpaceRight) / 2)) ++ "px" )
                                            , ( "margin", "0" )
                                            , ( "margin-left", toString ((-1 * left) + (parentSpaceLeft / 2)) ++ "px" )
                                            , if order == First || order == FirstAndLast then
                                                ( "margin-top", toString (-1 * top) ++ "px" )
                                              else
                                                ( "margin-top", toString (parentSpaceTop / 2) ++ "px" )
                                            , if order == Last || order == FirstAndLast then
                                                ( "margin-bottom", toString (-1 * bottom) ++ "px" )
                                              else
                                                ( "margin-bottom", toString (parentSpaceBottom / 2) ++ "px" )
                                            ]

                            _ ->
                                []
        in
        Html.Attributes.style
            (defaults ++ ((passthrough << gridPos << layout << spacing << opacity << shrink << padding << position << overflow) <| expandedProps))
            :: attributes
    else
        Html.Attributes.style
            ((passthrough << gridPos << layout << spacing << opacity << shrink << width << height << padding << horizontal << vertical << position << overflow) <| defaults)
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
