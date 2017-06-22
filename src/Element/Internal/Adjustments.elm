module Element.Internal.Adjustments exposing (..)

{-| This module captures all the structure adjustments that need to takes place on the html before it is rendered.
-}

import Element.Internal.Model exposing (..)
import Style.Internal.Model as Internal exposing (Length)
import Style.Internal.Render.Value as Value
import Style.Internal.Render.Property as Property
import Html.Attributes
import Element.Internal.Modify as Modify


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
                if nearbyPosition == (Just (Nearby Above)) || nearbyPosition == (Just (Nearby Below)) then
                    Layout "div"
                        (Internal.FlexLayout Internal.GoRight [])
                        Nothing
                        (PointerEvents False
                            :: Height (Internal.Px 0)
                            :: Width (Internal.Percent 100)
                            :: PositionFrame
                                (Absolute
                                    (if nearbyPosition == (Just (Nearby Above)) then
                                        TopLeft
                                     else
                                        BottomLeft
                                    )
                                )
                            :: Position (Just 0) (Just 0) Nothing
                            :: (nearbyAlignment ++ aligned)
                        )
                        (Normal
                            [ Element "div"
                                Nothing
                                [ PointerEvents False
                                , PositionFrame
                                    (Absolute
                                        (if nearbyPosition == (Just (Nearby Above)) then
                                            BottomLeft
                                         else
                                            TopLeft
                                        )
                                    )
                                , Position Nothing (Just 0) Nothing
                                , VAlign Bottom
                                , Attr <| noColor
                                ]
                                (counterSpacing
                                    (Modify.setAttrs
                                        (PointerEvents True :: PositionFrame (Absolute TopLeft) :: Position (Just 0) (Just 0) Nothing :: unaligned)
                                        el
                                    )
                                )
                                Nothing
                            ]
                        )
                else
                    Layout "div"
                        (Internal.FlexLayout Internal.GoRight [])
                        Nothing
                        (PointerEvents False
                            :: Height (Internal.Percent 100)
                            :: Width (Internal.Percent 100)
                            :: PositionFrame (Absolute TopLeft)
                            :: Position (Just 0) (Just 0) Nothing
                            :: (nearbyAlignment ++ aligned)
                        )
                        (Normal
                            [ Element "div"
                                Nothing
                                (unaligned
                                    ++ [ PointerEvents False
                                       , PositionFrame Relative
                                       , Position (Just 0) (Just 0) Nothing
                                       , Padding (Just 0) (Just 0) (Just 0) (Just 0)
                                       , Attr <| noColor
                                       ]
                                )
                                (counterSpacing
                                    (Modify.addAttrList
                                        (PointerEvents True :: PositionFrame (Absolute TopLeft) :: Position (Just 0) (Just 0) Nothing :: [])
                                        el
                                    )
                                )
                                Nothing
                            ]
                        )
    in
        case elm of
            Element node element attrs child otherChildren ->
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

            Layout node layout element attrs children ->
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
        Layout node layout element attrs children ->
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
                                            , right + left
                                            )

                                phantomPadding =
                                    PhantomPadding
                                        (Maybe.withDefault ( 0, 0, 0, 0 ) padding)
                            in
                                Layout
                                    node
                                    (Internal.FlexLayout Internal.GoRight [])
                                    element
                                    (PointerEvents True :: unaligned)
                                    (Normal
                                        [ Layout
                                            "div"
                                            layout
                                            Nothing
                                            (PointerEvents False
                                                :: phantomPadding
                                                :: Margin negativeMargin
                                                :: spacingAttr
                                                :: Width (Internal.Calc 100 totalHSpacing)
                                                :: Shrink 1
                                                :: aligned
                                            )
                                            (case children of
                                                Normal childs ->
                                                    Normal <| List.map (Modify.addAttr (PointerEvents True)) childs

                                                Keyed childs ->
                                                    Keyed <| List.map (Tuple.mapSecond <| Modify.addAttr (PointerEvents True)) childs
                                            )
                                        ]
                                    )
                        else
                            Layout node layout element (PointerEvents True :: attrs) children

                    _ ->
                        Layout node layout element attrs children

        _ ->
            elm


{-| Center a text layout using flexbox
-}
centerTextLayout : Element style variation msg -> Element style variation msg
centerTextLayout elm =
    case elm of
        Layout node layout element attrs children ->
            let
                ( centeredProps, others ) =
                    List.partition (\attr -> attr == HAlign Center || attr == VAlign VerticalCenter) attrs
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
                                    [ Layout node layout element (PointerEvents True :: others) children ]
                                )
                        else
                            Layout node layout element attrs children

                    _ ->
                        Layout node layout element attrs children

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
            Element node element attrs child otherChildren ->
                if elementIsOnScreen attrs then
                    ( Empty, Just [ el ] )
                else
                    ( el, Nothing )

            Layout node layout element attrs children ->
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
