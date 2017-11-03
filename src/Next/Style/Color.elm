module Next.Style.Color exposing (background, border, cursor, text)

{-| Set Colors for your style.

Meant to be imported as

    import Style.Color as Color

@docs text, background, border, cursor

-}

import Color exposing (Color)
import Next.Internal.Model exposing (..)


{-| -}
text : Color -> Attribute msg
text clr =
    StyleProperty "color" (formatColor clr)



-- Single ("c-" ++ toString clr.red ++ "-" ++ toString clr.red ++ "-" ++ toString clr.red ++ "-" ++ toString clr.alpha)
-- "color"
-- (formatColor clr)


{-| -}
background : Color -> Attribute msg
background clr =
    StyleProperty "background-color" (formatColor clr)


{-| -}
border : Color -> Attribute msg
border clr =
    StyleProperty "border-color" (formatColor clr)


{-| -}
cursor : Color -> Attribute msg
cursor clr =
    StyleProperty "cursor-color" (formatColor clr)



-- {-| Text decoration color.
-- -}
-- decoration : Color -> Property
-- decoration clr =
--     Internal.Exact "text-decoration-color" (formatColor clr)
-- {-| -}
-- selection : Color -> Property
-- selection clr =
--     Internal.SelectionColor clr
-- {-| The color of the input `placeholder` element.
-- -}
-- placeholder : Color -> Property
-- placeholder clr =
--     Internal.PseudoElement "::placeholder"
--         [ Internal.TextColor clr
--         , Internal.Exact "opacity" "1"
--         ]
