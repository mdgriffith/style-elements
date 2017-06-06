module Style.Background
    exposing
        ( step
        , percent
        , px
        , gradientRight
        , gradientLeft
        , gradientUp
        , gradientDown
        , gradientTopRight
        , gradientBottomRight
        , gradientTopLeft
        , gradientBottomLeft
        , gradient
        , image
        , imageWith
        , repeatX
        , repeatY
        , repeat
        , space
        , round
        , noRepeat
        )

{-|


## Background Image

@docs image, imageWith, repeatX, repeatY, repeat, space, round, noRepeat


## Background Gradient

@docs gradient, step, percent, px


## Directed Gradients

@docs gradientRight, gradientLeft, gradientUp, gradientDown, gradientTopRight, gradientBottomRight, gradientTopLeft, gradientBottomLeft

-}

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
percent : Float -> Color -> GradientStep
percent p c =
    Internal.PercentStep c p


{-| -}
px : Float -> Color -> GradientStep
px p c =
    Internal.PxStep c p


{-| Here's an example of creating a background gradient:

    Background.gradient 0 [ step Color.blue, step Color.green]

The first number of the gradient angle given in radians, where 0 is pointing up.

-}
gradient : Float -> List GradientStep -> Property class variation
gradient angle steps =
    steps
        |> Internal.BackgroundLinearGradient (Internal.ToAngle angle)
        |> Internal.Background


{-| -}
gradientUp : List GradientStep -> Property class variation
gradientUp steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToUp
        |> Internal.Background


{-| -}
gradientDown : List GradientStep -> Property class variation
gradientDown steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToDown
        |> Internal.Background


{-| -}
gradientRight : List GradientStep -> Property class variation
gradientRight steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToRight
        |> Internal.Background


{-| -}
gradientTopRight : List GradientStep -> Property class variation
gradientTopRight steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToTopRight
        |> Internal.Background


{-| -}
gradientBottomRight : List GradientStep -> Property class variation
gradientBottomRight steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToBottomRight
        |> Internal.Background


{-| -}
gradientLeft : List GradientStep -> Property class variation
gradientLeft steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToLeft
        |> Internal.Background


{-| -}
gradientTopLeft : List GradientStep -> Property class variation
gradientTopLeft steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToTopLeft
        |> Internal.Background


{-| -}
gradientBottomLeft : List GradientStep -> Property class variation
gradientBottomLeft steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToBottomLeft
        |> Internal.Background


{-| -}
image : String -> Property class variation
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
    -> Property class variation
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
