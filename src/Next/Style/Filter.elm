module Next.Style.Filter exposing (blur, brightness, contrast, grayscale, hueRotate, invert, opacity, saturate, sepia, url)

{-| Filters that can be applied to an element.

If multiple filters are given, they will stack.

@docs url, blur, brightness, contrast, grayscale, hueRotate, invert, opacity, saturate, sepia

-}

import Next.Internal.Model exposing (..)


{-| -}
url : String -> Attribute msg
url s =
    Filter (FilterUrl s)


{-| -}
blur : Float -> Attribute msg
blur x =
    Filter (Blur x)


{-| -}
brightness : Float -> Attribute msg
brightness x =
    Filter (Brightness x)


{-| -}
contrast : Float -> Attribute msg
contrast x =
    Filter (Contrast x)


{-| -}
grayscale : Float -> Attribute msg
grayscale x =
    Filter (Grayscale x)


{-| -}
hueRotate : Float -> Attribute msg
hueRotate x =
    Filter (HueRotate x)


{-| -}
invert : Float -> Attribute msg
invert x =
    Filter (Invert x)


{-| -}
opacity : Float -> Attribute msg
opacity x =
    Filter (OpacityFilter x)


{-| -}
saturate : Float -> Attribute msg
saturate x =
    Filter (Saturate x)


{-| -}
sepia : Float -> Attribute msg
sepia x =
    Filter (Sepia x)
