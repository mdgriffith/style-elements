port module Tests.Run exposing (..)

{-| -}

import Testable.Runner
import Tests.Basic


main : Testable.Runner.TestableProgram
main =
    Testable.Runner.program
        [ ( "Basic Element", Tests.Basic.view ) ]
