module Style exposing 
    (Style, Property, Shadow, style, variation, prop, shadows, position, border, box, width, height, maxHeight, minHeight, maxWidth, minWidth)

{-|
# Welcome to the Style Elements Library!


@docs Style, Property

@docs style, variation

@docs prop

@docs position

@docs border

@docs box, width, maxWidth, minWidth, height, maxHeight, minHeight

@docs Shadow, shadows


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
        Internal.Border (update Internal.emptyBorder)
    

{-| -}
position : (Position -> Position) -> Property class variation animation
position update =
    Internal.Position (update Internal.emptyPosition)


type alias Box = Internal.BoxModel

{-| -}
box : (Box -> Box) -> Property class variation animation
box update =
        Internal.Box (update Internal.emptyBox)



{-| -}
width : Length -> Box -> Box
width len box =
    { box | width = Just <| Render.length len }


{-| -}
minWidth : Length -> Box -> Box
minWidth  len box =
    { box | minWidth = Just <| Render.length len }


{-| -}
maxWidth : Length -> Box -> Box
maxWidth  len box =
    { box | maxWidth = Just <| Render.length len }


{-|-}
height : Length -> Box -> Box
height  len box =
    { box | height = Just <| Render.length len }


{-| -}
minHeight : Length -> Box -> Box
minHeight  len box =
    { box | minHeight= Just <| Render.length len }


{-| -}
maxHeight : Length -> Box -> Box
maxHeight  len box =
    { box | maxHeight = Just <| Render.length len }


{-| -}
padding : ( Float, Float, Float, Float ) -> Box -> Box
padding  pad box =
    { box | padding = Just <| Render.box pad }

{-|-}
type alias Shadow = List Internal.ShadowModel

{-|-}
shadows : (Shadow -> Shadow) ->  Property class variation animation
shadows update =
        Internal.Shadows (update [])




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


