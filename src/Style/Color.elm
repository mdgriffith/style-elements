module Style.Color exposing (text, background, border, cursor, decoration, selection)

{-| -}

import Style.Internal.Model as Internal
import Color exposing (Color)
import Style exposing (Property)
import Style.Internal.Render.Value as Value


{-| -}
text : Color -> Property class variation animation
text =
    Internal.TextColor


{-| -}
background : Color -> Property class variation animation
background clr =
    Internal.Exact "background-color" (Value.color clr)


{-| -}
border : Color -> Property class variation animation
border clr =
    Internal.Exact "border-color" (Value.color clr)


{-| -}
cursor : Color -> Property class variation animation
cursor clr =
    Internal.Exact "cursor-color" (Value.color clr)


{-| -}
decoration : Color -> Property class variation animation
decoration clr =
    Internal.Exact "text-decoration-color" (Value.color clr)


{-| -}
selection : Color -> Property class variation animation
selection clr =
    Internal.Exact "text-decoration-color" (Value.color clr)
