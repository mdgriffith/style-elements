module Element.Font
    exposing
        ( Font
        , alignLeft
        , alignRight
        , bold
        , center
        , color
        , external
        , family
        , glow
        , italic
        , justify
        , letterSpacing
        , light
        , lineHeight
        , monospace
        , mouseOverColor
        , sansSerif
        , serif
        , shadow
        , size
        , strike
        , typeface
        , underline
        , weight
        , wordSpacing
        )

{-| _Note_

`Font.color`, `Font.size`, `Font.family`, and `Font.lineHeight` are all inherited, meaning you can set them at the top of your view and all subsequent nodes will have that value.


## Typefaces

@docs family, typeface, font, serif, sansSerif, monospace, importUrl


## Properties

@docs color, mouseOverColor, size, lineHeight, letterSpacing, wordSpacing, alignLeft, alignRight, center, justify


## Font Styles

@docs underline, strike, italic, bold, weight, light

-}

import Color exposing (Color)
import Internal.Model as Internal exposing (Attribute(..), Style(..))


{-| -}
type alias Font =
    Internal.Font


{-| -}
color : Color -> Attribute msg
color fontColor =
    StyleClass (Colored ("font-color-" ++ Internal.formatColorClass fontColor) "color" fontColor)


{-| -}
mouseOverColor : Color -> Attribute msg
mouseOverColor fontColor =
    Internal.hover (Colored ("hover-font-color-" ++ Internal.formatColorClass fontColor) "color" fontColor)


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
    let
        renderFontClassName font current =
            current
                ++ (case font of
                        Internal.Serif ->
                            "serif"

                        Internal.SansSerif ->
                            "sans-serif"

                        Internal.Monospace ->
                            "monospace"

                        Internal.Typeface name ->
                            name
                                |> String.toLower
                                |> String.words
                                |> String.join "-"

                        Internal.ImportFont name url ->
                            name
                                |> String.toLower
                                |> String.words
                                |> String.join "-"
                   )
    in
    StyleClass <| Internal.FontFamily (List.foldl renderFontClassName "font-" families) families


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


{-| Font size as `px`
-}
size : Int -> Attribute msg
size size =
    StyleClass (Single ("font-size-" ++ toString size) "font-size" (toString size ++ "px"))


{-| This is the only unitless value in the library that isn't `px`.

Given as a _proportion_ of the `Font.size`.

This means the final lineHeight in px is:

      Font.size * Font.lineHeight == lineHeightInPx

-}
lineHeight : Float -> Attribute msg
lineHeight =
    StyleClass << LineHeight


{-| In `px`.
-}
letterSpacing : Float -> Attribute msg
letterSpacing offset =
    StyleClass <|
        Single
            ("letter-spacing-" ++ Internal.floatClass offset)
            "letter-spacing"
            (toString offset ++ "px")


{-| In `px`.
-}
wordSpacing : Float -> Attribute msg
wordSpacing offset =
    StyleClass <|
        Single ("word-spacing-" ++ Internal.floatClass offset) "word-spacing" (toString offset ++ "px")


{-| -}
weight : Int -> Attribute msg
weight fontWeight =
    StyleClass <|
        Single ("font-weight-" ++ toString fontWeight) "word-spacing" (toString fontWeight ++ "px")


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


{-| Align font center.
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
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Internal.Attribute msg
shadow { offset, blur, color } =
    Internal.TextShadow
        { offset = offset
        , blur = blur
        , color = color
        }


{-| -}
glow : Color -> Float -> Internal.Attribute msg
glow color size =
    Internal.TextShadow
        { offset = ( 0, 0 )
        , blur = size * 2
        , color = color
        }
