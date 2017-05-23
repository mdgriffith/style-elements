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

@docs gradientRight, gradientLeft, gradientUp, gradientDown, gradientTopRight, gradientBottomRight, gradientTopLeft, gradientBottomLeft, gradientAngle

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
percent : Color -> Float -> GradientStep
percent =
    Internal.PercentStep


{-| -}
px : Color -> Float -> GradientStep
px =
    Internal.PxStep


{-| Gradient angle given in radians.

Here's an example of creating a background gradient:

    Background.gradient 0 [ step Color.blue, step Color.green]

-}
gradient : Float -> List GradientStep -> Property class variation animation
gradient angle steps =
    steps
        |> Internal.BackgroundLinearGradient (Internal.ToAngle angle)
        |> Internal.Background


{-| -}
gradientUp : List GradientStep -> Property class variation animation
gradientUp steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToUp
        |> Internal.Background


{-| -}
gradientDown : List GradientStep -> Property class variation animation
gradientDown steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToDown
        |> Internal.Background


{-| -}
gradientRight : List GradientStep -> Property class variation animation
gradientRight steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToRight
        |> Internal.Background


{-| -}
gradientTopRight : List GradientStep -> Property class variation animation
gradientTopRight steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToTopRight
        |> Internal.Background


{-| -}
gradientBottomRight : List GradientStep -> Property class variation animation
gradientBottomRight steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToBottomRight
        |> Internal.Background


{-| -}
gradientLeft : List GradientStep -> Property class variation animation
gradientLeft steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToLeft
        |> Internal.Background


{-| -}
gradientTopLeft : List GradientStep -> Property class variation animation
gradientTopLeft steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToTopLeft
        |> Internal.Background


{-| -}
gradientBottomLeft : List GradientStep -> Property class variation animation
gradientBottomLeft steps =
    steps
        |> Internal.BackgroundLinearGradient Internal.ToBottomLeft
        |> Internal.Background


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
