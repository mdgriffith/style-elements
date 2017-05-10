module Style.Background exposing (..)

{-| -}

import Style.Internal.Model as Internal
import Color exposing (Color)
import Style exposing (Property)


{-| -}
type alias GradientDirection =
    Internal.GradientDirection


{-| -}
type alias GradientStep =
    Internal.GradientStep


{-| -}
type alias Repeat =
    Internal.Repeat


{-| -}
step : Color -> GradientStep
step =
    Internal.ColorStep


{-| -}
percent : Color -> Float -> GradientStep
percent =
    Internal.PercentStep


{-| -}
px : Color -> Float -> GradientStep
px =
    Internal.PxStep


{-| -}
toUp : GradientDirection
toUp =
    Internal.ToUp


{-| -}
toDown : GradientDirection
toDown =
    Internal.ToDown


{-| -}
toRight : GradientDirection
toRight =
    Internal.ToRight


{-| -}
toTopRight : GradientDirection
toTopRight =
    Internal.ToTopRight


{-| -}
toBottomRight : GradientDirection
toBottomRight =
    Internal.ToBottomRight


{-| -}
toLeft : GradientDirection
toLeft =
    Internal.ToLeft


{-| -}
toTopLeft : GradientDirection
toTopLeft =
    Internal.ToTopLeft


{-| -}
toBottomLeft : GradientDirection
toBottomLeft =
    Internal.ToBottomLeft


{-| Gradient angle given in radians.
-}
toAngle : Float -> GradientDirection
toAngle =
    Internal.ToAngle


{-| -}
gradient : GradientDirection -> List GradientStep -> Property class variation animation
gradient dir steps =
    Internal.Background <|
        Internal.BackgroundLinearGradient dir steps


{-| -}
image : String -> Property class variation animation
image src =
    Internal.Background <|
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
    -> Property class variation animation
imageWith attrs =
    Internal.Background <|
        Internal.BackgroundImage attrs


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
