module Style.Filter exposing (..)

{-| -}

import Style.Internal.Model as Internal
import Style exposing (Filter)


url : String -> Filter -> Filter
url s filt =
    (Internal.FilterUrl s) :: filt


{-| -}
blur : Float -> Filter -> Filter
blur x filt =
    (Internal.Blur x) :: filt


{-| -}
brightness : Float -> Filter -> Filter
brightness x filt =
    (Internal.Brightness x) :: filt


{-| -}
contrast : Float -> Filter -> Filter
contrast x filt =
    (Internal.Contrast x) :: filt


{-| -}
grayscale : Float -> Filter -> Filter
grayscale x filt =
    (Internal.Grayscale x) :: filt


{-| -}
hueRotate : Float -> Filter -> Filter
hueRotate x filt =
    (Internal.HueRotate x) :: filt


{-| -}
invert : Float -> Filter -> Filter
invert x filt =
    (Internal.Invert x) :: filt


{-| -}
opacityFilter : Float -> Filter -> Filter
opacityFilter x filt =
    (Internal.Opacity x) :: filt


{-| -}
saturate : Float -> Filter -> Filter
saturate x filt =
    (Internal.Saturate x) :: filt


{-| -}
sepia : Float -> Filter -> Filter
sepia x filt =
    (Internal.Sepia x) :: filt
