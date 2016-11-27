module Style.Color exposing (..)

{-|
-}

import Color exposing (Color)
import Color.Mixing


type alias Palette =
    { dark : Color
    , normal : Color
    , light : Color
    }


type alias LargePalette =
    { darkest : Color
    , darker : Color
    , dark : Color
    , normal : Color
    , light : Color
    , lighter : Color
    , lightest : Color
    }


{-| -}
palette : Color -> Palette
palette color =
    { dark = Color.Mixing.darken 0.1 color
    , normal = color
    , light = Color.Mixing.lighten 0.1 color
    }


{-| -}
largePalette : Color -> LargePalette
largePalette color =
    { darkest = Color.Mixing.darken 0.4 color
    , darker = Color.Mixing.darken 0.2 color
    , dark = Color.Mixing.darken 0.1 color
    , normal = color
    , light = Color.Mixing.lighten 0.1 color
    , lighter = Color.Mixing.lighten 0.2 color
    , lightest = Color.Mixing.lighten 0.4 color
    }
