module Style.Render exposing (render, convertToCSS)

{-|
-}

import Html
import Html.Attributes
import Svg.Attributes
import Style.Model exposing (..)
import Style
import Color exposing (Color)
import String
import Char
import Murmur3
import Json.Encode as Json
import Set exposing (Set)


classNameAndTags : StyleDefinition -> String
classNameAndTags def =
    case def of
        StyleDef { name, tags } ->
            name ++ " " ++ String.join " " tags


className : StyleDefinition -> String
className (StyleDef { name }) =
    name


styleProps : StyleDefinition -> List ( String, String )
styleProps (StyleDef { style }) =
    style


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


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


render : Model -> ( String, StyleDefinition )
render (Model style) =
    case style.visibility of
        Hidden ->
            let
                renderedStyle =
                    [ "display" => "none" ]

                styleDefinition =
                    addClassName
                        { style = renderedStyle
                        , tags = []
                        , animations = []
                        , media = []
                        }
            in
                ( classNameAndTags styleDefinition
                , styleDefinition
                )

        Transparent transparency ->
            let
                ( layout, childrenPermissions ) =
                    renderLayout style.layout

                renderedStyle =
                    let
                        simple =
                            List.filterMap identity
                                [ if style.inline then
                                    Just <| "display" => "inline-block"
                                  else
                                    Nothing
                                , Just ("box-sizing" => "border-box")
                                , Just ("opacity" => toString (1.0 - transparency))
                                , Just ("width" => renderLength style.width)
                                , Just ("height" => renderLength style.height)
                                , Just ("cursor" => style.cursor)
                                , Just ("padding" => render4tuplePx style.padding)
                                , Just ("border-width" => render4tuplePx style.borderWidth)
                                , Just ("border-radius" => render4tuplePx style.borderRadius)
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
                                , Maybe.map (\minWidth -> "min-width" => renderLength minWidth) style.minWidth
                                , Maybe.map (\minHeight -> "min-height" => renderLength minHeight) style.minHeight
                                , Maybe.map (\maxWidth -> "max-width" => renderLength maxWidth) style.maxWidth
                                , Maybe.map (\maxHeight -> "max-height" => renderLength maxHeight) style.maxHeight
                                , Maybe.map renderFilters style.filters
                                , Maybe.map renderTransforms style.transforms
                                ]

                        compound =
                            List.concat <|
                                List.filterMap identity
                                    [ Just layout
                                    , Just <| renderPosition style.relativeTo style.anchor style.position
                                    , Just <| renderColorPalette style.colors
                                    , Just <| renderText style.font
                                    , Maybe.map renderBackgroundImage style.backgroundImage
                                    , Maybe.map renderFloating style.float
                                    , Maybe.map renderShadow style.shadows
                                    , style.properties
                                    , if List.any isTransition style.animations then
                                        Just cssTransitions
                                      else
                                        Nothing
                                    ]
                    in
                        simple ++ compound

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

                childOverrides =
                    case style.layout of
                        TableLayout ->
                            [ ( PseudoClass " > *:not(.inline)"
                              , [ "margin" => render4tuplePx style.spacing
                                , "display" => "table-row !important"
                                ]
                              , Nothing
                              )
                            , ( PseudoClass " > * > *"
                              , [ "display" => "table-cell !important" ]
                              , Nothing
                              )
                            ]

                        _ ->
                            [ ( PseudoClass " > *:not(.inline)"
                              , [ "margin" => render4tuplePx style.spacing ]
                              , Nothing
                              )
                            ]

                styleDefinition =
                    addClassName
                        { style = renderedStyle
                        , tags = restrictedTags
                        , animations = List.map renderAnimation style.animations ++ childOverrides
                        , media = List.map (\(MediaQuery query mediaStyle) -> ( query, Tuple.second <| render mediaStyle )) style.media
                        }
            in
                ( classNameAndTags styleDefinition
                , styleDefinition
                )


isTransition : Animation -> Bool
isTransition (Animation { frames }) =
    case frames of
        Transition _ ->
            True

        _ ->
            False


brace : String -> String
brace str =
    " {\n" ++ str ++ "\n}"


isMount : ( Trigger, Style, Maybe ( String, Keyframes ) ) -> Bool
isMount ( trigger, _, _ ) =
    trigger == Style.Model.Mount


renderProp : ( String, String ) -> String
renderProp ( propName, propValue ) =
    "  " ++ propName ++ ": " ++ propValue ++ ";"


{-| Only handles the CSS related

Keyframes are rendered elsewhere.
-}
convertAnimation : String -> ( Trigger, Style, Maybe ( String, Keyframes ) ) -> String
convertAnimation name ( trigger, style, frames ) =
    let
        triggerName =
            case trigger of
                Mount ->
                    ""

                PseudoClass cls ->
                    cls

        class =
            "." ++ name ++ triggerName

        props =
            List.map renderProp style
                |> String.join "\n"
    in
        class ++ (brace props)


convertToCSS : List StyleDefinition -> String
convertToCSS styles =
    let
        convert style =
            case style of
                StyleDef { name, style, animations, media } ->
                    if List.length style == 0 then
                        ""
                    else
                        let
                            class =
                                "." ++ name

                            ( mountAnims, transitions ) =
                                List.partition isMount animations

                            animationProps =
                                List.concatMap
                                    (\mounts ->
                                        case mounts of
                                            ( _, aProps, _ ) ->
                                                aProps
                                    )
                                    mountAnims

                            props =
                                List.map renderProp
                                    (style
                                        ++ animationProps
                                    )
                                    |> String.join "\n"

                            keyframes =
                                List.map
                                    (\( _, _, keyframes ) ->
                                        Maybe.map (\( animName, frames ) -> convertKeyframesToCSS animName frames) keyframes
                                    )
                                    animations
                                    |> List.filterMap identity
                                    |> String.join "\n"
                                    |> (++) "\n"

                            modes =
                                List.map (convertAnimation name) transitions
                                    |> String.join "\n"
                                    |> (++) "\n"

                            mediaQueries =
                                List.map
                                    (\( query, styleVarDef ) ->
                                        let
                                            mediaProps =
                                                List.map renderProp (styleProps styleVarDef)
                                                    |> List.map (\prop -> "  " ++ prop)
                                                    |> String.join "\n"

                                            braced =
                                                " {" ++ mediaProps ++ "\n  }\n"
                                        in
                                            "@media " ++ query ++ brace ("  " ++ class ++ braced)
                                    )
                                    media
                                    |> String.join "\n"
                        in
                            class
                                ++ (brace props)
                                ++ "\n"
                                ++ modes
                                ++ keyframes
                                ++ mediaQueries
    in
        uniqueBy className styles
            |> List.map convert
            |> String.join "\n"
            |> String.trim


convertKeyframesToCSS : String -> List ( Float, List ( String, String ) ) -> String
convertKeyframesToCSS animName frames =
    "@keyframes "
        ++ animName
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
        ++ "}"


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


addClassName :
    { animations : List ( Trigger, Style, Maybe ( String, Keyframes ) )
    , style : List ( String, String )
    , tags : List String
    , media : List ( String, StyleDefinition )
    }
    -> StyleDefinition
addClassName { tags, style, animations, media } =
    let
        styleString =
            List.map (\( propName, value ) -> propName ++ value) style
                |> String.concat

        keyframeString =
            List.map
                (\( trigger, style, keyframes ) ->
                    let
                        renderedKeyframes =
                            case keyframes of
                                Just ( animName, frames ) ->
                                    Just <| convertKeyframesToCSS animName frames

                                Nothing ->
                                    Nothing

                        renderedStyle =
                            Just <| String.concat <| List.map (\( name, val ) -> name ++ val) style

                        renderedTrigger =
                            case trigger of
                                Mount ->
                                    Just "mount"

                                PseudoClass cls ->
                                    Just cls
                    in
                        String.concat <| List.filterMap identity [ renderedKeyframes, renderedStyle, renderedTrigger ]
                )
                animations
                |> String.concat

        modes =
            List.filter (\anim -> not <| isMount anim) animations
                |> List.map (convertAnimation "placeholder-for-hashing")
                |> String.concat

        mediaQueries =
            List.map
                (\( query, styleVarDef ) ->
                    let
                        mediaProps =
                            List.map renderProp (styleProps styleVarDef)
                                |> List.map (\prop -> "  " ++ prop)
                                |> String.join "\n"
                    in
                        query ++ mediaProps
                )
                media
                |> String.concat

        -- For some reason this gives an error if these are not captured in parentheses
        name =
            hash (((styleString ++ modes) ++ keyframeString) ++ mediaQueries)
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
            , animations = animations
            , media = media
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


listMaybeMap : (List a -> b) -> List a -> Maybe b
listMaybeMap fn ls =
    case ls of
        [] ->
            Nothing

        nonEmptyList ->
            Just <| fn nonEmptyList


renderAnimation : Animation -> ( Trigger, Style.Model.Style, Maybe ( String, Style.Model.Keyframes ) )
renderAnimation (Animation { trigger, duration, easing, frames }) =
    let
        ( renderedStyle, renderedFrames ) =
            case frames of
                Transition variation ->
                    let
                        rendered =
                            case Tuple.second <| render variation of
                                StyleDef { style } ->
                                    style
                    in
                        ( rendered
                            ++ [ "transition-property" => "all"
                               , "transition-duration" => (toString duration ++ "ms")
                               , "-webkit-transition-timing-function" => easing
                               , "transition-timing-function" => easing
                               ]
                        , Nothing
                        )

                Keyframes { repeat, steps } ->
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
                                    (\( marker, variation ) ->
                                        let
                                            ( name, styleDef ) =
                                                render variation

                                            rendered =
                                                case styleDef of
                                                    StyleDef { style } ->
                                                        style
                                        in
                                            ( name, ( marker, rendered ) )
                                    )
                                    steps

                        animationName =
                            "animation-" ++ (hash <| String.concat allNames)
                    in
                        ( [ "animation" => (animationName ++ " " ++ renderedDuration ++ " " ++ easing ++ " " ++ iterations) ]
                        , Just
                            ( animationName
                            , renderedSteps
                            )
                        )
    in
        ( trigger, renderedStyle, renderedFrames )


cssTransitions : List ( String, String )
cssTransitions =
    [ "transition-property" => "all"
    , "transition-duration" => "300ms"
    , "-webkit-transition-timing-function" => "ease-out"
    , "transition-timing-function" => "ease-out"
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
