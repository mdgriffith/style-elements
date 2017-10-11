module Style.Color exposing (background, border, cursor, decoration, placeholder, selection, text)

{-| Set Colors for your style.

Meant to be imported as

    import Style.Color as Color

@docs text, background, border, cursor, decoration, selection, placeholder

-}

import Color exposing (Color)
import Style exposing (Property)
import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Value


{-| -}
text : Color -> Property class variation
text =
    Internal.TextColor


{-| -}
background : Color -> Property class variation
background clr =
    Internal.Exact "background-color" (Value.color clr)


{-| -}
border : Color -> Property class variation
border clr =
    Internal.Exact "border-color" (Value.color clr)


{-| -}
cursor : Color -> Property class variation
cursor clr =
    Internal.Exact "cursor-color" (Value.color clr)


{-| Text decoration color.
-}
decoration : Color -> Property class variation
decoration clr =
    Internal.Exact "text-decoration-color" (Value.color clr)


{-| -}
selection : Color -> Property class variation
selection clr =
    Internal.SelectionColor clr


{-| The color of the input `placeholder` element.
-}
placeholder : Color -> Property class variation
placeholder clr =
    Internal.PseudoElement "::placeholder"
        [ Internal.TextColor clr
        , Internal.Exact "opacity" "1"
        ]
