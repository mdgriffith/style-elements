module Style.Scale exposing (modular, roundedModular)

{-| When designing it's nice to use a modular scale to set spacial rythms.

    scaled =
        Scale.modular 16 1.618

A modular scale starts with a number, and multiplies it by a ratio a number of times.

Then, when setting font sizes you can use:

    Font.size (scaled 1) -- results in 16

    Font.size (scaled 2) -- 16 * (1.618 ^ 2) results in 25.8

We can also provide negative numbers to scale below 16px.

@docs modular, roundedModular

-}


{-| -}
modular : Float -> Float -> Int -> Float
modular normal ratio fontScale =
    resize normal ratio fontScale


{-| Same a modular but rounds to the nearest integer.

Still returns a Float for compatibility reasons.

-}
roundedModular : Float -> Float -> Int -> Float
roundedModular normal ratio =
    toFloat << round << resize normal ratio


resize : Float -> Float -> Int -> Float
resize normal ratio scale =
    if scale == 0 || scale == 1 then
        normal
    else if scale < 0 then
        shrink ratio (scale * -1) normal
    else
        grow ratio (scale - 1) normal


grow : Float -> Int -> Float -> Float
grow ratio i size =
    if i <= 0 then
        size
    else
        grow ratio (i - 1) (size * ratio)


shrink : Float -> Int -> Float -> Float
shrink ratio i size =
    if i <= 0 then
        size
    else
        shrink ratio (i - 1) (size / ratio)
