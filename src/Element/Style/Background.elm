module Element.Style.Background exposing (..)

{-| -}

import Element.Style.Internal.Model as Internal
import Color exposing (Color)
import Element.Style exposing (Background, Repeat, GradientStep, GradientDirection)


step : Color -> GradientStep
step =
    Internal.ColorStep


percent : Color -> Float -> GradientStep
percent =
    Internal.PercentStep


px : Color -> Float -> GradientStep
px =
    Internal.PxStep


toUp : GradientDirection
toUp =
    Internal.ToUp


toDown : GradientDirection
toDown =
    Internal.ToDown


toRight : GradientDirection
toRight =
    Internal.ToRight


toTopRight : GradientDirection
toTopRight =
    Internal.ToTopRight


toBottomRight : GradientDirection
toBottomRight =
    Internal.ToBottomRight


toLeft : GradientDirection
toLeft =
    Internal.ToLeft


toTopLeft : GradientDirection
toTopLeft =
    Internal.ToTopLeft


toBottomLeft : GradientDirection
toBottomLeft =
    Internal.ToBottomLeft


{-| Gradient angle given in radians.
-}
toAngle : Float -> GradientDirection
toAngle =
    Internal.ToAngle


{-|


-}
gradient : GradientDirection -> List GradientStep -> Background
gradient dir steps =
    Internal.BackgroundLinearGradient dir steps


{-| -}
image : String -> Background
image src =
    Internal.BackgroundImage
        { src = src
        , position = ( 0, 0 )
        , repeat = noRepeat
        }


{-| -}
imageWith :
    { src : String
    , position : ( Float, Float )
    , repeat : Repeat
    }
    -> Background
imageWith =
    Internal.BackgroundImage


{-| -}
repeatX : Repeat
repeatX =
    Internal.RepeatX


{-| -}
repeatY : Repeat
repeatY =
    Internal.RepeatY


{-| -}
repeat : Repeat
repeat =
    Internal.Repeat


{-| -}
space : Repeat
space =
    Internal.Space


{-| -}
round : Repeat
round =
    Internal.Round


{-| -}
noRepeat : Repeat
noRepeat =
    Internal.NoRepeat
