module Style.Layout exposing (..)

{-|

-}

import Style.Internal.Model as Internal exposing (Property, Centerable(..), Vertical(..), Horizontal(..))
import Style exposing (FlexBox)


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
spacing =
    Internal.Spacing
