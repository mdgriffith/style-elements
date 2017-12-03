module Element.Color exposing (background, border, cursor, text)

{-| Set Colors for your style.

Meant to be imported as

    import Style.Color as Color

@docs text, background, border, cursor

-}

import Color exposing (Color)
import Internal.Model exposing (..)


{-| -}
text : Color -> Attribute msg
text clr =
    StyleClass (Colored ("text-color-" ++ formatColorClass clr) "color" clr)


{-| -}
background : Color -> Attribute msg
background clr =
    StyleClass (Colored ("bg-" ++ formatColorClass clr) "background-color" clr)


{-| -}
border : Color -> Attribute msg
border clr =
    StyleClass (Colored ("border-color-" ++ formatColorClass clr) "border-color" clr)


{-| -}
cursor : Color -> Attribute msg
cursor clr =
    StyleClass (Colored ("cursor-color-" ++ formatColorClass clr) "cursor-color" clr)



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
