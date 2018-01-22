module Element.Palette exposing (..)

{-| An exploration of palettes which could be used both:

  - To create a "design system"
  - As a means of enforced themeing
  - As a performance optimization by skipping the dynamic collection of styles.

-}

import Color exposing (Color)
import Internal.Model as Internal


{-


   A General example using Color.background


       type alias CustomPalette =
           { primary : Palette.Protected Color
           }

       makeMyPalette : Palette CustomPalette
       makeMyPalette =
           Palette.colors CustomPalette
               |> Palette.color purple







    And in View code

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



    Creating a fontsize Palette

        For a given size, we should be able to specify the literal pixel size. We could also specify a scaling function based on window size.

        Simple approach

        Palette.scale (0, 20) <|
            (\i ->
                i
                    -- scales the font modularly
                    |> Scale.modular 1.3
                    -- scales the result based on the window width
                    -- where window.width 1200 is 1.0, on a slope of 1.3
                    |> Scale.linear 1.3 1200 window.width
            )




        fontSizes : Palette CustomPalette
        fontSizes =
           Palette.colors CustomPalette
               |> Palette.color purple



      Values to start with

      * Colors -> renders as backgorund, text, and border colors
      * FontSizes ->
          (no reason these should be dynamic)  They can scale globally based on window size or something if needbe, using linear scaling!
      * FontFamilies ->
          (no reason these should be dynamic)
      * Border Sizes
      * Border Radius
      * Spacing/Padding

-}


type InternalAttribute color fonts msg
    = InternalAttribute color fonts msg


type InternalElement color msg
    = Element msg



-- type Attribute color msg
--     = ColorStyle color


{-| Concrete Values
-}
type alias Attr msg =
    InternalAttribute Color (List Internal.Font) msg


{-| Palette based attributes
-}
type alias Attribute colors fonts msg =
    InternalAttribute (colors -> Protected Color) (fonts -> Protected Internal.Font) msg


{-| A way of protecting values so that the user can't construct them.
-}
type Protected thing
    = Protected thing
    | Dynamic thing


dynamic : Color -> Colors colors -> Protected Color
dynamic value palette =
    Dynamic value


type Palette colors fonts
    = Palette
        { colors : Colors colors
        , fontSizes : Scale
        , fontFamilies : Fonts fonts
        , spacing : Scale
        }


type Scale
    = Linear Int
    | Modular
        { base : Int
        , factor : Float
        }


type Colors a
    = Colors
        { protected : a
        , values : List Color
        }


colors : a -> Colors a
colors a =
    Colors
        { protected = a
        , values = []
        }


color : Color -> Colors (Protected Color -> a) -> Colors a
color color pal =
    let
        addColor p =
            { protected = p.protected (Protected color)
            , values = color :: p.values
            }
    in
    map addColor pal


map : ({ protected : a, values : List Color } -> { protected : a1, values : List Color }) -> Colors a -> Colors a1
map fn pal =
    case pal of
        Colors a ->
            Colors (fn a)


type Fonts a
    = Fonts
        { protected : a
        , values : List FontFamily
        }


type FontFamily
    = FontFamily (List Internal.Font)


fonts : a -> Fonts a
fonts a =
    Fonts
        { protected = a
        , values = []
        }


family : FontFamily -> Fonts (Protected FontFamily -> a) -> Fonts a
family fam pal =
    let
        addFontFamily p =
            { protected = p.protected (Protected fam)
            , values = fam :: p.values
            }
    in
    mapFont addFontFamily pal


mapFont : ({ protected : a, values : List FontFamily } -> { protected : a1, values : List FontFamily }) -> Fonts a -> Fonts a1
mapFont fn pal =
    case pal of
        Fonts a ->
            Fonts (fn a)



-- type Scale a
--     = Scale
--         { protected : a
--         , values : List Int
--         }
-- type Scale2 a
--     = Scale2
--         { range : a
--         , values : List Int
--         }
-- scale : a -> Scale a
-- scale a =
--     Scale
--         { protected = a
--         , values = []
--         }
-- int : Int -> Scale (Protected Int -> a) -> Scale a
-- int i pal =
--     let
--         addInt p =
--             { protected = p.protected (Protected i)
--             , values = i :: p.values
--             }
--     in
--     mapScale addInt pal
-- range : Int -> Int -> Scale (Protected Int -> a) -> Scale a
-- range i j pal =
--     let
--         addInt val scale =
--             mapScale
--                 (\sc ->
--                     { protected = sc.protected (Protected val)
--                     , values = val :: sc.values
--                     }
--                 )
--                 scale
--     in
--     List.foldl addInt pal (List.range i j)
-- mapScale : ({ protected : a, values : List Int } -> { protected : a1, values : List Int }) -> Scale a -> Scale a1
-- mapScale fn pal =
--     case pal of
--         Scale a ->
--             Scale (fn a)
