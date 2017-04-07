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
        , style
        , variation
        , child
        , prop
        , font
        , shadows
        , position
        , border
        , box
        , width
        , height
        , maxHeight
        , minHeight
        , maxWidth
        , minWidth
        , transform
        , filters
        , px
        , percent
        , auto
        , all
        , left
        , right
        , top
        , bottom
        )

{-|
# Welcome to the Style Elements Library!


@docs Style, Property

@docs style, variation, child

@docs prop

@docs position

@docs Border, border

@docs box, px, auto, percent, width, maxWidth, minWidth, height, maxHeight, minHeight

@docs Shadow, shadows

@docs Transform, transform

@docs Filter, filters

@docs Font, font

@docs Background, Repeat

@docs all, top, left, right, bottom

-}

import Style.Internal.Model as Internal
import Style.Internal.Render as Render


{-| -}
type alias Style class variation animation =
    Internal.BatchedStyle class variation animation


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
style : class -> List (Property class variation animation) -> Style class variation animation
style cls props =
    Internal.Single (Internal.Style cls props)


{-| -}
variation : variation -> List (Property class Never animation) -> Property class variation animation
variation variation props =
    Internal.Variation variation props


{-| -}
child : class -> List (Property class variation animation) -> Property class variation animation
child class props =
    Internal.Child class props


{-| -}
prop : String -> String -> Property class variation animation
prop =
    Internal.Exact


{-| -}
border : List Border -> Property class variation animation
border =
    Internal.Border


{-| -}
font : List Font -> Property class variation animation
font =
    Internal.Font


{-| -}
position : List Position -> Property class variation animation
position =
    Internal.Position


{-| -}
box : List Box -> Property class variation animation
box =
    Internal.Box


{-| -}
px : Float -> Length
px =
    Internal.Px


{-| -}
auto : Length
auto =
    Internal.Auto


{-| -}
percent : Float -> Length
percent =
    Internal.Percent


{-| -}
width : Length -> Box
width len =
    Internal.BoxProp "width" (Render.length len)


{-| -}
minWidth : Length -> Box
minWidth len =
    Internal.BoxProp "min-width" (Render.length len)


{-| -}
maxWidth : Length -> Box
maxWidth len =
    Internal.BoxProp "max-width" (Render.length len)


{-| -}
height : Length -> Box
height len =
    Internal.BoxProp "height" (Render.length len)


{-| -}
minHeight : Length -> Box
minHeight len =
    Internal.BoxProp "min-height" (Render.length len)


{-| -}
maxHeight : Length -> Box
maxHeight len =
    Internal.BoxProp "max-height" (Render.length len)


{-| -}
padding : ( Float, Float, Float, Float ) -> Box
padding pad =
    Internal.BoxProp "padding" (Render.box pad)


{-| -}
type alias Shadow =
    List Internal.ShadowModel


{-| -}
shadows : (Shadow -> Shadow) -> Property class variation animation
shadows update =
    Internal.Shadows (update [])


{-| -}
transform : List Transform -> Property class variation animation
transform =
    Internal.Transform


{-| -}
type alias Filter =
    Internal.Filter


{-| -}
filters : List Filter -> Property class variation animation
filters =
    Internal.Filters



{- Box Constructors


-}


{-| -}
all : Float -> ( Float, Float, Float, Float )
all x =
    ( x, x, x, x )


{-| -}
left : Float -> ( Float, Float, Float, Float )
left x =
    ( 0, 0, 0, x )


{-| -}
right : Float -> ( Float, Float, Float, Float )
right x =
    ( 0, x, 0, 0 )


{-| -}
top : Float -> ( Float, Float, Float, Float )
top x =
    ( x, 0, 0, 0 )


{-| -}
bottom : Float -> ( Float, Float, Float, Float )
bottom x =
    ( 0, 0, x, 0 )
