module Color
    exposing
        ( Color
          -- , Gradient
        , black
        , blue
        , brown
        , charcoal
          -- , complement
        , darkBlue
        , darkBrown
        , darkCharcoal
        , darkGray
        , darkGreen
        , darkGrey
        , darkOrange
        , darkPurple
        , darkRed
        , darkYellow
        , gray
          -- , grayscale
        , green
        , grey
          -- , greyscale
          -- , hsl
          -- , hsla
        , lightBlue
        , lightBrown
        , lightCharcoal
        , lightGray
        , lightGreen
        , lightGrey
        , lightOrange
        , lightPurple
        , lightRed
        , lightYellow
          -- , linear
        , orange
        , purple
          -- , radial
        , red
        , rgb
        , rgba
          -- , toHsl
          -- , toRgb
        , white
        , yellow
        )

{-| -}

import Style exposing (Color)


type alias Color =
    Style.Color


{-| Create RGB colors with an alpha component for transparency.
The alpha component is specified with numbers between 0 and 1.
-}
rgba : Int -> Int -> Int -> Float -> Color
rgba r g b a =
    Style.rgba
        (toFloat r / 255)
        (toFloat g / 255)
        (toFloat b / 255)
        a


{-| Create RGB colors from numbers between 0 and 255 inclusive.
-}
rgb : Int -> Int -> Int -> Color
rgb r g b =
    Style.rgb
        (toFloat r / 255)
        (toFloat g / 255)
        (toFloat b / 255)



-- {-| Extract the components of a color in the RGB format.
-- -}
-- toRgb : Color -> { red : Int, green : Int, blue : Int, alpha : Float }
-- toRgb color =
--     case color of
--         RGBA r g b a ->
--             { red = r, green = g, blue = b, alpha = a }
-- BUILT-IN COLORS


{-| -}
lightRed : Color
lightRed =
    rgba 239 41 41 1


{-| -}
red : Color
red =
    rgba 204 0 0 1


{-| -}
darkRed : Color
darkRed =
    rgba 164 0 0 1


{-| -}
lightOrange : Color
lightOrange =
    rgba 252 175 62 1


{-| -}
orange : Color
orange =
    rgba 245 121 0 1


{-| -}
darkOrange : Color
darkOrange =
    rgba 206 92 0 1


{-| -}
lightYellow : Color
lightYellow =
    rgba 255 233 79 1


{-| -}
yellow : Color
yellow =
    rgba 237 212 0 1


{-| -}
darkYellow : Color
darkYellow =
    rgba 196 160 0 1


{-| -}
lightGreen : Color
lightGreen =
    rgba 138 226 52 1


{-| -}
green : Color
green =
    rgba 115 210 22 1


{-| -}
darkGreen : Color
darkGreen =
    rgba 78 154 6 1


{-| -}
lightBlue : Color
lightBlue =
    rgba 114 159 207 1


{-| -}
blue : Color
blue =
    rgba 52 101 164 1


{-| -}
darkBlue : Color
darkBlue =
    rgba 32 74 135 1


{-| -}
lightPurple : Color
lightPurple =
    rgba 173 127 168 1


{-| -}
purple : Color
purple =
    rgba 117 80 123 1


{-| -}
darkPurple : Color
darkPurple =
    rgba 92 53 102 1


{-| -}
lightBrown : Color
lightBrown =
    rgba 233 185 110 1


{-| -}
brown : Color
brown =
    rgba 193 125 17 1


{-| -}
darkBrown : Color
darkBrown =
    rgba 143 89 2 1


{-| -}
black : Color
black =
    rgba 0 0 0 1


{-| -}
white : Color
white =
    rgba 255 255 255 1


{-| -}
lightGrey : Color
lightGrey =
    rgba 238 238 236 1


{-| -}
grey : Color
grey =
    rgba 211 215 207 1


{-| -}
darkGrey : Color
darkGrey =
    rgba 186 189 182 1


{-| -}
lightGray : Color
lightGray =
    rgba 238 238 236 1


{-| -}
gray : Color
gray =
    rgba 211 215 207 1


{-| -}
darkGray : Color
darkGray =
    rgba 186 189 182 1


{-| -}
lightCharcoal : Color
lightCharcoal =
    rgba 136 138 133 1


{-| -}
charcoal : Color
charcoal =
    rgba 85 87 83 1


{-| -}
darkCharcoal : Color
darkCharcoal =
    rgba 46 52 54 1
