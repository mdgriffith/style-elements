module Element.Palette exposing (..)

{-| An exploration of palettes which could be used both:

  - To create a "design system"
  - As a means of enforced themeing
  - As a performance optimization by skipping the dynamic collection of styles.

-}

import Color exposing (Color)
import Html exposing (Html)


{- A General example using Color.background



   -- pulling a value from the palette
   el
       [ Color.background .primary
       ]
       (text "I'm styled")

   -- specifying a dynamic value
   el
       [ Color.background (dynamic blue)
       ]
       (text "I'm styled")



   -- If the type signature is different, this should be possile
   -- this would be the default
   el
       [ Color.background blue
       ]
       (text "I'm styled")


-}


type Element color msg
    = Element msg


{-| A way of protecting values so that the user can't construct them.
-}
type Protected thing
    = Protected thing
    | Dynamic thing


dynamic : a -> b -> Protected a
dynamic value palette =
    Dynamic value



-- repaint : Palette -> Element color msg -> Element color msg
-- repaint palette el =
--     el


type Palette colors
    = Palette
        { colors : colors

        -- , colorName : colors -> Protected Color
        , rendered : String
        }


type SpacingPalette
    = SpacingPalette (List Int)


type alias ColorPalette =
    { primary : Protected Color }


formatColor : Color -> String
formatColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    ("rgba(" ++ toString red)
        ++ ("," ++ toString green)
        ++ ("," ++ toString blue)
        ++ ("," ++ toString alpha ++ ")")



-- myPalette : Palette { primary : Color }
-- myPalette =
--     Palette
--         { colors =
--             { primary = Color.blue
--             , secondary = Color.red
--             }
--         , renderColors =
--             \colors ->
--                 formatColor colors.primary
--                     ++ formatColor colors.secondary
--         }


colorsPalette =
    { primary = Color.blue
    , secondary = Color.red
    }


makePalette : a -> (a -> List Color) -> Palette a
makePalette colors get =
    Palette
        { colors =
            colors
        , rendered =
            get colors
                |> List.foldr (\color acc -> formatColor color ++ acc) ""
        }


layout : Palette color -> Element color msg -> Html msg
layout palette el =
    Html.div []
        [ Html.node "style" [] [ Html.text <| paletteToStyle palette ]
        , renderEl palette el
        ]


paletteToStyle : Palette color -> String
paletteToStyle (Palette { colors, rendered }) =
    rendered


renderEl palette el =
    Html.text ""



{-





-}


type Attribute color msg
    = ColorStyle color


{-| Concrete Values
-}
type alias Attr msg =
    Attribute Color msg


{-| Palette based attributes
-}
type alias PaletteAttribute msg =
    Attribute (ColorPalette -> Protected Color) msg


background : color -> Attribute color msg
background =
    ColorStyle


concrete : Attr msg
concrete =
    background Color.blue


fromPalette : PaletteAttribute msg
fromPalette =
    background .primary


overrideWithDynamic : PaletteAttribute msg
overrideWithDynamic =
    background (dynamic Color.blue)
