module Style.Font
    exposing
        ( FontScale(..)
        , scale
        , scaleSeparately
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

{-|

@docs typeface, size, height, letterSpacing, wordSpacing, left, right, center, justify, justifyAll

@docs FontScale, scale, scaleSeparately

@docs wrap, pre, preWrap, preLine, noWrap

@docs uppercase, capitalize, lowercase, underline, strike, italicize, bold, weight, light

-}

import Style.Internal.Model as Internal
import Style.Internal.Batchable as Batchable
import Style.Internal.Render.Value as Value
import Style exposing (Property)


{-|
-}
type FontScale
    = Mini
    | Tiny
    | Small
    | Normal
    | Large
    | Big
    | Huge


{-| When dealing with font sizes, it's nice to make them all relate to each other using a ratio.

This function will set font-size and line-height if you give it your normal font size, the ratio to use, and the `FontSize`.

`scale 16 1.618 Normal` results in a font-size of 16px and a line height of 1.618.
`scale 16 1.618 Large` results in a font-size of 26px(font sizes are always rounded) and a line height or 1.618

It's nice to use this In one place for your entire app.

So, define  `fontsize = scale 16 1.618` somewhere and then in your stylesheet you can just call `fontsize Big` and everything works out.

`1.618` is a [great place to start for a ratio](https://en.wikipedia.org/wiki/Golden_ratio)!

-}
scale : Float -> Float -> FontScale -> Property class variation animation
scale normal ratio fontScale =
    let
        ( size, lineHeight ) =
            resize normal ratio fontScale
    in
        Internal.Font "font-size" (toString (round size) ++ "px")



-- [ Batchable.Many
--     [ Internal.Font "font-size" (toString (round size) ++ "px")
--     , Internal.Font "line-height" (toString lineHeight)
--     ]
-- ]


{-| Scale font size and line height separately
-}
scaleSeparately : Float -> Float -> Float -> FontScale -> Property class variation animation
scaleSeparately lineHeight normal ratio fontScale =
    let
        ( size, _ ) =
            resize normal ratio fontScale
    in
        Internal.Font "font-size" (toString (round size) ++ "px")



-- [ Batchable.Many
--     [ Internal.Font "font-size" (toString (round size) ++ "px")
--     , Internal.Font "line-height" (toString lineHeight)
--     ]
-- ]


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


resize : Float -> Float -> FontScale -> ( Float, Float )
resize normal ratio fontScale =
    case fontScale of
        Mini ->
            ( shrink ratio 3 normal, ratio )

        Tiny ->
            ( shrink ratio 2 normal, ratio )

        Small ->
            ( shrink ratio 1 normal, ratio )

        Normal ->
            ( normal, ratio )

        Large ->
            ( grow ratio 1 normal, ratio )

        Big ->
            ( grow ratio 2 normal, ratio )

        Huge ->
            ( grow ratio 3 normal, ratio )


{-|
-}
typeface : List String -> Property class variation animation
typeface families =
    Internal.Font "font-family" (Value.typeface families)


{-| Set font-size.  Only px allowed.
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
