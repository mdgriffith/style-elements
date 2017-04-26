module Element.Style.Font
    exposing
        ( typeface
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

@docs wrap, pre, preWrap, preLine, noWrap

@docs uppercase, capitalize, lowercase, underline, strike, italicize, bold, weight, light

-}

import Element.Style.Internal.Model as Internal
import Element.Style.Internal.Render.Value as Render
import Element.Style.Internal.Batchable as Batchable
import Element.Style exposing (Font)
import Color exposing (Color)
import String


type FontScale
    = Mini
    | Tiny
    | Small
    | Normal
    | Large
    | Big
    | Huge


{-|
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
            [ Internal.FontElement "font-size" (toString resized ++ "px")
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
