module Style.Position exposing (..)

{-| -}


{-| Render an element as 'inline-block'.

This element will no longer be affected by 'spacing'

-}
inline : PositionProperty animation variation msg
inline =
    PositionProp Style.Model.Inline


{-| Float something to the left.  Only valid in textLayouts.

Will ignore any left spacing that it's parent has set for it.

-}
floatLeft : PositionProperty animation variation msg
floatLeft =
    PositionProp (FloatProp Style.Model.FloatLeft)


{-|

-}
floatRight : PositionProperty animation variation msg
floatRight =
    PositionProp (FloatProp Style.Model.FloatRight)


{-| Same as floatLeft, except it will ignore any top spacing that it's parent has set for it.

This is useful for floating things at the beginning of text.

-}
floatTopLeft : PositionProperty animation variation msg
floatTopLeft =
    PositionProp (FloatProp Style.Model.FloatTopLeft)


{-|

-}
floatTopRight : PositionProperty animation variation msg
floatTopRight =
    PositionProp (FloatProp Style.Model.FloatTopRight)


{-| -}
screen : PositionParent
screen =
    Style.Model.Screen


{-| -}
parent : PositionParent
parent =
    Style.Model.Parent


{-| -}
currentPosition : PositionParent
currentPosition =
    Style.Model.CurrentPosition


{-| -}
positionBy : PositionParent -> PositionProperty animation variation msg
positionBy parent =
    PositionProp (Style.Model.RelProp parent)


{-| -}
topLeft : Float -> Float -> PositionProperty animation variation msg
topLeft y x =
    let
        anchor =
            Style.Model.AnchorTop => Style.Model.AnchorLeft
    in
        PositionProp (Position anchor x y)


{-| -}
topRight : Float -> Float -> PositionProperty animation variation msg
topRight y x =
    let
        anchor =
            Style.Model.AnchorTop => Style.Model.AnchorRight
    in
        PositionProp (Position anchor x y)


{-| -}
bottomLeft : Float -> Float -> PositionProperty animation variation msg
bottomLeft y x =
    let
        anchor =
            Style.Model.AnchorBottom => Style.Model.AnchorLeft
    in
        PositionProp (Position anchor x y)


{-| -}
bottomRight : Float -> Float -> PositionProperty animation variation msg
bottomRight y x =
    let
        anchor =
            Style.Model.AnchorBottom => Style.Model.AnchorRight
    in
        PositionProp (Position anchor x y)


{-| -}
zIndex : Int -> Property animation variation msg
zIndex i =
    Property "z-index" (toString i)
