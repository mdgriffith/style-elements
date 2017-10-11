module Style.Filter exposing (blur, brightness, contrast, grayscale, hueRotate, invert, opacity, saturate, sepia, url)

{-| Filters that can be applied to an element.

If multiple filters are given, they will stack.

    import Style.Filter as Filter
    import Style exposing (..)

    style MyFitleredStyle
        [ Filter.blur 0.5
        , Filter.invert 0.5
        ]

@docs url, blur, brightness, contrast, grayscale, hueRotate, invert, opacity, saturate, sepia

-}

import Style exposing (Property)
import Style.Internal.Model as Internal


{-| -}
url : String -> Property class variation
url s =
    Internal.Filters [ Internal.FilterUrl s ]


{-| -}
blur : Float -> Property class variation
blur x =
    Internal.Filters [ Internal.Blur x ]


{-| -}
brightness : Float -> Property class variation
brightness x =
    Internal.Filters [ Internal.Brightness x ]


{-| -}
contrast : Float -> Property class variation
contrast x =
    Internal.Filters [ Internal.Contrast x ]


{-| -}
grayscale : Float -> Property class variation
grayscale x =
    Internal.Filters [ Internal.Grayscale x ]


{-| -}
hueRotate : Float -> Property class variation
hueRotate x =
    Internal.Filters [ Internal.HueRotate x ]


{-| -}
invert : Float -> Property class variation
invert x =
    Internal.Filters [ Internal.Invert x ]


{-| -}
opacity : Float -> Property class variation
opacity x =
    Internal.Filters [ Internal.OpacityFilter x ]


{-| -}
saturate : Float -> Property class variation
saturate x =
    Internal.Filters [ Internal.Saturate x ]


{-| -}
sepia : Float -> Property class variation
sepia x =
    Internal.Filters [ Internal.Sepia x ]
