module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Style exposing (..)
import Style.Font as Font
import Style.Border as Border
import Style.Sheet
import Color
import Style.Color as Color


main : BenchmarkProgram
main =
    program suite


suite : Benchmark
suite =
    describe "Stylesheet Hashing"
        [ Benchmark.compare "1 complex style"
            (benchmark1 "normal" Style.Sheet.render styles)
            (benchmark1 "hashed" Style.Sheet.guarded styles)
        , Benchmark.compare "1000 styles"
            (benchmark1 "normal" Style.Sheet.render styles)
            (benchmark1 "hashed" Style.Sheet.guarded styles)
        ]


type Styles
    = None
    | Test


type Variation
    = Warning
    | Error
    | Success


manyStyles =
    styles
        |> List.repeat 1000
        |> List.concat


styles =
    Style.styleSheet
        [ Style.style None []
        , Style.style Test
            [ Color.background Color.red
            , Color.text Color.blue
            , Font.size 16
            , Border.all 1
            , Color.border Color.yellow
            ]
        ]
