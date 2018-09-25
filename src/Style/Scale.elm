module Style.Scale exposing (modular, roundedModular)

{-| When designing it's nice to use a modular scale to set spacial rythms.

    scaled =
        Scale.modular 16 1.618

A modular scale starts with a number, and multiplies it by a ratio a number of times.

Then, when setting font sizes you can use:

    Font.size (scaled 1) -- results in 16

    Font.size (scaled 2) -- 16 * 1.618 results in 25.8

    Font.size (scaled 4) -- 16 * 1.618 ^ (4 - 1) results in 67.8

We can also provide negative numbers to scale below 16px.

    Font.size (scaled -1) -- 16 * 1.618 ^ (-1) results in 9.9

@docs modular, roundedModular

-}


{-| Given a normal size and a ratio, returns a function which takes a scale parameter and returns a new size
-}
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
    if scale == 0 then
        normal
    else if scale < 0 then
        normal * ratio ^ (toFloat scale)
    else
        normal * ratio ^ (toFloat scale - 1)
