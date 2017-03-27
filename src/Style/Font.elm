module Style.Font exposing (..)

{-| -}

import String


{-|
-}
stack : List String -> Property animation variation msg
stack families =
    Property "font-family" (String.join "," families)


{-| Set font-family
-}
font : String -> Property animation variation msg
font family =
    Property "font-family" family


{-| Set font-size.  Only px allowed.
-}
size : Float -> Property animation variation msg
size size =
    Property "font-size" (toString size ++ "px")


{-| -}
color : Color -> Property animation variation msg
color color =
    ColorProp "color" color


{-| Given as unitless lineheight.
-}
height : Float -> Property animation variation msg
height size =
    Property "line-height" (toString size)


{-| -}
letterSpacing : Float -> Property animation variation msg
letterSpacing offset =
    Property "letter-spacing" (toString offset ++ "px")


{-| -}
align : Centerable Horizontal -> Property animation variation msg
align alignment =
    case alignment of
        Other Left ->
            Property "text-align" "left"

        Other Right ->
            Property "text-align" "right"

        Center ->
            Property "text-align" "center"

        Stretch ->
            Property "text-align" "justify"



--JustifyAll ->
--    Property "text-align" "justify-all"


{-| -}
whitespace : Whitespace -> Property animation variation msg
whitespace ws =
    case ws of
        Normal ->
            Property "white-space" "normal"

        Pre ->
            Property "white-space" "pre"

        PreWrap ->
            Property "white-space" "pre-wrap"

        PreLine ->
            Property "white-space" "pre-line"

        NoWrap ->
            Property "white-space" "no-wrap"


{-| -}
normal : Whitespace
normal =
    Style.Model.Normal


{-| -}
pre : Whitespace
pre =
    Style.Model.Pre


{-| -}
preWrap : Whitespace
preWrap =
    Style.Model.PreWrap


{-| -}
preLine : Whitespace
preLine =
    Style.Model.PreLine


{-| -}
noWrap : Whitespace
noWrap =
    Style.Model.NoWrap


{-| -}
underline : Property animation variation msg
underline =
    Property "text-decoration" "underline"


{-| -}
strike : Property animation variation msg
strike =
    Property "text-decoration" "line-through"


{-| -}
italicize : Property animation variation msg
italicize =
    Property "font-style" "italic"


{-| -}
bold : Property animation variation msg
bold =
    Property "font-weight" "700"


{-| -}
light : Property animation variation msg
light =
    Property "font-weight" "300"


{-| -}
weight : Int -> Property animation variation msg
weight weight =
    Property "font-weight" (toString weight)
