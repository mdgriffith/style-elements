module Style.Internal.Render.Value exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (..)


box : Box Float -> String
box (Box a b c d) =
    String.fromFloat a ++ "px " ++ String.fromFloat b ++ "px " ++ String.fromFloat c ++ "px " ++ String.fromFloat d ++ "px"


length : Length -> String
length l =
    case l of
        Px x ->
            String.fromFloat x ++ "px"

        Percent x ->
            String.fromFloat x ++ "%"

        Auto ->
            "auto"

        Fill i ->
            "100%"

        Calc perc px ->
            "calc(" ++ String.fromFloat perc ++ "% + " ++ String.fromFloat px ++ "px)"


parentAdjustedLength : Length -> Float -> String
parentAdjustedLength len adjustment =
    case len of
        Px x ->
            String.fromFloat x ++ "px"

        Percent x ->
            "calc(" ++ String.fromFloat x ++ "% - " ++ String.fromFloat adjustment ++ "px)"

        Auto ->
            "auto"

        Fill i ->
            "calc(100% - " ++ String.fromFloat adjustment ++ "px)"

        Calc perc px ->
            "calc(" ++ String.fromFloat perc ++ "% + " ++ String.fromFloat px ++ "px)"


color : Color -> String
color (RGBA red green blue alpha) =
    ("rgba(" ++ String.fromInt (round (red * 255)))
        ++ ("," ++ String.fromInt (round (green * 255)))
        ++ ("," ++ String.fromInt (round (blue * 255)))
        ++ ("," ++ String.fromFloat alpha ++ ")")


shadow : ShadowModel -> String
shadow (ShadowModel shadowModel) =
    [ if shadowModel.kind == "inset" then
        Just "inset"
      else
        Nothing
    , Just <| String.fromFloat (Tuple.first shadowModel.offset) ++ "px"
    , Just <| String.fromFloat (Tuple.second shadowModel.offset) ++ "px"
    , Just <| String.fromFloat shadowModel.blur ++ "px"
    , if shadowModel.kind == "text" || shadowModel.kind == "drop" then
        Nothing
      else
        Just <| String.fromFloat shadowModel.size ++ "px"
    , Just <| color shadowModel.color
    ]
        |> List.filterMap identity
        |> String.join " "


gridPosition : GridPosition -> Maybe String
gridPosition (GridPosition { start, width, height }) =
    let
        ( x, y ) =
            start

        ( rowStart, rowEnd ) =
            ( y + 1, y + 1 + height )

        ( colStart, colEnd ) =
            ( x + 1, x + 1 + width )
    in
    if width == 0 || height == 0 then
        Nothing
    else
        Just <|
            String.join " / "
                [ String.fromInt rowStart
                , String.fromInt colStart
                , String.fromInt rowEnd
                , String.fromInt colEnd
                ]


typeface : List Font -> String
typeface families =
    let
        renderFont font =
            case font of
                Serif ->
                    "serif"

                SansSerif ->
                    "sans-serif"

                Cursive ->
                    "cursive"

                Fantasy ->
                    "fantasy"

                Monospace ->
                    "monospace"

                FontName name ->
                    "\"" ++ name ++ "\""

                ImportFont name url ->
                    "\"" ++ name ++ "\""
    in
    families
        |> List.map renderFont
        |> String.join ", "
