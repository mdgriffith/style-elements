module ScaleTest exposing (..)

import Expect
import Style.Scale exposing (roundedModular)
import Fuzz exposing (intRange, floatRange)
import Test exposing (..)


fakeModular : Float -> Float -> Int -> Float
fakeModular a b n =
    let
        resize n =
            if n > 0 then
                a * b ^ (n - 1)
            else
                a * b ^ n
    in
        case n of
            0 ->
                a

            x ->
                resize x


fakeRounded a b =
    toFloat << round << fakeModular a b


expecter : Float -> Float -> Int -> Expect.Expectation
expecter a b n =
    (fakeRounded a b n == roundedModular a b n)
        |> Expect.true "implementations don't match"


normal =
    floatRange 1 200


ratio =
    floatRange 1 3


exponent =
    intRange -10 10


suite =
    fuzz3
        normal
        ratio
        exponent
        "Check that the implementation matches my implementation"
        expecter
