module Style.Palette exposing (..)

{-|

All CSS Properties that relate to color

 * text
 * background
 * shadow
 * border
 * [border-block-end-color](https://developer.mozilla.org/en-US/docs/Web/CSS/border-block-end-color) - This is the border color that changes position based on writing-mode, direction, and text-orientation.
 * border-inline-start-color - Oh boy, I have no idea
 * caret-color - Cursor color
 * [column-rule-color](https://developer.mozilla.org/en-US/docs/Web/CSS/column-rule-color) -
 * outline-color - color of outline, outside of border
 * text-decoration-color: color of underlines, strikes, and overlines
 * text-emphasis-color:

## Example Usage


-- External Palette
   class LargerStyle
            [ palette
                [ Color.text emphasis
                , Color.border transparent
                ]
            ]


-}

import Style.Internal.Model as Internal exposing (Property)
import Color exposing (Color)
import Style exposing (ColorElement)


{-| -}
text : Color -> ColorElement
text color =
    Internal.ColorElement "color" color


{-| -}
border : Color -> ColorElement
border color =
    Internal.ColorElement "border-color" color


{-| -}
background : Color -> ColorElement
background color =
    Internal.ColorElement "background-color" color


{-| -}
decoration : Color -> ColorElement
decoration color =
    Internal.ColorElement "text-decoration-color" color


{-| -}
caret : Color -> ColorElement
caret color =
    Internal.ColorElement "caret-color" color



-- Needs to add the color to an existing selection pseudo element
-- {-| -}
-- selection : Color -> ColorElement
-- selection color =
--     Internal.ColorElement "caret-color" color
