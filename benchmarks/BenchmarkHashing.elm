module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Color
import Murmur3
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Sheet


main : BenchmarkProgram
main =
    program suite


short =
    "hashmepls!"


medium =
    String.repeat 50 short


long =
    String.repeat 100 short


suite : Benchmark
suite =
    describe "Stylesheet Hashing"
        [ benchmark1 "short" (Murmur3.hashString 8675309) short
        , benchmark1 "medium" (Murmur3.hashString 8675309) medium
        , benchmark1 "long" (Murmur3.hashString 8675309) long
        , benchmark1 "converting ints" convertInt [ 0, 255, 0, 0, 2, 0, 0, 255, 3, 16, 4, 1, 5, 0, 255, 255 ]
        , benchmark1 "joining strs" (String.join "") [ "0", "25500", "2", "00255", "3", "16", "4", "1", "5", "0255255" ]

        -- Benchmark.compare "1 complex style"
        -- (benchmark1 "normal" Style.Sheet.render styles)
        -- (benchmark1 "hashed" Style.Sheet.guarded styles)
        -- , Benchmark.compare "1000 styles"
        --     (benchmark1 "normal" Style.Sheet.render styles)
        --     (benchmark1 "hashed" Style.Sheet.guarded styles)
        ]


test =
    Style.style Test
        [ Color.background Color.red
        , Color.text Color.blue
        , Font.size 16
        , Border.all 1
        , Color.border Color.yellow
        ]


convertInt i =
    List.map toString i
        |> String.join ""


_ =
    Debug.log "encoded"
        (List.map toString [ 0, 255, 0, 0, 2, 0, 0, 255, 3, 16, 4, 1, 5, 0, 255, 255 ]
            |> String.join ""
            |> String.length
        )
_ =
    Debug.log "average style" (String.length <| toString test)


type Styles
    = None
    | Test


type Variation
    = Warning
    | Error
    | Success



-- manyStyles =
--     styles
--         |> List.repeat 1000
--         |> List.concat
-- styles =
--     Style.styleSheet
--         [ Style.style None []
--         , Style.style Test
--             [ Color.background Color.red
--             , Color.text Color.blue
--             , Font.size 16
--             , Border.all 1
--             , Color.border Color.yellow
--             ]
--         ]
