module Style.Internal.Render.Value exposing (..)

{-| -}

import Color exposing (Color)
import Style.Internal.Model as Internal exposing (..)


box : ( Float, Float, Float, Float ) -> String
box ( a, b, c, d ) =
    toString a ++ "px " ++ toString b ++ "px " ++ toString c ++ "px " ++ toString d ++ "px"


length : Length -> String
length l =
    case l of
        Px x ->
            toString x ++ "px"

        Percent x ->
            toString x ++ "%"

        Auto ->
            "auto"

        Fill i ->
            "100%"

        Calc perc px ->
            "calc(" ++ toString perc ++ "% + " ++ toString px ++ "px)"


parentAdjustedLength : Length -> Float -> String
parentAdjustedLength len adjustment =
    case len of
        Px x ->
            toString x ++ "px"

        Percent x ->
            "calc(" ++ toString x ++ "% - " ++ toString adjustment ++ "px)"

        Auto ->
            "auto"

        Fill i ->
            "calc(100% - " ++ toString adjustment ++ "px)"

        Calc perc px ->
            "calc(" ++ toString perc ++ "% + " ++ toString px ++ "px)"


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


shadow : ShadowModel -> String
shadow (ShadowModel shadow) =
    [ if shadow.kind == "inset" then
        Just "inset"
      else
        Nothing
    , Just <| toString (Tuple.first shadow.offset) ++ "px"
    , Just <| toString (Tuple.second shadow.offset) ++ "px"
    , Just <| toString shadow.blur ++ "px"
    , if shadow.kind == "text" || shadow.kind == "drop" then
        Nothing
      else
        Just <| toString shadow.size ++ "px"
    , Just <| color shadow.color
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
                [ toString rowStart
                , toString colStart
                , toString rowEnd
                , toString colEnd
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
