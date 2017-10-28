module Next.Element.Content
    exposing
        ( alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , center
        , padding
        , paddingBottom
        , paddingLeft
        , paddingRight
        , paddingTop
        , paddingXY
        , spaceEvenly
        , spacing
        , spacingXY
        , verticalCenter
        , verticalSpread
        )

{- -}

import Next.Internal.Model exposing (Attribute(..), HorizontalAlign(..), Length(..), Property(..), VerticalAlign(..))


{-| -}
padding : Float -> Attribute msg
padding x =
    Padding
        { top = Just x
        , left = Just x
        , bottom = Just x
        , right = Just x
        }


{-| Set horizontal and vertical padding.
-}
paddingXY : Float -> Float -> Attribute msg
paddingXY x y =
    Padding
        { top = Just y
        , left = Just x
        , bottom = Just y
        , right = Just x
        }


{-| -}
paddingLeft : Float -> Attribute msg
paddingLeft x =
    Padding
        { top = Nothing
        , left = Just x
        , bottom = Nothing
        , right = Nothing
        }


{-| -}
paddingRight : Float -> Attribute msg
paddingRight x =
    Padding
        { top = Nothing
        , left = Nothing
        , bottom = Nothing
        , right = Just x
        }


{-| -}
paddingTop : Float -> Attribute msg
paddingTop x =
    Padding
        { top = Just x
        , left = Nothing
        , bottom = Nothing
        , right = Nothing
        }


{-| -}
paddingBottom : Float -> Attribute msg
paddingBottom x =
    Padding
        { top = Nothing
        , left = Nothing
        , bottom = Just x
        , right = Nothing
        }


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
