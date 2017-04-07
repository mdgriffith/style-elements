module Style.Layout exposing (..)

{-|

-}

import Style.Internal.Model as Internal exposing (Property, Centerable(..), Vertical(..), Horizontal(..))


type alias FlexBox =
    Internal.FlexBoxElement


{-| This is the familiar block layout.

It's called `text` because this layout should generally only be used for doing text layouts.

__Note:__ It's the only layout that allows for child elements to use `Position.float` or `Position.inline`.

-}
text : Property class variation animation
text =
    Internal.Layout <|
        Internal.TextLayout { spacing = Nothing }


{-| Same as `Layout.text`, but sets margin on all children.

-}
spacedText : ( Float, Float, Float, Float ) -> Property class variation animation
spacedText space =
    Internal.Layout <|
        Internal.TextLayout { spacing = (Just space) }


{-| -}
row : Property class variation animation
row =
    Internal.Layout <|
        Internal.FlexLayout
            [ Internal.Go Internal.GoRight
            ]


{-| -}
spacedRow : ( Float, Float, Float, Float ) -> Property class variation animation
spacedRow i =
    Internal.Layout <|
        Internal.FlexLayout
            [ Internal.Go Internal.GoRight
            , spacing i
            ]


{-| -}
column : Property class variation animation
column =
    Internal.Layout <|
        Internal.FlexLayout
            [ Internal.Go Internal.Down
            ]


{-| -}
spacedColumn : ( Float, Float, Float, Float ) -> Property class variation animation
spacedColumn i =
    Internal.Layout <|
        Internal.FlexLayout
            [ Internal.Go Internal.Down
            , spacing i
            ]


{-| -}
flowRight : List FlexBox -> Property class variation animation
flowRight flexbox =
    Internal.FlexLayout Internal.GoRight flexbox
        |> Internal.Layout


{-| -}
flowLeft : List FlexBox -> Property class variation animation
flowLeft flexbox =
    Internal.FlexLayout Internal.GoLeft flexbox
        |> Internal.Layout


{-| -}
flowDown : List FlexBox -> Property class variation animation
flowDown flexbox =
    Internal.FlexLayout Internal.Down flexbox
        |> Internal.Layout


{-| -}
flowUp : List FlexBox -> Property class variation animation
flowUp flexbox =
    Internal.FlexLayout Internal.Up flexbox
        |> Internal.Layout


{-| -}
alignRight : FlexBox
alignRight =
    Internal.Horz (Other Right)


{-| -}
alignLeft : FlexBox
alignLeft =
    Internal.Horz (Other Left)


{-| -}
center : FlexBox
center =
    Internal.Horz Center


{-| -}
alignTop : FlexBox
alignTop =
    Internal.Vert (Other Top)


{-| -}
alignBottom : FlexBox
alignBottom =
    Internal.Vert (Other Bottom)


{-| -}
vCenter : FlexBox
vCenter =
    Internal.Vert Center


{-| -}
justify : FlexBox
justify =
    Internal.Horz Justify


{-| -}
justifyAll : FlexBox
justifyAll =
    Internal.Horz JustifyAll


{-| -}
vJustify : FlexBox
vJustify =
    Internal.Vert Justify


{-| -}
vJustifyAll : FlexBox
vJustifyAll =
    Internal.Vert JustifyAll


{-| -}
wrap : FlexBox
wrap =
    Internal.Wrap True


{-| -}
nowrap : FlexBox
nowrap =
    Internal.Wrap False


{-| -}
spacing : ( Float, Float, Float, Float ) -> FlexBox
spacing box =
    Internal.Spacing box
