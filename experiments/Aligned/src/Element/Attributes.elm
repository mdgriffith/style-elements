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


{-| If we have this construct, it makes it easier to change states for something like a button.

    el
        [ Color.background blue
        , onClick Send
        , mixIf model.disabled
            [ Color.background grey
            , onClick NoOp
            ]
        ]

Does it allow elimination of event handlers? Would have to rely on html behavior for that if it's true.

People could implement systems that involve multiple properties being set together.

Example of a disabled button

    Input.button
        [ Color.background
            ( if disabled then
                grey
             else
                blue
            )
        , Color.border
            ( if disabled then
                grey
             else
                blue
            )
        ]
        { onPress = switch model.disabled Send
        , label = text "Press me"
        }

Advantages: no new constructs(!)

Disadvantages: could get verbose in the case of many properties set.

  - How many properties would likely vary in this way?

  - Would a `Color.palette {text, background, border}` go help?

    Input.button
    [ Color.palette
    ( if disabled then
    { background = grey
    , text = darkGrey
    , border = grey
    }
    else
    { background = blue
    , text = black
    , border = blue
    }
    )
    ]
    { onPress = switch model.disabled Send
    , label = text "Press me"
    }

-- with mixIf

    Input.button
        [ Color.background blue
        , mixIf model.disabled
            [ Color.background grey
            ]
        ]
        { onPress = (if model.disabled then Nothing else Just Send )
        , label = text "Press me"
        }

Advantages:

  - Any properties can be set together.
  - Would allow `above`/`below` type elements to be triggered manually.

Disadvantages:

  - Does binding certain properties together lead to a good experience?

-}
mixIf : Bool -> List (Attribute msg) -> List (Attribute msg)
mixIf on attrs =
    if on then
        attrs
    else
        []


{-| For the hover pseudoclass, the considerations:

1.  What happens on mobile/touch devices?
      - Let the platform handle it

2.  We can make the hover event show a 'nearby', like 'below' or something.
      - what happens on mobile? Do first clicks now perform that action?

-}
hover : List (Attribute msg) -> Attribute msg
hover x =
    hidden True


{-| -}
focus : List (Attribute msg) -> Attribute msg
focus x =
    hidden True


description : String -> Attribute msg
description =
    Describe << Label


{-| -}
below : Internal.Element msg -> Attribute msg
below =
    Nearby Below


{-| -}
above : Internal.Element msg -> Attribute msg
above =
    Nearby Above


{-| -}
onRight : Internal.Element msg -> Attribute msg
onRight =
    Nearby OnRight


{-| -}
onLeft : Internal.Element msg -> Attribute msg
onLeft =
    Nearby OnLeft


{-| -}
overlay : Internal.Element msg -> Attribute msg
overlay =
    Nearby Overlay


{-| -}
width : Length -> Attribute msg
width =
    Width



-- case len of
--     Px px ->
--         StyleClass (Single ("width-px-" ++ Internal.floatClass px) "width" (toString px ++ "px"))
--     Content ->
--         Class "width" "width-content"
--     Fill portion ->
--         -- TODO: account for fill /= 1
--         Class "width" "width-fill"


{-| -}
height : Length -> Attribute msg
height =
    Height



-- case len of
--     Px px ->
--         StyleClass (Single ("height-px-" ++ Internal.floatClass px) "height" (toString px ++ "px"))
--     Content ->
--         Class "height" "height-content"
--     Fill portion ->
--         -- TODO: account for fill /= 1
--         Class "height" "height-fill"


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


{-| -}
paddingEach : { bottom : Int, left : Int, right : Int, top : Int } -> Attribute msg
paddingEach { top, right, bottom, left } =
    StyleClass (PaddingStyle top right bottom left)


{-| -}
center : Attribute msg
center =
    AlignX CenterX


{-| -}
centerY : Attribute msg
centerY =
    AlignY CenterY


{-| -}
alignTop : Attribute msg
alignTop =
    AlignY Top


{-| -}
alignBottom : Attribute msg
alignBottom =
    AlignY Bottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    AlignX Left


{-| -}
alignRight : Attribute msg
alignRight =
    AlignX Right


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
