module Style.Position exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property)


--{-| Render an element as 'inline-block'.
--This element will no longer be affected by 'spacing'
---}
--inline : PositionProperty animation variation msg
--inline =
--    PositionProp Style.Model.Inline
--{-| Float something to the left.  Only valid in textLayouts.
--Will ignore any left spacing that it's parent has set for it.
---}
--floatLeft : PositionProperty animation variation msg
--floatLeft =
--    PositionProp (FloatProp Style.Model.FloatLeft)
--{-|
---}
--floatRight : PositionProperty animation variation msg
--floatRight =
--    PositionProp (FloatProp Style.Model.FloatRight)
--{-| Same as floatLeft, except it will ignore any top spacing that it's parent has set for it.
--This is useful for floating things at the beginning of text.
---}
--floatTopLeft : PositionProperty animation variation msg
--floatTopLeft =
--    PositionProp (FloatProp Style.Model.FloatTopLeft)
--{-|
---}
--floatTopRight : PositionProperty animation variation msg
--floatTopRight =
--    PositionProp (FloatProp Style.Model.FloatTopRight)


{-| -}
screen : Property class variation animation -> Property class variation animation
screen =
    Internal.addProperty Internal.Position "position" "fixed"


{-| -}
parent : Property class variation animation -> Property class variation animation
parent =
    Internal.addProperty Internal.Position "position" "absolute"


{-| -}
relative : Property class variation animation -> Property class variation animation
relative =
    Internal.addProperty Internal.Position "position" "relative"


{-| -}
left : Int -> Property class variation animation -> Property class variation animation
left i =
    Internal.addProperty Internal.Position "left" (toString i ++ "px")


{-| -}
right : Int -> Property class variation animation -> Property class variation animation
right i =
    Internal.addProperty Internal.Position "right" (toString i ++ "px")


{-| -}
top : Int -> Property class variation animation -> Property class variation animation
top i =
    Internal.addProperty Internal.Position "top" (toString i ++ "px")


{-| -}
bottom : Int -> Property class variation animation -> Property class variation animation
bottom i =
    Internal.addProperty Internal.Position "bottom" (toString i ++ "px")


{-| -}
zIndex : Int -> Property class variation animation -> Property class variation animation
zIndex i =
    Internal.addProperty Internal.Position "z-index" (toString i)
