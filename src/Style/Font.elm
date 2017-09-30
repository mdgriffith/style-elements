module Style.Font
    exposing
        ( alignLeft
        , alignRight
        , bold
        , capitalize
        , center
        , cursive
        , fantasy
        , font
        , importUrl
        , italic
        , justify
        , justifyAll
        , letterSpacing
        , light
        , lineHeight
        , lowercase
        , monospace
        , sansSerif
        , serif
        , size
        , strike
        , typeface
        , underline
        , uppercase
        , weight
        , wordSpacing
        )

{-| Font Properties

Meant to be imported as:

    import Style.Font as Font


## Typefaces

@docs typeface, font, serif, sansSerif, cursive, fantasy, monospace, importUrl


## Properties

@docs size, lineHeight, letterSpacing, wordSpacing, alignLeft, alignRight, center, justify, justifyAll


## Font Styles

@docs uppercase, capitalize, lowercase, underline, strike, italic, bold, weight, light

-}

import Style exposing (Font, Property)
import Style.Internal.Model as Internal


{-| -}
typeface : List Font -> Property class variation
typeface families =
    Internal.FontFamily families


{-| -}
serif : Font
serif =
    Internal.Serif


{-| -}
sansSerif : Font
sansSerif =
    Internal.SansSerif


{-| -}
cursive : Font
cursive =
    Internal.Cursive


{-| -}
fantasy : Font
fantasy =
    Internal.Fantasy


{-| -}
monospace : Font
monospace =
    Internal.Monospace


{-| -}
font : String -> Font
font =
    Internal.FontName


{-| -}
importUrl : { url : String, name : String } -> Font
importUrl { url, name } =
    Internal.ImportFont name url


{-| Font size as `px`
-}
size : Float -> Property class variation
size size =
    Internal.Font "font-size" (toString size ++ "px")


{-| This is the only unitless value in the library that isn't `px`.

Given as a _proportion_ of the `Font.size`.

This means the final lineHeight in px is:

      Font.size * Font.lineHeight == lineHeightInPx

-}
lineHeight : Float -> Property class variation
lineHeight height =
    Internal.Font "line-height" (toString height)


{-| In `px`.
-}
letterSpacing : Float -> Property class variation
letterSpacing offset =
    Internal.Font "letter-spacing" (toString offset ++ "px")


{-| In `px`.
-}
wordSpacing : Float -> Property class variation
wordSpacing offset =
    Internal.Font "word-spacing" (toString offset ++ "px")


{-| Align the font to the left.
-}
alignLeft : Property class variation
alignLeft =
    Internal.Font "text-align" "left"


{-| Align the font to the right.
-}
alignRight : Property class variation
alignRight =
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
    Internal.Font "text-align" "justify-all"


{-| -}
underline : Property class variation
underline =
    Internal.Font "text-decoration" "underline"


{-| -}
strike : Property class variation
strike =
    Internal.Font "text-decoration" "line-through"


{-| -}
italic : Property class variation
italic =
    Internal.Font "font-style" "italic"


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
