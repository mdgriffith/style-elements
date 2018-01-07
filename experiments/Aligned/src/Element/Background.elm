module Element.Background
    exposing
        ( color
        , fittedImage
        , gradient
        , image
        , mouseOverColor
        , tiled
        , tiledX
        , tiledY
        )

{-|

@docs color, mouseOverColor, gradient

@docs image, fittedImage, tiled, tiledX, tiledY

-}

import Color exposing (Color)
import Internal.Model exposing (..)


{-| The background will change to this color when the mouse is over it.
-}
mouseOverColor : Color -> Attribute msg
mouseOverColor clr =
    hover (Colored ("hover-bg-" ++ formatColorClass clr) "background-color" clr)


{-| -}
color : Color -> Attribute msg
color clr =
    StyleClass (Colored ("bg-" ++ formatColorClass clr) "background-color" clr)


{-| A background image that keeps it's natural width and height.
-}
image : String -> Attribute msg
image src =
    StyleClass (Single ("bg-image-" ++ className src) "background" ("url(\"" ++ src ++ "\") top left / contain no-repeat"))


{-| Scale the image to fit the size of the element while maintaining proportions and cropping the overflow.
-}
fittedImage : String -> Attribute msg
fittedImage src =
    StyleClass (Single ("bg-fitted-image-" ++ className src) "background" ("url(\"" ++ src ++ "\") top left / cover no-repeat"))


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


type Direction
    = ToUp
    | ToDown
    | ToRight
    | ToTopRight
    | ToBottomRight
    | ToLeft
    | ToTopLeft
    | ToBottomLeft
    | ToAngle Float


type Step
    = ColorStep Color
    | PercentStep Float Color
    | PxStep Int Color


{-| -}
step : Color -> Step
step =
    ColorStep


{-| -}
px : Int -> Color -> Step
px =
    PxStep


{-| A linear gradient.

First you need to specify what direction the gradient is going by providing an angle in radians. `0` is up and `pi` is down.

The colors will be evenly spaced.

-}
gradient : Float -> List Color -> Attribute msg
gradient angle colors =
    StyleClass <|
        Single ("bg-gradient-" ++ (String.join "-" <| floatClass angle :: List.map formatColorClass colors))
            "background"
            ("linear-gradient(" ++ (String.join ", " <| (toString angle ++ "rad") :: List.map formatColor colors) ++ ")")



-- {-| -}
-- gradientWith : { direction : Direction, steps : List Step } -> Attribute msg
-- gradientWith { direction, steps } =
--     StyleClass <|
--         Single ("bg-gradient-" ++ (String.join "-" <| renderDirectionClass direction :: List.map renderStepClass steps))
--             "background"
--             ("linear-gradient(" ++ (String.join ", " <| renderDirection direction :: List.map renderStep steps) ++ ")")
-- {-| -}
-- renderStep : Step -> String
-- renderStep step =
--     case step of
--         ColorStep color ->
--             formatColor color
--         PercentStep percent color ->
--             formatColor color ++ " " ++ toString percent ++ "%"
--         PxStep px color ->
--             formatColor color ++ " " ++ toString px ++ "px"
-- {-| -}
-- renderStepClass : Step -> String
-- renderStepClass step =
--     case step of
--         ColorStep color ->
--             formatColorClass color
--         PercentStep percent color ->
--             formatColorClass color ++ "-" ++ floatClass percent ++ "p"
--         PxStep px color ->
--             formatColorClass color ++ "-" ++ toString px ++ "px"
-- toUp : Direction
-- toUp =
--     ToUp
-- toDown : Direction
-- toDown =
--     ToDown
-- toRight : Direction
-- toRight =
--     ToRight
-- toTopRight : Direction
-- toTopRight =
--     ToTopRight
-- toBottomRight : Direction
-- toBottomRight =
--     ToBottomRight
-- toLeft : Direction
-- toLeft =
--     ToLeft
-- toTopLeft : Direction
-- toTopLeft =
--     ToTopLeft
-- toBottomLeft : Direction
-- toBottomLeft =
--     ToBottomLeft
-- radians : Float -> Direction
-- radians rad =
--     ToAngle rad
-- renderDirection : Direction -> String
-- renderDirection dir =
--     case dir of
--         ToUp ->
--             "to top"
--         ToDown ->
--             "to bottom"
--         ToRight ->
--             "to right"
--         ToTopRight ->
--             "to top right"
--         ToBottomRight ->
--             "to bottom right"
--         ToLeft ->
--             "to left"
--         ToTopLeft ->
--             "to top left"
--         ToBottomLeft ->
--             "to bottom left"
--         ToAngle angle ->
--             toString angle ++ "rad"
-- renderDirectionClass : Direction -> String
-- renderDirectionClass dir =
--     case dir of
--         ToUp ->
--             "to-top"
--         ToDown ->
--             "to-bottom"
--         ToRight ->
--             "to-right"
--         ToTopRight ->
--             "to-top-right"
--         ToBottomRight ->
--             "to-bottom-right"
--         ToLeft ->
--             "to-left"
--         ToTopLeft ->
--             "to-top-left"
--         ToBottomLeft ->
--             "to-bottom-left"
--         ToAngle angle ->
--             floatClass angle ++ "rad"
