module Style exposing (Style, Property, style, variation, prop)

{-|
# Welcome to the Style Elements Library!


@docs Style, Property

@docs style, variation

@docs prop

-}

import Style.Internal.Model as Internal


{-|-}
type alias Style class variation animation = 
    Internal.BatchedStyle class variation animation

{-| -}
type alias Property class variation animation =
    Internal.Property class variation animation


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
    Internal.Property

{-  Box Constructors


-}

type alias Box = (Float, Float, Float, Float)

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

