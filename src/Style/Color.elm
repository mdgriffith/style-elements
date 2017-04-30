module Style.Color exposing (text, palette, decorations)

{-|



-}

import Style.Internal.Model as Internal
import Color exposing (Color)
import Style exposing (Property)


text : Color -> Property class variation animation
text =
    Internal.TextColor


palette : { background : Color, border : Color, text : Color } -> Property class variation animation
palette =
    Internal.Palette


decorations :
    { cursor : Maybe Color
    , decoration : Maybe Color
    , selection : Maybe Color
    }
    -> Property class variation animation
decorations =
    Internal.DecorationPalette
