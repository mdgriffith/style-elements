module Element.Palette exposing (..)

{-| An exploration of palettes which could be used both:

  - To create a "design system"
  - As a means of enforced themeing
  - As a performance optimization by skipping the dynamic collection of styles.

-}

import Color exposing (Color)


{-| -}
type Element palette msg
    = Element


{-| A way of protecting values so that the user can't construct them.
-}
type Protected thing
    = Protected thing
    | Dynamic thing



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


repaint : Palette -> Element color msg -> Element color msg
repaint palette el =
    el


type Attribute color msg
    = ColorStyle color


type Palette
    = Palette
        { colors : ColorPalette
        , spacing : SpacingPalette
        }


type SpacingPalette
    = SpacingPalette


type alias Attr msg =
    Attribute Color msg


type alias PaletteAttribute msg =
    Attribute (ColorPalette -> Protected Color) msg


type alias ColorPalette =
    { primary : Protected Color }


dynamic : a -> b -> Protected a
dynamic value palette =
    Dynamic value


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
