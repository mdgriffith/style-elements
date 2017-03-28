module Style exposing (Style, Property, style, variation, prop)

{-|
# Welcome to the Style Elements Library!


@docs Style, Property

@docs style, variation

@docs prop

-}

import Style.Internal.Model as Internal
import Style.Internal.Render as Render
import Style.Border exposing (Border)

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
        Internal.Border (update Internal.emptyBorderModel)
    


--{-| -}
--box : Property class variation animation
--box =
--    Internal.Property Internal.Box []


--{-| -}
--position : Property class variation animation
--position =
--    Internal.Property Internal.Position []


--{-| -}
--width : Length -> Property class variation animation -> Property class variation animation
--width value =
--    Internal.addProperty Internal.Box "width" (Render.length value)


--{-| -}
--minWidth : Length -> Property class variation animation -> Property class variation animation
--minWidth value =
--    Internal.addProperty Internal.Box "min-width" (Render.length value)


--{-| -}
--maxWidth : Length -> Property class variation animation -> Property class variation animation
--maxWidth value =
--    Internal.addProperty Internal.Box "max-width" (Render.length value)


--| 
--height : Length -> Property class variation animation -> Property class variation animation
--height value =
--    Internal.addProperty Internal.Box "height" (Render.length value)


--{-| -}
--minHeight : Length -> Property class variation animation -> Property class variation animation
--minHeight value =
--    Internal.addProperty Internal.Box "min-height" (Render.length value)


--{-| -}
--maxHeight : Length -> Property class variation animation -> Property class variation animation
--maxHeight value =
--    Internal.addProperty Internal.Box "max-height" (Render.length value)


--{-| -}
--padding : ( Float, Float, Float, Float ) -> Property class variation animation -> Property class variation animation
--padding box =
--    Internal.addProperty Internal.Border "padding" (Render.box box)




{-| This is not a fancy operator.

This is a synonym for `<|`.  If `<|` was used directly, `elm-format` would make your styles look weird.

-}
(|^) : (a -> b) -> a -> b
(|^) =
    (<|)
infixr 0 |^


{-| This is not a fancy operator.

This is just a synonym for `<<`, but with a higher infix priority so that it plays nicely with `|^`.

I highly recommending only using this when dealing with this library, it's not meant as a general operator.

-}
(|-) : (b -> c) -> (a -> b) -> (a -> c)
(|-) =
    (<<)
infixl 1 |-


{- Box Constructors


-}


type alias Box =
    ( Float, Float, Float, Float )


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
