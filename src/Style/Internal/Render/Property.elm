module Style.Internal.Render.Property exposing (..)

{-| -}

import Style.Internal.Model exposing (..)
import Style.Internal.Render.Value as Value


visibility : Visible -> List ( String, String )
visibility vis =
    case vis of
        Hidden ->
            [ ( "display", "none" ) ]

        Invisible ->
            [ ( "visibility", "hidden" ) ]

        Opacity x ->
            [ ( "opacity", String.fromFloat x ) ]


flexWidth : Length -> Float -> List ( String, String )
flexWidth len adjustment =
    case len of
        Px x ->
            [ ( "width", String.fromFloat x ++ "px" ) ]

        Percent x ->
            [ ( "width", "calc(" ++ String.fromFloat x ++ "% - " ++ String.fromFloat adjustment ++ "px)" ) ]

        Auto ->
            [ ( "width", "auto" ) ]

        Fill i ->
            [ ( "flex-grow", String.fromFloat i ), ( "flex-basis", "0" ) ]

        Calc perc px ->
            [ ( "width", "calc(" ++ String.fromFloat perc ++ "% + " ++ String.fromFloat px ++ "px)" ) ]


flexHeight : Length -> List ( String, String )
flexHeight l =
    case l of
        Px x ->
            [ ( "height", String.fromFloat x ++ "px" ) ]

        Percent x ->
            [ ( "height", String.fromFloat x ++ "%" ) ]

        Auto ->
            [ ( "height", "auto" ) ]

        Fill i ->
            [ ( "flex-grow", String.fromFloat i ), ( "flex-basis", "0" ) ]

        Calc perc px ->
            [ ( "height", "calc(" ++ String.fromFloat perc ++ "% + " ++ String.fromFloat px ++ "px)" ) ]


filters : List Filter -> List ( String, String )
filters myFilters =
    let
        filterName filtr =
            case filtr of
                FilterUrl url ->
                    "url(" ++ url ++ ")"

                Blur x ->
                    "blur(" ++ String.fromFloat x ++ "px)"

                Brightness x ->
                    "brightness(" ++ String.fromFloat x ++ "%)"

                Contrast x ->
                    "contrast(" ++ String.fromFloat x ++ "%)"

                Grayscale x ->
                    "grayscale(" ++ String.fromFloat x ++ "%)"

                HueRotate x ->
                    "hueRotate(" ++ String.fromFloat x ++ "deg)"

                Invert x ->
                    "invert(" ++ String.fromFloat x ++ "%)"

                OpacityFilter x ->
                    "opacity(" ++ String.fromFloat x ++ "%)"

                Saturate x ->
                    "saturate(" ++ String.fromFloat x ++ "%)"

                Sepia x ->
                    "sepia(" ++ String.fromFloat x ++ "%)"

                DropShadow dropShadow ->
                    let
                        shadowModel =
                            ShadowModel
                                { kind = "drop"
                                , offset = dropShadow.offset
                                , size = dropShadow.size
                                , blur = dropShadow.blur
                                , color = dropShadow.color
                                }
                    in
                    "drop-shadow(" ++ Value.shadow shadowModel ++ ")"
    in
    if List.length myFilters == 0 then
        []
    else
        [ ( "filter"
          , String.join " " <| List.map filterName myFilters
          )
        ]


shadow : List ShadowModel -> List ( String, String )
shadow shadows =
    let
        ( text, boxShadow ) =
            List.partition (\(ShadowModel s) -> s.kind == "text") shadows

        renderedBox =
            String.join ", " (List.map Value.shadow boxShadow)

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
                    "translate3d(" ++ String.fromFloat x ++ "px, " ++ String.fromFloat y ++ "px, " ++ String.fromFloat z ++ "px)"

                RotateAround x y z angle ->
                    "rotate3d(" ++ String.fromFloat x ++ "," ++ String.fromFloat y ++ "," ++ String.fromFloat z ++ "," ++ String.fromFloat angle ++ "rad)"

                Rotate x ->
                    "rotate(" ++ String.fromFloat x ++ "rad)"

                Scale x y z ->
                    "scale3d(" ++ String.fromFloat x ++ ", " ++ String.fromFloat y ++ ", " ++ String.fromFloat z ++ ")"

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
                    ( "left", String.fromFloat x ++ "px" )

                PosRight x ->
                    ( "right", String.fromFloat x ++ "px" )

                PosTop x ->
                    ( "top", String.fromFloat x ++ "px" )

                PosBottom x ->
                    ( "bottom", String.fromFloat x ++ "px" )

                ZIndex i ->
                    ( "z-index", String.fromInt i )

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
                    String.fromFloat angle ++ "rad"

        renderStep step =
            case step of
                ColorStep color ->
                    Value.color color

                PercentStep color percent ->
                    Value.color color ++ " " ++ String.fromFloat percent ++ "%"

                PxStep color percent ->
                    Value.color color ++ " " ++ String.fromFloat percent ++ "px"
    in
    case prop of
        BackgroundElement name val ->
            [ ( name, val ) ]

        BackgroundImage image ->
            [ ( "background-image", "url(" ++ image.src ++ ")" )
            , ( "background-position", String.fromFloat (Tuple.first image.position) ++ "px " ++ String.fromFloat (Tuple.second image.position) ++ "px" )
            , ( "background-repeat"
              , case image.repeat of
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
              , case image.size of
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
                            String.fromFloat x ++ "px"

                        Percent x ->
                            String.fromFloat x ++ "%"

                        Auto ->
                            "auto"

                        Fill i ->
                            String.fromFloat i ++ "fr"

                        Calc perc px ->
                            "calc(" ++ String.fromFloat perc ++ "% + " ++ String.fromFloat px ++ "px)"

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
                        -- let
                        --     _ =
                        --         Debug.log "style-elements" "Named grid row is too big for this grid!"
                        -- in
                        areaStrs
                            |> String.join " "
                            |> quote
                    else if List.length areaStrs < List.length columns then
                        -- let
                        --     _ =
                        --         Debug.log "style-elements" "Named grid row doesn't have enough names to fit this grid!"
                        -- in
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
                            String.fromFloat x ++ "px"

                        Percent x ->
                            String.fromFloat x ++ "%"

                        Auto ->
                            "auto"

                        Fill i ->
                            String.fromFloat i ++ "fr"

                        Calc perc px ->
                            "calc(" ++ String.fromFloat perc ++ "% + " ++ String.fromFloat px ++ "px)"

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
            ( "grid-gap", String.fromFloat row ++ "px " ++ String.fromFloat column ++ "px" )

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
                [ prop, String.fromFloat duration ++ "ms", easing, String.fromFloat delay ++ "ms" ]
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
