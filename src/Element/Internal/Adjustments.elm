module Element.Internal.Adjustments exposing (..)

{-| This module captures all the structure adjustments that need to takes place on the html before it is rendered.
-}

import Element.Internal.Model exposing (..)
import Element.Internal.Modify as Modify
import Html.Attributes
import Style.Internal.Model as Internal exposing (Length)


apply : Element style variation msg -> ( Element style variation msg, Maybe (List (Element style variation msg)) )
apply root =
    let
        stack parent el =
            el
                |> (centerTextLayout
                        >> positionNearby parent
                        >> hoistFixedScreenElements
                   )
    in
    adjust stack Nothing root


tagIntermediates : Bool
tagIntermediates =
    False


tag : String -> Attribute variation msg
tag str =
    if tagIntermediates then
        Attr <| Html.Attributes.class str
    else
        Attr <| Html.Attributes.class ""


{-| Adjust the structure so that `above` and friends can be used.

Counterspacing is also called here or else things get wacky.

-}
positionNearby : Maybe Internal.LayoutModel -> Element style variation msg -> Element style variation msg
positionNearby parent elm =
    let
        separateAlignment attrs =
            List.partition forAlignment attrs

        forAlignment attr =
            case attr of
                HAlign _ ->
                    True

                VAlign _ ->
                    True

                _ ->
                    False

        setPosition nearbyPosition ( aligned, unaligned ) el =
            let
                forWidth prop =
                    case prop of
                        Width _ ->
                            True

                        _ ->
                            False

                width =
                    unaligned
                        |> List.filter forWidth
                        |> List.reverse
                        |> List.head

                forHeight prop =
                    case prop of
                        Height _ ->
                            True

                        _ ->
                            False

                height =
                    unaligned
                        |> List.filter forHeight
                        |> List.reverse
                        |> List.head

                addWidthHeight attrs =
                    case ( width, height ) of
                        ( Nothing, Nothing ) ->
                            attrs

                        ( Just w, Just h ) ->
                            w :: h :: attrs

                        ( Nothing, Just h ) ->
                            h :: attrs

                        ( Just w, Nothing ) ->
                            w :: attrs

                adjustWidthHeight elem =
                    let
                        adjustWidth element =
                            case width of
                                Nothing ->
                                    element

                                Just (Width (Internal.Percent percent)) ->
                                    Modify.addAttrPriority
                                        (Width (Internal.Percent 100))
                                        element

                                Just x ->
                                    -- This property should already exist on the element,
                                    -- so no need to add it.
                                    element

                        adjustHeight element =
                            case height of
                                Nothing ->
                                    element

                                Just (Height (Internal.Percent percent)) ->
                                    Modify.addAttrPriority
                                        (Width (Internal.Percent 100))
                                        element

                                Just x ->
                                    -- This property should already exist on the element,
                                    -- so no need to add it.
                                    element
                    in
                    elem
                        |> adjustWidth
                        |> adjustHeight

                framed =
                    case nearbyPosition of
                        Nothing ->
                            False

                        _ ->
                            True

                isLayout =
                    case elm of
                        Layout _ ->
                            True

                        _ ->
                            False

                nearbyAlignment =
                    case nearbyPosition of
                        Just (Nearby Above) ->
                            [ VAlign Top ]

                        Just (Nearby Below) ->
                            [ VAlign Bottom ]

                        Just (Nearby OnRight) ->
                            [ HAlign Right ]

                        Just (Nearby OnLeft) ->
                            [ HAlign Left ]

                        _ ->
                            []
            in
            if nearbyPosition == Just (Nearby Above) || nearbyPosition == Just (Nearby Below) then
                Layout
                    { node = "div"
                    , style = Nothing
                    , layout = Internal.FlexLayout Internal.GoRight []
                    , attrs =
                        tag "above-below-intermediate-parent"
                            :: PointerEvents False
                            :: Height (Internal.Px 0)
                            :: Width (Internal.Percent 100)
                            :: PositionFrame
                                (Absolute
                                    (if nearbyPosition == Just (Nearby Above) then
                                        TopLeft
                                     else
                                        BottomLeft
                                    )
                                )
                            :: Position (Just 0) (Just 0) Nothing
                            :: (if isLayout then
                                    nearbyAlignment
                                else
                                    nearbyAlignment ++ aligned
                               )
                    , children =
                        Normal
                            [ Element
                                { node = "div"
                                , style = Nothing
                                , attrs =
                                    let
                                        addWidth attrs =
                                            if isLayout then
                                                Width (Internal.Percent 100) :: attrs
                                            else
                                                attrs

                                        -- Width (Internal.Percent 100) :: attrs
                                    in
                                    addWidth
                                        [ tag "above-below-intermediate"
                                        , PointerEvents False
                                        , PositionFrame
                                            (Absolute
                                                (if nearbyPosition == Just (Nearby Above) then
                                                    BottomLeft
                                                 else
                                                    TopLeft
                                                )
                                            )
                                        , Position Nothing (Just 0) Nothing
                                        , VAlign Bottom
                                        , Attr <| Html.Attributes.style [ ( "z-index", "10" ) ]
                                        ]
                                , child =
                                    el
                                        |> Modify.setAttrs
                                            (PointerEvents True
                                                :: PositionFrame (Absolute TopLeft)
                                                :: Position (Just 0) (Just 0) Nothing
                                                :: unaligned
                                            )
                                        |> counterSpacing
                                , absolutelyPositioned = Nothing
                                }
                            ]
                    , absolutelyPositioned = Nothing
                    }
            else if framed then
                Layout
                    { node = "div"
                    , style = Nothing
                    , layout = Internal.FlexLayout Internal.GoRight []
                    , attrs =
                        tag "nearby-intermediate-parent"
                            :: PointerEvents False
                            :: Height (Internal.Percent 100)
                            :: Width (Internal.Percent 100)
                            :: PositionFrame (Absolute TopLeft)
                            :: Position (Just 0) (Just 0) Nothing
                            :: (if isLayout then
                                    nearbyAlignment
                                else
                                    nearbyAlignment ++ aligned
                               )
                    , children =
                        Normal
                            [ Element
                                { node = "div"
                                , style = Nothing
                                , attrs =
                                    addWidthHeight
                                        [ PointerEvents False
                                        , PositionFrame Relative
                                        , Position (Just 0) (Just 0) Nothing
                                        , Padding (Just 0) (Just 0) (Just 0) (Just 0)
                                        , Attr <| Html.Attributes.style [ ( "z-index", "10" ) ]
                                        , tag "nearby-intermediate"
                                        ]
                                , child =
                                    el
                                        |> Modify.addAttrList
                                            (PointerEvents True
                                                :: PositionFrame (Absolute TopLeft)
                                                :: Position (Just 0) (Just 0) Nothing
                                                :: []
                                            )
                                        |> adjustWidthHeight
                                        |> counterSpacing
                                , absolutelyPositioned = Nothing
                                }
                            ]
                    , absolutelyPositioned = Nothing
                    }
            else if not (List.isEmpty aligned) then
                -- This differs from the above in that the intermediate elements
                -- are set with position:relative instead of position:absolute;
                -- We can do this because we have a guarantee that if the element is not framed,
                -- and has no layout parent,
                -- then it's the only child.
                Layout
                    { node = "div"
                    , style = Nothing
                    , layout = Internal.FlexLayout Internal.GoRight []
                    , attrs =
                        tag "nearby-aligned-intermediate-parent"
                            :: PointerEvents False
                            :: Height (Internal.Percent 100)
                            :: Width (Internal.Percent 100)
                            :: PositionFrame Relative
                            :: Position (Just 0) (Just 0) Nothing
                            :: (if isLayout then
                                    nearbyAlignment
                                else
                                    nearbyAlignment ++ aligned
                               )
                    , children =
                        Normal
                            [ Element
                                { node = "div"
                                , style = Nothing
                                , attrs =
                                    addWidthHeight
                                        [ PointerEvents False
                                        , PositionFrame Relative
                                        , Position (Just 0) (Just 0) Nothing
                                        , Padding (Just 0) (Just 0) (Just 0) (Just 0)
                                        , tag "nearby-aligned-intermediate"
                                        ]
                                , child =
                                    el
                                        |> Modify.addAttrList
                                            (PointerEvents True
                                                :: PositionFrame Relative
                                                :: Position (Just 0) (Just 0) Nothing
                                                :: []
                                            )
                                        |> adjustWidthHeight
                                        |> counterSpacing
                                , absolutelyPositioned = Nothing
                                }
                            ]
                    , absolutelyPositioned = Nothing
                    }
            else
                counterSpacing elm
    in
    case elm of
        Element { attrs } ->
            let
                ( aligned, unaligned ) =
                    separateAlignment attrs

                isFrame attr =
                    case attr of
                        PositionFrame x ->
                            Just x

                        _ ->
                            Nothing

                frame =
                    attrs
                        |> List.filterMap isFrame
                        |> List.head
            in
            case parent of
                Nothing ->
                    setPosition frame ( aligned, unaligned ) elm

                _ ->
                    elm

        Layout { attrs } ->
            let
                ( aligned, unaligned ) =
                    separateAlignment attrs

                isFrame attr =
                    case attr of
                        PositionFrame x ->
                            Just x

                        _ ->
                            Nothing

                frame =
                    attrs
                        |> List.filterMap isFrame
                        |> List.head
            in
            case parent of
                Nothing ->
                    setPosition frame ( aligned, unaligned ) elm

                _ ->
                    counterSpacing elm

        _ ->
            counterSpacing elm


{-| Inserts an intermediate element which has negative margin.

This is so that padding:0 fits with this library's concept of padding:0.

-}
counterSpacing : Element style variation msg -> Element style variation msg
counterSpacing elm =
    case elm of
        Layout ({ node, layout, style, attrs, children, absolutelyPositioned } as layoutEl) ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) attrs

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
                                        , (right + left) / 2
                                        )

                            phantomPadding =
                                PhantomPadding
                                    (Maybe.withDefault ( 0, 0, 0, 0 ) padding)
                        in
                        Layout
                            { node = node
                            , style = style
                            , layout = Internal.FlexLayout Internal.GoRight []
                            , attrs = tag "counter-spacing-container" :: PointerEvents True :: unaligned
                            , children =
                                Normal
                                    [ Layout
                                        { node = "div"
                                        , style = Nothing
                                        , layout = layout
                                        , attrs =
                                            tag "counter-spacing"
                                                :: PointerEvents False
                                                :: phantomPadding
                                                :: Margin negativeMargin
                                                :: spacingAttr
                                                :: Width (Internal.Calc 100 totalHSpacing)
                                                :: Shrink 1
                                                :: aligned
                                        , children =
                                            case children of
                                                Normal childs ->
                                                    Normal <| List.map (Modify.addAttr (PointerEvents True)) childs

                                                Keyed childs ->
                                                    Keyed <| List.map (Tuple.mapSecond <| Modify.addAttr (PointerEvents True)) childs
                                        , absolutelyPositioned = Nothing
                                        }
                                    ]
                            , absolutelyPositioned = absolutelyPositioned
                            }
                    else
                        Layout { layoutEl | attrs = PointerEvents True :: attrs }

                _ ->
                    elm

        _ ->
            elm


{-| Center a text layout using flexbox
-}
centerTextLayout : Element style variation msg -> Element style variation msg
centerTextLayout elm =
    case elm of
        Layout ({ attrs, layout } as layoutEl) ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) attrs
            in
            case layout of
                Internal.TextLayout _ ->
                    if not <| List.isEmpty centeredProps then
                        Layout
                            { node = "div"
                            , style = Nothing
                            , layout = Internal.FlexLayout Internal.GoRight []
                            , attrs = tag "center-text" :: PointerEvents False :: centeredProps
                            , children =
                                Normal
                                    [ Layout { layoutEl | attrs = PointerEvents True :: others } ]
                            , absolutelyPositioned = Nothing
                            }
                    else
                        elm

                _ ->
                    elm

        _ ->
            elm


{-| Due to stacking contexts, we need to hoist any element that needs to be fixed on the screen up to the top of the hierarchy.
-}
hoistFixedScreenElements : Element style variation msg -> ( Element style variation msg, Maybe (List (Element style variation msg)) )
hoistFixedScreenElements el =
    let
        elementIsOnScreen attrs =
            List.any (\attr -> attr == PositionFrame Screen) attrs
    in
    case el of
        Element { attrs } ->
            if elementIsOnScreen attrs then
                ( Empty, Just [ el ] )
            else
                ( el, Nothing )

        Layout { attrs } ->
            if elementIsOnScreen attrs then
                ( Empty, Just [ el ] )
            else
                ( el, Nothing )

        _ ->
            ( el, Nothing )


defaultPadding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float ) -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
defaultPadding ( mW, mX, mY, mZ ) ( w, x, y, z ) =
    ( Maybe.withDefault w mW
    , Maybe.withDefault x mX
    , Maybe.withDefault y mY
    , Maybe.withDefault z mZ
    )


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
