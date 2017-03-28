module Style.Color exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property)
import Color exposing (Color)


type Palette
    = Palette
        { text : Color
        , background : Color
        , border : Color
        }



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
