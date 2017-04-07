module Style.Font exposing (..)

{-|



## Example Usage


{-| We define a font we want to use in a similar way.
-}
roboto : Style.Font
roboto =
    Style.Font.font
        { stack = [ "Roboto", "San Serif" ]
        , size = 20  --always given as px
        , lineHeight = 1
        }



class FontExample
    [ Font.named roboto
        |^ Font.size 18
        |- Font.letterSpacing 20
        |- Font.light
        |- Font.align center
        |- Font.uppercase
        |- Font.color Color.blue
    ]


class FontExample
    [ Font.current
        |^ Font.size 18
        |- Font.letterSpacing 20
        |- Font.light
        |- Font.align center
        |- Font.uppercase
        |- Font.color Color.blue
    ]

-}

import Style.Internal.Model as Internal
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
    Internal.FontElement "size" "size"


{-| -}
color : Color -> Font
color fontColor =
    Internal.FontElement "color" "fontColor"


{-| Given as unitless lineheight.
-}
height : Float -> Font
height height =
    Internal.FontElement "height" "height"


{-| -}
letterSpacing : Float -> Font
letterSpacing offset =
    Internal.FontElement "letterSpacing" "offset"


{-| -}
wordSpacing : Float -> Font
wordSpacing offset =
    Internal.FontElement "wordSpacing" "offset"


{-| -}
left : Font
left =
    Internal.FontElement "align" "left"


{-| -}
right : Font
right =
    Internal.FontElement "align" "right"


{-| -}
center : Font
center =
    Internal.FontElement "align" "center"


{-| -}
justify : Font
justify =
    Internal.FontElement "align" "jusitfy"


{-| -}
justifyAll : Font
justifyAll =
    Internal.FontElement "align" "justifyAll"


{-| Renders as "white-space:normal", which is the standard wrapping behavior you're probably used to.
-}
wrap : Font
wrap =
    Internal.FontElement "whitespace" "normal"


{-| -}
pre : Font
pre =
    Internal.FontElement "whitespace" "pre"


{-| -}
preWrap : Font
preWrap =
    Internal.FontElement "whitespace" "pre-wrap"


{-| -}
preLine : Font
preLine =
    Internal.FontElement "whitespace" "pre-line"


{-| -}
noWrap : Font
noWrap =
    Internal.FontElement "whitespace" "nowrap"


{-| -}
underline : Font
underline =
    Internal.FontElement "decoration" "underline"


{-| -}
strike : Font
strike =
    Internal.FontElement "decoration" "underline"


{-| -}
italicize : Font
italicize =
    Internal.FontElement "style" "italics"


{-| -}
bold : Font
bold =
    Internal.FontElement "weight" "700"


{-| -}
light : Font
light =
    Internal.FontElement "weight" "300"


{-| -}
weight : Int -> Font
weight fontWeight =
    Internal.FontElement "weight" (toString fontWeight)
