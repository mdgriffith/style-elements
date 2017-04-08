module Style.Internal.Render exposing (stylesheet, guardedStylesheet, box, color, length)

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


guardedStylesheet : List (Internal.BatchedStyle class variation animation) -> String
guardedStylesheet batched =
    batched
        |> concat
        |> List.map renderGuarded
        |> String.join "\n"


renderGuarded : Style class variation animation -> String
renderGuarded (Internal.Style class props) =
    let
        className =
            "." ++ formatName class

        ( embeddedElements, renderedProps ) =
            renderAllProps className props

        guard =
            calculateGuard <| Intermediate className renderedProps :: embeddedElements

        children =
            List.map (renderGuardedIntermediate guard) embeddedElements

        parent =
            renderGuardedIntermediate guard <| Intermediate className renderedProps
    in
        String.join "\n" <|
            (parent :: children)


calculateGuard : List IntermediateStyle -> String
calculateGuard intermediates =
    let
        propToString ( x, y ) =
            x ++ y

        asString inter =
            case inter of
                Intermediate class props ->
                    String.concat <| List.map propToString props

                MediaIntermediate query class props ->
                    query ++ (String.concat <| List.map propToString props)
    in
        intermediates
            |> List.map asString
            |> String.concat
            |> hash


{-| -}
hash : String -> String
hash value =
    Murmur3.hashString 8675309 value
        |> toString


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
      --              query  class  props  intermediates
    | MediaIntermediate String String (List ( String, String ))


asMediaQuery : String -> IntermediateStyle -> IntermediateStyle
asMediaQuery query style =
    case style of
        Intermediate class props ->
            MediaIntermediate query class props

        x ->
            x


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
        List.foldr renderPropsAndChildren ( [], [] ) allProps


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

        MediaQuery query props ->
            let
                ( intermediates, renderedProps ) =
                    renderAllProps parentClass props

                mediaQueries =
                    List.map (asMediaQuery query) intermediates
            in
                ( (MediaIntermediate ("@media " ++ query) parentClass renderedProps) :: mediaQueries
                , []
                )

        Exact name val ->
            ( [], [ ( name, val ) ] )

        Border props ->
            ( [], List.map borderProp props )

        Box props ->
            ( [], List.map boxProp props )

        Position pos ->
            ( [], position pos )

        Font props ->
            ( [], List.map fontProp props )

        Layout lay ->
            ( layoutSpacing parentClass lay
            , layout lay
            )

        Background props ->
            ( [], background props )

        Shadows shadows ->
            ( [], renderShadow shadows )

        Transform transformations ->
            ( [], renderTransformations transformations )

        Filters filters ->
            ( [], renderFilters filters )


renderIntermediate : IntermediateStyle -> String
renderIntermediate intermediate =
    case intermediate of
        Intermediate class props ->
            (class ++ brace 0 (String.join "\n" <| List.map (cssProp 2) props) ++ "\n")

        MediaIntermediate query class props ->
            query ++ brace 0 ("  " ++ class ++ brace 2 (String.join "\n" <| List.map (cssProp 4) props))


renderGuardedIntermediate : String -> IntermediateStyle -> String
renderGuardedIntermediate guard intermediate =
    case intermediate of
        Intermediate class props ->
            (class ++ "-" ++ guard ++ brace 0 (String.join "\n" <| List.map (cssProp 2) props) ++ "\n")

        MediaIntermediate query class props ->
            query ++ brace 0 ("  " ++ class ++ "-" ++ guard ++ brace 2 (String.join "\n" <| List.map (cssProp 4) props))


brace : Int -> String -> String
brace i str =
    " {\n" ++ str ++ "\n" ++ String.repeat i " " ++ "}"


cssProp : Int -> ( String, String ) -> String
cssProp i ( propName, propValue ) =
    (String.repeat i " ") ++ propName ++ ": " ++ propValue ++ ";"


boxProp : BoxElement -> ( String, String )
boxProp (BoxProp name val) =
    ( name, val )


borderProp : BorderElement -> ( String, String )
borderProp (BorderElement name val) =
    ( name, val )


fontProp : FontElement -> ( String, String )
fontProp (FontElement name val) =
    ( name, val )


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
                    let
                        shadowModel =
                            ShadowModel
                                { kind = "drop"
                                , offset = shadow.offset
                                , size = shadow.size
                                , blur = shadow.blur
                                , color = shadow.color
                                }
                    in
                        "drop-shadow(" ++ shadowValue shadowModel ++ ")"
    in
        if List.length filters == 0 then
            []
        else
            [ "filter"
                => (String.join " " <| List.map filterName filters)
            ]


renderShadow : List ShadowModel -> List ( String, String )
renderShadow shadows =
    let
        ( text, box ) =
            List.partition (\(ShadowModel s) -> s.kind == "text") shadows

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


shadowValue : ShadowModel -> String
shadowValue (ShadowModel shadow) =
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
        , color shadow.color
        ]


renderTransformations : List Transformation -> List ( String, String )
renderTransformations transforms =
    let
        transformToString transform =
            case transform of
                Translate x y z ->
                    ("translate3d(" ++ toString x ++ "px, " ++ toString y ++ "px, " ++ toString z ++ "px)")

                Rotate x y z ->
                    ("rotateX(" ++ toString x ++ "rad) rotateY(" ++ toString y ++ "rad) rotateZ(" ++ toString z ++ "rad)")

                Scale x y z ->
                    ("scale3d(" ++ toString x ++ ", " ++ toString y ++ ", " ++ toString z ++ ")")

                _ ->
                    ""

        transformOriginToString transform =
            case transform of
                Origin x y z ->
                    Just ( "transform-origin", (toString x ++ "px  " ++ toString y ++ "px " ++ toString z ++ "px") )

                _ ->
                    Nothing

        transformString =
            (String.join " " (List.map transformToString transforms))

        renderedTransforms =
            if String.length transformString > 0 then
                [ "transform" => transformString ]
            else
                []

        renderedOrigin =
            List.filterMap transformOriginToString transforms
    in
        if List.length transforms == 0 then
            []
        else
            renderedTransforms ++ renderedOrigin


background : List BackgroundElement -> List ( String, String )
background props =
    let
        bgElement bg =
            case bg of
                BackgroundElement name val ->
                    [ ( name, val ) ]

                BackgroundImage { src, position, repeat } ->
                    [ "background-image" => src
                    , "background-repeat"
                        => case repeat of
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
                    , "background-position" => (toString (Tuple.first position) ++ "px " ++ toString (Tuple.second position) ++ "px")
                    ]
    in
        List.concatMap bgElement props


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
                        [ ( "margin", box space ) ]
                    ]

        Internal.FlexLayout _ props ->
            let
                spacing prop =
                    case prop of
                        Spacing spaced ->
                            Just <|
                                Intermediate
                                    (parent ++ " > *:not(.nospacing)")
                                    [ ( "margin", box spaced ) ]

                        _ ->
                            Nothing
            in
                List.filterMap spacing props


{-| -}
layout : LayoutModel -> List ( String, String )
layout lay =
    case lay of
        Internal.TextLayout _ ->
            [ "display" => "block" ]

        Internal.FlexLayout direction flexProps ->
            ("display" => "flex") :: renderDirection direction :: List.map (renderFlexbox direction) flexProps


renderDirection : Direction -> ( String, String )
renderDirection dir =
    case dir of
        GoRight ->
            "flex-direction" => "row"

        GoLeft ->
            "flex-direction" => "row-reverse"

        Down ->
            "flex-direction" => "column"

        Up ->
            "flex-direction" => "column-reverse"


renderFlexbox : Direction -> FlexBoxElement -> ( String, String )
renderFlexbox dir el =
    case el of
        Wrap wrap ->
            if wrap then
                "flex-wrap" => "wrap"
            else
                "flex-wrap" => "nowrap"

        Spacing _ ->
            ( "", "" )

        Horz horizontal ->
            case dir of
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

        Vert vertical ->
            case dir of
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
