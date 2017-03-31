module Style.Transform exposing (..)

{-|
-}

import Style exposing (Transform)
import Style.Internal.Model as Internal


{-| Units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.
-}
rotate : Float -> Float -> Float -> Transform -> Transform
rotate x y z transforms =
    (Internal.Rotate x y z) :: transforms


{-| Units are always as pixels
-}
translate : Float -> Float -> Float -> Transform -> Transform
translate x y z transforms =
    (Internal.Translate x y z) :: transforms


{-| -}
scale : Float -> Float -> Float -> Transform -> Transform
scale x y z transforms =
    (Internal.Scale x y z) :: transforms
