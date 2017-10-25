module Next.Style.Font
    exposing
        ( alignLeft
        , alignRight
        , bold
        , center
        , family
          -- , importUrl
        , italic
        , justify
        , justifyAll
        , letterSpacing
        , light
        , lineHeight
        , monospace
        , sansSerif
        , serif
        , size
        , strike
        , typeface
        , underline
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

import Next.Internal.Model as Internal exposing (Attribute, Font, Property)


{-| -}
family : List Font -> Attribute msg
family families =
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
monospace : Font
monospace =
    Internal.Monospace


{-| -}
typeface : String -> Font
typeface =
    Internal.Typeface



-- {-| -}
-- importUrl : { url : String, name : String } -> Font
-- importUrl { url, name } =
--     Internal.ImportFont name url


{-| Font size as `px`
-}
size : Float -> Attribute msg
size size =
    Internal.StyleProperty "font-size" (toString size ++ "px")


{-| This is the only unitless value in the library that isn't `px`.

Given as a _proportion_ of the `Font.size`.

This means the final lineHeight in px is:

      Font.size * Font.lineHeight == lineHeightInPx

-}
lineHeight : Float -> Attribute msg
lineHeight height =
    Internal.StyleProperty "line-height" (toString height)


{-| In `px`.
-}
letterSpacing : Float -> Attribute msg
letterSpacing offset =
    Internal.StyleProperty "letter-spacing" (toString offset ++ "px")


{-| In `px`.
-}
wordSpacing : Float -> Attribute msg
wordSpacing offset =
    Internal.StyleProperty "word-spacing" (toString offset ++ "px")


{-| Align the font to the left.
-}
alignLeft : Attribute msg
alignLeft =
    Internal.StyleProperty "text-align" "left"


{-| Align the font to the right.
-}
alignRight : Attribute msg
alignRight =
    Internal.StyleProperty "text-align" "right"


{-| Align font center.
-}
center : Attribute msg
center =
    Internal.StyleProperty "text-align" "center"


{-| -}
justify : Attribute msg
justify =
    Internal.StyleProperty "text-align" "justify"


{-| -}
justifyAll : Attribute msg
justifyAll =
    Internal.StyleProperty "text-align" "justify-all"


{-| -}
underline : Attribute msg
underline =
    Internal.StyleProperty "text-decoration" "underline"


{-| -}
strike : Attribute msg
strike =
    Internal.StyleProperty "text-decoration" "line-through"


{-| -}
italic : Attribute msg
italic =
    Internal.StyleProperty "font-style" "italic"


{-| -}
bold : Attribute msg
bold =
    Internal.StyleProperty "font-weight" "700"


{-| -}
light : Attribute msg
light =
    Internal.StyleProperty "font-weight" "300"


{-| -}
weight : Int -> Attribute msg
weight fontWeight =
    Internal.StyleProperty "font-weight" (toString fontWeight)
