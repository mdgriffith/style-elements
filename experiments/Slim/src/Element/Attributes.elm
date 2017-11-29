module Element.Attributes
    exposing
        ( above
        , alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , below
        , center
        , centerY
        , description
        , height
        , moveDown
        , moveLeft
        , moveRight
        , moveUp
        , onLeft
        , onRight
        , overlay
        , padding
        , paddingEach
        , paddingXY
        , spaceEvenly
        , spacing
        , spacingXY
        , width
        )

{-| -}

import Internal.Model as Internal exposing (..)


description : String -> Attribute msg
description =
    Describe << Label


below : Internal.Element msg -> Attribute msg
below =
    Nearby Below


above : Internal.Element msg -> Attribute msg
above =
    Nearby Above


onRight : Internal.Element msg -> Attribute msg
onRight =
    Nearby OnRight


onLeft : Internal.Element msg -> Attribute msg
onLeft =
    Nearby OnLeft


overlay : Internal.Element msg -> Attribute msg
overlay =
    Nearby Overlay


{-| -}
width : Length -> Attribute msg
width len =
    case len of
        Px px ->
            StyleClass (Single ("width-px-" ++ Internal.floatClass px) "width" (toString px ++ "px"))

        Content ->
            Class "width" "width-content"

        Expand ->
            Class "width" "width-expand"

        Fill portion ->
            -- TODO: account for fill /= 1
            Class "width" "width-fill"


{-| -}
height : Length -> Attribute msg
height len =
    case len of
        Px px ->
            StyleClass (Single ("height-px-" ++ Internal.floatClass px) "height" (toString px ++ "px"))

        Content ->
            Class "height" "height-content"

        Expand ->
            Class "height" "height-expand"

        Fill portion ->
            -- TODO: account for fill /= 1
            Class "height" "height-fill"


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


{-| -}
rotate : Float -> Attribute msg
rotate angle =
    Rotate 0 0 1 angle


{-| -}
padding : Int -> Attribute msg
padding x =
    StyleClass (PaddingStyle x x x x)


{-| Set horizontal and vertical padding.
-}
paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    StyleClass (PaddingStyle y x y x)


paddingEach : { bottom : Int, left : Int, right : Int, top : Int } -> Attribute msg
paddingEach { top, right, bottom, left } =
    StyleClass (PaddingStyle top right bottom left)


{-| -}
center : Attribute msg
center =
    Class "x-align" "self-center-x"


{-| -}
centerY : Attribute msg
centerY =
    Class "y-align" "self-center-y"


{-| -}
alignTop : Attribute msg
alignTop =
    Class "y-align" "self-top"


{-| -}
alignBottom : Attribute msg
alignBottom =
    Class "y-align" "self-bottom"


{-| -}
alignLeft : Attribute msg
alignLeft =
    Class "x-align" "self-left"


{-| -}
alignRight : Attribute msg
alignRight =
    Class "x-align" "self-right"


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    Class "x-align" "space-evenly"


{-| -}
spacing : Int -> Attribute msg
spacing x =
    StyleClass (SpacingStyle x x)


{-| -}
spacingXY : Int -> Int -> Attribute msg
spacingXY x y =
    StyleClass (SpacingStyle x y)


{-| -}
hidden : Bool -> Attribute msg
hidden on =
    if on then
        Internal.class "hidden"
    else
        NoAttribute
