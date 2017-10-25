module Palette exposing (..)

{-| An experiment on making styles reusable by focusing on capturing values instead of style classes.

We want to captures values for:

    - font families/stacks
    - font sizes
    - color palette
    - spacing ++ padding scales

-}

import Color exposing (Color)


type alias Palette =
    { primary : Color
    , accent : Color
    , focus : Color
    , link : Color

    -- Where Scale would be the steps that are allowed for greyscale.
    , greyscale : Scale Color
    , backdrop : Color
    , mediumBackdrop : Color
    }



{- Naming schemes for color palettes

     - Color name/value
     - Purpose - primary, accent, etc  (though this is vague once you have a bunch of names)
     - Property Name (background, text, yadda yadda)


   Desired capabilities:

      Adjusting a color in one place
      The color's `value` isn't tied to it's name.  Meaning if your palette just a field named 'red' and you change the value to green, it should still make sense.
      Having the field name be `primary` avoids that.

      Certain color combinations work with each other.  Example would be black background with white text works.  The inverse is also true.  But you can't switch them.

      Can the palette capture hints/rules about what colors work together?

      The more nuanced version of this is enforcing/achieving contrast ratios.


   Crazy Ideas -

   We could require a color palette.  Meaning the palette would be provided at the top of the elements, and passed down as the elements are rendered.

   Values have to be taken from the palette.


   layout palette <|
       el
           [ Color.text .primary
           ]
           (text "hello!")


   You could specify manual values via always


   layout palette <|
       el
           [ Color.text (always Color.black)
           ]
           (text "hello!")


   A Palette could also be manually adjusted/reset


   layout palette <|
       row []
           [ el
               [ Color.text (always Color.black)
               ]
               (text "hello!")
           , repaint otherPalette <|
               el
                   [ Color.text .mySpecialPaletteName
                   ]
                   (text "hello!")
           ]

   Palettes would have to be captured at the type level.

-}
