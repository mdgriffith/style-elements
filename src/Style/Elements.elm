module Style.Elements exposing (map, html, element, elementAs, build, buildWithTransitions)

import String
import Char
import Murmur3
import Color exposing (Color)
import Html
import Html.Attributes


--import Style exposing (..)

import Style.Model exposing (..)


type alias HtmlNode msg =
    List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg


map : (Model -> Model) -> Element msg -> Element msg
map fn el =
    case el of
        Html node ->
            Html node

        Element props ->
            Element { props | style = fn props.style }


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


build : Element msg -> Html.Html msg
build element =
    case element of
        Html html ->
            html

        Element model ->
            let
                ( parent, childStyle, childPermissions ) =
                    render model.style { floats = False, inline = False }
            in
                model.node
                    (Html.Attributes.style parent :: model.attributes)
                    (List.map
                        (buildChild childPermissions childStyle)
                        model.children
                    )


buildChild : Permissions -> Html.Attribute msg -> Element msg -> Html.Html msg
buildChild permissions inherited element =
    case element of
        Html html ->
            html

        Element model ->
            let
                ( parent, childStyle, childrenPermissions ) =
                    render model.style permissions
            in
                model.node
                    (Html.Attributes.style parent :: inherited :: model.attributes)
                    (List.map
                        (buildChild childrenPermissions childStyle)
                        model.children
                    )


buildWithTransitions : Element msg -> Html.Html msg
buildWithTransitions element =
    case element of
        Html html ->
            html

        Element model ->
            let
                ( parent, childMargin, childPermissions ) =
                    render model.style { floats = False, inline = False }

                ( children, childTransitions ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildChildWithTransitions childPermissions childMargin child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtTransitions
                                )
                        )
                        ( [], "" )
                        model.children

                className =
                    generateId parent

                transitionStyleSheet =
                    Html.node "style"
                        []
                        [ Html.text <|
                            renderCssTransitions className model.style
                                ++ childTransitions
                        ]

                attributes =
                    if model.style.onHover /= Nothing || model.style.onFocus /= Nothing then
                        Html.Attributes.class className :: Html.Attributes.style parent :: model.attributes
                    else
                        Html.Attributes.style parent :: model.attributes
            in
                model.node
                    attributes
                    (transitionStyleSheet :: children)


buildChildWithTransitions : Permissions -> Html.Attribute msg -> Element msg -> ( Html.Html msg, String )
buildChildWithTransitions permissions inherited element =
    case element of
        Html html ->
            ( html, "" )

        Element model ->
            let
                ( parent, childStyle, childPermissions ) =
                    render model.style permissions

                ( children, childTransitions ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildChildWithTransitions childPermissions childStyle child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtTransitions
                                )
                        )
                        ( [], "" )
                        model.children

                className =
                    generateId parent

                attributes =
                    if model.style.onHover /= Nothing || model.style.onFocus /= Nothing then
                        Html.Attributes.class className :: Html.Attributes.style parent :: inherited :: model.attributes
                    else
                        Html.Attributes.style parent :: inherited :: model.attributes
            in
                ( model.node
                    attributes
                    children
                , renderCssTransitions className model.style ++ childTransitions
                )


(=>) =
    (,)


type alias Permissions =
    { floats : Bool
    , inline : Bool
    }



--renderWeak : Model -> Permissions -> ( List ( String, String ), List (Html.Attribute msg), Permissions )
--renderWeak style permissions =
--     case style.visibility of
--        Hidden ->
--            ( [ "display" => "none" ]
--            , []
--            , { floats = False, inline = False }
--            )
--        Transparent transparency ->
--            let
--                ( layout, childLayout, childrenPermissions ) =
--                    renderLayout style.layout
--                renderedStyle =
--                    List.concat
--                        [ layout
--                        , renderPosition style.position
--                        , if style.inline then
--                            if permissions.inline then
--                                [ "display" => "inline-block" ]
--                            else
--                                let
--                                    _ =
--                                        Debug.log "style-blocks" "Elements can only be inline if they are in a text layout."
--                                in
--                                    []
--                          else
--                            []
--                        , [ "opacity" => toString (1.0 - transparency)
--                          , "width" => (renderLength style.width)
--                          , "height" => (renderLength style.height)
--                          , "cursor" => style.cursor
--                          , "padding" => render4tuplePx style.padding
--                          ]
--                        , renderColors style.colors
--                        , renderText style.text
--                        , renderBorder style.border
--                        , case style.backgroundImage of
--                            Nothing ->
--                                []
--                            Just image ->
--                                [ "background-image" => image.src
--                                , "background-repeat"
--                                    => case image.repeat of
--                                        RepeatX ->
--                                            "repeat-x"
--                                        RepeatY ->
--                                            "repeat-y"
--                                        Repeat ->
--                                            "repeat"
--                                        Space ->
--                                            "space"
--                                        Round ->
--                                            "round"
--                                        NoRepeat ->
--                                            "no-repeat"
--                                , "background-position" => ((toString (fst image.position)) ++ "px " ++ (toString (snd image.position)) ++ "px")
--                                ]
--                        , case style.float of
--                            Nothing ->
--                                []
--                            Just floating ->
--                                if permissions.floats then
--                                    case floating of
--                                        FloatLeft ->
--                                            [ "float" => "left" ]
--                                        FloatRight ->
--                                            [ "float" => "right" ]
--                                else
--                                    let
--                                        _ =
--                                            Debug.log "style-blocks" "Elements can only use float if they are in a text layout."
--                                    in
--                                        []
--                        , renderShadow "box-shadow" False style.shadows
--                        , renderShadow "box-shadow" True style.insetShadows
--                        , renderShadow "text-shadow" False style.textShadows
--                        , renderFilters style.filters
--                        , renderTransforms style.transforms
--                        ]
--            in
--                ( renderedStyle
--                , [ Html.Attributes.style childLayout ]
--                , childrenPermissions
--                )


render : Model -> Permissions -> ( List ( String, String ), Html.Attribute msg, Permissions )
render style permissions =
    case style.visibility of
        Hidden ->
            ( [ "display" => "none" ]
            , Html.Attributes.style []
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
                            , if style.inline then
                                if permissions.inline then
                                    Just [ "display" => "inline-block" ]
                                else
                                    let
                                        _ =
                                            Debug.log "style-blocks" "Elements can only be inline if they are in a text layout."
                                    in
                                        Nothing
                              else
                                Nothing
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
                            , renderShadow "box-shadow" False style.shadows
                            , renderShadow "box-shadow" True style.insetShadows
                            , renderShadow "text-shadow" False style.textShadows
                            , renderFilters style.filters
                            , renderTransforms style.transforms
                            ]
            in
                ( renderedStyle
                , Html.Attributes.style [ "margin" => childMargin ]
                , childrenPermissions
                )


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


renderTransforms : List Transform -> Maybe (List ( String, String ))
renderTransforms transforms =
    case transforms of
        [] ->
            Nothing

        ts ->
            Just
                [ "transform"
                    => (String.join " " (List.map transformToString ts))
                ]


transformToString : Transform -> String
transformToString transform =
    case transform of
        Translate x y z ->
            "transform3d("
                ++ toString x
                ++ ", "
                ++ toString y
                ++ ", "
                ++ toString z
                ++ ")"

        Rotate x y z ->
            "rotateX("
                ++ toString x
                ++ ")  rotateY("
                ++ toString y
                ++ ") rotateZ("
                ++ toString z
                ++ ")"

        Scale x y z ->
            "scale3d("
                ++ toString x
                ++ ", "
                ++ toString y
                ++ ", "
                ++ toString z
                ++ ")"


renderFilters : List Filter -> Maybe (List ( String, String ))
renderFilters filters =
    case filters of
        [] ->
            Nothing

        fs ->
            Just
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


renderShadow : String -> Bool -> List Shadow -> Maybe (List ( String, String ))
renderShadow shadowName inset shadows =
    let
        rendered =
            String.join ", " (List.map (shadowValue inset) shadows)
    in
        if rendered == "" then
            Nothing
        else
            Just [ shadowName => rendered ]


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
    """
    transition-property: opacity, padding, left, top, right, bottom, height, width, color, background-color, border-color, border-width, box-shadow, text-shadow, filter, transform, font-size, line-height;
    transition-duration: 500ms;
    -webkit-transition-timing-function: ease-out;
    transition-timing-function: ease-out;
"""


renderTransitionStyle : Model -> String
renderTransitionStyle style =
    let
        stylePairs =
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
                            , renderShadow "box-shadow" False style.shadows
                            , renderShadow "box-shadow" True style.insetShadows
                            , renderShadow "text-shadow" False style.textShadows
                            , renderFilters style.filters
                            , renderTransforms style.transforms
                            ]
    in
        List.map (\( name, val ) -> "    " ++ name ++ ": " ++ val ++ " !important;\n") stylePairs
            |> String.concat


{-| Produces valid css code.
-}
renderCssTransitions : String -> Model -> String
renderCssTransitions id model =
    let
        hover =
            case model.onHover of
                Nothing ->
                    ""

                Just (Transition hoverStyle) ->
                    "."
                        ++ id
                        ++ "{\n"
                        ++ cssTransitions
                        ++ "\n}\n"
                        ++ "."
                        ++ id
                        ++ ":hover {\n"
                        ++ renderTransitionStyle hoverStyle
                        ++ "\n}\n"

        focus =
            case model.onFocus of
                Nothing ->
                    ""

                Just (Transition focusStyle) ->
                    "."
                        ++ id
                        ++ "{\n"
                        ++ cssTransitions
                        ++ "\n}\n"
                        ++ "."
                        ++ id
                        ++ ":focus {\n"
                        ++ renderTransitionStyle focusStyle
                        ++ "\n}\n"
    in
        hover ++ focus


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
