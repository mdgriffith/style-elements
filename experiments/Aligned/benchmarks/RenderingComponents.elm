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


main : BenchmarkProgram
main =
    program suite


intToString : Int -> String
intToString i =
    case i of
        0 ->
            "0"

        1 ->
            "1"

        2 ->
            "2"

        _ ->
            toString i


suite : Benchmark
suite =
    describe "The Functions Needed to Render an Element"
        [ benchmark1 "toString" toString 0
        , benchmark1 "inttToString" intToString 0
        , benchmark1 "Raw render" rawRender ()
        , describe "Font Rendering"
            [ benchmark1 "Format Font" Font.family [ Font.typeface "Helvetica", Font.sansSerif ]
            , benchmark1 "Font Family Property"
                Font.family
                [ Font.typeface "Helvetica"
                , Font.sansSerif
                ]
            ]
        , describe "Color Rendering"
            [ benchmark1 "Color Class"
                Internal.formatColorClass
                yellow
            , benchmark1 "Format Color" Internal.formatColor red
            , benchmark1 "Font Color Property"
                Font.color
                yellow
            , benchmark1 "Deconstructing Color" Color.toRgb yellow
            , benchmark1 "Comparing Color Match" ((==) yellow) yellow
            , benchmark1 "Comparing Color NoMatch" ((==) red) yellow
            ]
        , describe "Preparing Attributes"
            [ benchmark1 "Gathering Attributes: Font Color, Background COlor,"
                (Internal.renderAttributes Nothing [])
                [ Font.color yellow
                , Background.color green
                , Font.size 30
                , Border.width 3
                , Border.color yellow
                , Font.family
                    [ Font.typeface "Helvetica"
                    , Font.sansSerif
                    ]
                ]
            , benchmark1 "Final Formatting"
                Internal.formatTransformations
                (Internal.initGathered Nothing [])
            ]
        ]


rawRender _ =
    ".my-test-string" ++ "{" ++ "backgorund-color" ++ ":" ++ Internal.formatColor red ++ ";" ++ "color" ++ ":" ++ Internal.formatColor yellow ++ "}"
