module Style.Layout exposing (..)

{-|



class FontExample
    [ Layout.row
        |^ Layout.spacing 10

    ]



class FontExample
    [ Layout.text
    ]


class FontExample
    [ Layout.down
        |^ Layout.spacing 10
        |- Layout.wrap
    ]

-- This should error....
class FontExample
    [ Layout.text
        |^ Layout.spacing 10
        |- Layout.wrap
    ]


class FontExample
    [ Layout.flow
        |^ Layout.down
        |- Layout.center
        |- Layout.spacing 10
        |- Layout.wrap
    ]

class FontExample
    [ layout
        |^ Layout.text
    ]





-}

import Style.Internal.Model as Internal exposing (Property, Centerable(..), Vertical(..), Horizontal(..))


type alias FlexBox =
    Internal.FlexBox



--test =
--    class FontExample
--        [ Layout.flex
--            |^ Layout.right
--                { horizontal = center
--                , vertical = center
--                , wrap = True
--                }
--            |- Layout.horizontal center
--          --|- Layout.vertical center
--          --|- Layout.spacing 10
--          --|- Layout.wrap
--        ]


{-| This is the familiar block layout.

__Note:__ It's the only layout that allows for child elements to use `Position.float` or `Position.inline`.

-}
text : Property class variation animation
text =
    Internal.Layout <|
        Internal.TextLayout Nothing


{-| This is the familiar block layout with spacing applied to the children.

__Note:__ It's the only layout that allows for child elements to use `Position.float` or `Position.inline`.

-}
spacedText : Int -> Property class variation animation
spacedText space =
    Internal.Layout <|
        Internal.TextLayout (Just space)


{-| -}
row : Property class variation animation
row =
    Internal.Layout <|
        Internal.FlexLayout <|
            Internal.emptyFlexBox


{-| -}
spacedRow : Int -> Property class variation animation
spacedRow i =
    Internal.FlexLayout


{-| -}
column : Property class variation animation
column i =
    Internal.FlexLayout


{-| -}
spacedColumn : Int -> Property class variation animation
spacedColumn i =
    Internal.FlexLayout


{-| -}
flow : (Flexbox -> Flexbox) -> Property class variation animation
flow update =
    Internal.Layout <| Internal.FlexLayout (update Internal.emptyFlexBox)


{-| -}
up : Flexbox -> Flexbox
up (Internal.FlexBox flex) =
    Internal.FlexBox { flex | go = Internal.Up }


{-| -}
down : Flexbox -> Flexbox
down (Internal.FlexBox flex) =
    Internal.FlexBox { flex | go = Internal.Down }


{-| -}
right : Flexbox -> Flexbox
right (Internal.FlexBox flex) =
    Internal.FlexBox { flex | go = Internal.GoRight }


{-| -}
left : Flexbox -> Flexbox
left (Internal.FlexBox flex) =
    Internal.FlexBox { flex | go = Internal.GoLeft }


{-| -}
alignRight : Flexbox -> Flexbox
alignRight (Internal.FlexBox flex) =
    Internal.FlexBox { flex | horizontal = Other Right }


{-| -}
alignLeft : Flexbox -> Flexbox
alignLeft (Internal.FlexBox flex) =
    Internal.FlexBox { flex | horizontal = Other Left }


{-| -}
center : Flexbox -> Flexbox
center (Internal.FlexBox flex) =
    Internal.FlexBox { flex | horizontal = Center }


{-| -}
alignTop : Flexbox -> Flexbox
alignTop (Internal.FlexBox flex) =
    Internal.FlexBox { flex | vertical = Other Top }


{-| -}
alignBottom : Flexbox -> Flexbox
alignBottom (Internal.FlexBox flex) =
    Internal.FlexBox { flex | vertical = Other Bottom }


{-| -}
vCenter : Flexbox -> Flexbox
vCenter (Internal.FlexBox flex) =
    Internal.FlexBox { flex | vertical = Center }


{-| -}
justify : Flexbox -> Flexbox
justify (Internal.FlexBox flex) =
    Internal.FlexBox { flex | horizontal = Justify }


{-| -}
justifyAll : Flexbox -> Flexbox
justifyAll (Internal.FlexBox flex) =
    Internal.FlexBox { flex | horizontal = JustifyAll }


{-| -}
vJustify : Flexbox -> Flexbox
vJustify (Internal.FlexBox flex) =
    Internal.FlexBox { flex | vertical = Justify }


{-| -}
vJustifyAll : Flexbox -> Flexbox
vJustifyAll (Internal.FlexBox flex) =
    Internal.FlexBox { flex | vertical = JustifyAll }


{-| -}
spacing : ( Float, Float, Float, Float ) -> (FlexBox -> FlexBox)
spacing box (Internal.LayoutModel layout) =
    Internal.LayoutModel { layout | spacing = Just box }
