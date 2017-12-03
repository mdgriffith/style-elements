module Style.Internal.Render.Property exposing (..)

{-| -}

import Style.Internal.Model exposing (..)
import Style.Internal.Render.Value as Value
import Time


visibility : Visible -> List ( String, String )
visibility vis =
    case vis of
        Hidden ->
            [ ( "display", "none" ) ]

        Invisible ->
            [ ( "visibility", "hidden" ) ]

        Opacity x ->
            [ ( "opacity", toString x ) ]


flexWidth : Length -> Float -> List ( String, String )
flexWidth len adjustment =
    case len of
        Px x ->
            [ ( "width", toString x ++ "px" ) ]

        Percent x ->
            [ ( "width", "calc(" ++ toString x ++ "% - " ++ toString adjustment ++ "px)" ) ]

        Auto ->
            [ ( "width", "auto" ) ]

        Fill i ->
            [ ( "flex-grow", toString i ), ( "flex-basis", "0" ) ]

        Calc perc px ->
            [ ( "width", "calc(" ++ toString perc ++ "% + " ++ toString px ++ "px)" ) ]


flexHeight : Length -> List ( String, String )
flexHeight l =
    case l of
        Px x ->
            [ ( "height", toString x ++ "px" ) ]

        Percent x ->
            [ ( "height", toString x ++ "%" ) ]

        Auto ->
            [ ( "height", "auto" ) ]

        Fill i ->
            [ ( "flex-grow", toString i ), ( "flex-basis", "0" ) ]

        Calc perc px ->
            [ ( "height", "calc(" ++ toString perc ++ "% + " ++ toString px ++ "px)" ) ]


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
        [ ( "filter"
          , String.join " " <| List.map filterName filters
          )
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
            Just ( "box-shadow", renderedBox )
        , if renderedText == "" then
            Nothing
          else
            Just ( "text-shadow", renderedText )
        ]


box : BoxElement -> ( String, String )
box (BoxProp name val) =
    ( name, val )


transformations : List Transformation -> List ( String, String )
transformations transforms =
    let
        transformToString transform =
            case transform of
                Translate x y z ->
                    "translate3d(" ++ toString x ++ "px, " ++ toString y ++ "px, " ++ toString z ++ "px)"

                RotateAround x y z angle ->
                    "rotate3d(" ++ toString x ++ "," ++ toString y ++ "," ++ toString z ++ "," ++ toString angle ++ "rad)"

                Rotate x ->
                    "rotate(" ++ toString x ++ "rad)"

                Scale x y z ->
                    "scale3d(" ++ toString x ++ ", " ++ toString y ++ ", " ++ toString z ++ ")"

        transformString =
            String.join " " (List.map transformToString transforms)

        renderedTransforms =
            if String.length transformString > 0 then
                [ ( "transform", transformString ) ]
            else
                []
    in
    if List.length transforms == 0 then
        []
    else
        renderedTransforms


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


background : BackgroundElement -> List ( String, String )
background prop =
    let
        directionName dir =
            case dir of
                ToUp ->
                    "to top"

                ToDown ->
                    "to bottom"

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
                    Value.color color ++ " " ++ toString percent ++ "%"

                PxStep color percent ->
                    Value.color color ++ " " ++ toString percent ++ "px"
    in
    case prop of
        BackgroundElement name val ->
            [ ( name, val ) ]

        BackgroundImage { src, position, repeat, size } ->
            [ ( "background-image", "url(" ++ src ++ ")" )
            , ( "background-position", toString (Tuple.first position) ++ "px " ++ toString (Tuple.second position) ++ "px" )
            , ( "background-repeat"
              , case repeat of
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
              )
            , ( "background-size"
              , case size of
                    Contain ->
                        "contain"

                    Cover ->
                        "cover"

                    BackgroundWidth width ->
                        Value.length width ++ " auto"

                    BackgroundHeight height ->
                        "auto " ++ Value.length height

                    BackgroundSize { width, height } ->
                        Value.length width ++ " " ++ Value.length height
              )
            ]

        BackgroundLinearGradient dir steps ->
            [ ( "background-image", "linear-gradient(" ++ (String.join ", " <| directionName dir :: List.map renderStep steps) ++ ")" ) ]


{-| -}
layout : Bool -> LayoutModel -> List ( String, String )
layout inline lay =
    case lay of
        TextLayout _ ->
            [ ( "display"
              , if inline then
                    "inline-block"
                else
                    "block"
              )
            ]

        FlexLayout dir flexProps ->
            ( "display"
            , if inline then
                "inline-flex"
              else
                "flex"
            )
                :: direction dir
                :: List.map (flexbox dir) flexProps

        Grid (NamedGridTemplate { rows, columns }) options ->
            let
                grid =
                    if inline then
                        ( "display", "inline-grid" )
                    else
                        ( "display", "grid" )

                renderLen len =
                    case len of
                        Px x ->
                            toString x ++ "px"

                        Percent x ->
                            toString x ++ "%"

                        Auto ->
                            "auto"

                        Fill i ->
                            toString i ++ "fr"

                        Calc perc px ->
                            "calc(" ++ toString perc ++ "% + " ++ toString px ++ "px)"

                alignment =
                    List.map gridAlignment options

                areaSpan (Named span maybeName) =
                    let
                        name =
                            case maybeName of
                                Nothing ->
                                    "."

                                Just str ->
                                    str
                    in
                    case span of
                        SpanAll ->
                            List.repeat (List.length columns) name

                        SpanJust i ->
                            List.repeat i name

                areasInRow areas =
                    let
                        quote str =
                            "\"" ++ str ++ "\""

                        areaStrs =
                            List.concatMap areaSpan areas
                    in
                    if List.length areaStrs > List.length columns then
                        let
                            _ =
                                Debug.log "style-elements" "Named grid row (" ++ toString areas ++ ") is too big for this grid!"
                        in
                        areaStrs
                            |> String.join " "
                            |> quote
                    else if List.length areaStrs < List.length columns then
                        let
                            _ =
                                Debug.log "style-elements" "Named grid row (" ++ toString areas ++ ") doesn't have enough names to fit this grid!"
                        in
                        areaStrs
                            |> String.join " "
                            |> quote
                    else
                        areaStrs
                            |> String.join " "
                            |> quote
            in
            grid
                :: ( "grid-template-rows"
                   , String.join " " <| List.map (renderLen << Tuple.first) rows
                   )
                :: ( "grid-template-columns"
                   , String.join " " <| List.map renderLen columns
                   )
                :: ( "grid-template-areas"
                   , String.join "\n" <| List.map (areasInRow << Tuple.second) rows
                   )
                :: alignment

        Grid (GridTemplate { rows, columns }) options ->
            let
                grid =
                    if inline then
                        ( "display", "inline-grid" )
                    else
                        ( "display", "grid" )

                renderLen len =
                    case len of
                        Px x ->
                            toString x ++ "px"

                        Percent x ->
                            toString x ++ "%"

                        Auto ->
                            "auto"

                        Fill i ->
                            toString i ++ "fr"

                        Calc perc px ->
                            "calc(" ++ toString perc ++ "% + " ++ toString px ++ "px)"

                alignment =
                    List.map gridAlignment options
            in
            grid
                :: ( "grid-template-rows"
                   , String.join " " <| List.map renderLen rows
                   )
                :: ( "grid-template-columns"
                   , String.join " " <| List.map renderLen columns
                   )
                :: alignment


gridAlignment : GridAlignment -> ( String, String )
gridAlignment align =
    case align of
        GridGap row column ->
            ( "grid-gap", toString row ++ "px " ++ toString column ++ "px" )

        GridH horizontal ->
            case horizontal of
                Other Left ->
                    ( "justify-content", "start" )

                Other Right ->
                    ( "justify-content", "end" )

                Center ->
                    ( "justify-content", "center" )

                Justify ->
                    ( "justify-content", "space-between" )

                JustifyAll ->
                    ( "justify-content", "space-between" )

        GridV vertical ->
            case vertical of
                Other Top ->
                    ( "align-content", "start" )

                Other Bottom ->
                    ( "align-content", "end" )

                Center ->
                    ( "align-content", "center" )

                Justify ->
                    ( "align-content", "space-between" )

                JustifyAll ->
                    ( "align-content", "space-between" )


direction : Direction -> ( String, String )
direction dir =
    case dir of
        GoRight ->
            ( "flex-direction", "row" )

        GoLeft ->
            ( "flex-direction", "row-reverse" )

        Down ->
            ( "flex-direction", "column" )

        Up ->
            ( "flex-direction", "column-reverse" )


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
                ( "flex-wrap", "wrap" )
            else
                ( "flex-wrap", "nowrap" )

        Horz horizontal ->
            case dir of
                GoRight ->
                    case horizontal of
                        Other Left ->
                            ( "justify-content", "flex-start" )

                        Other Right ->
                            ( "justify-content", "flex-end" )

                        Center ->
                            ( "justify-content", "center" )

                        Justify ->
                            ( "justify-content", "space-between" )

                        JustifyAll ->
                            ( "justify-content", "space-between" )

                GoLeft ->
                    case horizontal of
                        Other Left ->
                            ( "justify-content", "flex-end" )

                        Other Right ->
                            ( "justify-content", "flex-start" )

                        Center ->
                            ( "justify-content", "center" )

                        Justify ->
                            ( "justify-content", "space-between" )

                        JustifyAll ->
                            ( "justify-content", "space-between" )

                Down ->
                    case horizontal of
                        Other Left ->
                            ( "align-items", "flex-start" )

                        Other Right ->
                            ( "align-items", "flex-end" )

                        Center ->
                            ( "align-items", "center" )

                        Justify ->
                            ( "align-items", "Justify" )

                        JustifyAll ->
                            ( "align-items", "Justify" )

                Up ->
                    case horizontal of
                        Other Left ->
                            ( "align-items", "flex-start" )

                        Other Right ->
                            ( "align-items", "flex-end" )

                        Center ->
                            ( "align-items", "center" )

                        Justify ->
                            ( "align-items", "Justify" )

                        JustifyAll ->
                            ( "align-items", "Justify" )

        Vert vertical ->
            case dir of
                GoRight ->
                    case vertical of
                        Other Top ->
                            ( "align-items", "flex-start" )

                        Other Bottom ->
                            ( "align-items", "flex-end" )

                        Center ->
                            ( "align-items", "center" )

                        Justify ->
                            ( "align-items", "Justify" )

                        JustifyAll ->
                            ( "align-items", "Justify" )

                GoLeft ->
                    case vertical of
                        Other Top ->
                            ( "align-items", "flex-start" )

                        Other Bottom ->
                            ( "align-items", "flex-end" )

                        Center ->
                            ( "align-items", "center" )

                        Justify ->
                            ( "align-items", "Justify" )

                        JustifyAll ->
                            ( "align-items", "Justify" )

                Down ->
                    case vertical of
                        Other Top ->
                            ( "justify-content", "flex-start" )

                        Other Bottom ->
                            ( "justify-content", "flex-end" )

                        Center ->
                            ( "justify-content", "center" )

                        Justify ->
                            ( "justify-content", "space-between" )

                        JustifyAll ->
                            ( "align-items", "Justify" )

                Up ->
                    case vertical of
                        Other Top ->
                            ( "justify-content", "flex-end" )

                        Other Bottom ->
                            ( "justify-content", "flex-start" )

                        Center ->
                            ( "justify-content", "center" )

                        Justify ->
                            ( "justify-content", "space-between" )

                        JustifyAll ->
                            ( "align-items", "Justify" )
