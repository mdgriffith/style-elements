module Style.Font
    exposing
        ( scale
        , scaleInt
        , typeface
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
        , italicize
        , bold
        , weight
        , light
        , uppercase
        , capitalize
        , lowercase
        )

{-| @docs typeface, size, height, letterSpacing, wordSpacing, left, right, center, justify, justifyAll

@docs scale, scaleInt

@docs wrap, pre, preWrap, preLine, noWrap

@docs uppercase, capitalize, lowercase, underline, strike, italicize, bold, weight, light

-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Value
import Style exposing (Property)


{-| When dealing with font sizes, it's nice to use a modular scale, which means all font sizes are related via a ratio.

Here's how it's done, first create a scale:

    scaled =
        scale 16 1.618

You can read this as "Starting at a base of 16, create a modular scale using the ratio 1.618."

Then, when setting font sizes you can use:

This will set the font size to 16px:

    Font.size (scaled 1)

Or we can scale up one level (which multiplies the result by 1.618):

    Font.size (scaled 2)

This results in a font size of 25.8px.

We can also provide negative numbers to scale below 16px.

-}
scale : Float -> Float -> Int -> Float
scale normal ratio fontScale =
    resize normal ratio fontScale


{-| Same as `scale` but rounds the resunt to an `Int`
-}
scaleInt : Float -> Float -> Int -> Int
scaleInt normal ratio fontScale =
    round <| resize normal ratio fontScale


resize : Float -> Float -> Int -> Float
resize normal ratio fontScale =
    if fontScale == 0 || fontScale == 1 then
        normal
    else if fontScale < 0 then
        shrink ratio (fontScale * -1) normal
    else
        grow ratio (fontScale - 1) normal


grow : Float -> Int -> Float -> Float
grow ratio i size =
    if i <= 0 then
        size
    else
        grow ratio (i - 1) (size * ratio)


shrink : Float -> Int -> Float -> Float
shrink ratio i size =
    if i <= 0 then
        size
    else
        shrink ratio (i - 1) (size / ratio)


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
italicize : Property class variation animation
italicize =
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
