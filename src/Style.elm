module Style
    exposing
        ( Style
        , Property
        , Shadow
        , Transform
        , Filter
        , style
        , variation
        , prop
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
        )

{-|
# Welcome to the Style Elements Library!


@docs Style, Property

@docs style, variation

@docs prop

@docs position

@docs border

@docs box, width, maxWidth, minWidth, height, maxHeight, minHeight

@docs Shadow, shadows

@docs Transform, transform

@docs Filter, filters


-}

import Style.Internal.Model as Internal
import Style.Internal.Render as Render
import Style.Border exposing (Border)
import Style.Position exposing (Position)


{-| -}
type alias Style class variation animation =
    Internal.BatchedStyle class variation animation


{-| -}
type alias Property class variation animation =
    Internal.Property class variation animation


type alias Length =
    Internal.Length


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
border : (Border -> Border) -> Property class variation animation
border update =
    Internal.Border (update [ Internal.BorderElement "border-style" "solid" ])


{-| -}
position : (Position -> Position) -> Property class variation animation
position update =
    Internal.Position (update [])


type alias Box =
    List Internal.BoxElement


{-| -}
box : (Box -> Box) -> Property class variation animation
box update =
    Internal.Box (update [])


{-| -}
width : Length -> Box -> Box
width len box =
    Internal.BoxProp "width" (Render.length len) :: box


{-| -}
minWidth : Length -> Box -> Box
minWidth len box =
    Internal.BoxProp "min-width" (Render.length len) :: box


{-| -}
maxWidth : Length -> Box -> Box
maxWidth len box =
    Internal.BoxProp "max-width" (Render.length len) :: box


{-| -}
height : Length -> Box -> Box
height len box =
    Internal.BoxProp "height" (Render.length len) :: box


{-| -}
minHeight : Length -> Box -> Box
minHeight len box =
    Internal.BoxProp "min-height" (Render.length len) :: box


{-| -}
maxHeight : Length -> Box -> Box
maxHeight len box =
    Internal.BoxProp "max-height" (Render.length len) :: box


{-| -}
padding : ( Float, Float, Float, Float ) -> Box -> Box
padding pad box =
    Internal.BoxProp "padding" (Render.box pad) :: box


{-| -}
type alias Shadow =
    List Internal.ShadowModel


{-| -}
shadows : (Shadow -> Shadow) -> Property class variation animation
shadows update =
    Internal.Shadows (update [])


{-| -}
type alias Transform =
    List Internal.Transformation


{-| -}
transform : (Transform -> Transform) -> Property class variation animation
transform update =
    Internal.Transform (update [])


{-| -}
type alias Filter =
    List Internal.Filter


{-| -}
filters : (Filter -> Filter) -> Property class variation animation
filters update =
    Internal.Filters (update [])


{-| This is not a fancy operator.

This is a synonym for `<|`.  If `<|` was used instead, `elm-format` would make your styles look weird.

-}
(|^) : (a -> b) -> a -> b
(|^) =
    (<|)
infixr 0 |^


{-| This is not a fancy operator.

This is just a synonym for `>>`, but with an adjusted infix priority so that it plays nicely with `|^`.

I highly recommending only using this when dealing with this library, it's not meant as a general operator.

-}
(|-) : (a -> b) -> (b -> c) -> (a -> c)
(|-) =
    (>>)
infixl 1 |-



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
