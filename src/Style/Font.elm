module Style.Font
    exposing
        ( stack
        , size
        , color
        , height
        , letterSpacing
        , wordSpacing
        , left
        , right
        , center
        , justify
        , justifyAll
        , wrap
        , pre
        , preWrap
        , preLine
        , noWrap
        , underline
        , strike
        , italicize
        , bold
        , weight
        , light
        , uppercase
        , capitalize
        , lowercase
        )

{-|

@docs stack, size, color, height, letterSpacing, wordSpacing, left, right, center, justify, justifyAll

@docs wrap, pre, preWrap, preLine, noWrap

@docs uppercase, capitalize, lowercase, underline, strike, italicize, bold, weight, light

-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Render
import Style exposing (Font)
import Color exposing (Color)
import String


{-|
-}
stack : List String -> Font
stack families =
    families
        |> List.map (\fam -> "\"" ++ fam ++ "\"")
        |> \fams -> Internal.FontElement "font-family" (String.join ", " fams)


{-| Set font-size.  Only px allowed.
-}
size : Float -> Font
size size =
    Internal.FontElement "font-size" (toString size ++ "px")


{-| -}
color : Color -> Font
color fontColor =
    Internal.FontElement "color" (Render.color fontColor)


{-| Given as unitless lineheight.
-}
height : Float -> Font
height height =
    Internal.FontElement "line-height" (toString height ++ "px")


{-| -}
letterSpacing : Float -> Font
letterSpacing offset =
    Internal.FontElement "letter-spacing" (toString offset ++ "px")


{-| -}
wordSpacing : Float -> Font
wordSpacing offset =
    Internal.FontElement "word-spacing" (toString offset ++ "px")


{-| -}
left : Font
left =
    Internal.FontElement "text-align" "left"


{-| -}
right : Font
right =
    Internal.FontElement "text-align" "right"


{-| -}
center : Font
center =
    Internal.FontElement "text-align" "center"


{-| -}
justify : Font
justify =
    Internal.FontElement "text-align" "justify"


{-| -}
justifyAll : Font
justifyAll =
    Internal.FontElement "text-align" "justifyAll"


{-| Renders as "white-space:normal", which is the standard wrapping behavior you're probably used to.
-}
wrap : Font
wrap =
    Internal.FontElement "white-space" "normal"


{-| -}
pre : Font
pre =
    Internal.FontElement "white-space" "pre"


{-| -}
preWrap : Font
preWrap =
    Internal.FontElement "white-space" "pre-wrap"


{-| -}
preLine : Font
preLine =
    Internal.FontElement "white-space" "pre-line"


{-| -}
noWrap : Font
noWrap =
    Internal.FontElement "white-space" "nowrap"


{-| -}
underline : Font
underline =
    Internal.FontElement "text-decoration" "underline"


{-| -}
strike : Font
strike =
    Internal.FontElement "text-decoration" "underline"


{-| -}
italicize : Font
italicize =
    Internal.FontElement "font-style" "italics"


{-| -}
bold : Font
bold =
    Internal.FontElement "font-weight" "700"


{-| -}
light : Font
light =
    Internal.FontElement "font-weight" "300"


{-| -}
weight : Int -> Font
weight fontWeight =
    Internal.FontElement "font-weight" (toString fontWeight)


{-| -}
uppercase : Font
uppercase =
    Internal.FontElement "text-transform" "uppercase"


{-| -}
capitalize : Font
capitalize =
    Internal.FontElement "text-transform" "capitalize"


{-| -}
lowercase : Font
lowercase =
    Internal.FontElement "text-transform" "lowercase"
