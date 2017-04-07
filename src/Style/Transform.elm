module Style.Transform exposing (rotate, translate, scale)

{-|

@docs rotate, translate, scale

-}

import Style exposing (Transform)
import Style.Internal.Model as Internal


{-| Units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.
-}
rotate : Float -> Float -> Float -> Transform
rotate x y z =
    Internal.Rotate x y z


{-| Units are always as pixels
-}
translate : Float -> Float -> Float -> Transform
translate x y z =
    Internal.Translate x y z


{-| -}
scale : Float -> Float -> Float -> Transform
scale x y z =
    Internal.Scale x y z
