module Next.Element.Position
    exposing
        ( alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , center
        , moveDown
        , moveLeft
        , moveRight
        , moveUp
        )

{- API Interface -}

import Next.Internal.Model exposing (Attribute(..), HorizontalAlign(..), Length(..), Property(..), VerticalAlign(..))


{-| -}
center : Attribute msg
center =
    SelfXAlign XCenter


{-| -}
verticalCenter : Attribute msg
verticalCenter =
    SelfYAlign YCenter


{-| -}
verticalSpread : Attribute msg
verticalSpread =
    SelfYAlign VerticalJustify


{-| -}
alignTop : Attribute msg
alignTop =
    SelfYAlign AlignTop


{-| -}
alignBottom : Attribute msg
alignBottom =
    SelfYAlign AlignBottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    SelfXAlign AlignLeft


{-| -}
alignRight : Attribute msg
alignRight =
    SelfXAlign AlignRight


{-| -}
moveUp : Float -> Attribute msg
moveUp y =
    Move Nothing (Just (negate y)) Nothing


{-| -}
moveDown : Float -> Attribute msg
moveDown y =
    Move Nothing (Just y) Nothing


{-| -}
moveRight : Float -> Attribute msg
moveRight x =
    Move (Just x) Nothing Nothing


{-| -}
moveLeft : Float -> Attribute msg
moveLeft x =
    Move (Just (negate x)) Nothing Nothing
