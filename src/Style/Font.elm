module Style.Font
    exposing
        ( typeface
        , size
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
        , italics
        , bold
        , weight
        , light
        , uppercase
        , capitalize
        , lowercase
        )

{-| Font Properties

@docs typeface, size, height, letterSpacing, wordSpacing, left, right, center, justify, justifyAll

@docs wrap, pre, preWrap, preLine, noWrap

@docs uppercase, capitalize, lowercase, underline, strike, italics, bold, weight, light

-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Value
import Style exposing (Property)


{-| -}
typeface : List String -> Property class variation animation
typeface families =
    Internal.Font "font-family" (Value.typeface families)


{-| Set font-size. Only px allowed.
-}
size : Float -> Property class variation animation
size size =
    Internal.Font "font-size" (toString size ++ "px")


{-| Given as unitless lineheight.
-}
height : Float -> Property class variation animation
height height =
    Internal.Font "line-height" (toString height)


{-| -}
letterSpacing : Float -> Property class variation animation
letterSpacing offset =
    Internal.Font "letter-spacing" (toString offset ++ "px")


{-| -}
wordSpacing : Float -> Property class variation animation
wordSpacing offset =
    Internal.Font "word-spacing" (toString offset ++ "px")


{-| -}
left : Property class variation animation
left =
    Internal.Font "text-align" "left"


{-| -}
right : Property class variation animation
right =
    Internal.Font "text-align" "right"


{-| -}
center : Property class variation animation
center =
    Internal.Font "text-align" "center"


{-| -}
justify : Property class variation animation
justify =
    Internal.Font "text-align" "justify"


{-| -}
justifyAll : Property class variation animation
justifyAll =
    Internal.Font "text-align" "justifyAll"


{-| Renders as "white-space:normal", which is the standard wrapping behavior you're probably used to.
-}
wrap : Property class variation animation
wrap =
    Internal.Font "white-space" "normal"


{-| -}
pre : Property class variation animation
pre =
    Internal.Font "white-space" "pre"


{-| -}
preWrap : Property class variation animation
preWrap =
    Internal.Font "white-space" "pre-wrap"


{-| -}
preLine : Property class variation animation
preLine =
    Internal.Font "white-space" "pre-line"


{-| -}
noWrap : Property class variation animation
noWrap =
    Internal.Font "white-space" "nowrap"


{-| -}
underline : Property class variation animation
underline =
    Internal.Font "text-decoration" "underline"


{-| -}
strike : Property class variation animation
strike =
    Internal.Font "text-decoration" "underline"


{-| -}
italics : Property class variation animation
italics =
    Internal.Font "font-style" "italics"


{-| -}
bold : Property class variation animation
bold =
    Internal.Font "font-weight" "700"


{-| -}
light : Property class variation animation
light =
    Internal.Font "font-weight" "300"


{-| -}
weight : Int -> Property class variation animation
weight fontWeight =
    Internal.Font "font-weight" (toString fontWeight)


{-| -}
uppercase : Property class variation animation
uppercase =
    Internal.Font "text-transform" "uppercase"


{-| -}
capitalize : Property class variation animation
capitalize =
    Internal.Font "text-transform" "capitalize"


{-| -}
lowercase : Property class variation animation
lowercase =
    Internal.Font "text-transform" "lowercase"
