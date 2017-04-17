module Style.Internal.Render.Property exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (..)
import Style.Internal.Render.Value as Value
import Time


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


colorElement : ColorElement -> ( String, String )
colorElement (ColorElement name val) =
    ( name, Value.color val )


visibility : Visible -> List ( String, String )
visibility vis =
    case vis of
        Hidden ->
            [ ( "display", "none" ) ]

        Invisible ->
            [ ( "visibility", "hidden" ) ]

        Opacity x ->
            [ ( "opacity", toString x ) ]


filters : List Filter -> List ( String, String )
filters filters =
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

                OpacityFilter x ->
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
                        "drop-shadow(" ++ Value.shadow shadowModel ++ ")"
    in
        if List.length filters == 0 then
            []
        else
            [ "filter"
                => (String.join " " <| List.map filterName filters)
            ]


shadow : List ShadowModel -> List ( String, String )
shadow shadows =
    let
        ( text, box ) =
            List.partition (\(ShadowModel s) -> s.kind == "text") shadows

        renderedBox =
            String.join ", " (List.map Value.shadow box)

        renderedText =
            String.join ", " (List.map Value.shadow text)
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


box : BoxElement -> ( String, String )
box (BoxProp name val) =
    ( name, val )


border : BorderElement -> ( String, String )
border (BorderElement name val) =
    ( name, val )


font : FontElement -> ( String, String )
font (FontElement name val) =
    ( name, val )


transformations : List Transformation -> List ( String, String )
transformations transforms =
    let
        transformToString transform =
            case transform of
                Translate x y z ->
                    ("translate3d(" ++ toString x ++ "px, " ++ toString y ++ "px, " ++ toString z ++ "px)")

                RotateAround x y z angle ->
                    ("rotate3d(" ++ toString x ++ "," ++ toString y ++ "," ++ toString z ++ "," ++ toString angle ++ "rad)")

                Rotate x ->
                    ("rotate(" ++ toString x ++ "rad)")

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


background : List BackgroundElement -> List ( String, String )
background props =
    let
        directionName dir =
            case dir of
                ToUp ->
                    "to top"

                ToDown ->
                    "to bottomn"

                ToRight ->
                    "to right"

                ToTopRight ->
                    "to top right"

                ToBottomRight ->
                    "to bottom right"

                ToLeft ->
                    "to left"

                ToTopLeft ->
                    "to top left"

                ToBottomLeft ->
                    "to bottom left"

                ToAngle angle ->
                    toString angle ++ "rad"

        renderStep step =
            case step of
                ColorStep color ->
                    Value.color color

                PercentStep color percent ->
                    (Value.color color ++ " " ++ toString percent ++ "%")

                PxStep color percent ->
                    (Value.color color ++ " " ++ toString percent ++ "px")

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

                BackgroundLinearGradient dir steps ->
                    [ "background-image" => ("linear-gradient(" ++ (String.join ", " <| directionName dir :: List.map renderStep steps) ++ ")") ]
    in
        List.concatMap bgElement props


{-| -}
layout : LayoutModel -> List ( String, String )
layout lay =
    case lay of
        Internal.TextLayout _ ->
            [ "display" => "block" ]

        Internal.FlexLayout dir flexProps ->
            ("display" => "flex") :: direction dir :: List.map (flexbox dir) flexProps


direction : Direction -> ( String, String )
direction dir =
    case dir of
        GoRight ->
            "flex-direction" => "row"

        GoLeft ->
            "flex-direction" => "row-reverse"

        Down ->
            "flex-direction" => "column"

        Up ->
            "flex-direction" => "column-reverse"


transition : Transition -> String
transition (Transition { delay, duration, easing, props }) =
    let
        formatTrans prop =
            String.join " "
                [ prop, toString (duration * Time.millisecond) ++ "ms", easing, toString (delay * Time.millisecond) ++ "ms" ]
    in
        props
            |> List.map formatTrans
            |> String.join ", "


flexbox : Direction -> FlexBoxElement -> ( String, String )
flexbox dir el =
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
