module Style.Internal.Render exposing (stylesheet, box, color, length)

{-|
-}

import Murmur3
import Color exposing (Color)
import Style.Internal.Model as Internal exposing (..)


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


box : ( Float, Float, Float, Float ) -> String
box ( a, b, c, d ) =
    toString a ++ "px " ++ toString b ++ "px " ++ toString c ++ "px " ++ toString d ++ "px"


length : Internal.Length -> String
length l =
    case l of
        Internal.Px x ->
            toString x ++ "px"

        Internal.Percent x ->
            toString x ++ "%"

        Internal.Auto ->
            "auto"


color : Color -> String
color color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
        ("rgba(" ++ toString red)
            ++ ("," ++ toString green)
            ++ ("," ++ toString blue)
            ++ ("," ++ toString alpha ++ ")")


concat : List (Internal.BatchedStyle class variation animation) -> List (Internal.Style class variation animation)
concat batched =
    let
        flatten batch =
            case batch of
                Internal.Single style ->
                    [ style ]

                Internal.Many styles ->
                    styles
    in
        List.concatMap flatten batched


stylesheet : List (Internal.BatchedStyle class variation animation) -> String
stylesheet batched =
    batched
        |> concat
        |> List.map renderStyle
        |> String.join "\n"


renderStyle : Style class variation animation -> String
renderStyle (Internal.Style class props) =
    let
        className =
            "." ++ formatName class

        ( embeddedElements, renderedProps ) =
            renderAllProps className props

        children =
            List.map renderIntermediate embeddedElements

        parent =
            renderIntermediate <| Intermediate className renderedProps
    in
        String.join "\n" <|
            (parent :: children)


type IntermediateStyle
    = Intermediate String (List ( String, String ))


renderAllProps : String -> List (Property class variation animation) -> ( List IntermediateStyle, List ( String, String ) )
renderAllProps parent allProps =
    let
        renderPropsAndChildren prop ( existing, rendered ) =
            let
                ( children, renderedProp ) =
                    renderProp parent prop
            in
                ( children ++ existing
                , renderedProp ++ rendered
                )
    in
        List.foldl renderPropsAndChildren ( [], [] ) allProps


formatName : a -> String
formatName x =
    let
        raw =
            toString x

        head =
            String.left 1 raw
                |> String.toLower

        tail =
            String.dropLeft 1 raw
    in
        head ++ tail


renderProp : String -> Property class variation animation -> ( List IntermediateStyle, List ( String, String ) )
renderProp parentClass prop =
    case prop of
        Child class props ->
            let
                selector =
                    parentClass ++ " > ." ++ formatName class

                ( intermediates, renderedProps ) =
                    renderAllProps selector props
            in
                ( (Intermediate selector renderedProps) :: intermediates
                , []
                )

        Variation var props ->
            let
                ( intermediates, renderedProps ) =
                    renderAllProps parentClass props
            in
                ( (Intermediate (parentClass ++ "-" ++ formatName var) renderedProps) :: intermediates
                , []
                )

        MediaQuery name props ->
            ( [], [] )

        Exact name val ->
            ( [], [ ( name, val ) ] )

        Border props ->
            ( [], borderProps props )

        Box props ->
            ( [], boxProps props )

        Position pos ->
            ( [], position pos )

        Font props ->
            ( [], [] )

        Layout lay ->
            ( layoutSpacing parentClass lay
            , layout lay
            )

        Background props ->
            ( [], [] )

        Shadows shadows ->
            ( [], [] )

        Transform transforms ->
            ( [], [] )

        Filters filters ->
            ( [], renderFilters filters )


renderIntermediate : IntermediateStyle -> String
renderIntermediate (Intermediate class props) =
    (class ++ brace (String.join "\n" <| List.map cssProp props) ++ "\n")


brace : String -> String
brace str =
    " {\n" ++ str ++ "\n}"


cssProp : ( String, String ) -> String
cssProp ( propName, propValue ) =
    "  " ++ propName ++ ": " ++ propValue ++ ";"


boxProps : List BoxElement -> List ( String, String )
boxProps elements =
    List.map (\(BoxProp name val) -> ( name, val )) elements
        |> List.reverse


borderProps : List BorderElement -> List ( String, String )
borderProps elements =
    List.map (\(BorderElement name val) -> ( name, val )) elements
        |> List.reverse


renderFilters : List Filter -> List ( String, String )
renderFilters filters =
    let
        filterName filtr =
            case filtr of
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
                    Debug.crash "TODO"

        -- "drop-shadow(" ++ shadowValue shadow ++ ")"
    in
        if List.length filters == 0 then
            []
        else
            [ "filter"
                => (String.join " " <| List.map filterName filters)
            ]



-- shadowValue : Shadow -> String
-- shadowValue (Shadow shadow) =
--     String.join " "
--         [ if shadow.kind == "inset" then
--             "inset"
--           else
--             ""
--         , toString (Tuple.first shadow.offset) ++ "px"
--         , toString (Tuple.second shadow.offset) ++ "px"
--         , toString shadow.blur ++ "px"
--         , (if shadow.kind == "text" || shadow.kind == "drop" then
--             ""
--            else
--             toString shadow.size ++ "px"
--           )
--         , color shadow.color
--         ]


position : List PositionElement -> List ( String, String )
position posEls =
    let
        renderPos pos =
            case pos of
                RelativeTo Screen ->
                    ( "position", "fixed" )

                RelativeTo Parent ->
                    ( "position", "absolute" )

                RelativeTo Current ->
                    ( "position", "relative" )

                PosLeft x ->
                    ( "left", toString x ++ "px" )

                PosRight x ->
                    ( "right", toString x ++ "px" )

                PosTop x ->
                    ( "top", toString x ++ "px" )

                PosBottom x ->
                    ( "bottom", toString x ++ "px" )

                ZIndex i ->
                    ( "z-index", toString i )

                Inline ->
                    ( "display", "inline-block" )

                Float FloatLeft ->
                    ( "float", "left" )

                Float FloatRight ->
                    ( "float", "right" )

                Float FloatTopLeft ->
                    ( "float", "left" )

                Float FloatTopRight ->
                    ( "float", "right" )
    in
        List.map renderPos posEls
            |> List.reverse


{-| -}
layoutSpacing : String -> LayoutModel -> List IntermediateStyle
layoutSpacing parent layout =
    case layout of
        Internal.TextLayout { spacing } ->
            case spacing of
                Nothing ->
                    []

                Just space ->
                    [ Intermediate
                        (parent ++ " > *:not(.nospacing)")
                        [ ( "margin", toString space ++ "px" ) ]
                    ]

        Internal.FlexLayout (Internal.FlexBox { spacing }) ->
            case spacing of
                Nothing ->
                    []

                Just space ->
                    [ Intermediate
                        (parent ++ " > *:not(.nospacing)")
                        [ ( "margin", toString space ++ "px" ) ]
                    ]


{-| -}
layout : LayoutModel -> List ( String, String )
layout lay =
    case lay of
        Internal.TextLayout _ ->
            [ "display" => "block" ]

        Internal.FlexLayout (Internal.FlexBox { go, wrap, horizontal, vertical, spacing }) ->
            [ "display" => "flex"
            , case go of
                GoRight ->
                    "flex-direction" => "row"

                GoLeft ->
                    "flex-direction" => "row-reverse"

                Down ->
                    "flex-direction" => "column"

                Up ->
                    "flex-direction" => "column-reverse"
            , if wrap then
                "flex-wrap" => "wrap"
              else
                "flex-wrap" => "nowrap"
            , case go of
                GoRight ->
                    case horizontal of
                        Other Left ->
                            "justify-content" => "flex-start"

                        Other Right ->
                            "justify-content" => "flex-end"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "justify-content" => "space-between"

                GoLeft ->
                    case horizontal of
                        Other Left ->
                            "justify-content" => "flex-end"

                        Other Right ->
                            "justify-content" => "flex-start"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "justify-content" => "space-between"

                Down ->
                    case horizontal of
                        Other Left ->
                            "align-items" => "flex-start"

                        Other Right ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"

                Up ->
                    case horizontal of
                        Other Left ->
                            "align-items" => "flex-start"

                        Other Right ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"
            , case go of
                GoRight ->
                    case vertical of
                        Other Top ->
                            "align-items" => "flex-start"

                        Other Bottom ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"

                GoLeft ->
                    case vertical of
                        Other Top ->
                            "align-items" => "flex-start"

                        Other Bottom ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"

                Down ->
                    case vertical of
                        Other Top ->
                            "justify-content" => "flex-start"

                        Other Bottom ->
                            "justify-content" => "flex-end"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "align-items" => "Justify"

                Up ->
                    case vertical of
                        Other Top ->
                            "justify-content" => "flex-end"

                        Other Bottom ->
                            "justify-content" => "flex-start"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "align-items" => "Justify"
            ]



--import Style.Model exposing (..)
--import Murmur3
--import String.Extra
--import List.Extra
--import Color exposing (Color)
--import Set exposing (Set)
--import String
--import Char
--(=>) : x -> y -> ( x, y )
--(=>) =
--    (,)
--type StyleIntermediate
--    = Single ( String, String )
--    | Multiple (List ( String, String ))
--    | Tagged String (List ( String, String ))
--    | AlmostStyle String (List ( String, String ))
--    | Block String (List ( String, String ))
--    | MediaIntermediate String (List ( String, String ))
--    | SubElementIntermediate String (List ( String, String ))
--    | Intermediates (List StyleIntermediate)
--    | StyleVariation String (List ( String, String ))
--type alias Style =
--    List ( String, String )
--type alias Tag =
--    String
--clearfix : StyleIntermediate
--clearfix =
--    Intermediates
--        [ SubElementIntermediate ":before"
--            [ "content" => "\" \""
--            , "display" => "table"
--            ]
--        , SubElementIntermediate ":after"
--            [ "content" => "\" \""
--            , "display" => "table"
--            , "clear" => "both"
--            ]
--        ]
----renderInline : Model class -> List ( String, String )
----renderInline (Model model) =
----    let
----        intermediates =
----            renderProperties model.properties
----        ( tags, style, blocks ) =
----            renderIntermediates "rendered-inline" intermediates
----    in
----        style
--verifyVariations : Model class layoutClass positionClass variation animation msg -> List variation -> List ( variation, Bool )
--verifyVariations model variations =
--    let
--        verify var =
--            case model of
--                StyleModel { properties } ->
--                    ( var
--                    , List.any (matchVariation var) properties
--                    )
--                _ ->
--                    ( var, False )
--        matchVariation var prop =
--            case prop of
--                Variation found _ ->
--                    found == var
--                _ ->
--                    False
--    in
--        List.map verify variations
--findStyle : class -> List (Model class layoutClass positionClass variation animation msg) -> Maybe (Model class layoutClass positionClass variation animation msg)
--findStyle cls models =
--    List.head <|
--        List.filterMap
--            (\model ->
--                case model of
--                    StyleModel state ->
--                        case state.selector of
--                            Class found ->
--                                if cls == found then
--                                    Just model
--                                else
--                                    Nothing
--                            _ ->
--                                Nothing
--                    _ ->
--                        Nothing
--            )
--            models
--findLayout : layoutClass -> List (Model class layoutClass positionClass variation animation msg) -> Maybe (Model class layoutClass positionClass variation animation msg)
--findLayout cls models =
--    List.head <|
--        List.filterMap
--            (\model ->
--                case model of
--                    LayoutModel state ->
--                        case state.selector of
--                            Class found ->
--                                if cls == found then
--                                    Just model
--                                else
--                                    Nothing
--                            _ ->
--                                Nothing
--                    _ ->
--                        Nothing
--            )
--            models
--findPosition : positionClass -> List (Model class layoutClass positionClass variation animation msg) -> Maybe (Model class layoutClass positionClass variation animation msg)
--findPosition cls models =
--    List.head <|
--        List.filterMap
--            (\model ->
--                case model of
--                    PositionModel state ->
--                        case state.selector of
--                            Class found ->
--                                if cls == found then
--                                    Just model
--                                else
--                                    Nothing
--                            _ ->
--                                Nothing
--                    _ ->
--                        Nothing
--            )
--            models
--render : Model class layoutClass positionClass variation animation msg -> ( ClassName, RenderedStyle )
--render model =
--    let
--        intermediates =
--            case model of
--                StyleModel model ->
--                    renderProperties model.properties
--                LayoutModel model ->
--                    renderProperties model.properties
--                PositionModel model ->
--                    renderProperties model.properties
--        ( name, selector ) =
--            case model of
--                StyleModel model ->
--                    case model.selector of
--                        Exactly str ->
--                            ( "", str )
--                        Class str ->
--                            let
--                                formatted =
--                                    formatName str
--                            in
--                                ( formatted, "." ++ formatted )
--                PositionModel model ->
--                    case model.selector of
--                        Exactly str ->
--                            ( "", str )
--                        Class str ->
--                            let
--                                formatted =
--                                    formatName str
--                            in
--                                ( formatted, "." ++ formatted )
--                LayoutModel model ->
--                    case model.selector of
--                        Exactly str ->
--                            ( "", str )
--                        Class str ->
--                            let
--                                formatted =
--                                    formatName str
--                            in
--                                ( formatted, "." ++ formatted )
--        ( tags, style, blocks ) =
--            renderIntermediates selector intermediates
--    in
--        ( String.join " " (name :: tags)
--        , cssClass 0 selector style
--            ++ (String.join "\n" blocks)
--        )
--renderProperties : List (Property animation variation msg) -> List StyleIntermediate
--renderProperties props =
--    props
--        |> List.reverse
--        |> List.Extra.uniqueBy propertyName
--        |> List.reverse
--        |> List.map renderProperty
--renderProperty : Property animation variation msg -> StyleIntermediate
--renderProperty prop =
--    case prop of
--        Property name value ->
--            Single ( name, value )
--        Mix props ->
--            Intermediates (List.map renderProperty props)
--        Box name box ->
--            Single ( name, (render4tuplePx box) )
--        Len name length ->
--            Single ( name, (renderLength length) )
--        Filters filters ->
--            Single <| renderFilters filters
--        Transforms transforms ->
--            Single <| renderTransforms transforms
--        TransitionProperty transition ->
--            Multiple <| renderTransition transition
--        Shadows shadows ->
--            Multiple <| renderShadow shadows
--        BackgroundImageProp image ->
--            Multiple <| renderBackgroundImage image
--        AnimationProp anim ->
--            let
--                ( style, keyframes ) =
--                    renderAnimation anim
--            in
--                Block keyframes [ style ]
--        VisibilityProp vis ->
--            Single <| renderVisibility vis
--        ColorProp name color ->
--            Single <| renderColor name color
--        MediaQuery query props ->
--            let
--                intermediates =
--                    renderProperties props
--                ( _, style, _ ) =
--                    renderIntermediates "media-query" intermediates
--            in
--                MediaIntermediate
--                    ("@media " ++ query)
--                    style
--        SubElement el props ->
--            let
--                intermediates =
--                    renderProperties props
--                ( _, style, _ ) =
--                    renderIntermediates el intermediates
--            in
--                SubElementIntermediate el style
--        Variation class props ->
--            let
--                intermediates =
--                    renderProperties props
--                ( _, style, _ ) =
--                    renderIntermediates "variation" intermediates
--            in
--                StyleVariation (variationName class) style
--        DynamicAnimation class props ->
--            Single ( "invalid", "invalid" )
--        LayoutProp layout ->
--            let
--                ( style, tag ) =
--                    renderLayout layout
--            in
--                Tagged tag style
--        Spacing box ->
--            Intermediates
--                [ AlmostStyle " > *"
--                    [ "margin" => render4tuplePx (adjustSpacing box)
--                    ]
--                  --, AlmostStyle " > .full-width"
--                  --    [ "margin" => "0px -{outer-x-padding}"
--                  --    , "width" => "100%"
--                  --    ]
--                  --, Multiple
--                  --    [ "margin" => toString outerPadding
--                  --    ]
--                ]
--        FloatProp floating ->
--            Tagged "floating" (renderFloating floating)
--        RelProp relTo ->
--            Single <| renderPositionBy relTo
--        Position anchor x y ->
--            Multiple <| renderPosition anchor ( x, y )
--        Inline ->
--            Tagged "inline" [ "display" => "inline-block" ]
--renderIntermediates : String -> List StyleIntermediate -> ( List Tag, Style, List String )
--renderIntermediates className intermediates =
--    List.foldr
--        (\point ( tags, style, subStyles ) ->
--            case point of
--                Single prop ->
--                    ( tags
--                    , prop :: style
--                    , subStyles
--                    )
--                Multiple props ->
--                    ( tags
--                    , props ++ style
--                    , subStyles
--                    )
--                Tagged tag props ->
--                    ( tag :: tags
--                    , props ++ style
--                    , subStyles
--                    )
--                AlmostStyle selector props ->
--                    ( tags
--                    , style
--                    , (cssClass 0 (className ++ selector) props) :: subStyles
--                    )
--                Block block props ->
--                    ( tags
--                    , props ++ style
--                    , block :: subStyles
--                    )
--                MediaIntermediate query props ->
--                    ( tags
--                    , style
--                    , (query ++ brace (cssClass 2 className props)) :: subStyles
--                    )
--                SubElementIntermediate selector props ->
--                    ( tags
--                    , style
--                    , (cssClass 0 (className ++ selector) props) :: subStyles
--                    )
--                StyleVariation name props ->
--                    ( tags
--                    , style
--                    , (cssClass 0 name props) :: subStyles
--                    )
--                Intermediates subIntermediates ->
--                    let
--                        ( childTags, childStyles, childSubstyles ) =
--                            renderIntermediates className subIntermediates
--                    in
--                        ( tags ++ childTags
--                        , style ++ childStyles
--                        , subStyles ++ childSubstyles
--                        )
--        )
--        ( [], [], [] )
--        intermediates
--type alias ClassName =
--    String
--type alias RenderedStyle =
--    String
--renderAnimation : Animation (Property animation variation msg) -> ( ( String, String ), String )
--renderAnimation (Animation { duration, easing, steps, repeat }) =
--    let
--        ( renderedStyle, renderedFrames ) =
--            let
--                renderedDuration =
--                    toString duration ++ "ms"
--                iterations =
--                    if isInfinite repeat then
--                        "infinite"
--                    else
--                        toString repeat
--                ( allNames, renderedSteps ) =
--                    List.unzip <|
--                        List.map
--                            (\( marker, properties ) ->
--                                let
--                                    intermediates =
--                                        renderProperties properties
--                                    name =
--                                        hash (toString intermediates)
--                                    ( _, style, _ ) =
--                                        renderIntermediates "animation" intermediates
--                                    block =
--                                        cssClass 2 (toString marker ++ "%") style
--                                in
--                                    ( name, block ++ "\n" )
--                            )
--                            steps
--                animationName =
--                    "animation-" ++ (hash <| String.concat allNames)
--            in
--                ( "animation" => (animationName ++ " " ++ renderedDuration ++ " " ++ easing ++ " " ++ iterations)
--                , "@keyframes "
--                    ++ animationName
--                    ++ " {\n"
--                    ++ (String.join "" renderedSteps)
--                    ++ "}"
--                )
--    in
--        ( renderedStyle, renderedFrames )
--renderTransition : Transition -> List ( String, String )
--renderTransition { property, duration, easing, delay } =
--    [ "transition-property" => property
--    , "transition-duration" => (toString duration ++ "ms")
--    , "-webkit-transition-timing-function" => easing
--    , "transition-timing-function" => easing
--    , "transition-delay" => (toString delay ++ "ms")
--    ]
--renderVisibility : Visibility -> ( String, String )
--renderVisibility vis =
--    case vis of
--        Hidden ->
--            "display" => "none"
--        Transparent transparency ->
--            "opacity" => toString (1.0 - transparency)
--renderFloating : Floating -> List ( String, String )
--renderFloating floating =
--    case floating of
--        FloatLeft ->
--            [ "float" => "left"
--            , "margin-left" => "0px !important"
--            ]
--        FloatRight ->
--            [ "float" => "right"
--            , "margin-right" => "0px !important"
--            ]
--        FloatTopLeft ->
--            [ "float" => "left"
--            , "margin-left" => "0px !important"
--            , "margin-top" => "0px !important"
--            ]
--        FloatTopRight ->
--            [ "float" => "right"
--            , "margin-right" => "0px !important"
--            , "margin-top" => "0px !important"
--            ]
--renderBackgroundImage : BackgroundImage -> List ( String, String )
--renderBackgroundImage image =
--    [ "background-image" => image.src
--    , "background-repeat"
--        => case image.repeat of
--            RepeatX ->
--                "repeat-x"
--            RepeatY ->
--                "repeat-y"
--            Repeat ->
--                "repeat"
--            Space ->
--                "space"
--            Round ->
--                "round"
--            NoRepeat ->
--                "no-repeat"
--    , "background-position" => ((toString (Tuple.first image.position)) ++ "px " ++ (toString (Tuple.second image.position)) ++ "px")
--    ]
--renderTransforms : List Transform -> ( String, String )
--renderTransforms transforms =
--    "transform"
--        => (String.join " " (List.map transformToString transforms))
--transformToString : Transform -> String
--transformToString transform =
--    case transform of
--        Translate x y z ->
--            "translate3d("
--                ++ toString x
--                ++ "px, "
--                ++ toString y
--                ++ "px, "
--                ++ toString z
--                ++ "px)"
--        Rotate x y z ->
--            "rotateX("
--                ++ toString x
--                ++ "rad) rotateY("
--                ++ toString y
--                ++ "rad) rotateZ("
--                ++ toString z
--                ++ "rad)"
--        Scale x y z ->
--            "scale3d("
--                ++ toString x
--                ++ ", "
--                ++ toString y
--                ++ ", "
--                ++ toString z
--                ++ ")"
--renderFilters : List Filter -> ( String, String )
--renderFilters filters =
--    "filter"
--        => (String.join " " <| List.map filterToString filters)
--filterToString : Filter -> String
--filterToString filter =
--    case filter of
--        FilterUrl url ->
--            "url(" ++ url ++ ")"
--        Blur x ->
--            "blur(" ++ toString x ++ "px)"
--        Brightness x ->
--            "brightness(" ++ toString x ++ "%)"
--        Contrast x ->
--            "contrast(" ++ toString x ++ "%)"
--        Grayscale x ->
--            "grayscale(" ++ toString x ++ "%)"
--        HueRotate x ->
--            "hueRotate(" ++ toString x ++ "deg)"
--        Invert x ->
--            "invert(" ++ toString x ++ "%)"
--        Opacity x ->
--            "opacity(" ++ toString x ++ "%)"
--        Saturate x ->
--            "saturate(" ++ toString x ++ "%)"
--        Sepia x ->
--            "sepia(" ++ toString x ++ "%)"
--        DropShadow shadow ->
--            "drop-shadow(" ++ shadowValue shadow ++ ")"
--renderShadow : List Shadow -> List ( String, String )
--renderShadow shadows =
--    let
--        ( text, box ) =
--            List.partition (\(Shadow s) -> s.kind == "text") shadows
--        renderedBox =
--            String.join ", " (List.map shadowValue box)
--        renderedText =
--            String.join ", " (List.map shadowValue text)
--    in
--        List.filterMap identity
--            [ if renderedBox == "" then
--                Nothing
--              else
--                Just ("box-shadow" => renderedBox)
--            , if renderedText == "" then
--                Nothing
--              else
--                Just ("text-shadow" => renderedText)
--            ]
--shadowValue : Shadow -> String
--shadowValue (Shadow shadow) =
--    String.join " "
--        [ if shadow.kind == "inset" then
--            "inset"
--          else
--            ""
--        , toString (Tuple.first shadow.offset) ++ "px"
--        , toString (Tuple.second shadow.offset) ++ "px"
--        , toString shadow.blur ++ "px"
--        , (if shadow.kind == "text" || shadow.kind == "drop" then
--            ""
--           else
--            toString shadow.size ++ "px"
--          )
--        , colorToString shadow.color
--        ]
--{-| This is a fudge-factor for dealing with margin collapse.
--Spacing is defined as the spaces between all items.
--Vertical items will have their margins.
---}
--adjustSpacing : ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
--adjustSpacing ( t, r, b, l ) =
--    ( t / 2
--    , r / 2
--    , b / 2
--    , l / 2
--    )
--render4tuplePx : ( Float, Float, Float, Float ) -> String
--render4tuplePx ( a, b, c, d ) =
--    toString a ++ "px " ++ toString b ++ "px " ++ toString c ++ "px " ++ toString d ++ "px"
--colorToString : Color -> String
--colorToString color =
--    let
--        { red, green, blue, alpha } =
--            Color.toRgb color
--    in
--        "rgba("
--            ++ toString red
--            ++ ","
--            ++ toString green
--            ++ ","
--            ++ toString blue
--            ++ ","
--            ++ toString alpha
--            ++ ")"
--renderColor : String -> Color -> ( String, String )
--renderColor name color =
--    name => (colorToString color)
--renderLength : Length -> String
--renderLength l =
--    case l of
--        Px x ->
--            toString x ++ "px"
--        Percent x ->
--            toString x ++ "%"
--        Auto ->
--            "auto"
--renderPositionBy : PositionParent -> ( String, String )
--renderPositionBy relativeTo =
--    case relativeTo of
--        Screen ->
--            "position" => "fixed"
--        CurrentPosition ->
--            "position" => "relative"
--        Parent ->
--            "position" => "absolute"
--renderPosition : Anchor -> ( Float, Float ) -> List ( String, String )
--renderPosition anchor position =
--    let
--        ( x, y ) =
--            position
--    in
--        case anchor of
--            ( AnchorTop, AnchorLeft ) ->
--                [ "top" => (toString y ++ "px")
--                , "left" => (toString x ++ "px")
--                ]
--            ( AnchorTop, AnchorRight ) ->
--                [ "top" => (toString y ++ "px")
--                , "right" => (toString (-1 * x) ++ "px")
--                ]
--            ( AnchorBottom, AnchorLeft ) ->
--                [ "bottom" => (toString (-1 * y) ++ "px")
--                , "left" => (toString x ++ "px")
--                ]
--            ( AnchorBottom, AnchorRight ) ->
--                [ "bottom" => (toString (-1 * y) ++ "px")
--                , "right" => (toString (-1 * x) ++ "px")
--                ]
--------------------------
---- Class Name Generation
--------------------------
--{-| -}
--formatName : a -> String
--formatName class =
--    (toString class)
--        |> String.Extra.unquote
--        |> String.Extra.decapitalize
--        |> String.Extra.dasherize
--{-| -}
--getName : Model class layoutClass positionClass variation animation msg -> String
--getName model =
--    Tuple.first <| render model
--{-| -}
--variationName : a -> String
--variationName class =
--    formatName class ++ "-variation"
--{-| -}
--hash : String -> String
--hash value =
--    Murmur3.hashString 8675309 value
--        |> toString
--        |> String.toList
--        |> List.map (Char.fromCode << ((+) 65) << Result.withDefault 0 << String.toInt << String.fromChar)
--        |> String.fromList
--        |> String.toLower
-------------------
---- CSS formatting
-------------------
--indent : Int -> String -> String
--indent x str =
--    str
--        |> String.split "\n"
--        |> List.filterMap
--            (\s ->
--                if String.isEmpty (String.trim s) then
--                    Nothing
--                else
--                    Just <| (String.repeat x " ") ++ s
--            )
--        |> String.join "\n"
--cssClass : Int -> String -> List ( String, String ) -> String
--cssClass x name props =
--    (name ++ brace (String.join "\n" <| List.map cssProp props) ++ "\n")
--        |> if x > 0 then
--            indent x
--           else
--            identity
--cssProp : ( String, String ) -> String
--cssProp ( propName, propValue ) =
--    "  " ++ propName ++ ": " ++ propValue ++ ";"
--reset : String
--reset =
--    """
--* {
--    all: initial;
--    display: block;
--    position: relative;
--}



--"""
----clearfix : String
----clearfix =
----    """
----.floating:after {
----    visibility: hidden;
----    display: block;
----    clear: both;
----    height: 0px;
----}
----"""
--missingError : String
--missingError =
--    """
--.missing-from-stylesheet {
--    border: 3px solid yellow; !important;
--}



--.missing-from-stylesheet::after {
--    border: 3px solid yellow; !important;
--    display: inline-block;
--    color: black;
--    background-color: yellow;
--    content: 'missing from stylesheet';
--}



--"""
--floatError : String
--floatError =
--    """
--.not-floatable > * {
--    float: none !important;
--}



--.not-floatable > .floating {
--    border: 3px solid red; !important;
--}



--.not-floatable > .floating::after {
--    display: inline-block;
--    color: black;
--    background-color: red;
--}



--.not-floatable > .floating:hover::after {
--    content: 'Floating elements can only be in text layouts';
--}



--"""
--inlineError : String
--inlineError =
--    """
--.not-inlineable > * {
--    float: none !important;
--}



--.not-inlineable > .inline {
--    border: 3px solid red;
--}



--.not-inlineable > .inline::after {
--    display: block;
--    content: 'Inline Elements can only be in Text Layouts';
--    color: black;
--    background-color: red;
--}



--"""
