module ScaleTest exposing (..)

import Expect
import Style.Scale exposing (roundedModular)
import Fuzz exposing (intRange, floatRange)
import Test exposing (..)


fakeModular : Float -> Float -> Int -> Float
fakeModular a b n =
    if n == 0 then
        a
    else if n < 0 then
        a * b ^ (toFloat n)
    else
        a * b ^ (toFloat n - 1)


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
