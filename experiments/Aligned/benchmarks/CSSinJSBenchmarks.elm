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


suite : Benchmark
suite =
    describe "Simple Test, Two styles"
        [ benchmark1 "1 container, 1 el" simple ()
        , benchmark1 "Repeated Empty Styles" repeatedEmptyStyles 20
        , benchmark1 "Repeated Styles" repeatedStyles 20
        , benchmark1 "Overlapping Styles" overlappingStyles 20
        , benchmark1 "Gathering Attributes"
            (List.foldr Internal.gatherAttributes (Internal.initGathered Nothing))
            [ Font.color yellow
            , Background.color green
            , Font.size 30
            , Border.width 3
            , Border.color yellow
            ]

        -- , benchmark1 "Format Color" Internal.formatColor red
        -- , benchmark1 "Format Font" Font.family [ Font.typeface "Helvetica", Font.sansSerif ]
        -- , benchmark1 "Raw render" rawRender ()
        ]


rawRender _ =
    ".my-test-string" ++ "{" ++ "backgorund-color" ++ ":" ++ Internal.formatColor red ++ ";" ++ "color" ++ ":" ++ Internal.formatColor yellow ++ "}"


simple : a -> Html.Html msg
simple _ =
    Element.layoutWith
        { options =
            [ Internal.RenderModeOption Internal.NoStaticStyleSheet
            ]
        }
        [ Font.color yellow
        , Background.color purple
        , Font.center
        , Element.padding 50
        ]
    <|
        Element.el
            [ Font.color yellow
            , Background.color green
            , Font.size 30
            , Border.width 3
            , Border.color yellow
            ]
            Element.empty


overlappingStyles : Int -> Html msg
overlappingStyles i =
    Element.layoutWith
        { options =
            [ Internal.RenderModeOption Internal.NoStaticStyleSheet
            ]
        }
        []
    <|
        Element.row
            [ --     Font.color yellow
              Background.color purple

            -- , Font.center
            -- , Element.padding 50
            ]
            (flip List.map
                (List.range 1 i)
                (\j ->
                    Element.el
                        [ Background.color green
                        , Element.padding j
                        ]
                        Element.empty
                )
            )


repeatedEmptyStyles : Int -> Html msg
repeatedEmptyStyles i =
    Element.layoutWith
        { options =
            [ Internal.RenderModeOption Internal.NoStaticStyleSheet
            ]
        }
        []
    <|
        Element.row
            [--     Font.color yellow
             --   Background.color purple
             -- , Font.center
             -- , Element.padding 50
            ]
            (flip List.map
                (List.range 1 i)
                (\j ->
                    Element.el
                        [--Background.color green
                        ]
                        Element.empty
                )
            )


repeatedStyles : Int -> Html msg
repeatedStyles i =
    Element.layoutWith
        { options =
            [ Internal.RenderModeOption Internal.NoStaticStyleSheet
            ]
        }
        []
    <|
        Element.row
            [ --     Font.color yellow
              Background.color purple

            -- , Font.center
            -- , Element.padding 50
            ]
            (flip List.map
                (List.range 1 i)
                (\j ->
                    Element.el
                        [ Background.color green
                        ]
                        Element.empty
                )
            )
