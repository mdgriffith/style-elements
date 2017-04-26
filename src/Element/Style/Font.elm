module Element.Style.Font
    exposing
        ( FontScale(..)
        , scale
        , typeface
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

@docs typeface, size, color, height, letterSpacing, wordSpacing, left, right, center, justify, justifyAll

@docs FontScale, scale

@docs wrap, pre, preWrap, preLine, noWrap

@docs uppercase, capitalize, lowercase, underline, strike, italicize, bold, weight, light

-}

import Element.Style.Internal.Model as Internal
import Element.Style.Internal.Render.Value as Render
import Element.Style.Internal.Batchable as Batchable
import Element.Style exposing (Font)
import Color exposing (Color)
import String


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

It's also nice to use this In one place for your entire app.

So, define  `fontsize = scale 16 1.618` somewhere and then in your stylesheet you can just call `fontsize Big` and everything works out.

`1.618` is a [great place to start for a ratio](https://en.wikipedia.org/wiki/Golden_ratio)!

-}
scale : Float -> Float -> FontScale -> Font
scale normal ratio fontScale =
    let
        grow i size =
            if i <= 0 then
                size
            else
                grow (i - 1) (size * ratio)

        shrink i size =
            if i <= 0 then
                size
            else
                shrink (i - 1) (size / ratio)

        resized =
            case fontScale of
                Mini ->
                    shrink 3 normal

                Tiny ->
                    shrink 2 normal

                Small ->
                    shrink 1 normal

                Normal ->
                    normal

                Large ->
                    grow 1 normal

                Big ->
                    grow 2 normal

                Huge ->
                    grow 3 normal
    in
        Batchable.Many
            [ Internal.FontElement "font-size" (toString (round resized) ++ "px")
            , Internal.FontElement "line-height" (toString ratio)
            ]


{-|
-}
mix : List Font -> Font
mix =
    Batchable.Many


{-|
-}
typeface : List String -> Font
typeface families =
    families
        |> List.map (\fam -> "\"" ++ fam ++ "\"")
        |> \fams -> Batchable.Single <| Internal.FontElement "font-family" (String.join ", " fams)


{-| Set font-size.  Only px allowed.
-}
size : Float -> Font
size size =
    Batchable.Single <| Internal.FontElement "font-size" (toString size ++ "px")


{-| -}
color : Color -> Font
color fontColor =
    Batchable.Single <| Internal.FontElement "color" (Render.color fontColor)


{-| Given as unitless lineheight.
-}
height : Float -> Font
height height =
    Batchable.Single <| Internal.FontElement "line-height" (toString height)


{-| -}
letterSpacing : Float -> Font
letterSpacing offset =
    Batchable.Single <| Internal.FontElement "letter-spacing" (toString offset ++ "px")


{-| -}
wordSpacing : Float -> Font
wordSpacing offset =
    Batchable.Single <| Internal.FontElement "word-spacing" (toString offset ++ "px")


{-| -}
left : Font
left =
    Batchable.Single <| Internal.FontElement "text-align" "left"


{-| -}
right : Font
right =
    Batchable.Single <| Internal.FontElement "text-align" "right"


{-| -}
center : Font
center =
    Batchable.Single <| Internal.FontElement "text-align" "center"


{-| -}
justify : Font
justify =
    Batchable.Single <| Internal.FontElement "text-align" "justify"


{-| -}
justifyAll : Font
justifyAll =
    Batchable.Single <| Internal.FontElement "text-align" "justifyAll"


{-| Renders as "white-space:normal", which is the standard wrapping behavior you're probably used to.
-}
wrap : Font
wrap =
    Batchable.Single <| Internal.FontElement "white-space" "normal"


{-| -}
pre : Font
pre =
    Batchable.Single <| Internal.FontElement "white-space" "pre"


{-| -}
preWrap : Font
preWrap =
    Batchable.Single <| Internal.FontElement "white-space" "pre-wrap"


{-| -}
preLine : Font
preLine =
    Batchable.Single <| Internal.FontElement "white-space" "pre-line"


{-| -}
noWrap : Font
noWrap =
    Batchable.Single <| Internal.FontElement "white-space" "nowrap"


{-| -}
underline : Font
underline =
    Batchable.Single <| Internal.FontElement "text-decoration" "underline"


{-| -}
strike : Font
strike =
    Batchable.Single <| Internal.FontElement "text-decoration" "underline"


{-| -}
italicize : Font
italicize =
    Batchable.Single <| Internal.FontElement "font-style" "italics"


{-| -}
bold : Font
bold =
    Batchable.Single <| Internal.FontElement "font-weight" "700"


{-| -}
light : Font
light =
    Batchable.Single <| Internal.FontElement "font-weight" "300"


{-| -}
weight : Int -> Font
weight fontWeight =
    Batchable.Single <| Internal.FontElement "font-weight" (toString fontWeight)


{-| -}
uppercase : Font
uppercase =
    Batchable.Single <| Internal.FontElement "text-transform" "uppercase"


{-| -}
capitalize : Font
capitalize =
    Batchable.Single <| Internal.FontElement "text-transform" "capitalize"


{-| -}
lowercase : Font
lowercase =
    Batchable.Single <| Internal.FontElement "text-transform" "lowercase"
