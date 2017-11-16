module Element.Content
    exposing
        ( alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , center
        , padding
        , paddingAll
        , paddingXY
        , spaceEvenly
        , spacing
        , spacingXY
        , verticalCenter
        , verticalSpread
        )

{- -}

import Internal.Model exposing (Attribute(..), HorizontalAlign(..), Length(..), Property(..), VerticalAlign(..))


{-| -}
paddingAll : Float -> Attribute msg
paddingAll x =
    Padding
        { top = x
        , left = x
        , bottom = x
        , right = x
        }


{-| Set horizontal and vertical padding.
-}
paddingXY : Float -> Float -> Attribute msg
paddingXY x y =
    Padding
        { top = y
        , left = x
        , bottom = y
        , right = x
        }


padding : { bottom : Float, left : Float, right : Float, top : Float } -> Attribute msg
padding =
    Padding


{-| -}
center : Attribute msg
center =
    ContentXAlign XCenter


{-| -}
verticalCenter : Attribute msg
verticalCenter =
    ContentYAlign YCenter


{-| -}
verticalSpread : Attribute msg
verticalSpread =
    ContentYAlign VerticalJustify


{-| -}
alignTop : Attribute msg
alignTop =
    ContentYAlign AlignTop


{-| -}
alignBottom : Attribute msg
alignBottom =
    ContentYAlign AlignBottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    ContentXAlign AlignLeft


{-| -}
alignRight : Attribute msg
alignRight =
    ContentXAlign AlignRight


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    ContentXAlign Spread


{-| -}
spacing : Float -> Attribute msg
spacing =
    Spacing


{-| -}
spacingXY : Float -> Float -> Attribute msg
spacingXY =
    SpacingXY
