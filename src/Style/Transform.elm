module Style.Transform exposing (origin, rotate, translate, scale)

{-|

@docs origin

@docs rotate, translate, scale

-}

import Style exposing (Transform)
import Style.Internal.Model as Internal


{-| Always rendered as px
-}
origin : Float -> Float -> Float -> Transform
origin x y z =
    Internal.Origin x y z


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
