module Style.Animation exposing (to, set, loop, repeat, send)

{-|


@docs to, set, loop, repeat, send
-}

import Style.Model exposing (..)
import Animation exposing (px, percent, rad)
import Animation.Messenger
import Time exposing (Time)


--subscription : (Animation.Msg -> msg) -> StyleSheet class layoutClass positionClass variation msg -> Sub msg
--subscription toMsg stylesheet =
--    Animation.subscription toMsg (animationStates stylesheet)


{-| -}
animation : animation -> List (Animation.Messenger.Step msg) -> Property animation variation msg
animation name anim =
    Style.Model.DynamicAnimation name (Animation.interrupt anim)


{-|
-}
to : List (Property animation variation msg) -> Animation.Messenger.Step msg
to props =
    props
        |> List.filterMap convert
        |> List.concat
        |> Animation.to


{-|
-}
set : List (Property animation variation msg) -> Animation.Messenger.Step msg
set props =
    props
        |> List.filterMap convert
        |> List.concat
        |> Animation.set


{-|
-}
loop : List (Animation.Messenger.Step msg) -> Animation.Messenger.Step msg
loop =
    Animation.loop


{-|
-}
repeat : Int -> List (Animation.Messenger.Step msg) -> Animation.Messenger.Step msg
repeat =
    Animation.repeat


wait : Time -> Animation.Messenger.Step msg
wait =
    Animation.wait



--update : Int -> Int


{-| -}
send : msg -> Animation.Messenger.Step msg
send msg =
    Animation.Messenger.send msg



--start : name -> Model class layoutClass positionClass variation -> Model class layoutClass positionClass variation
--stop : name -> name
--reset : name -> name


{-|
-}
convert : Style.Model.Property animation variation msg -> Maybe (List Animation.Property)
convert prop =
    case prop of
        Property name val ->
            Just [ Animation.exactly name val ]

        Mix props ->
            case props of
                [] ->
                    Nothing

                _ ->
                    props
                        |> List.filterMap convert
                        |> List.concat
                        |> Just

        Box name val ->
            if name == "border-width" then
                let
                    ( top, right, bottom, left ) =
                        val
                in
                    Just
                        [ Animation.borderLeftWidth (px left)
                        , Animation.borderTopWidth (px top)
                        , Animation.borderBottomWidth (px bottom)
                        , Animation.borderRightWidth (px right)
                        ]
            else if name == "padding" then
                let
                    ( top, right, bottom, left ) =
                        val
                in
                    Just
                        [ Animation.paddingLeft (px left)
                        , Animation.paddingTop (px top)
                        , Animation.paddingBottom (px bottom)
                        , Animation.paddingRight (px right)
                        ]
            else
                Nothing

        Len name length ->
            if name == "width" then
                case length of
                    Px value ->
                        Just [ Animation.width (px value) ]

                    Percent value ->
                        Just [ Animation.width (percent value) ]

                    Auto ->
                        Nothing
                --else if name == "min-width" then
                --    Just [ Animation.minWidth (px value) ]
                --else if name == "max-width" then
                --    Just [ Animation.maxWidth (px value) ]
            else if name == "height" then
                case length of
                    Px value ->
                        Just [ Animation.height (px value) ]

                    Percent value ->
                        Just [ Animation.height (percent value) ]

                    Auto ->
                        Nothing
                --else if name == "min-height" then
                --    Just [ Animation.minHeight (px value) ]
                --else if name == "max-height" then
                --    Just [ Animation.maxHeight (px value) ]
            else
                Nothing

        Filters filters ->
            Just <|
                List.filterMap
                    (\filter ->
                        case filter of
                            FilterUrl _ ->
                                Nothing

                            Blur x ->
                                Just <| Animation.blur (px x)

                            Brightness x ->
                                Just <| Animation.brightness x

                            Contrast x ->
                                Just <| Animation.contrast x

                            Grayscale x ->
                                Just <| Animation.grayscale x

                            HueRotate x ->
                                Just <| Animation.hueRotate (Animation.rad x)

                            Invert x ->
                                Just <| Animation.invert x

                            Opacity x ->
                                Just <| Animation.opacity x

                            Saturate x ->
                                Just <| Animation.saturate x

                            Sepia x ->
                                Just <| Animation.sepia x

                            DropShadow (Shadow shadow) ->
                                Just <|
                                    Animation.dropShadow
                                        { offsetX = Tuple.first shadow.offset
                                        , offsetY = Tuple.second shadow.offset
                                        , size = shadow.size
                                        , blur = shadow.blur
                                        , color = shadow.color
                                        }
                    )
                    filters

        Transforms transforms ->
            Just <|
                List.map
                    (\transform ->
                        case transform of
                            Translate x y z ->
                                Animation.translate3d (px x) (px y) (px z)

                            Rotate x y z ->
                                Animation.rotate3d (rad x) (rad y) (rad z)

                            Scale x y z ->
                                Animation.scale3d x y z
                    )
                    transforms

        TransitionProperty _ ->
            Nothing

        Shadows shadows ->
            Just <|
                List.filterMap
                    (\(Shadow shadow) ->
                        if shadow.kind == "box" then
                            Just <|
                                Animation.shadow
                                    { offsetX = Tuple.first shadow.offset
                                    , offsetY = Tuple.second shadow.offset
                                    , size = shadow.size
                                    , blur = shadow.blur
                                    , color = shadow.color
                                    }
                        else if shadow.kind == "inset" then
                            Just <|
                                Animation.insetShadow
                                    { offsetX = Tuple.first shadow.offset
                                    , offsetY = Tuple.second shadow.offset
                                    , size = shadow.size
                                    , blur = shadow.blur
                                    , color = shadow.color
                                    }
                        else if shadow.kind == "text" then
                            Just <|
                                Animation.textShadow
                                    { offsetX = Tuple.first shadow.offset
                                    , offsetY = Tuple.second shadow.offset
                                    , size = shadow.size
                                    , blur = shadow.blur
                                    , color = shadow.color
                                    }
                        else if shadow.kind == "drop" then
                            Just <|
                                Animation.dropShadow
                                    { offsetX = Tuple.first shadow.offset
                                    , offsetY = Tuple.second shadow.offset
                                    , size = shadow.size
                                    , blur = shadow.blur
                                    , color = shadow.color
                                    }
                        else
                            Nothing
                    )
                    shadows

        BackgroundImageProp _ ->
            Nothing

        AnimationProp _ ->
            Nothing

        VisibilityProp vis ->
            case vis of
                Transparent transparency ->
                    Just [ Animation.opacity (1 - transparency) ]

                Hidden ->
                    Just [ Animation.display Animation.none ]

        ColorProp name value ->
            if name == "color" then
                Just [ Animation.color value ]
            else if name == "background-color" then
                Just [ Animation.backgroundColor value ]
            else if name == "border-color" then
                Just [ Animation.borderColor value ]
            else
                Nothing

        MediaQuery name _ ->
            Nothing

        SubElement name _ ->
            Nothing

        Variation name _ ->
            Nothing

        Position anchor x y ->
            Nothing

        LayoutProp layout ->
            Nothing

        Spacing _ ->
            Nothing

        DynamicAnimation name anim ->
            Nothing

        FloatProp _ ->
            Nothing

        RelProp _ ->
            Nothing

        Inline ->
            Nothing



--convertPositionProp : Style.Model.PositionProperty variation -> Animation.Property
--convertPositionProp prop =
--    case prop of
--        PositionProp anchor x y ->
--        RelProp PositionParent ->
--        FloatProp Floating -> "illegal"
--        PositionVariation variation (List (PositionProperty variation)) -> "illegal"
