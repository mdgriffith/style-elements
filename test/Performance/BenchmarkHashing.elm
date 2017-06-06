module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Style exposing (..)
import Style.Font as Font
import Style.Border as Border
import Style.Media
import Style.Sheet
import Color


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
    = NavBar
    | Button
    | OtherButton


type Variation
    = Warning
    | Error
    | Success


manyStyles =
    styles
        |> List.repeat 1000
        |> List.concat


styles =
    [ style NavBar
        [ block
        , font
            [ Font.stack [ "Open Sans" ]
            , Font.size 18
            , Font.letterSpacing 20
            , Font.light
            , Font.center
            , Font.uppercase
            ]
        , box
            [ width (px 10)
            , height (px 200)
            ]
        , border
            [ Border.width (all 5)
            , Border.radius (all 5)
            , Border.solid
            ]
        , Style.variation Error
            [ font
                [ Font.color Color.red
                ]
            ]
        , Style.child Button
            [ blockSpaced (all 10)
            , variation Error
                [ font
                    [ Font.color Color.red
                    ]
                ]
            ]
        , Style.Media.phoneOnly
            [ block
            , font
                [ Font.stack [ "Open Sans" ]
                , Font.size 18
                , Font.letterSpacing 20
                , Font.light
                , Font.center
                , Font.uppercase
                ]
            , box
                [ width (px 10)
                , height (px 200)
                ]
            , border
                [ Border.width (all 5)
                , Border.radius (all 5)
                , Border.solid
                ]
            ]
        ]
    ]
