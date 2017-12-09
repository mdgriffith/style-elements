module Element.Background exposing (color, image, tiled, tiledX, tiledY)

{-|

@docs color, image, tiled, tiledX, tiledY

      Background images

        - image []
        - tiledX []
        - tiledY []
        - tiled []

Gradient

       - gradient : Float -> List GradientStep -> Property class variation

       - gradientTopRight
       - gradientTopLeft
       - gradientBottomRight
       - gradientBottomLeft

-}

import Color exposing (Color)
import Internal.Model exposing (..)


{-| -}
color : Color -> Attribute msg
color clr =
    StyleClass (Colored ("bg-" ++ formatColorClass clr) "background-color" clr)


{-| A background image that keeps it's natural width and height.
-}
image : String -> Attribute msg
image src =
    StyleClass (Single ("bg-image-" ++ className src) "background" ("url(\"" ++ src ++ "\")"))


{-| Scale the image to fit the size of the element while maintaining proportions and cropping the overflow.
-}
fittedImage : String -> Attribute msg
fittedImage src =
    StyleClass (Single ("bg-fitted-image-" ++ className src) "background" ("url(\"" ++ src ++ "\") cover"))


{-| Tile an image in the x and y axes.
-}
tiled : String -> Attribute msg
tiled src =
    StyleClass (Single ("bg-image-" ++ className src) "background" ("url(\"" ++ src ++ "\") repeat"))


{-| Tile an image in the x axis.
-}
tiledX : String -> Attribute msg
tiledX src =
    StyleClass (Single ("bg-image-" ++ className src) "background" ("url(\"" ++ src ++ "\") repeat-x"))


{-| Tile an image in the y axis.
-}
tiledY : String -> Attribute msg
tiledY src =
    StyleClass (Single ("bg-image-" ++ className src) "background" ("url(\"" ++ src ++ "\") repeat-y"))


type GradientDirection
    = ToUp
    | ToDown
    | ToRight
    | ToTopRight
    | ToBottomRight
    | ToLeft
    | ToTopLeft
    | ToBottomLeft
    | ToAngle Float


type GradientStep
    = ColorStep Color
    | PercentStep Float Color
    | PxStep Float Color


{-| -}
step : Color -> GradientStep
step =
    ColorStep


{-| -}
percent : Float -> Color -> GradientStep
percent =
    PercentStep


{-| -}
px : Float -> Color -> GradientStep
px =
    PxStep


renderStep step =
    case step of
        ColorStep color ->
            formatColor color

        PercentStep percent color ->
            formatColor color ++ " " ++ toString percent ++ "%"

        PxStep px color ->
            formatColor color ++ " " ++ toString percent ++ "px"


renderStepClass step =
    case step of
        ColorStep color ->
            formatColorClass color

        PercentStep percent color ->
            formatColorClass color ++ "-" ++ toString percent ++ "p"

        PxStep px color ->
            formatColorClass color ++ "-" ++ toString percent ++ "px"


{-| -}
gradient : Float -> List GradientStep -> Attribute msg
gradient angle steps =
    StyleClass <|
        Single ("bg-gradient-" ++ (String.join "-" <| toString angle :: List.map renderStepClass steps))
            "background"
            ("linear-gradient(" ++ (String.join ", " <| (toString angle ++ "rad") :: List.map renderStep steps) ++ ")")
