module Next.Style.Color exposing (background, border, cursor, text)

{-| Set Colors for your style.

Meant to be imported as

    import Style.Color as Color

@docs text, background, border, cursor

-}

import Color exposing (Color)
import Next.Internal.Model exposing (..)
import Next.Internal.Value as Value


{-| -}
text : Color -> Attribute msg
text clr =
    StyleProperty "color" (Value.color clr)


{-| -}
background : Color -> Attribute msg
background clr =
    StyleProperty "background-color" (Value.color clr)


{-| -}
border : Color -> Attribute msg
border clr =
    StyleProperty "border-color" (Value.color clr)


{-| -}
cursor : Color -> Attribute msg
cursor clr =
    StyleProperty "cursor-color" (Value.color clr)



-- {-| Text decoration color.
-- -}
-- decoration : Color -> Property
-- decoration clr =
--     Internal.Exact "text-decoration-color" (Value.color clr)
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
