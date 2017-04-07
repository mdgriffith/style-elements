module Style.Color exposing (..)

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
            [ Colors.from primary
                |^ Color.text emphasis
                |- Color.border transparent
            ]

-- modify external Palette


-}

import Style.Internal.Model as Internal exposing (Property)
import Color exposing (Color)


type Palette
    = Palette
        { text : Color
        , background : Color
        , border : Color
        }



--from : Palette -> (Palette -> Palette)
--from
--from : Palette -> Property animation variation msg -> Property animation variation msg
--from box border =
--    Internal.addProperty Internal.Border "border-width" (Render.box box) border


invisible : Color
invisible color =
    let
        { red, green, blue } =
            Color.toRgb color
    in
        Color.rgba red green blue 0.0


{-| -}
transparent : Palette
transparent =
    Palette
        { text = invisible Color.black
        , background = invisible Color.white
        , border = invisible Color.white
        }


{-| Replace the text color with the text color from another palette
-}
text : Palette -> Palette -> Palette
text (Palette { text }) (Palette palette) =
    Palette
        { palette | text = text }


{-| Replace the background color with the background color from another palette
-}
background : Palette -> Palette -> Palette
background (Palette { background }) (Palette palette) =
    Palette
        { palette | background = background }


{-| Replace the border color with the border color from another palette
-}
border : Palette -> Palette -> Palette
border (Palette { border }) (Palette palette) =
    Palette
        { palette | border = border }
