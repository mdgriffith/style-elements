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
    , (if shadow.kind == "text" || shadow.kind == "drop" then
        Nothing
       else
        Just <| toString shadow.size ++ "px"
      )
    , Just <| color shadow.color
    ]
        |> List.filterMap identity
        |> String.join " "
