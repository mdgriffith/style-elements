module Element.Style
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
        , ColorElement
        , GradientDirection
        , GradientStep
        , StyleSheet
        , Edges
        , Corners
        , variation
        , prop
        , cursor
        , font
        , background
        , shadows
        , border
        , palette
        , marginHint
        , transforms
        , filters
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
        , hover
        , focus
          -- , after
          -- , before
        , pseudo
        )

{-|
# Welcome to the Style Elements Library!


@docs StyleSheet, Style, Property

@docs variation

@docs prop

@docs cursor


@docs palette, ColorElement

@docs Border, border, Corners

@docs marginHint, Edges

@docs Shadow, shadows

@docs Transform, transforms

@docs Filter, filters

@docs Font, font

@docs background, Background, Repeat, GradientDirection, GradientStep

@docs all, top, left, right, bottom, leftRight, topBottom, leftRightAndTopBottom, leftRightTopBottom, allButTop, allButLeft, allButRight, allButBottom

@docs hover, focus, pseudo
-}

import Element.Style.Internal.Model as Internal
import Element.Style.Internal.Render.Value as Value
import Element.Style.Internal.Batchable as Batchable exposing (Batchable)
import Element.Internal.Model as Element exposing (StyleAttribute)


{-| The stylesheet contains the rendered css as a string, and two functions to lookup
-}
type alias StyleSheet class variation animation msg =
    Internal.StyleSheet class variation animation msg


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
    Internal.FontElement


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
type alias ColorElement =
    Internal.ColorElement


{-| -}
type alias GradientDirection =
    Internal.GradientDirection


{-| -}
type alias GradientStep =
    Internal.GradientStep


{-| -}
variation : variation -> List (Property class Never animation) -> StyleAttribute class variation animation msg
variation variation props =
    Element.Style <| Internal.Variation variation props


{-| -}
prop : String -> String -> StyleAttribute class variation animation msg
prop name val =
    Element.Style <| Internal.Exact name val


{-| -}
cursor : String -> StyleAttribute class variation animation msg
cursor name =
    Element.Style <| Internal.Exact "cursor" name


{-| -}
border : List Border -> StyleAttribute class variation animation msg
border elems =
    Element.Style <| Internal.Border (Internal.BorderElement "border-style" "solid" :: elems)


{-| -}
background : List Background -> StyleAttribute class variation animation msg
background bgs =
    Element.Style <| Internal.Background bgs


{-| -}
font : List Font -> StyleAttribute class variation animation msg
font f =
    Element.Style <| Internal.Font f


{-| -}
palette : List ColorElement -> StyleAttribute class variation animation msg
palette colors =
    Element.Style <| Internal.Palette colors


{-| You can give a hint about what the padding should be for this element, but the layout can override it.

-}
paddingHint : ( Float, Float, Float, Float ) -> StyleAttribute class variation animation msg
paddingHint pad =
    Element.Style <| Internal.Box <| [ Internal.BoxProp "padding" (Value.box pad) ]



{-
   Shadows
-}


{-| -}
type alias Shadow =
    Internal.ShadowModel


{-| -}
shadows : List Shadow -> StyleAttribute class variation animation msg
shadows shades =
    Element.Style <| Internal.Shadows shades


{-| -}
transforms : List Transform -> StyleAttribute class variation animation msg
transforms ts =
    Element.Style <| Internal.Transform ts


{-| -}
type alias Filter =
    Internal.Filter


{-| -}
filters : List Filter -> StyleAttribute class variation animation msg
filters fs =
    Element.Style <| Internal.Filters fs



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


{-| -}
hover : List (Property class variation animation) -> StyleAttribute class variation animation msg
hover props =
    Element.Style <| Internal.PseudoElement ":hover" props


{-| -}
focus : List (Property class variation animation) -> StyleAttribute class variation animation msg
focus props =
    Element.Style <| Internal.PseudoElement ":focus" props


{-| -}
checked : List (Property class variation animation) -> StyleAttribute class variation animation msg
checked props =
    Element.Style <| Internal.PseudoElement ":checked" props


{-| -}
pseudo : String -> List (Property class variation animation) -> StyleAttribute class variation animation msg
pseudo psu props =
    Element.Style <| Internal.PseudoElement (":" ++ psu) props



-- {-| -}
-- after : String -> List (Property class variation animation) -> StyleAttribute class variation animation msg
-- after content props =
--     Element.Style <| Internal.PseudoElement ":after" (prop "content" ("'" ++ content ++ "'") :: props)
-- {-| -}
-- before : String -> List (Property class variation animation) -> StyleAttribute class variation animation msg
-- before content props =
--     Element.Style <| Internal.PseudoElement ":before" (prop "content" ("'" ++ content ++ "'") :: props)
