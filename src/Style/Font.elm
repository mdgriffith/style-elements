module Style.Font exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property)
import Style.Internal.Render as Render
import Color exposing (Color)
import String


{-|
-}
stack : List String -> Property animation variation msg -> Property animation variation msg
stack families =
    Internal.addProperty Internal.Font "font-family" (String.join "," families)


{-| Set font-family
-}
font : String -> Property animation variation msg -> Property animation variation msg
font family =
    Internal.addProperty Internal.Font "font-family" family


{-| Set font-size.  Only px allowed.
-}
size : Float -> Property animation variation msg -> Property animation variation msg
size size =
    Internal.addProperty Internal.Font "font-size" (toString size ++ "px")


{-| -}
color : Color -> Property animation variation msg -> Property animation variation msg
color fontColor =
    Internal.addProperty Internal.Font "color" (Render.color fontColor)


{-| Given as unitless lineheight.
-}
height : Float -> Property animation variation msg -> Property animation variation msg
height size =
    Internal.addProperty Internal.Font "line-height" (toString size)


{-| -}
letterSpacing : Float -> Property animation variation msg -> Property animation variation msg
letterSpacing offset =
    Internal.addProperty Internal.Font "letter-spacing" (toString offset ++ "px")


{-| -}
wordSpacing : Float -> Property animation variation msg -> Property animation variation msg
wordSpacing offset =
    Internal.addProperty Internal.Font "word-spacing" (toString offset ++ "px")


{-| -}
left : Property animation variation msg -> Property animation variation msg
left =
    Internal.addProperty Internal.Font "text-align" "left"


{-| -}
right : Property animation variation msg -> Property animation variation msg
right =
    Internal.addProperty Internal.Font "text-align" "right"


{-| -}
center : Property animation variation msg -> Property animation variation msg
center =
    Internal.addProperty Internal.Font "text-align" "center"


{-| -}
justify : Property animation variation msg -> Property animation variation msg
justify =
    Internal.addProperty Internal.Font "text-align" "justify"


{-| -}
justifyAll : Property animation variation msg -> Property animation variation msg
justifyAll =
    Internal.addProperty Internal.Font "text-align" "justify-all"


{-| Renders as "white-space:normal", which is the standard wrapping behavior you're probably used to.
-}
wrap : Property animation variation msg -> Property animation variation msg
wrap =
    Internal.addProperty Internal.Font "white-space" "normal"


{-| -}
pre : Property animation variation msg -> Property animation variation msg
pre =
    Internal.addProperty Internal.Font "white-space" "pre"


{-| -}
preWrap : Property animation variation msg -> Property animation variation msg
preWrap =
    Internal.addProperty Internal.Font "white-space" "pre-wrap"


{-| -}
preLine : Property animation variation msg -> Property animation variation msg
preLine =
    Internal.addProperty Internal.Font "white-space" "pre-line"


{-| -}
noWrap : Property animation variation msg -> Property animation variation msg
noWrap =
    Internal.addProperty Internal.Font "white-space" "no-wrap"


{-| -}
underline : Property animation variation msg -> Property animation variation msg
underline =
    Internal.addProperty Internal.Font "text-decoration" "underline"


{-| -}
strike : Property animation variation msg -> Property animation variation msg
strike =
    Internal.addProperty Internal.Font "text-decoration" "line-through"


{-| -}
italicize : Property animation variation msg -> Property animation variation msg
italicize =
    Internal.addProperty Internal.Font "font-style" "italic"


{-| -}
bold : Property animation variation msg -> Property animation variation msg
bold =
    Internal.addProperty Internal.Font "font-weight" "700"


{-| -}
light : Property animation variation msg -> Property animation variation msg
light =
    Internal.addProperty Internal.Font "font-weight" "300"


{-| -}
weight : Int -> Property animation variation msg -> Property animation variation msg
weight fontWeight =
    Internal.addProperty Internal.Font "font-weight" (toString fontWeight)
