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

Meant to be imported as:

    import Style.Font as Font

@docs typeface, size, height, letterSpacing, wordSpacing, left, right, center, justify, justifyAll

@docs wrap, pre, preWrap, preLine, noWrap

@docs uppercase, capitalize, lowercase, underline, strike, italics, bold, weight, light

-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Value
import Style exposing (Property)


{-| -}
typeface : List String -> Property class variation
typeface families =
    Internal.Font "font-family" (Value.typeface families)


{-| Only px allowed.
-}
size : Float -> Property class variation
size size =
    Internal.Font "font-size" (toString size ++ "px")


{-| Given as unitless lineheight.
-}
height : Float -> Property class variation
height height =
    Internal.Font "line-height" (toString height)


{-| In px.
-}
letterSpacing : Float -> Property class variation
letterSpacing offset =
    Internal.Font "letter-spacing" (toString offset ++ "px")


{-| In px.
-}
wordSpacing : Float -> Property class variation
wordSpacing offset =
    Internal.Font "word-spacing" (toString offset ++ "px")


{-| Align the font to the left.
-}
left : Property class variation
left =
    Internal.Font "text-align" "left"


{-| Align the font to the right.
-}
right : Property class variation
right =
    Internal.Font "text-align" "right"


{-| Align font center.
-}
center : Property class variation
center =
    Internal.Font "text-align" "center"


{-| -}
justify : Property class variation
justify =
    Internal.Font "text-align" "justify"


{-| -}
justifyAll : Property class variation
justifyAll =
    Internal.Font "text-align" "justifyAll"


{-| Renders as "white-space:normal", which is the standard wrapping behavior you're probably used to.
-}
wrap : Property class variation
wrap =
    Internal.Font "white-space" "normal"


{-| -}
pre : Property class variation
pre =
    Internal.Font "white-space" "pre"


{-| -}
preWrap : Property class variation
preWrap =
    Internal.Font "white-space" "pre-wrap"


{-| -}
preLine : Property class variation
preLine =
    Internal.Font "white-space" "pre-line"


{-| -}
noWrap : Property class variation
noWrap =
    Internal.Font "white-space" "nowrap"


{-| -}
underline : Property class variation
underline =
    Internal.Font "text-decoration" "underline"


{-| -}
strike : Property class variation
strike =
    Internal.Font "text-decoration" "underline"


{-| -}
italics : Property class variation
italics =
    Internal.Font "font-style" "italics"


{-| -}
bold : Property class variation
bold =
    Internal.Font "font-weight" "700"


{-| -}
light : Property class variation
light =
    Internal.Font "font-weight" "300"


{-| -}
weight : Int -> Property class variation
weight fontWeight =
    Internal.Font "font-weight" (toString fontWeight)


{-| -}
uppercase : Property class variation
uppercase =
    Internal.Font "text-transform" "uppercase"


{-| -}
capitalize : Property class variation
capitalize =
    Internal.Font "text-transform" "capitalize"


{-| -}
lowercase : Property class variation
lowercase =
    Internal.Font "text-transform" "lowercase"
