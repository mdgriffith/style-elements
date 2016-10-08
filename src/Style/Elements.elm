module Style.Elements exposing (map, html, element, elementAs, build, buildInline)

import String
import Char
import Murmur3
import Color exposing (Color)
import Html
import Set exposing (Set)
import Html.Attributes
import Style.Model exposing (..)


type alias HtmlNode msg =
    List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg


map : (Model -> Model) -> Element msg -> Element msg
map fn el =
    case el of
        Element props ->
            Element { props | style = fn props.style }

        _ ->
            el


html : Html.Html msg -> Element msg
html node =
    Html node


element : Model -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
element styleModel attrs content =
    Element
        { style = styleModel
        , node = Html.div
        , attributes = attrs
        , children = content
        }


elementAs : HtmlNode msg -> Model -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
elementAs node styleModel attrs content =
    Element
        { style = styleModel
        , node = node
        , attributes = attrs
        , children = content
        }


weak : Weak -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
weak styleModel attrs content =
    WeakElement
        { style = styleModel
        , node = Html.div
        , attributes = attrs
        , children = content
        }


weakAs : HtmlNode msg -> Weak -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
weakAs node styleModel attrs content =
    WeakElement
        { style = styleModel
        , node = node
        , attributes = attrs
        , children = content
        }


type StyleDefinition
    = StyleDef
        { name : String
        , style : List ( String, String )
        , modes :
            List StyleDefinition
        , keyframes :
            Maybe (List ( Float, List ( String, String ) ))
        }


className : StyleDefinition -> String
className def =
    case def of
        StyleDef { name } ->
            name


buildInline : Element msg -> Html.Html msg
buildInline element =
    let
        construct node attributes children ( parentStyle, childMargin, childPermissions ) =
            let
                ( builtChildren, childStyles ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildInlineChild childPermissions childMargin child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtTransitions
                                )
                        )
                        ( [], [] )
                        children

                ( className, renderedStyle, parentAndInherited ) =
                    case parentStyle of
                        StyleDef { name, style, modes, keyframes } ->
                            ( name
                            , style
                            , StyleDef
                                { name = name
                                , style = []
                                , modes = modes
                                , keyframes = keyframes
                                }
                            )

                styleSheet =
                    Html.node "style"
                        []
                        [ Html.text <|
                            convertToCSS (parentAndInherited :: childStyles)
                        ]
            in
                node
                    (Html.Attributes.class className :: Html.Attributes.style renderedStyle :: attributes)
                    (styleSheet :: builtChildren)
    in
        case element of
            Html html ->
                html

            Element model ->
                render model.style { floats = False, inline = False }
                    |> construct model.node model.attributes model.children

            WeakElement model ->
                renderWeak model.style { floats = False, inline = False }
                    |> construct model.node model.attributes model.children


buildInlineChild : Permissions -> List ( String, String ) -> Element msg -> ( Html.Html msg, List StyleDefinition )
buildInlineChild permissions inherited element =
    let
        construct node attributes children ( parentStyle, childMargin, childPermissions ) =
            let
                ( builtChildren, childStyle ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtStyle ) =
                                    buildInlineChild childPermissions childMargin child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtStyle
                                )
                        )
                        ( [], [] )
                        children

                ( className, renderedStyle, parentAndInherited ) =
                    case parentStyle of
                        StyleDef { name, style, modes, keyframes } ->
                            ( name
                            , style ++ inherited
                            , StyleDef
                                { name = name
                                , style = []
                                , modes = modes
                                , keyframes = keyframes
                                }
                            )
            in
                ( node
                    (Html.Attributes.class className :: Html.Attributes.style renderedStyle :: attributes)
                    builtChildren
                , parentAndInherited :: childStyle
                )
    in
        case element of
            Html html ->
                ( html, [] )

            Element model ->
                render model.style permissions
                    |> construct model.node model.attributes model.children

            WeakElement model ->
                renderWeak model.style permissions
                    |> construct model.node model.attributes model.children


build : Element msg -> Html.Html msg
build element =
    let
        construct node attributes children ( parentStyle, childMargin, childPermissions ) =
            let
                ( builtChildren, childStyles ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildChild childPermissions childMargin child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtTransitions
                                )
                        )
                        ( [], [] )
                        children

                styleSheet =
                    Html.node "style"
                        []
                        [ Html.text <|
                            convertToCSS (parentStyle :: childStyles)
                        ]
            in
                node
                    (Html.Attributes.class (className parentStyle) :: attributes)
                    (styleSheet :: builtChildren)
    in
        case element of
            Html html ->
                html

            Element model ->
                render model.style { floats = False, inline = False }
                    |> construct model.node model.attributes model.children

            WeakElement model ->
                renderWeak model.style { floats = False, inline = False }
                    |> construct model.node model.attributes model.children


buildChild : Permissions -> List ( String, String ) -> Element msg -> ( Html.Html msg, List StyleDefinition )
buildChild permissions inherited element =
    let
        construct node attributes children ( parentStyle, childMargin, childPermissions ) =
            let
                ( builtChildren, childStyle ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtStyle ) =
                                    buildChild childPermissions childMargin child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtStyle
                                )
                        )
                        ( [], [] )
                        children

                ( className, parentAndInherited ) =
                    case parentStyle of
                        StyleDef { name, style, modes, keyframes } ->
                            ( name
                            , StyleDef
                                { name = name
                                , style = (style ++ inherited)
                                , modes = modes
                                , keyframes = keyframes
                                }
                            )
            in
                ( node
                    (Html.Attributes.class className :: attributes)
                    builtChildren
                , parentAndInherited :: childStyle
                )
    in
        case element of
            Html html ->
                ( html, [] )

            Element model ->
                render model.style permissions
                    |> construct model.node model.attributes model.children

            WeakElement model ->
                renderWeak model.style permissions
                    |> construct model.node model.attributes model.children


convertToCSS : List StyleDefinition -> String
convertToCSS styles =
    let
        convert style =
            case style of
                StyleDef { name, style, modes, keyframes } ->
                    (if List.length style == 0 then
                        ""
                     else
                        "."
                            ++ name
                            ++ " {\n"
                            ++ (String.concat <|
                                    List.map
                                        (\( propName, propValue ) ->
                                            "  " ++ propName ++ ": " ++ propValue ++ ";\n"
                                        )
                                        style
                               )
                            ++ "}\n"
                    )
                        ++ (String.join "\n" <|
                                List.map
                                    (\st ->
                                        case st of
                                            StyleDef mode ->
                                                "."
                                                    ++ name
                                                    ++ mode.name
                                                    ++ " {\n"
                                                    ++ (String.concat <|
                                                            List.map
                                                                (\( propName, propValue ) ->
                                                                    "  " ++ propName ++ ": " ++ propValue ++ " !important;\n"
                                                                )
                                                                mode.style
                                                       )
                                                    ++ "}\n"
                                    )
                                    modes
                           )
                        ++ (case keyframes of
                                Nothing ->
                                    ""

                                Just frames ->
                                    "@keyframes animation-"
                                        ++ name
                                        ++ " {\n"
                                        ++ (String.join "\n" <|
                                                List.map
                                                    (\( marker, frame ) ->
                                                        "  "
                                                            ++ toString marker
                                                            ++ "% {\n"
                                                            ++ (String.concat <|
                                                                    List.map
                                                                        (\( propName, propValue ) ->
                                                                            "    " ++ propName ++ ": " ++ propValue ++ ";\n"
                                                                        )
                                                                        frame
                                                               )
                                                            ++ "  }\n"
                                                    )
                                                    frames
                                           )
                                        ++ "}\n"
                           )
    in
        uniqueBy className styles
            |> List.map convert
            |> String.join "\n"
            |> String.trim



--Maybe (List ( Float, List ( String, String ) ))


{-| Drop duplicates where what is considered to be a duplicate is the result of first applying the supplied function to the elements of the list.
-}
uniqueBy : (a -> comparable) -> List a -> List a
uniqueBy f list =
    uniqueHelp f Set.empty list


uniqueHelp : (a -> comparable) -> Set comparable -> List a -> List a
uniqueHelp f existing remaining =
    case remaining of
        [] ->
            []

        first :: rest ->
            let
                computedFirst =
                    f first
            in
                if Set.member computedFirst existing then
                    uniqueHelp f existing rest
                else
                    first :: uniqueHelp f (Set.insert computedFirst existing) rest


(=>) =
    (,)


type alias Permissions =
    { floats : Bool
    , inline : Bool
    }


render : Model -> Permissions -> ( StyleDefinition, List ( String, String ), Permissions )
render style permissions =
    case style.visibility of
        Hidden ->
            let
                renderedStyle =
                    [ "display" => "none" ]

                className =
                    generateId renderedStyle
            in
                ( StyleDef
                    { name = className
                    , style = renderedStyle
                    , modes = []
                    , keyframes = Nothing
                    }
                , []
                , { floats = False, inline = False }
                )

        Transparent transparency ->
            let
                ( layout, childMargin, childrenPermissions ) =
                    renderLayout style.layout

                renderedStyle =
                    List.concat <|
                        List.filterMap identity
                            [ Just <| layout
                            , Just <| renderPosition style.position
                            , renderInline permissions.inline style.inline
                            , Just
                                [ "opacity" => toString (1.0 - transparency)
                                , "width" => (renderLength style.width)
                                , "height" => (renderLength style.height)
                                , "cursor" => style.cursor
                                , "padding" => render4tuplePx style.padding
                                ]
                            , Just <| renderColors style.colors
                            , Just <| renderText style.text
                            , Just <| renderBorder style.border
                            , Maybe.map renderBackgroundImage style.backgroundImage
                            , Maybe.map (renderFloating permissions.floats) style.float
                            , listMaybeMap (renderShadow "box-shadow" False) style.shadows
                            , listMaybeMap (renderShadow "box-shadow" True) style.insetShadows
                            , listMaybeMap (renderShadow "text-shadow" False) style.textShadows
                            , listMaybeMap renderFilters style.filters
                            , listMaybeMap renderTransforms style.transforms
                            , if style.onHover /= Nothing || style.onFocus /= Nothing then
                                Just cssTransitions
                              else
                                Nothing
                            ]

                class =
                    generateId renderedStyle

                withAnimation =
                    case Maybe.map (renderAnimation class) style.animation of
                        Nothing ->
                            renderedStyle

                        Just anim ->
                            renderedStyle ++ anim

                transitions =
                    renderCssTransitions class style

                keyframes =
                    Maybe.map renderAnimationKeyframes style.animation
            in
                ( StyleDef
                    { name = class
                    , style = withAnimation
                    , modes = transitions
                    , keyframes = keyframes
                    }
                , [ "margin" => childMargin ]
                , childrenPermissions
                )


renderWeak : Weak -> Permissions -> ( StyleDefinition, List ( String, String ), Permissions )
renderWeak style permissions =
    let
        ( layout, childMargin, childrenPermissions ) =
            Maybe.map renderLayout style.layout
                |> Maybe.withDefault ( [], "0px", { floats = False, inline = False } )

        renderedStyle =
            List.concat <|
                List.filterMap identity
                    [ Just layout
                    , Maybe.map renderPosition style.position
                    , renderInline permissions.inline style.inline
                    , Just <|
                        List.filterMap identity
                            [ Maybe.map (\w -> "width" => (renderLength w)) style.width
                            , Maybe.map (\h -> "height" => (renderLength h)) style.height
                            , Maybe.map (\c -> "cursor" => c) style.cursor
                            , Maybe.map (\p -> "padding" => (render4tuplePx p)) style.padding
                            ]
                    , Maybe.map renderColors style.colors
                    , Maybe.map renderText style.text
                    , Maybe.map renderBorder style.border
                    , Maybe.map renderBackgroundImage style.backgroundImage
                    , Maybe.map (renderFloating permissions.floats) style.float
                    , listMaybeMap (renderShadow "box-shadow" False) style.shadows
                    , listMaybeMap (renderShadow "box-shadow" True) style.insetShadows
                    , listMaybeMap (renderShadow "text-shadow" False) style.textShadows
                    , listMaybeMap renderFilters style.filters
                    , listMaybeMap renderTransforms style.transforms
                    , Maybe.map renderVisibility style.visibility
                    , if style.onHover /= Nothing || style.onFocus /= Nothing then
                        Just cssTransitions
                      else
                        Nothing
                    ]

        class =
            generateId renderedStyle

        withAnimation =
            case Maybe.map (renderAnimation class) style.animation of
                Nothing ->
                    renderedStyle

                Just anim ->
                    renderedStyle ++ anim

        transitions =
            renderCssTransitionsWeak class style

        keyframes =
            Maybe.map renderAnimationKeyframes style.animation
    in
        ( StyleDef
            { name = class
            , style = withAnimation
            , modes = transitions
            , keyframes = keyframes
            }
        , [ "margin" => childMargin ]
        , childrenPermissions
        )


listMaybeMap : (List a -> b) -> List a -> Maybe b
listMaybeMap fn ls =
    case ls of
        [] ->
            Nothing

        nonEmptyList ->
            Just <| fn nonEmptyList


renderAnimationKeyframes : Animation -> List ( Float, List ( String, String ) )
renderAnimationKeyframes (Animation anim) =
    let
        renderAnimStep ( marker, styleDef ) =
            let
                ( rendered, _, _ ) =
                    renderWeak styleDef { floats = False, inline = False }
            in
                case rendered of
                    StyleDef { style } ->
                        ( marker, style )
    in
        List.map renderAnimStep anim.steps


renderAnimation : String -> Animation -> List ( String, String )
renderAnimation class (Animation anim) =
    let
        animName =
            "animation-" ++ class

        duration =
            toString anim.duration ++ "ms"

        iterations =
            if isInfinite anim.repeat then
                "infinite"
            else
                toString anim.repeat
    in
        [ "animation" => (animName ++ " " ++ duration ++ " " ++ anim.easing ++ " " ++ iterations)
        ]


renderVisibility : Visibility -> List ( String, String )
renderVisibility vis =
    case vis of
        Hidden ->
            [ "display" => "none" ]

        Transparent transparency ->
            [ "opacity" => toString (1.0 - transparency) ]


renderInline : Bool -> Bool -> Maybe (List ( String, String ))
renderInline permission inline =
    if inline then
        if permission then
            Just [ "display" => "inline-block" ]
        else
            let
                _ =
                    Debug.log "style-blocks" "Elements can only be inline if they are in a text layout."
            in
                Nothing
    else
        Nothing


renderFloating : Bool -> Floating -> List ( String, String )
renderFloating permission floating =
    if permission then
        case floating of
            FloatLeft ->
                [ "float" => "left" ]

            FloatRight ->
                [ "float" => "right" ]
    else
        let
            _ =
                Debug.log "style-blocks" "Elements can only use float if they are in a text layout."
        in
            []


renderBackgroundImage : BackgroundImage -> List ( String, String )
renderBackgroundImage image =
    [ "background-image" => image.src
    , "background-repeat"
        => case image.repeat of
            RepeatX ->
                "repeat-x"

            RepeatY ->
                "repeat-y"

            Repeat ->
                "repeat"

            Space ->
                "space"

            Round ->
                "round"

            NoRepeat ->
                "no-repeat"
    , "background-position" => ((toString (fst image.position)) ++ "px " ++ (toString (snd image.position)) ++ "px")
    ]


renderTransforms : List Transform -> List ( String, String )
renderTransforms transforms =
    [ "transform"
        => (String.join " " (List.map transformToString transforms))
    ]


transformToString : Transform -> String
transformToString transform =
    case transform of
        Translate x y z ->
            "transform3d("
                ++ toString x
                ++ "px, "
                ++ toString y
                ++ "px, "
                ++ toString z
                ++ "px)"

        Rotate x y z ->
            "rotateX("
                ++ toString x
                ++ "deg) rotateY("
                ++ toString y
                ++ "deg) rotateZ("
                ++ toString z
                ++ "deg)"

        Scale x y z ->
            "scale3d("
                ++ toString x
                ++ ", "
                ++ toString y
                ++ ", "
                ++ toString z
                ++ ")"


renderFilters : List Filter -> List ( String, String )
renderFilters filters =
    [ "filter"
        => (String.join " " <| List.map filterToString filters)
    ]


filterToString : Filter -> String
filterToString filter =
    case filter of
        FilterUrl url ->
            "url(" ++ url ++ ")"

        Blur x ->
            "blur(" ++ toString x ++ "px)"

        Brightness x ->
            "brightness(" ++ toString x ++ "%)"

        Contrast x ->
            "contrast(" ++ toString x ++ "%)"

        Grayscale x ->
            "grayscale(" ++ toString x ++ "%)"

        HueRotate x ->
            "hueRotate(" ++ toString x ++ "deg)"

        Invert x ->
            "invert(" ++ toString x ++ "%)"

        Opacity x ->
            "opacity(" ++ toString x ++ "%)"

        Saturate x ->
            "saturate(" ++ toString x ++ "%)"

        Sepia x ->
            "sepia(" ++ toString x ++ "%)"


renderShadow : String -> Bool -> List Shadow -> List ( String, String )
renderShadow shadowName inset shadows =
    [ shadowName => (String.join ", " (List.map (shadowValue inset) shadows)) ]


shadowValue : Bool -> Shadow -> String
shadowValue inset { offset, size, blur, color } =
    String.join " "
        [ if inset then
            "inset"
          else
            ""
        , toString (fst offset) ++ "px"
        , toString (snd offset) ++ "px"
        , toString blur ++ "px"
        , colorToString color
        ]


render4tuplePx : ( Float, Float, Float, Float ) -> String
render4tuplePx ( a, b, c, d ) =
    toString a ++ "px " ++ toString b ++ "px " ++ toString c ++ "px " ++ toString d ++ "px"


renderBorder : Border -> List ( String, String )
renderBorder { style, width, corners } =
    [ "border-style"
        => case style of
            Solid ->
                "solid"

            Dashed ->
                "dashed"

            Dotted ->
                "dotted"
    , "border-width"
        => render4tuplePx width
    , "border-radius"
        => render4tuplePx corners
    ]


renderText : Text -> List ( String, String )
renderText text =
    List.filterMap identity
        [ Just ("font-family" => text.font)
        , Just ("font-size" => (toString text.size ++ "px"))
        , Just ("line-height" => (toString (text.size * text.lineHeight) ++ "px"))
        , Maybe.map
            (\offset ->
                "letter-spacing" => (toString offset ++ "px")
            )
            text.characterOffset
        , Just <|
            if text.italic then
                "font-style" => "italic"
            else
                "font-style" => "normal"
        , Maybe.map
            (\bold ->
                "font-weight" => (toString bold)
            )
            text.boldness
        , Just <|
            case text.align of
                AlignLeft ->
                    "text-align" => "left"

                AlignRight ->
                    "text-align" => "right"

                AlignCenter ->
                    "text-align" => "center"

                Justify ->
                    "text-align" => "justify"

                JustifyAll ->
                    "text-align" => "justify-all"
        , Just <|
            "text-decoration"
                => case text.decoration of
                    Nothing ->
                        "none"

                    Just position ->
                        case position of
                            Underline ->
                                "underline"

                            Overline ->
                                "overline"

                            Strike ->
                                "line-through"
        ]


colorToString : Color -> String
colorToString color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
        "rgba("
            ++ toString red
            ++ ","
            ++ toString green
            ++ ","
            ++ toString blue
            ++ ","
            ++ toString alpha
            ++ ")"


renderColors : Colors -> List ( String, String )
renderColors { text, background, border } =
    [ "border-color" => colorToString border
    , "color" => colorToString text
    , "background-color" => colorToString background
    ]


renderLength : Length -> String
renderLength l =
    case l of
        Px x ->
            toString x ++ "px"

        Percent x ->
            toString x ++ "%"

        Auto ->
            "auto"


renderPosition : Position -> List ( String, String )
renderPosition { relativeTo, anchor, position } =
    let
        ( x, y ) =
            position

        relative =
            case relativeTo of
                Screen ->
                    "position" => "fixed"

                CurrentPosition ->
                    "position" => "relative"

                Parent ->
                    "position" => "absolute"
    in
        case anchor of
            ( AnchorTop, AnchorLeft ) ->
                [ relative
                , "top" => (toString (-1 * y) ++ "px")
                , "left" => (toString x ++ "px")
                ]

            ( AnchorTop, AnchorRight ) ->
                [ relative
                , "top" => (toString (-1 * y) ++ "px")
                , "right" => (toString (-1 * x) ++ "px")
                ]

            ( AnchorBottom, AnchorLeft ) ->
                [ relative
                , "bottom" => (toString y ++ "px")
                , "left" => (toString x ++ "px")
                ]

            ( AnchorBottom, AnchorRight ) ->
                [ relative
                , "bottom" => (toString y ++ "px")
                , "right" => (toString (-1 * x) ++ "px")
                ]


renderLayout : Layout -> ( List ( String, String ), String, Permissions )
renderLayout layout =
    case layout of
        TextLayout { spacing } ->
            ( [ "display" => "block" ]
            , render4tuplePx spacing
            , { floats = True
              , inline = True
              }
            )

        TableLayout { spacing } ->
            ( [ "display" => "block" ]
            , render4tuplePx spacing
            , { floats = False
              , inline = False
              }
            )

        FlexLayout flex ->
            ( [ "display" => "flex"
              , case flex.go of
                    Right ->
                        "flex-direction" => "row"

                    Left ->
                        "flex-direction" => "row-reverse"

                    Down ->
                        "flex-direction" => "column"

                    Up ->
                        "flex-direction" => "column-reverse"
              , if flex.wrap then
                    "flex-wrap" => "wrap"
                else
                    "flex-wrap" => "nowrap"
              , case flex.go of
                    Right ->
                        case fst flex.align of
                            HLeft ->
                                "justify-content" => "flex-start"

                            HRight ->
                                "justify-content" => "flex-end"

                            HCenter ->
                                "justify-content" => "center"

                            HStretch ->
                                "justify-content" => "stretch"

                    Left ->
                        case fst flex.align of
                            HLeft ->
                                "justify-content" => "flex-end"

                            HRight ->
                                "justify-content" => "flex-start"

                            HCenter ->
                                "justify-content" => "center"

                            HStretch ->
                                "justify-content" => "stretch"

                    Down ->
                        case fst flex.align of
                            HLeft ->
                                "align-items" => "flex-start"

                            HRight ->
                                "align-items" => "flex-end"

                            HCenter ->
                                "align-items" => "center"

                            HStretch ->
                                "align-items" => "stretch"

                    Up ->
                        case fst flex.align of
                            HLeft ->
                                "align-items" => "flex-start"

                            HRight ->
                                "align-items" => "flex-end"

                            HCenter ->
                                "align-items" => "center"

                            HStretch ->
                                "align-items" => "stretch"
              , case flex.go of
                    Right ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-start"

                            VBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Left ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-start"

                            VBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Down ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-start"

                            VBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Up ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-end"

                            VBottom ->
                                "align-items" => "flex-start"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"
              ]
            , render4tuplePx flex.spacing
            , { floats = False
              , inline = False
              }
            )


cssTransitions =
    [ "transition-property" => "opacity, padding, left, top, right, bottom, height, width, color, background-color, border-color, border-width, box-shadow, text-shadow, filter, transform, font-size, line-height"
    , "transition-duration" => "500ms"
    , "-webkit-transition-timing-function" => "ease-out"
    , "transition-timing-function" => "ease-out"
    ]


renderTransitionStyle : Model -> List ( String, String )
renderTransitionStyle style =
    --let
    --stylePairs =
    case style.visibility of
        Hidden ->
            [ "display" => "none" ]

        Transparent transparency ->
            List.concat <|
                List.filterMap identity
                    [ Just
                        [ "opacity" => toString (1.0 - transparency)
                        , "width" => (renderLength style.width)
                        , "height" => (renderLength style.height)
                        , "padding" => render4tuplePx style.padding
                        ]
                    , Just <| renderColors style.colors
                    , Just <| renderText style.text
                    , Just <| renderBorder style.border
                    , listMaybeMap (renderShadow "box-shadow" False) style.shadows
                    , listMaybeMap (renderShadow "box-shadow" True) style.insetShadows
                    , listMaybeMap (renderShadow "text-shadow" False) style.textShadows
                    , listMaybeMap renderFilters style.filters
                    , listMaybeMap renderTransforms style.transforms
                    ]


{-| Produces valid css code.
-}
renderCssTransitions : String -> Model -> List StyleDefinition
renderCssTransitions id model =
    let
        hover =
            case model.onHover of
                Nothing ->
                    Nothing

                Just (Transition hoverStyle) ->
                    Just <|
                        StyleDef
                            { name = ":hover"
                            , style = renderTransitionStyle hoverStyle
                            , modes = []
                            , keyframes = Nothing
                            }

        focus =
            case model.onFocus of
                Nothing ->
                    Nothing

                Just (Transition focusStyle) ->
                    Just <|
                        StyleDef
                            { name = ":focus"
                            , style = renderTransitionStyle focusStyle
                            , modes = []
                            , keyframes = Nothing
                            }
    in
        List.filterMap identity [ hover, focus ]


renderCssTransitionsWeak : String -> Weak -> List StyleDefinition
renderCssTransitionsWeak id model =
    let
        hover =
            case model.onHover of
                Nothing ->
                    Nothing

                Just (Transition hoverStyle) ->
                    Just <|
                        StyleDef
                            { name = ":hover"
                            , style = renderTransitionStyle hoverStyle
                            , modes = []
                            , keyframes = Nothing
                            }

        focus =
            case model.onFocus of
                Nothing ->
                    Nothing

                Just (Transition focusStyle) ->
                    Just <|
                        StyleDef
                            { name = ":focus"
                            , style = renderTransitionStyle focusStyle
                            , modes = []
                            , keyframes = Nothing
                            }
    in
        List.filterMap identity [ hover, focus ]


generateId : List ( String, String ) -> String
generateId style =
    List.map (\( name, value ) -> name ++ value) style
        |> String.concat
        |> hash


{-| http://package.elm-lang.org/packages/Skinney/murmur3/2.0.2/Murmur3
-}
hash : String -> String
hash value =
    Murmur3.hashString 8675309 value
        |> toString
        |> String.toList
        |> List.map (Char.fromCode << ((+) 65) << Result.withDefault 0 << String.toInt << String.fromChar)
        |> String.fromList
        |> String.toLower
