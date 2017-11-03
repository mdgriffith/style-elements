module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Dict
import Set


main : BenchmarkProgram
main =
    program suite


type Style
    = Style String (List ( String, String ))



-- 10k dicts with avg of 2 values, with 3k possible keys


range =
    List.range 1 10000


keySize =
    50


dicts =
    List.map createDict range


createDict i =
    let
        val x =
            x % 20

        name x =
            x % 150

        key x =
            x % keySize

        -- Number of unique values allowed
        prop variation =
            ( toString (key variation)
            , [ ( toString (name variation), toString (val (i * variation)) )
              ]
            )
    in
    case i % 4 of
        0 ->
            Dict.fromList
                [ prop i ]

        1 ->
            Dict.fromList
                [ prop i
                , prop (i + 1)
                ]

        2 ->
            Dict.fromList
                [ prop i
                , prop (i + 1)
                , prop (i + 2)
                ]

        3 ->
            Dict.fromList
                [ prop i
                , prop (i + 1)
                , prop (i + 2)
                , prop (i + 3)
                ]

        _ ->
            Dict.fromList
                [ prop i
                , prop (i + 1)
                , prop (i + 2)
                , prop (i + 3)
                ]


renderDict dict =
    Dict.toList dict
        |> renderList


renderList ls =
    let
        renderProp ( name, val ) =
            name ++ ":" ++ val

        render ( key, vals ) =
            List.map renderProp vals
                |> String.join ";"

        gather el existing =
            render el ++ existing
    in
    List.foldr gather "" ls


list =
    List.foldr addToList [] range


addToList i ls =
    let
        val x =
            x % 20

        name x =
            x % 150

        key x =
            x % keySize

        -- Number of unique values allowed
        prop variation =
            ( toString (key variation)
            , [ ( toString (name variation), toString (val (i * variation)) )
              ]
            )
    in
    case i % 4 of
        0 ->
            prop i :: ls

        1 ->
            prop i
                :: prop (i + 1)
                :: ls

        2 ->
            prop i
                :: prop (i + 1)
                :: prop (i + 2)
                :: ls

        3 ->
            prop i
                :: prop (i + 1)
                :: prop (i + 2)
                :: prop (i + 3)
                :: ls

        _ ->
            [ prop i
            , prop (i + 1)
            , prop (i + 2)
            , prop (i + 3)
            ]


merge ds =
    List.foldr Dict.union Dict.empty ds
        |> renderDict


reduceList ls =
    renderList


reduceAndRenderList ls =
    let
        renderProp ( name, val ) =
            name ++ ":" ++ val

        render ( key, vals ) =
            List.map renderProp vals
                |> String.join ";"

        reduceNRender ( key, vals ) ( rendered, cache ) =
            if Set.member key cache then
                ( rendered, cache )
            else
                ( (List.map renderProp vals
                    |> String.join ";"
                  )
                    ++ "\n"
                    ++ rendered
                , Set.insert key cache
                )
    in
    List.foldr reduceNRender ( "", Set.empty ) ls


suite : Benchmark
suite =
    describe "Stylesheet Hashing"
        [ benchmark1 "merge 10k dicts, size ~2, 3k potential keys" merge dicts
        , benchmark1 "merge 10k list, size ~2, 3k potential keys" reduceAndRenderList list
        , benchmark1 "10k list, size ~2, 3k potential keys, no reduction" renderList list
        ]
