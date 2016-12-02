module Style.Render exposing (render, renderInline, find, getName, formatName, inlineError, floatError, missingError)

{-|
-}

import Style.Model exposing (..)
import Murmur3
import String.Extra
import List.Extra
import Color exposing (Color)
import Set exposing (Set)
import String
import Char


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


type StyleIntermediate
    = Single ( String, String )
    | Multiple (List ( String, String ))
    | Tagged String (List ( String, String ))
    | AlmostStyle String (List ( String, String ))
    | Block String (List ( String, String ))
    | MediaIntermediate String (List ( String, String ))
    | SubElementIntermediate String (List ( String, String ))
    | Intermediates (List StyleIntermediate)


type alias Style =
    List ( String, String )


type alias Tag =
    String


renderInline : Model class -> List ( String, String )
renderInline (Model model) =
    let
        intermediates =
            renderProperties model.properties

        ( tags, style, blocks ) =
            renderIntermediates "rendered-inline" intermediates
    in
        style


find : class -> List (Model class) -> Maybe (Model class)
find cls models =
    List.head <|
        List.filterMap
            (\(Model state) ->
                case state.selector of
                    Class found ->
                        if cls == found then
                            Just (Model state)
                        else
                            Nothing

                    _ ->
                        Nothing
            )
            models


render : Model class -> ( ClassName, RenderedStyle )
render (Model model) =
    let
        intermediates =
            renderProperties model.properties

        hashedName =
            hash (toString intermediates)

        ( name, selector ) =
            case model.selector of
                AutoClass ->
                    ( hashedName, "." ++ hashedName )

                Exactly str ->
                    ( "", str )

                Class str ->
                    let
                        formatted =
                            formatName str ++ "-" ++ hashedName
                    in
                        ( formatted, "." ++ formatted )

        ( tags, style, blocks ) =
            renderIntermediates selector intermediates
    in
        ( String.join " " (name :: tags)
        , cssClass 0 selector style
            ++ (String.join "\n" blocks)
        )


renderProperties : List Property -> List StyleIntermediate
renderProperties props =
    props
        |> List.reverse
        |> List.Extra.uniqueBy propertyName
        |> List.reverse
        |> List.map renderProperty


renderProperty : Property -> StyleIntermediate
renderProperty prop =
    case prop of
        Property name value ->
            Single ( name, value )

        Mix props ->
            Intermediates (List.map renderProperty props)

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

        LayoutProp layout ->
            let
                ( style, tag ) =
                    renderLayout layout
            in
                Tagged tag style

        Spacing box ->
            AlmostStyle " > .pos" [ ( "margin", render4tuplePx box ) ]

        AnimationProp anim ->
            let
                ( style, keyframes ) =
                    renderAnimation anim
            in
                Block keyframes [ style ]

        VisibilityProp vis ->
            Single <| renderVisibility vis

        FloatProp floating ->
            Tagged "floating" (renderFloating floating)

        RelProp relTo ->
            Single <| renderPositionBy relTo

        PositionProp anchor x y ->
            Multiple <| renderPosition anchor ( x, y )

        ColorProp name color ->
            Single <| renderColor name color

        MediaQuery query props ->
            let
                intermediates =
                    renderProperties props

                ( _, style, _ ) =
                    renderIntermediates "media-query" intermediates
            in
                MediaIntermediate
                    ("@media " ++ query)
                    style

        SubElement el props ->
            let
                intermediates =
                    renderProperties props

                ( _, style, _ ) =
                    renderIntermediates el intermediates
            in
                SubElementIntermediate el style


renderIntermediates : String -> List StyleIntermediate -> ( List Tag, Style, List String )
renderIntermediates className intermediates =
    List.foldr
        (\point ( tags, style, subStyles ) ->
            case point of
                Single prop ->
                    ( tags
                    , prop :: style
                    , subStyles
                    )

                Multiple props ->
                    ( tags
                    , props ++ style
                    , subStyles
                    )

                Tagged tag props ->
                    ( tag :: tags
                    , props ++ style
                    , subStyles
                    )

                AlmostStyle selector props ->
                    ( tags
                    , style
                    , (cssClass 0 (className ++ selector) props) :: subStyles
                    )

                Block block props ->
                    ( tags
                    , props ++ style
                    , block :: subStyles
                    )

                MediaIntermediate query props ->
                    ( tags
                    , style
                    , (query ++ brace (cssClass 2 className props)) :: subStyles
                    )

                SubElementIntermediate selector props ->
                    ( tags
                    , style
                    , (cssClass 0 (className ++ selector) props) :: subStyles
                    )

                Intermediates subIntermediates ->
                    let
                        ( childTags, childStyles, childSubstyles ) =
                            renderIntermediates className subIntermediates
                    in
                        ( tags ++ childTags
                        , style ++ childStyles
                        , subStyles ++ childSubstyles
                        )
        )
        ( [], [], [] )
        intermediates


type alias ClassName =
    String


type alias RenderedStyle =
    String


renderAnimation : Animation -> ( ( String, String ), String )
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
                            (\( marker, properties ) ->
                                let
                                    intermediates =
                                        renderProperties properties

                                    name =
                                        hash (toString intermediates)

                                    ( _, style, _ ) =
                                        renderIntermediates "animation" intermediates

                                    block =
                                        cssClass 2 (toString marker ++ "%") style
                                in
                                    ( name, block ++ "\n" )
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


renderColor : String -> Color -> ( String, String )
renderColor name color =
    name => (colorToString color)


renderLength : Length -> String
renderLength l =
    case l of
        Px x ->
            toString x ++ "px"

        Percent x ->
            toString x ++ "%"

        Auto ->
            "auto"


renderPositionBy : PositionParent -> ( String, String )
renderPositionBy relativeTo =
    case relativeTo of
        Screen ->
            "position" => "fixed"

        CurrentPosition ->
            "position" => "relative"

        Parent ->
            "position" => "absolute"


renderPosition : Anchor -> ( Float, Float ) -> List ( String, String )
renderPosition anchor position =
    let
        ( x, y ) =
            position
    in
        case anchor of
            ( AnchorTop, AnchorLeft ) ->
                [ "top" => (toString y ++ "px")
                , "left" => (toString x ++ "px")
                ]

            ( AnchorTop, AnchorRight ) ->
                [ "top" => (toString y ++ "px")
                , "right" => (toString (-1 * x) ++ "px")
                ]

            ( AnchorBottom, AnchorLeft ) ->
                [ "bottom" => (toString (-1 * y) ++ "px")
                , "left" => (toString x ++ "px")
                ]

            ( AnchorBottom, AnchorRight ) ->
                [ "bottom" => (toString (-1 * y) ++ "px")
                , "right" => (toString (-1 * x) ++ "px")
                ]


renderLayout : Layout -> ( List ( String, String ), String )
renderLayout layout =
    case layout of
        TextLayout ->
            ( [ "display" => "block" ]
            , "pos"
            )

        InlineLayout ->
            ( [ "display" => "inline-block" ]
            , "inline"
            )

        TableLayout ->
            ( [ "display" => "table", "border-collapse" => "collapse" ]
            , "pos not-floatable not-inlineable"
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
            , "pos not-floatable not-inlineable"
            )



------------------------
-- Class Name Generation
------------------------


{-| -}
formatName : a -> String
formatName class =
    (toString class)
        |> String.Extra.unquote
        |> String.Extra.decapitalize
        |> String.Extra.dasherize


{-| -}
getName : Model class -> String
getName model =
    Tuple.first <| render model


{-| -}
hash : String -> String
hash value =
    Murmur3.hashString 8675309 value
        |> toString
        |> String.toList
        |> List.map (Char.fromCode << ((+) 65) << Result.withDefault 0 << String.toInt << String.fromChar)
        |> String.fromList
        |> String.toLower



-----------------
-- CSS formatting
-----------------


brace : String -> String
brace str =
    " {\n" ++ str ++ "\n}"


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


cssClass : Int -> String -> List ( String, String ) -> String
cssClass x name props =
    (name ++ brace (String.join "\n" <| List.map cssProp props) ++ "\n")
        |> if x > 0 then
            indent x
           else
            identity


cssProp : ( String, String ) -> String
cssProp ( propName, propValue ) =
    "  " ++ propName ++ ": " ++ propValue ++ ";"


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


missingError : String
missingError =
    """
.missing-from-stylesheet {
    border: 3px solid yellow; !important;
}
.missing-from-stylesheet::after {
    border: 3px solid yellow; !important;
    display: inline-block;
    color: black;
    background-color: yellow;
    content: 'missing from stylesheet';
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
    content: 'Floating elements can only be in text layouts';
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
