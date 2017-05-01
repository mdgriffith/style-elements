module Style
    exposing
        ( Style
        , Property
        , Font
        , Background
        , Border
        , Repeat
        , Shadow
        , Transform
        , Filter
        , GradientDirection
        , GradientStep
        , Edges
        , Corners
        , style
        , variation
        , prop
        , cursor
        , font
        , background
        , shadows
        , border
        , paddingHint
        , transforms
        , filters
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
        )

{-|
# Welcome to the Style Elements Library!


@docs Style, style, Property

@docs variation

@docs prop

@docs cursor

@docs Border, border, Corners

@docs paddingHint, Edges

@docs Shadow, shadows

@docs Transform, transforms

@docs Filter, filters

@docs Font, font

@docs hover, checked, focus, pseudo

@docs background, Background, Repeat, GradientDirection, GradientStep

@docs all, top, left, right, bottom, leftRight, topBottom, leftRightAndTopBottom, leftRightTopBottom, allButTop, allButLeft, allButRight, allButBottom

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
type alias Border =
    Internal.BorderElement


{-| -}
type alias Box =
    Internal.BoxElement


{-| -}
type alias Position =
    Internal.PositionElement


{-| -}
type alias Font =
    Batchable Internal.FontElement


{-| -}
type alias Background =
    Internal.BackgroundElement


{-| -}
type alias Repeat =
    Internal.Repeat


{-| -}
type alias Transform =
    Internal.Transformation


{-| -}
type alias GradientDirection =
    Internal.GradientDirection


{-| -}
type alias GradientStep =
    Internal.GradientStep


{-| -}
style : class -> List (Property class variation animation) -> Style class variation animation
style cls props =
    Batchable.one (Internal.Style cls props)


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


{-| -}
border : List Border -> Property class variation animation
border elems =
    Internal.Border (Internal.BorderElement "border-style" "solid" :: elems)


{-| -}
background : List Background -> Property class variation animation
background bgs =
    Internal.Background bgs


{-| -}
font : List Font -> Property class variation animation
font f =
    Internal.Font (Batchable.toList f)


{-| You can give a hint about what the padding should be for this element, but the layout can override it.

-}
paddingHint : ( Float, Float, Float, Float ) -> Property class variation animation
paddingHint pad =
    Internal.Box <| [ Internal.BoxProp "padding" (Value.box pad) ]



{-
   Shadows
-}


{-| -}
type alias Shadow =
    Internal.ShadowModel


{-| -}
shadows : List Shadow -> Property class variation animation
shadows shades =
    Internal.Shadows shades


{-| -}
transforms : List Transform -> Property class variation animation
transforms ts =
    Internal.Transform ts


{-| -}
type alias Filter =
    Internal.Filter


{-| -}
filters : List Filter -> Property class variation animation
filters fs =
    Internal.Filters fs



{- Box Constructors


-}


{-| A tuple of four floats to define any property with edges, such as:

  * `padding`
  * `margin`
  * `Layout.spacing`
  * `Border.width`

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

It's still a four element tuple like `Edges`, but the numbers are semantically different.

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



-- {-| -}
-- after : String -> List (Property class variation animation) -> Property class variation animation
-- after content props =
--      Internal.PseudoElement ":after" (prop "content" ("'" ++ content ++ "'") :: props)
-- {-| -}
-- before : String -> List (Property class variation animation) -> Property class variation animation
-- before content props =
--      Internal.PseudoElement ":before" (prop "content" ("'" ++ content ++ "'") :: props)


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
