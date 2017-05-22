module Style
    exposing
        ( Style
        , Property
        , Shadow
        , Filter
        , style
        , variation
        , prop
        , cursor
        , shadows
        , paddingHint
        , filters
        , origin
        , translate
        , rotate
        , rotateAround
        , scale
        , hover
        , checked
        , focus
        , pseudo
        , rounded
        , roundTopLeft
        , roundTopRight
        , roundBottomRight
        , roundBottomLeft
        )

{-|


# Welcome to the Style Elements Library!

@docs Style, style, variation, Property, prop

@docs cursor, paddingHint

@docs Shadow, shadows

@docs Filter, filters

@docs origin, translate, rotate, rotateAround, scale

@docs hover, checked, focus, pseudo

@docs rounded, roundTopLeft, roundTopRight, roundBottomRight, roundBottomLeft

-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Value
import Style.Internal.Batchable as Batchable exposing (Batchable)


{-| -}
type alias Style class variation animation =
    Batchable (Internal.Style class variation animation)


{-| -}
type alias Property class variation animation =
    Internal.Property class variation animation


{-| -}
type alias Length =
    Internal.Length


{-| -}
type alias Transform =
    Internal.Transformation


{-| -}
style : class -> List (Property class variation animation) -> Style class variation animation
style cls props =
    Batchable.one (Internal.Style cls (prop "border-style" "solid" :: props))


{-| -}
variation : variation -> List (Property class Never animation) -> Property class variation animation
variation variation props =
    Internal.Variation variation props


{-| -}
prop : String -> String -> Property class variation animation
prop name val =
    Internal.Exact name val


{-| -}
cursor : String -> Property class variation animation
cursor name =
    Internal.Exact "cursor" name


{-| You can give a hint about what the padding should be for this element, but the layout can override it.
-}
paddingHint : Float -> Property class variation animation
paddingHint x =
    Internal.Exact "padding" (toString x ++ "px")


{-| -}
paddingLeftHint : Float -> Property class variation animation
paddingLeftHint x =
    Internal.Exact "padding-left" (toString x ++ "px")


{-| -}
paddingRightHint : Float -> Property class variation animation
paddingRightHint x =
    Internal.Exact "padding-right" (toString x ++ "px")


{-| -}
paddingTopHint : Float -> Property class variation animation
paddingTopHint x =
    Internal.Exact "padding-top" (toString x ++ "px")


{-| -}
paddingBottomHint : Float -> Property class variation animation
paddingBottomHint x =
    Internal.Exact "padding-bottom" (toString x ++ "px")


{-| -}
type alias Shadow =
    Internal.ShadowModel


{-| -}
shadows : List Shadow -> Property class variation animation
shadows shades =
    Internal.Shadows shades



-- {-| -}
-- transforms : List Transform -> Property class variation animation
-- transforms ts =
--     Internal.Transform ts


{-| -}
type alias Filter =
    Internal.Filter


{-| -}
filters : List Filter -> Property class variation animation
filters fs =
    Internal.Filters fs


{-| Always rendered as px
-}
origin : Float -> Float -> Float -> Property class variation animation
origin x y z =
    Internal.Exact "transform-origin" (toString x ++ "px  " ++ toString y ++ "px " ++ toString z ++ "px")


{-| Units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.

-}
rotate : Float -> Property class variation animation
rotate a =
    Internal.Transform <| [ Internal.Rotate a ]


{-| Units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.

-}
rotateAround : ( Float, Float, Float ) -> Float -> Property class variation animation
rotateAround ( x, y, z ) angle =
    Internal.Transform <| [ Internal.RotateAround x y z angle ]


{-| Units are always as pixels
-}
translate : Float -> Float -> Float -> Property class variation animation
translate x y z =
    Internal.Transform <| [ Internal.Translate x y z ]


{-| -}
scale : Float -> Float -> Float -> Property class variation animation
scale x y z =
    Internal.Transform <| [ Internal.Scale x y z ]


{-| Round the corners. Sets `border-radius`.
-}
rounded : Float -> Property class variation animation
rounded box =
    Internal.Exact "border-radius" (toString box ++ "px")


{-| -}
roundTopLeft : Float -> Property class variation animation
roundTopLeft x =
    Internal.Exact "border-top-left-radius" (toString x ++ "px")


{-| -}
roundTopRight : Float -> Property class variation animation
roundTopRight x =
    Internal.Exact "border-top-right-radius" (toString x ++ "px")


{-| -}
roundBottomRight : Float -> Property class variation animation
roundBottomRight x =
    Internal.Exact "border-bottom-right-radius" (toString x ++ "px")


{-| -}
roundBottomLeft : Float -> Property class variation animation
roundBottomLeft x =
    Internal.Exact "border-bottom-left-radius" (toString x ++ "px")


{-| -}
hover :
    List (Property class variation animation)
    -> Property class variation animation
hover props =
    Internal.PseudoElement ":hover" props


{-| -}
focus :
    List (Property class variation animation)
    -> Property class variation animation
focus props =
    Internal.PseudoElement ":focus" props


{-| -}
checked :
    List (Property class variation animation)
    -> Property class variation animation
checked props =
    Internal.PseudoElement ":checked" props


{-| -}
pseudo :
    String
    -> List (Property class variation animation)
    -> Property class variation animation
pseudo psu props =
    Internal.PseudoElement (":" ++ psu) props
