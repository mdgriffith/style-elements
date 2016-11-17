module Style.Render exposing (render, getName)

{-|
-}

import Html
import Html.Attributes
import Svg.Attributes
import Style.Model exposing (..)
import Color exposing (Color)
import String
import Char
import Murmur3
import Json.Encode as Json
import String.Extra


formatName : a -> String
formatName class =
    (toString class)
        |> String.Extra.unquote
        |> String.Extra.decapitalize
        |> String.Extra.dasherize


type alias Permissions =
    { floats : Bool
    , inline : Bool
    }


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


getName : Model a -> String
getName model =
    Tuple.first <| render model


renderBaseStyle : Model a -> List ( String, String )
renderBaseStyle (Model style) =
    let
        ( layout, childrenPermissions ) =
            renderLayout style.layout

        animationAndKeyframes =
            Maybe.map renderAnimation style.animation

        simple =
            List.filterMap identity
                [ Just ("box-sizing" => "border-box")
                , Just <|
                    "border-style"
                        => case style.borderStyle of
                            Solid ->
                                "solid"

                            Dashed ->
                                "dashed"

                            Dotted ->
                                "dotted"
                , if style.italic then
                    Just ("font-style" => "italic")
                  else
                    Nothing
                , Maybe.map
                    (\bold ->
                        "font-weight"
                            => toString bold
                    )
                    style.bold
                , case ( style.underline, style.strike ) of
                    ( False, False ) ->
                        Just ("text-decoration" => "none")

                    ( True, False ) ->
                        Just ("text-decoration" => "underline")

                    ( False, True ) ->
                        Just ("text-decoration" => "line-through")

                    ( True, True ) ->
                        Just ("text-decoration" => "underline line-through")
                , Maybe.map (\zIndex -> "z-index" => toString zIndex) style.zIndex
                  --, Maybe.map renderFilters style.filters
                  --, Maybe.map renderTransforms style.transforms
                , Maybe.map Tuple.first animationAndKeyframes
                , Just <| renderVisibility style.visibility
                ]

        compound =
            List.concat <|
                List.filterMap identity
                    [ Just layout
                    , Just <| renderPosition style.relativeTo style.anchor style.position
                    , Just <| renderColorPalette style.colors
                    , Just <| renderText style.font
                      --, Maybe.map renderBackgroundImage style.backgroundImage
                    , Maybe.map renderFloating style.float
                      --, Maybe.map renderShadow style.shadows
                      --, Maybe.map renderTransition style.transition
                    , if style.inline then
                        Just [ "display" => "inline-block" ]
                      else
                        Nothing
                    , Just (renderPoints (List.map renderProperty style.properties))
                    ]
    in
        simple ++ compound


type StylePoint
    = Single ( String, String )
    | Multiple (List ( String, String ))


renderPoints : List StylePoint -> List ( String, String )
renderPoints points =
    List.foldr
        (\point aggregate ->
            case point of
                Single prop ->
                    prop :: aggregate

                Multiple props ->
                    props ++ aggregate
        )
        []
        points



--type alias StyleDefinition =
--    { selector : String
--    , style : List ( String, String )
--    , additional : List String
--    }


renderProperty : Property a -> StylePoint
renderProperty prop =
    case prop of
        Property name value ->
            Single ( name, value )

        Box name box ->
            Single ( name, (render4tuplePx box) )

        Len name length ->
            Single ( name, (renderLength length) )

        Filters filters ->
            Single <| renderFilters filters

        Transforms transforms ->
            Single <| renderTransforms transforms

        TransitionProperty transition ->
            Multiple <| renderTransition transition

        Shadows shadows ->
            Multiple <| renderShadow shadows

        BackgroundImageProp image ->
            Multiple <| renderBackgroundImage image


render : Model a -> ( String, String )
render (Model style) =
    let
        ( layout, childrenPermissions ) =
            renderLayout style.layout

        animationAndKeyframes =
            Maybe.map renderAnimation style.animation

        renderedStyle =
            renderBaseStyle (Model style)

        tags =
            let
                floating =
                    Maybe.map (\_ -> "floating") style.float

                inline =
                    if not style.inline then
                        Just "pos"
                    else
                        Nothing

                permissions =
                    if not childrenPermissions.floats && not childrenPermissions.inline then
                        Just "not-floatable not-inlineable"
                    else if not childrenPermissions.floats then
                        Just "not-floatable"
                    else if not childrenPermissions.inline then
                        Just "not-inlineable"
                    else
                        Nothing
            in
                List.filterMap identity [ permissions, inline, floating ]

        ( name, selector ) =
            case style.classOverride of
                Just override ->
                    ( override, override )

                Nothing ->
                    case style.class of
                        Just str ->
                            let
                                formatted =
                                    formatName str
                            in
                                ( formatted, "." ++ formatted )

                        Nothing ->
                            let
                                childrenSignature =
                                    Maybe.map renderSubElementSignature style.subelements
                                        |> Maybe.withDefault ""

                                propSignature =
                                    String.join "" <| List.map renderProp renderedStyle

                                mediaSignature =
                                    String.join "" <| List.map renderMediaQuerySignature style.media

                                hashed =
                                    hash (propSignature ++ childrenSignature ++ mediaSignature)
                            in
                                ( hashed, "." ++ hashed )

        childMargin =
            renderClass 0
                (selector ++ " > .pos")
                [ ( "margin", render4tuplePx style.spacing ) ]

        children =
            case Maybe.map (renderSubElements selector) style.subelements of
                Nothing ->
                    childMargin

                Just subs ->
                    childMargin ++ subs

        mediaQueries =
            case List.map (renderMediaQuery selector) style.media of
                [] ->
                    ""

                queries ->
                    (String.join "\n" queries) ++ "\n"
    in
        ( String.join " " (name :: tags)
        , renderClass 0 selector renderedStyle
            ++ children
            ++ (Maybe.map Tuple.second animationAndKeyframes
                    |> Maybe.withDefault ""
               )
            ++ mediaQueries
        )


brace : String -> String
brace str =
    " {\n" ++ str ++ "\n}"


type alias ClassPair =
    ( String, List ( String, String ) )


indent : Int -> String -> String
indent x str =
    str
        |> String.split "\n"
        |> List.filterMap
            (\s ->
                if String.isEmpty (String.trim s) then
                    Nothing
                else
                    Just <| (String.repeat x " ") ++ s
            )
        |> String.join "\n"


renderClass : Int -> String -> List ( String, String ) -> String
renderClass x name props =
    (name ++ brace (String.join "\n" <| List.map renderProp props) ++ "\n")
        |> if x > 0 then
            indent x
           else
            identity


renderProp : ( String, String ) -> String
renderProp ( propName, propValue ) =
    "  " ++ propName ++ ": " ++ propValue ++ ";"


renderSubElementSignature : SubElements a -> String
renderSubElementSignature sub =
    String.join "\n" <|
        List.filterMap
            (\( name, style ) ->
                case style of
                    Nothing ->
                        Nothing

                    Just (Model state) ->
                        Just (Tuple.second <| render (Model { state | classOverride = Just name }))
            )
            [ ":hover" => sub.hover
            , ":focus" => sub.focus
            , ":selection" => sub.selection
            , ":focus" => sub.focus
            , ":checked" => sub.checked
            , ":after" => sub.after
            , ":before" => sub.before
            ]


renderSubElements : String -> SubElements a -> String
renderSubElements className sub =
    String.join "\n" <|
        List.filterMap
            (\( name, style ) ->
                case style of
                    Nothing ->
                        Nothing

                    Just (Model state) ->
                        Just <| renderClass 0 (className ++ name) (renderBaseStyle (Model state))
            )
            [ ":hover" => sub.hover
            , ":focus" => sub.focus
            , ":selection" => sub.selection
            , ":focus" => sub.focus
            , ":checked" => sub.checked
            , ":after" => sub.after
            , ":before" => sub.before
            ]


renderMediaQuerySignature : MediaQuery a -> String
renderMediaQuerySignature (MediaQuery query (Model state)) =
    query ++ (Tuple.second (render (Model { state | classOverride = Just "media-query" })))


renderMediaQuery : String -> MediaQuery a -> String
renderMediaQuery className (MediaQuery query model) =
    let
        style =
            renderClass 2 className (renderBaseStyle model)
    in
        "@media " ++ query ++ brace style


{-|

-}
hash : String -> String
hash value =
    Murmur3.hashString 8675309 value
        |> toString
        |> String.toList
        |> List.map (Char.fromCode << ((+) 65) << Result.withDefault 0 << String.toInt << String.fromChar)
        |> String.fromList
        |> String.toLower


renderAnimation : Animation a -> ( ( String, String ), String )
renderAnimation (Animation { duration, easing, steps, repeat }) =
    let
        ( renderedStyle, renderedFrames ) =
            let
                renderedDuration =
                    toString duration ++ "ms"

                iterations =
                    if isInfinite repeat then
                        "infinite"
                    else
                        toString repeat

                ( allNames, renderedSteps ) =
                    List.unzip <|
                        List.map
                            (\( marker, model ) ->
                                let
                                    name =
                                        getName model

                                    style =
                                        renderClass 2 (toString marker ++ "%") (renderBaseStyle model)
                                in
                                    ( name, style ++ "\n" )
                            )
                            steps

                animationName =
                    "animation-" ++ (hash <| String.concat allNames)
            in
                ( "animation" => (animationName ++ " " ++ renderedDuration ++ " " ++ easing ++ " " ++ iterations)
                , "@keyframes "
                    ++ animationName
                    ++ " {\n"
                    ++ (String.join "" renderedSteps)
                    ++ "}"
                )
    in
        ( renderedStyle, renderedFrames )


renderTransition : Transition -> List ( String, String )
renderTransition { property, duration, easing, delay } =
    [ "transition-property" => property
    , "transition-duration" => (toString duration ++ "ms")
    , "-webkit-transition-timing-function" => easing
    , "transition-timing-function" => easing
    , "transition-delay" => (toString delay ++ "ms")
    ]


renderVisibility : Visibility -> ( String, String )
renderVisibility vis =
    case vis of
        Hidden ->
            "display" => "none"

        Transparent transparency ->
            "opacity" => toString (1.0 - transparency)


renderFloating : Floating -> List ( String, String )
renderFloating floating =
    case floating of
        FloatLeft ->
            [ "float" => "left"
            , "margin-left" => "0px !important"
            ]

        FloatRight ->
            [ "float" => "right"
            , "margin-right" => "0px !important"
            ]

        FloatTopLeft ->
            [ "float" => "left"
            , "margin-left" => "0px !important"
            , "margin-top" => "0px !important"
            ]

        FloatTopRight ->
            [ "float" => "right"
            , "margin-right" => "0px !important"
            , "margin-top" => "0px !important"
            ]


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
    , "background-position" => ((toString (Tuple.first image.position)) ++ "px " ++ (toString (Tuple.second image.position)) ++ "px")
    ]


renderTransforms : List Transform -> ( String, String )
renderTransforms transforms =
    "transform"
        => (String.join " " (List.map transformToString transforms))


transformToString : Transform -> String
transformToString transform =
    case transform of
        Translate x y z ->
            "translate3d("
                ++ toString x
                ++ "px, "
                ++ toString y
                ++ "px, "
                ++ toString z
                ++ "px)"

        Rotate x y z ->
            "rotateX("
                ++ toString x
                ++ "rad) rotateY("
                ++ toString y
                ++ "rad) rotateZ("
                ++ toString z
                ++ "rad)"

        Scale x y z ->
            "scale3d("
                ++ toString x
                ++ ", "
                ++ toString y
                ++ ", "
                ++ toString z
                ++ ")"


renderFilters : List Filter -> ( String, String )
renderFilters filters =
    "filter"
        => (String.join " " <| List.map filterToString filters)


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

        DropShadow shadow ->
            "drop-shadow(" ++ shadowValue shadow ++ ")"


renderShadow : List Shadow -> List ( String, String )
renderShadow shadows =
    let
        ( text, box ) =
            List.partition (\(Shadow s) -> s.kind == "text") shadows

        renderedBox =
            String.join ", " (List.map shadowValue box)

        renderedText =
            String.join ", " (List.map shadowValue text)
    in
        List.filterMap identity
            [ if renderedBox == "" then
                Nothing
              else
                Just ("box-shadow" => renderedBox)
            , if renderedText == "" then
                Nothing
              else
                Just ("text-shadow" => renderedText)
            ]


shadowValue : Shadow -> String
shadowValue (Shadow shadow) =
    String.join " "
        [ if shadow.kind == "inset" then
            "inset"
          else
            ""
        , toString (Tuple.first shadow.offset) ++ "px"
        , toString (Tuple.second shadow.offset) ++ "px"
        , toString shadow.blur ++ "px"
        , (if shadow.kind == "text" || shadow.kind == "drop" then
            ""
           else
            toString shadow.size ++ "px"
          )
        , colorToString shadow.color
        ]


render4tuplePx : ( Float, Float, Float, Float ) -> String
render4tuplePx ( a, b, c, d ) =
    toString a ++ "px " ++ toString b ++ "px " ++ toString c ++ "px " ++ toString d ++ "px"


renderText : Font -> List ( String, String )
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
            text.letterOffset
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


renderColorPalette : ColorPalette -> List ( String, String )
renderColorPalette { text, background, border } =
    [ "border-color" => colorToString border
    , "color" => colorToString text
    , "background-color" => colorToString background
    , "fill" => colorToString background
    , "stroke" => colorToString border
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


renderPosition : RelativeTo -> Anchor -> ( Float, Float ) -> List ( String, String )
renderPosition relativeTo anchor position =
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
                , "top" => (toString y ++ "px")
                , "left" => (toString x ++ "px")
                ]

            ( AnchorTop, AnchorRight ) ->
                [ relative
                , "top" => (toString y ++ "px")
                , "right" => (toString (-1 * x) ++ "px")
                ]

            ( AnchorBottom, AnchorLeft ) ->
                [ relative
                , "bottom" => (toString (-1 * y) ++ "px")
                , "left" => (toString x ++ "px")
                ]

            ( AnchorBottom, AnchorRight ) ->
                [ relative
                , "bottom" => (toString (-1 * y) ++ "px")
                , "right" => (toString (-1 * x) ++ "px")
                ]


renderLayout : Layout -> ( List ( String, String ), Permissions )
renderLayout layout =
    case layout of
        TextLayout ->
            ( [ "display" => "block" ]
            , { floats = True
              , inline = True
              }
            )

        TableLayout ->
            ( [ "display" => "table", "border-collapse" => "collapse" ]
            , { floats = False
              , inline = False
              }
            )

        FlexLayout (Flexible flex) ->
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
                                "justify-content" => "space-between"

                            JustifyAll ->
                                "justify-content" => "space-between"

                    Left ->
                        case flex.horizontal of
                            AlignLeft ->
                                "justify-content" => "flex-end"

                            AlignRight ->
                                "justify-content" => "flex-start"

                            AlignCenter ->
                                "justify-content" => "center"

                            Justify ->
                                "justify-content" => "space-between"

                            JustifyAll ->
                                "justify-content" => "space-between"

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
                                "justify-content" => "flex-start"

                            AlignBottom ->
                                "justify-content" => "flex-end"

                            VCenter ->
                                "justify-content" => "center"

                            VStretch ->
                                "justify-content" => "space-between"

                    Up ->
                        case flex.vertical of
                            AlignTop ->
                                "justify-content" => "flex-end"

                            AlignBottom ->
                                "justify-content" => "flex-start"

                            VCenter ->
                                "justify-content" => "center"

                            VStretch ->
                                "justify-content" => "space-between"
              ]
            , { floats = False
              , inline = False
              }
            )


clearfix : String
clearfix =
    """
.floating:after {
    visibility: hidden;
    display: block;
    clear: both;
    height: 0px;
}
"""


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
    display: inline-block;
    color: black;
    background-color: red;
}
.not-floatable > .floating:hover::after {
    content: 'Floating Elements can only be in Text Layouts';
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
