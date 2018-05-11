module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Color exposing (..)
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Internal.Model as Internal
import Internal.Style exposing (..)


main : BenchmarkProgram
main =
    program suite


suite : Benchmark
suite =
    describe "Simple Test, Two styles"
        [ benchmark1 "Gathering Attributes"
            (List.foldr Internal.gatherAttributes (Internal.initGathered Nothing))
            [ Font.color yellow
            , Background.color green
            , Font.size 30
            , Border.width 3
            , Border.color yellow
            ]
        , benchmark1 "Format Color" Internal.formatColor red
        , benchmark1 "Fast Format Color" fastColor red
        , benchmark1 "Format Font" Font.family [ Font.typeface "Helvetica", Font.sansSerif ]
        , benchmark1 "Get Class as record" .pointer classesRecord
        , benchmark1 "Get Class as fn" findClass Pointer
        ]


fastColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    "c" ++ fastChannel red ++ fastChannel green ++ fastChannel blue ++ fastChannel (round (255 * alpha))


fastChannel x =
    case min 255 (max 0 x) of
        0 ->
            "0"

        1 ->
            "1"

        2 ->
            "2"

        _ ->
            "9"


classesRecord =
    { pointer = "p"
    , widthFill = "w"
    , heightFill = "x"
    }


type Class
    = Pointer
    | WidthFill
    | HeightFill


findClass cls =
    case cls of
        Pointer ->
            "p"

        WidthFill ->
            "w"

        HeightFill ->
            "x"
