module Style
    exposing
        ( Style
        , Property
        , Shadow
        , Filter
        , Edges
        , Corners
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
        , all
        , left
        , right
        , top
        , bottom
        , topBottom
        , leftRight
        , leftRightAndTopBottom
        , leftRightTopBottom
        , allButTop
        , allButLeft
        , allButRight
        , allButBottom
        , topLeft
        , topRight
        , bottomLeft
        , bottomRight
        )

{-|


# Welcome to the Style Elements Library!

@docs Style, style, variation, Property, prop

@docs cursor, paddingHint

@docs Shadow, shadows

@docs Filter, filters

@docs origin, translate, rotate, rotateAround, scale

@docs hover, checked, focus, pseudo

@docs all, Edges, top, left, right, bottom, leftRight, topBottom, leftRightAndTopBottom, leftRightTopBottom, allButTop, allButLeft, allButRight, allButBottom

@docs Corners, topLeft, topRight, bottomRight, bottomLeft

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
paddingHint : ( Float, Float, Float, Float ) -> Property class variation animation
paddingHint pad =
    Internal.Box <| [ Internal.BoxProp "padding" (Value.box pad) ]


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


{-| A tuple of four floats to define any property with edges, such as:

  - `padding`
  - `spacing`
  - `Border.width`

`(top, right, bottom, left)`

-}
type alias Edges =
    ( Float, Float, Float, Float )


{-| Can be used for any property that takes `Edges` or `Corners`.
-}
all : Float -> ( Float, Float, Float, Float )
all x =
    ( x, x, x, x )


{-| -}
top : Float -> Edges
top x =
    ( x, 0, 0, 0 )


{-| -}
right : Float -> Edges
right x =
    ( 0, x, 0, 0 )


{-| -}
bottom : Float -> Edges
bottom x =
    ( 0, 0, x, 0 )


{-| -}
left : Float -> Edges
left x =
    ( 0, 0, 0, x )


{-| -}
topBottom : Float -> Edges
topBottom x =
    ( x, 0, x, 0 )


{-| -}
leftRight : Float -> Edges
leftRight x =
    ( 0, x, 0, x )


{-| -}
leftRightAndTopBottom : Float -> Float -> Edges
leftRightAndTopBottom x y =
    ( y, x, y, x )


{-| -}
leftRightTopBottom : Float -> Float -> Float -> Float -> Edges
leftRightTopBottom l r t b =
    ( t, r, b, l )


{-| -}
allButRight : Float -> Edges
allButRight x =
    ( x, 0, x, x )


{-| -}
allButLeft : Float -> Edges
allButLeft x =
    ( x, x, x, 0 )


{-| -}
allButTop : Float -> Edges
allButTop x =
    ( 0, x, x, x )


{-| -}
allButBottom : Float -> Edges
allButBottom x =
    ( x, x, 0, x )


{-| This is used to define border-radius.

It's still a four Float tuple like `Edges`, but the numbers are semantically different.

`(topLeft, topRight, bottomRight, bottomLeft)`

The function `all` works for both Corners and Edges.

-}
type alias Corners =
    ( Float, Float, Float, Float )


{-| -}
topLeft : Float -> Corners
topLeft x =
    ( x, 0, 0, 0 )


{-| -}
topRight : Float -> Corners
topRight x =
    ( 0, x, 0, 0 )


{-| -}
bottomRight : Float -> Corners
bottomRight x =
    ( 0, 0, x, 0 )


{-| -}
bottomLeft : Float -> Corners
bottomLeft x =
    ( 0, 0, 0, x )


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
