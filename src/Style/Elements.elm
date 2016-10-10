module Style.Elements exposing (map, html, element, elementAs, build, buildInline)

import String
import Char
import Murmur3
import Color exposing (Color)
import Html
import Set exposing (Set)
import Svg.Attributes
import Html.Attributes
import Style.Model exposing (..)


html : Html.Html msg -> Element msg
html node =
    Html node


element : Model -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
element styleModel attrs content =
    Element
        { style = styleModel
        , node = "div"
        , attributes = attrs
        , children = content
        }


elementAs : String -> Model -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
elementAs node styleModel attrs content =
    Element
        { style = styleModel
        , node = node
        , attributes = attrs
        , children = content
        }


map : (Model -> Model) -> Element msg -> Element msg
map fn el =
    case el of
        Element props ->
            Element { props | style = fn props.style }

        _ ->
            el


type StyleDefinition
    = StyleDef
        { name : String
        , tags : List String
        , style : List ( String, String )
        , modes :
            List StyleDefinition
        , keyframes :
            Maybe (List ( Float, List ( String, String ) ))
        }


classNameAndTags : StyleDefinition -> String
classNameAndTags def =
    case def of
        StyleDef { name, tags } ->
            name ++ " " ++ String.join " " tags


className : StyleDefinition -> String
className def =
    case def of
        StyleDef { name } ->
            name


buildInline : Element msg -> Html.Html msg
buildInline element =
    let
        construct node attributes children parentStyle =
            let
                ( builtChildren, childStyles ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildInlineChild child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtTransitions
                                )
                        )
                        ( [], [] )
                        children

                ( className, renderedStyle, onlyTransitionsAndAnimations ) =
                    case parentStyle of
                        StyleDef { name, tags, style, modes, keyframes } ->
                            ( name
                            , style
                            , StyleDef
                                { name = name
                                , tags = tags
                                , style = []
                                , modes = modes
                                , keyframes = keyframes
                                }
                            )

                styleSheet =
                    Html.node "style"
                        []
                        [ Html.text <|
                            floatError
                                ++ inlineError
                                ++ convertToCSS (onlyTransitionsAndAnimations :: childStyles)
                        ]
            in
                Html.node
                    node
                    (Svg.Attributes.class (classNameAndTags parentStyle) :: Html.Attributes.style renderedStyle :: attributes)
                    (styleSheet :: builtChildren)
    in
        case element of
            Html html ->
                html

            Element model ->
                render model.style
                    |> construct model.node model.attributes model.children


buildInlineChild : Element msg -> ( Html.Html msg, List StyleDefinition )
buildInlineChild element =
    let
        construct node attributes children parentStyle =
            let
                ( builtChildren, childStyle ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtStyle ) =
                                    buildInlineChild child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtStyle
                                )
                        )
                        ( [], [] )
                        children

                ( renderedStyle, onlyTransitionsAndAnimations ) =
                    case parentStyle of
                        StyleDef { name, style, tags, modes, keyframes } ->
                            ( style
                            , StyleDef
                                { name = name
                                , tags = tags
                                , style = []
                                , modes = modes
                                , keyframes = keyframes
                                }
                            )
            in
                ( Html.node
                    node
                    (Svg.Attributes.class (classNameAndTags parentStyle) :: Html.Attributes.style renderedStyle :: attributes)
                    builtChildren
                , onlyTransitionsAndAnimations :: childStyle
                )
    in
        case element of
            Html html ->
                ( html, [] )

            Element model ->
                render model.style
                    |> construct model.node model.attributes model.children


type alias Permissions =
    { floats : Bool
    , inline : Bool
    }


renderPermissions : Permissions -> String
renderPermissions perm =
    if not perm.floats && not perm.inline then
        "not-floatable not-inlineable"
    else if not perm.floats then
        "not-floatable"
    else if not perm.inline then
        "not-inlineable"
    else
        ""


build : Element msg -> Html.Html msg
build element =
    let
        construct node attributes children parentStyle =
            let
                ( builtChildren, childStyles ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildChild child
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
                            floatError
                                ++ inlineError
                                ++ convertToCSS (parentStyle :: childStyles)
                        ]
            in
                Html.node
                    node
                    (Svg.Attributes.class (classNameAndTags parentStyle) :: attributes)
                    (styleSheet :: builtChildren)
    in
        case element of
            Html html ->
                html

            Element model ->
                render model.style
                    |> construct model.node model.attributes model.children


buildChild : Element msg -> ( Html.Html msg, List StyleDefinition )
buildChild element =
    let
        construct node attributes children parentStyle =
            let
                ( builtChildren, childStyle ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtStyle ) =
                                    buildChild child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtStyle
                                )
                        )
                        ( [], [] )
                        children
            in
                ( Html.node
                    node
                    (Svg.Attributes.class (classNameAndTags parentStyle) :: attributes)
                    builtChildren
                , parentStyle :: childStyle
                )
    in
        case element of
            Html html ->
                ( html, [] )

            Element model ->
                render model.style
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
                        ++ convertModesToCSS name modes
                        ++ convertKeyframesToCSS name keyframes
    in
        uniqueBy className styles
            |> List.map convert
            |> String.join "\n"
            |> String.trim



--convertKeyframesToCSS


convertKeyframesToCSS name keyframes =
    case keyframes of
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



--convertModesToCSS :


convertModesToCSS name modes =
    String.join "\n" <|
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


render : Model -> StyleDefinition
render style =
    case style.visibility of
        Hidden ->
            let
                renderedStyle =
                    [ "display" => "none" ]
            in
                addClassName style.addClass
                    { style = renderedStyle
                    , tags = []
                    , modes = []
                    , keyframes = Nothing
                    }

        Transparent transparency ->
            let
                ( layout, childMargin, childrenPermissions ) =
                    renderLayout style.layout

                renderedStyle =
                    List.concat <|
                        List.filterMap identity
                            [ Just <| layout
                            , Just <| renderPosition style.position
                            , renderInline style.inline
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
                            , Maybe.map renderFloating style.float
                            , listMaybeMap (renderShadow "box-shadow" False) style.shadows
                            , listMaybeMap (renderShadow "box-shadow" True) style.insetShadows
                            , listMaybeMap (renderShadow "text-shadow" False) style.textShadows
                            , listMaybeMap renderFilters style.filters
                            , listMaybeMap renderTransforms style.transforms
                            , if not <| List.isEmpty style.transitions then
                                Just cssTransitions
                              else
                                Nothing
                            , Maybe.map renderAnimation style.animation
                            ]

                restrictedTags =
                    let
                        floating =
                            Maybe.map (\_ -> "floating") style.float

                        inline =
                            if style.inline then
                                Just "inline"
                            else
                                Nothing

                        permissions =
                            Just <|
                                renderPermissions childrenPermissions
                    in
                        List.filterMap identity [ permissions, inline, floating ]
            in
                addClassName style.addClass
                    { style = renderedStyle
                    , tags = restrictedTags
                    , modes =
                        StyleDef
                            { name = " > *"
                            , style = [ "margin" => childMargin ]
                            , tags = []
                            , modes = []
                            , keyframes = Nothing
                            }
                            :: List.map renderCssTransitions style.transitions
                    , keyframes = Maybe.map renderAnimationKeyframes style.animation
                    }


addClassName mAdditionalNames { tags, style, modes, keyframes } =
    let
        styleString =
            List.map (\( name, value ) -> name ++ value) style
                |> String.concat

        keyframeString =
            convertKeyframesToCSS "" keyframes

        modesString =
            convertModesToCSS "" modes

        name =
            case mAdditionalNames of
                Nothing ->
                    hash (styleString ++ keyframeString ++ modesString)

                Just addName ->
                    hash (styleString ++ keyframeString ++ modesString) ++ " " ++ addName
    in
        StyleDef
            { name = name
            , tags = tags
            , style =
                List.map
                    (\( pName, pValue ) ->
                        if pName == "animation" then
                            ( pName, "animation-" ++ name ++ " " ++ pValue )
                        else
                            ( pName, pValue )
                    )
                    style
            , modes = modes
            , keyframes = keyframes
            }


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


renderVariation : Variation -> StyleDefinition
renderVariation style =
    let
        ( layout, childMargin, childrenPermissions ) =
            Maybe.map renderLayout style.layout
                |> Maybe.withDefault ( [], "0px", { floats = False, inline = False } )

        renderedStyle =
            List.concat <|
                List.filterMap identity
                    [ Just layout
                    , Maybe.map renderPosition style.position
                    , renderInline style.inline
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
                    , Maybe.map renderFloating style.float
                    , listMaybeMap (renderShadow "box-shadow" False) style.shadows
                    , listMaybeMap (renderShadow "box-shadow" True) style.insetShadows
                    , listMaybeMap (renderShadow "text-shadow" False) style.textShadows
                    , listMaybeMap renderFilters style.filters
                    , listMaybeMap renderTransforms style.transforms
                    , Maybe.map renderVisibility style.visibility
                    , if not <| List.isEmpty style.transitions then
                        Just cssTransitions
                      else
                        Nothing
                    , Maybe.map renderAnimation style.animation
                    ]

        restrictedTags =
            let
                floating =
                    Maybe.map (\_ -> "floating") style.float

                inline =
                    if style.inline then
                        Just "inline"
                    else
                        Nothing

                permissions =
                    Just <|
                        renderPermissions childrenPermissions
            in
                List.filterMap identity [ permissions, inline, floating ]
    in
        addClassName Nothing
            { style = renderedStyle
            , tags = restrictedTags
            , modes =
                StyleDef
                    { name = " > *"
                    , tags = []
                    , style = [ "margin" => childMargin ]
                    , modes = []
                    , keyframes = Nothing
                    }
                    :: List.map renderCssTransitions style.transitions
            , keyframes = Maybe.map renderAnimationKeyframes style.animation
            }


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
            case renderVariation styleDef of
                StyleDef { style } ->
                    ( marker, style )
    in
        List.map renderAnimStep anim.steps


renderAnimation : Animation -> List ( String, String )
renderAnimation (Animation anim) =
    let
        duration =
            toString anim.duration ++ "ms"

        iterations =
            if isInfinite anim.repeat then
                "infinite"
            else
                toString anim.repeat
    in
        [ "animation" => (duration ++ " " ++ anim.easing ++ " " ++ iterations)
        ]


renderVisibility : Visibility -> List ( String, String )
renderVisibility vis =
    case vis of
        Hidden ->
            [ "display" => "none" ]

        Transparent transparency ->
            [ "opacity" => toString (1.0 - transparency) ]


renderInline : Bool -> Maybe (List ( String, String ))
renderInline inline =
    if inline then
        Just [ "display" => "inline-block" ]
    else
        Nothing


renderFloating : Floating -> List ( String, String )
renderFloating floating =
    case floating of
        FloatLeft ->
            [ "float" => "left" ]

        FloatRight ->
            [ "float" => "right" ]


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
        , case text.whitespace of
            Normal ->
                Just ("white-space" => "normal")

            Pre ->
                Just ("white-space" => "pre")

            PreWrap ->
                Just ("white-space" => "pre-wrap")

            PreLine ->
                Just ("white-space" => "pre-line")

            NoWrap ->
                Just ("white-space" => "no-wrap")
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
    , "stroke" => colorToString border
    , "color" => colorToString text
    , "background-color" => colorToString background
    , "fill" => colorToString background
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
                        case flex.horizontal of
                            AlignLeft ->
                                "justify-content" => "flex-start"

                            AlignRight ->
                                "justify-content" => "flex-end"

                            AlignCenter ->
                                "justify-content" => "center"

                            Justify ->
                                "justify-content" => "stretch"

                            JustifyAll ->
                                "justify-content" => "stretch"

                    Left ->
                        case flex.horizontal of
                            AlignLeft ->
                                "justify-content" => "flex-end"

                            AlignRight ->
                                "justify-content" => "flex-start"

                            AlignCenter ->
                                "justify-content" => "center"

                            Justify ->
                                "justify-content" => "stretch"

                            JustifyAll ->
                                "justify-content" => "stretch"

                    Down ->
                        case flex.horizontal of
                            AlignLeft ->
                                "align-items" => "flex-start"

                            AlignRight ->
                                "align-items" => "flex-end"

                            AlignCenter ->
                                "align-items" => "center"

                            Justify ->
                                "align-items" => "stretch"

                            JustifyAll ->
                                "align-items" => "stretch"

                    Up ->
                        case flex.horizontal of
                            AlignLeft ->
                                "align-items" => "flex-start"

                            AlignRight ->
                                "align-items" => "flex-end"

                            AlignCenter ->
                                "align-items" => "center"

                            Justify ->
                                "align-items" => "stretch"

                            JustifyAll ->
                                "align-items" => "stretch"
              , case flex.go of
                    Right ->
                        case flex.vertical of
                            AlignTop ->
                                "align-items" => "flex-start"

                            AlignBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Left ->
                        case flex.vertical of
                            AlignTop ->
                                "align-items" => "flex-start"

                            AlignBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Down ->
                        case flex.vertical of
                            AlignTop ->
                                "align-items" => "flex-start"

                            AlignBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Up ->
                        case flex.vertical of
                            AlignTop ->
                                "align-items" => "flex-end"

                            AlignBottom ->
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


cssTransitions : List ( String, String )
cssTransitions =
    [ "transition-property" => "opacity, padding, left, top, right, bottom, height, width, color, background-color, border-color, border-width, box-shadow, text-shadow, filter, transform, font-size, line-height"
    , "transition-duration" => "500ms"
    , "-webkit-transition-timing-function" => "ease-out"
    , "transition-timing-function" => "ease-out"
    ]


renderTransitionStyle : Variation -> List ( String, String )
renderTransitionStyle style =
    List.concat <|
        List.filterMap identity
            [ Just <|
                List.filterMap identity
                    [ Maybe.map (\w -> "width" => (renderLength w)) style.width
                    , Maybe.map (\h -> "height" => (renderLength h)) style.height
                    , Maybe.map (\c -> "cursor" => c) style.cursor
                    , Maybe.map (\p -> "padding" => (render4tuplePx p)) style.padding
                    ]
            , Maybe.map renderColors style.colors
            , Maybe.map renderText style.text
            , Maybe.map renderBorder style.border
            , listMaybeMap (renderShadow "box-shadow" False) style.shadows
            , listMaybeMap (renderShadow "box-shadow" True) style.insetShadows
            , listMaybeMap (renderShadow "text-shadow" False) style.textShadows
            , listMaybeMap renderFilters style.filters
            , listMaybeMap renderTransforms style.transforms
            , Maybe.map renderVisibility style.visibility
            ]


{-|
-}
renderCssTransitions : Transition -> StyleDefinition
renderCssTransitions (Transition name targetStyle) =
    StyleDef
        { name = ":" ++ name
        , tags = []
        , style = renderTransitionStyle targetStyle
        , modes = []
        , keyframes = Nothing
        }


floatError : String
floatError =
    """
.not-floatable > * {
    float: none !important;
}
.not-floatable > .floating {
    border: 3px solid red; !important;
}
.not-floatable > .floating::after {
    display: block;
    content: 'Floating Elements can only be in Text Layouts';
    color: black;
    background-color: red;
}
"""


inlineError : String
inlineError =
    """
.not-inlineable > * {
    float: none !important;
}
.not-inlineable > .inline {
    border: 3px solid red;
}
.not-inlineable > .inline::after {
    display: block;
    content: 'Inline Elements can only be in Text Layouts';
    color: black;
    background-color: red;
}
"""
