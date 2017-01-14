module Style.Animation exposing (..)

{-|

-}

import Style.Model
import Animation
import Animation.Messenger


--subscription : (Animation.Msg -> msg) -> StyleSheet class layoutClass positionClass variation msg -> Sub msg
--subscription toMsg stylesheet =
--    Animation.subscription toMsg (animationStates stylesheet)


animation : animation -> List Step -> Property animation variation msg
animation name anim =
    Style.Model.DynamicAnimation name (StyleAnimation.interrupt anim)



--to : List prop -> Step prop
--to props =
--    StyleAnimation.to
--        (List.map convert props)
--set : List prop -> Step prop
--loop : Int -> Int
--repeat : Int -> Int
--wait : Int -> Int
--update : Int -> Int
--send : msg -> Step msg
--start : name -> Model class layoutClass positionClass variation -> Model class layoutClass positionClass variation
--stop : name -> name
--reset : name -> name


convert : Style.Model.Property variation -> Maybe (List StyleAnimation.Property)
convert prop =
    case prop of
        Property name val ->
            Just [ StyleAnimation.exactly name val ]

        Mix props ->
            Nothing

        Box name val ->
            if name == "border-width" then
                let
                    ( top, right, bottom, left ) =
                        val
                in
                    Just
                        [ StyleAnimation.borderLeftWidth (px left)
                        , StyleAnimation.borderTopWidth (px top)
                        , StyleAnimation.borderBottomWidth (px bottom)
                        , StyleAnimation.borderRightWidth (px right)
                        ]
            else if name == "padding" then
                let
                    ( top, right, bottom, left ) =
                        val
                in
                    Just
                        [ StyleAnimation.paddingLeft (px left)
                        , StyleAnimation.paddingTop (px top)
                        , StyleAnimation.paddingBottom (px bottom)
                        , StyleAnimation.paddingRight (px right)
                        ]
            else
                Nothing

        Len name value ->
            if name == "width" then
                Just [ StyleAnimation.width (px value) ]
            else if name == "min-width" then
                Just [ StyleAnimation.minWidth (px value) ]
            else if name == "max-width" then
                Just [ StyleAnimation.maxWidth (px value) ]
            else if name == "height" then
                Just [ StyleAnimation.height (px value) ]
            else if name == "min-height" then
                Just [ StyleAnimation.minHeight (px value) ]
            else if name == "max-height" then
                Just [ StyleAnimation.maxHeight (px value) ]
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
                                Just <| StyleAnimation.blur x

                            Brightness x ->
                                Just <| StyleAnimation.brightness x

                            Contrast x ->
                                Just <| StyleAnimation.contrast x

                            Grayscale x ->
                                Just <| StyleAnimation.grayscale x

                            HueRotate x ->
                                Just <| StyleAnimation.hueRotate (StyleAnimation.rad x)

                            Invert x ->
                                Just <| StyleAnimation.invert x

                            Opacity x ->
                                Just <| StyleAnimation.opacity x

                            Saturate x ->
                                Just <| StyleAnimation.saturate x

                            Sepia x ->
                                Just <| StyleAnimation.sepia x

                            DropShadow shadow ->
                                Just <|
                                    StyleAnimation.dropShadow
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
                                StyleAnimation.translate3d x y z

                            Rotate x y z ->
                                StyleAnimation.rotate3d x y z

                            Scale x y z ->
                                StyleAnimation.scale3d x y z
                    )
                    transforms

        TransitionProperty _ ->
            Nothing

        Shadows shadows ->
            Just <|
                List.filterMap
                    (\shadow ->
                        if shadow.kind == "box" then
                            Just <|
                                StyleAnimation.shadow
                                    { offsetX = Tuple.first shadow.offset
                                    , offsetY = Tuple.second shadow.offset
                                    , size = shadow.size
                                    , blur = shadow.blur
                                    , color = shadow.color
                                    }
                        else if shadow.kind == "inset" then
                            Just <|
                                StyleAnimation.insetShadow
                                    { offsetX = Tuple.first shadow.offset
                                    , offsetY = Tuple.second shadow.offset
                                    , size = shadow.size
                                    , blur = shadow.blur
                                    , color = shadow.color
                                    }
                        else if shadow.kind == "text" then
                            Just <|
                                StyleAnimation.textShadow
                                    { offsetX = Tuple.first shadow.offset
                                    , offsetY = Tuple.second shadow.offset
                                    , size = shadow.size
                                    , blur = shadow.blur
                                    , color = shadow.color
                                    }
                        else if shadow.kind == "drop" then
                            Just <|
                                StyleAnimation.dropShadow
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
                    Just [ StyleAnimation.opacity (1 - transparency) ]

                Hidden ->
                    Just [ StyleAnimation.display StyleAnimation.none ]

        ColorProp name value ->
            if name == "color" then
                Just [ StyleAnimation.color value ]
            else if name == "background-color" then
                Just [ StyleAnimation.backgroundColor value ]
            else if name == "border-color" then
                Just [ StyleAnimation.borderColor value ]
            else
                Nothing

        MediaQuery name _ ->
            Nothing

        SubElement name _ ->
            Nothing

        Variation name _ ->
            Nothing



--convertPositionProp : Style.Model.PositionProperty variation -> StyleAnimation.Property
--convertPositionProp prop =
--    case prop of
--        PositionProp anchor x y ->
--        RelProp PositionParent ->
--        FloatProp Floating -> "illegal"
--        PositionVariation variation (List (PositionProperty variation)) -> "illegal"
