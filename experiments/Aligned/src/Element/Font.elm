module Element.Font
    exposing
        ( Font
        , alignLeft
        , alignRight
        , bold
        , center
        , color
        , external
        , extraBold
        , extraLight
        , family
        , glow
        , hairline
        , heavy
        , italic
        , justify
        , letterSpacing
        , light
        , lineHeight
        , medium
        , monospace
        , regular
        , sansSerif
        , semiBold
        , serif
        , shadow
        , size
        , strike
        , typeface
        , underline
        , unitalicized
        , wordSpacing
        )

{-|


# Style your fonts!

    import Color exposing (blue)
    import Element
    import Element.Font as Font

    view =
        Element.el
            [ Font.color blue
            , Font.size 18
            , Font.lineHeight 1.3 -- line height is given as a ratio of Font.size.
            , Font.family
                [ Font.typeface "Open Sans"
                , Font.sansSerif
                ]
            ]
            (Element.text "Woohoo, I'm stylish text")

**Note**: `Font.color`, `Font.size`, `Font.family`, and `Font.lineHeight` are all inherited, meaning you can set them at the top of your view and all subsequent nodes will have that value.

@docs color, size, lineHeight


## Typefaces

@docs family, Font, typeface, serif, sansSerif, monospace

@docs external

`Font.external` can be used to import font files. Let's say you found a neat font on <http://fonts.google.com>:

    import Element
    import Element.Font as Font

    view =
        Element.el
            [ Font.family
                [ Font.external
                    { name = "Roboto"
                    , url = "https://fonts.googleapis.com/css?family=Roboto"
                    }
                , Font.sansSerif
                ]
            ]
            (Element.text "Woohoo, I'm stylish text")


## Alignment and Spacing

@docs alignLeft, alignRight, center, justify, letterSpacing, wordSpacing


## Font Styles

@docs underline, strike, italic, unitalicized


## Font Weight

@docs heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline


## Shadows

@docs glow, shadow

-}

import Color exposing (Color)
import Element exposing (Attr, Attribute)
import Internal.Model as Internal


{-| -}
type alias Font =
    Internal.Font


{-| -}
color : Color -> Attr decorative msg
color fontColor =
    Internal.StyleClass (Internal.Colored ("font-color-" ++ Internal.formatColorClass fontColor) "color" fontColor)


{-|

    import Element
    import Element.Font as Font

    myElement =
        Element.el
            [ Font.family
                [ Font.typeface "Helvetica"
                , Font.sansSerif
                ]
            ]
            (text "")

-}
family : List Font -> Attribute msg
family families =
    Internal.StyleClass <| Internal.FontFamily (List.foldl Internal.renderFontClassName "font-" families) families


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


{-| -}
external : { url : String, name : String } -> Font
external { url, name } =
    Internal.ImportFont name url


{-| Font sizes are always given as `px`.
-}
size : Int -> Attr decorative msg
size size =
    Internal.StyleClass (Internal.Single ("font-size-" ++ toString size) "font-size" (toString size ++ "px"))


{-| This is the only unitless value in the library that isn't `px`.

It's given as a _proportion_ of the `Font.size`.

This means the final lineHeight in px is:

      Font.size * Font.lineHeight == lineHeightInPx

-}
lineHeight : Float -> Attr decorative msg
lineHeight =
    Internal.StyleClass << Internal.LineHeight


{-| In `px`.
-}
letterSpacing : Float -> Attribute msg
letterSpacing offset =
    Internal.StyleClass <|
        Internal.Single
            ("letter-spacing-" ++ Internal.floatClass offset)
            "letter-spacing"
            (toString offset ++ "px")


{-| In `px`.
-}
wordSpacing : Float -> Attribute msg
wordSpacing offset =
    Internal.StyleClass <|
        Internal.Single ("word-spacing-" ++ Internal.floatClass offset) "word-spacing" (toString offset ++ "px")


{-| Align the font to the left.
-}
alignLeft : Attribute msg
alignLeft =
    Internal.class "text-left"


{-| Align the font to the right.
-}
alignRight : Attribute msg
alignRight =
    Internal.class "text-right"


{-| Center align the font.
-}
center : Attribute msg
center =
    Internal.class "text-center"


{-| -}
justify : Attribute msg
justify =
    Internal.class "text-justify"



-- {-| -}
-- justifyAll : Attribute msg
-- justifyAll =
--     Internal.class "text-justify-all"


{-| -}
underline : Attribute msg
underline =
    Internal.class "underline"


{-| -}
strike : Attribute msg
strike =
    Internal.class "strike"


{-| -}
italic : Attribute msg
italic =
    Internal.class "italic"


{-| -}
bold : Attribute msg
bold =
    Internal.class "bold"


{-| -}
light : Attribute msg
light =
    Internal.class "text-light"


{-| -}
hairline : Attribute msg
hairline =
    Internal.class "text-thin"


{-| -}
extraLight : Attribute msg
extraLight =
    Internal.class "text-extra-light"


{-| -}
regular : Attribute msg
regular =
    Internal.class "text-normal-weight"


{-| -}
semiBold : Attribute msg
semiBold =
    Internal.class "text-semi-bold"


{-| -}
medium : Attribute msg
medium =
    Internal.class "text-medium"


{-| -}
extraBold : Attribute msg
extraBold =
    Internal.class "text-extra-bold"


{-| -}
heavy : Attribute msg
heavy =
    Internal.class "text-heavy"


{-| This will reset bold and italic.
-}
unitalicized : Attribute msg
unitalicized =
    Internal.class "text-unitalicized"


{-| -}
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Attr decorative msg
shadow { offset, blur, color } =
    Internal.TextShadow
        { offset = offset
        , blur = blur
        , color = color
        }


{-| A glow is just a simplified shadow
-}
glow : Color -> Float -> Attr decorative msg
glow color size =
    Internal.TextShadow
        { offset = ( 0, 0 )
        , blur = size * 2
        , color = color
        }
