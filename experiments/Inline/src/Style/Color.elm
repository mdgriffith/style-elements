module Style.Color exposing (background, border, cursor, text)

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
    SingletonStyle ("text-color-" ++ formatColorClass clr) "color" (formatColor clr)


{-| -}
background : Color -> Attribute msg
background clr =
    SingletonStyle ("bg-" ++ formatColorClass clr) "background-color" (formatColor clr)


{-| -}
border : Color -> Attribute msg
border clr =
    SingletonStyle ("border-color-" ++ formatColorClass clr) "color" (formatColor clr)


{-| -}
cursor : Color -> Attribute msg
cursor clr =
    SingletonStyle ("cursor-color-" ++ formatColorClass clr) "cursor-color" (formatColor clr)



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
