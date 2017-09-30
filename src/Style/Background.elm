module Style.Background
    exposing
        ( contain
        , cover
        , coverImage
        , gradient
        , gradientBottomLeft
        , gradientBottomRight
        , gradientDown
        , gradientLeft
        , gradientRight
        , gradientTopLeft
        , gradientTopRight
        , gradientUp
        , height
        , image
        , imageWith
        , natural
        , noRepeat
        , percent
        , px
        , repeat
        , repeatX
        , repeatY
        , size
        , space
        , step
        , stretch
        , width
        )

{-|


## Background Image

@docs image, coverImage, imageWith, repeatX, repeatY, repeat, space, stretch, noRepeat


### Background Image Sizes

@docs natural, cover, contain, width, height, size


## Background Gradient

@docs gradient, step, percent, px


## Directed Gradients

@docs gradientRight, gradientLeft, gradientUp, gradientDown, gradientTopRight, gradientBottomRight, gradientTopLeft, gradientBottomLeft

-}

import Color exposing (Color)
import Style exposing (Property)
import Style.Internal.Model as Internal


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


{-| A background image that keeps it's natural width and height.
-}
image : String -> Property class variation
image src =
    Internal.Background <|
        Internal.BackgroundImage
            { src = src
            , position = ( 0, 0 )
            , repeat = noRepeat
            , size = natural
            }


{-| A background image that will scale to cover the entire background.
-}
coverImage : String -> Property class variation
coverImage src =
    Internal.Background <|
        Internal.BackgroundImage
            { src = src
            , position = ( 0, 0 )
            , repeat = noRepeat
            , size = cover
            }


{-| -}
type alias Size =
    Internal.BackgroundSize


{-| Scale the image proportionally so that it fits entirely in view.
-}
contain : Size
contain =
    Internal.Contain


{-| Scale the image proportionally so that it covers the background.
-}
cover : Size
cover =
    Internal.Cover


{-| Keep the image at it's natural size.
-}
natural : Size
natural =
    size
        { height = Internal.Auto
        , width = Internal.Auto
        }


{-| Set only the background image width, the height will be scaled autmatically.
-}
width : Internal.Length -> Size
width =
    Internal.BackgroundWidth


{-| Set only the background image height, the width will be scaled autmatically.
-}
height : Internal.Length -> Size
height =
    Internal.BackgroundHeight


{-| Set both the width and height independently. This can potentially skew the image.
-}
size : { height : Internal.Length, width : Internal.Length } -> Size
size =
    Internal.BackgroundSize


{-| -}
imageWith :
    { src : String
    , position : ( Float, Float )
    , repeat : Repeat
    , size : Size
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


{-| Leftover space between tiled images will be blank.
-}
space : Repeat
space =
    Internal.Space


{-| Images will stretch to take up to take up leftover space. Background position will be ignored.
-}
stretch : Repeat
stretch =
    Internal.Round


{-| -}
noRepeat : Repeat
noRepeat =
    Internal.NoRepeat
