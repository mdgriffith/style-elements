module Scale exposing (modular, integer)

{-| Useful scales to generate consistent design.

@docs modular, integer

-}


{-| When dealing with font sizes, it's nice to use a modular scale, which means all font sizes are related via a ratio.

Here's how it's done, first create a scale:

    scaled =
        Scale.modular 16 1.618

You can read this as "Starting at a base of 16, create a modular scale using the ratio 1.618."

Then, when setting font sizes you can use:

This will set the font size to 16px:

    Font.size (scaled 1)

Or we can scale up one level (which multiplies the result by 1.618):

    Font.size (scaled 2)

This results in a font size of 25.8px.

We can also provide negative numbers to scale below 16px.

-}
modular : Float -> Float -> Int -> Float
modular normal ratio fontScale =
    resize normal ratio fontScale


{-| Same as `scale` but rounds to an `Int`. This should be used for font sizes.
-}
integer : Float -> Float -> Int -> Int
integer normal ratio fontScale =
    round <| resize normal ratio fontScale


resize : Float -> Float -> Int -> Float
resize normal ratio fontScale =
    if fontScale == 0 || fontScale == 1 then
        normal
    else if fontScale < 0 then
        shrink ratio (fontScale * -1) normal
    else
        grow ratio (fontScale - 1) normal


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
