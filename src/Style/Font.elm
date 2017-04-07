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

import Style.Internal.Model as Internal exposing (Property, FontModel(..))
import Style.Internal.Render as Render
import Color exposing (Color)
import String


type alias Font =
    Internal.FontModel


{-| -}
font : { stack : List String, size : Float, lineHeight : Float } -> Font
font given =
    Internal.emptyFont
        |> stack given.stack
        |> size given.size
        |> height given.lineHeight


{-| -}
current : (Font -> Font) -> Property class variation animation
current update =
    Internal.Font (update Internal.emptyFont)


{-| -}
named : Font -> (Font -> Font) -> Property class variation animation
named font update =
    Internal.Font (update font)


{-| -}
only : Font -> Property class variation animation
only font =
    Internal.Font font


{-|
-}
stack : List String -> Font -> Font
stack families (FontModel font) =
    Internal.FontModel { font | stack = Just families }


{-| Set font-size.  Only px allowed.
-}
size : Float -> Font -> Font
size size (FontModel font) =
    Internal.FontModel { font | size = Just size }


{-| -}
color : Color -> Font -> Font
color fontColor (FontModel font) =
    Internal.FontModel { font | color = Just fontColor }


{-| Given as unitless lineheight.
-}
height : Float -> Font -> Font
height height (FontModel font) =
    Internal.FontModel { font | height = Just height }


{-| -}
letterSpacing : Float -> Font -> Font
letterSpacing offset (FontModel font) =
    Internal.FontModel { font | letterSpacing = Just offset }


{-| -}
wordSpacing : Float -> Font -> Font
wordSpacing offset (FontModel font) =
    Internal.FontModel { font | wordSpacing = Just offset }


{-| -}
left : Font -> Font
left (FontModel font) =
    Internal.FontModel { font | align = Just "left" }


{-| -}
right : Font -> Font
right (FontModel font) =
    Internal.FontModel { font | align = Just "right" }


{-| -}
center : Font -> Font
center (FontModel font) =
    Internal.FontModel { font | align = Just "center" }


{-| -}
justify : Font -> Font
justify (FontModel font) =
    Internal.FontModel { font | align = Just "jusitfy" }


{-| -}
justifyAll : Font -> Font
justifyAll (FontModel font) =
    Internal.FontModel { font | align = Just "justifyAll" }


{-| Renders as "white-space:normal", which is the standard wrapping behavior you're probably used to.
-}
wrap : Font -> Font
wrap (FontModel font) =
    Internal.FontModel { font | whitespace = Just "normal" }


{-| -}
pre : Font -> Font
pre (FontModel font) =
    Internal.FontModel { font | whitespace = Just "pre" }


{-| -}
preWrap : Font -> Font
preWrap (FontModel font) =
    Internal.FontModel { font | whitespace = Just "pre-wrap" }


{-| -}
preLine : Font -> Font
preLine (FontModel font) =
    Internal.FontModel { font | whitespace = Just "pre-line" }


{-| -}
noWrap : Font -> Font
noWrap (FontModel font) =
    Internal.FontModel { font | whitespace = Just "nowrap" }


{-| -}
underline : Font -> Font
underline (FontModel font) =
    Internal.FontModel { font | decoration = Just "underline" }


{-| -}
strike : Font -> Font
strike (FontModel font) =
    Internal.FontModel { font | decoration = Just "underline" }


{-| -}
italicize : Font -> Font
italicize (FontModel font) =
    Internal.FontModel { font | style = Just "italics" }


{-| -}
bold : Font -> Font
bold (FontModel font) =
    Internal.FontModel { font | weight = Just "700" }


{-| -}
light : Font -> Font
light (FontModel font) =
    Internal.FontModel { font | weight = Just "300" }


{-| -}
weight : Int -> Font -> Font
weight fontWeight (FontModel font) =
    Internal.FontModel { font | weight = Just <| toString fontWeight }
