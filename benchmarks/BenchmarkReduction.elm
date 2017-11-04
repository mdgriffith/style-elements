module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Color exposing (Color)
import Dict
import Set


main : BenchmarkProgram
main =
    program suite


suite : Benchmark
suite =
    describe "Stylesheet Hashing - 10k dicts of size ~2, with 3k potential keys"
        [ benchmark1 "merge dicts via foldr Dict.union" merge dicts
        , benchmark1 "check key Set when rendering, skip if found" reduceAndRenderList list
        , benchmark1 "1render everything" renderList list
        , benchmark1 "maybe dicts, skip union if a maybe" mergeMaybeDict maybeDicts
        , benchmark1 "dict insert ten things" insert10Things ()
        , benchmark1 "dict union 2 dicts of 5 things" union25 ()
        , benchmark1 "formatting color" formatColor Color.red
        , benchmark1 "color tuple lookup" (\color -> Dict.get (colorToTuple color) colorNameDict) Color.red
        ]


colorToTuple color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    ( red, green, blue, alpha )


colorNameDict =
    Dict.fromList
        [ ( colorToTuple Color.red, formatColor Color.red )
        , ( colorToTuple Color.blue, formatColor Color.blue )
        , ( colorToTuple Color.green, formatColor Color.green )
        , ( colorToTuple Color.yellow, formatColor Color.yellow )
        ]


formatColor : Color -> String
formatColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    ("rgba(" ++ toString red)
        ++ ("," ++ toString green)
        ++ ("," ++ toString blue)
        ++ ("," ++ toString alpha ++ ")")


insert10Things _ =
    Dict.empty
        |> Dict.insert 1 1
        |> Dict.insert 2 2
        |> Dict.insert 3 3
        |> Dict.insert 4 4
        |> Dict.insert 5 5
        |> Dict.insert 6 6
        |> Dict.insert 7 7
        |> Dict.insert 8 8
        |> Dict.insert 9 9
        |> Dict.insert 10 10


dictOne =
    Dict.empty
        |> Dict.insert 1 1
        |> Dict.insert 2 2
        |> Dict.insert 3 3
        |> Dict.insert 4 4
        |> Dict.insert 5 5


dictTwo =
    Dict.empty
        |> Dict.insert 6 6
        |> Dict.insert 7 7
        |> Dict.insert 8 8
        |> Dict.insert 9 9
        |> Dict.insert 10 10


union25 _ =
    Dict.union dictOne dictTwo


type Style
    = Style String (List ( String, String ))



-- 10k dicts with avg of 2 values, with 3k possible keys


range =
    List.range 1 10000


keySize =
    300


mergeMaybeDict ds =
    let
        unionMaybe new existing =
            case new of
                Nothing ->
                    existing

                Just styleDict ->
                    case existing of
                        Nothing ->
                            Just styleDict

                        Just existingStyleDict ->
                            Just (Dict.union styleDict existingStyleDict)
    in
    List.foldr unionMaybe Nothing ds
        |> Maybe.map renderDict
        |> Maybe.withDefault ""


maybeDicts : List (Maybe (Dict.Dict String (List ( String, String ))))
maybeDicts =
    List.map createMaybeDict range


createMaybeDict : Int -> Maybe (Dict.Dict String (List ( String, String )))
createMaybeDict i =
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
    case i % 5 of
        0 ->
            Nothing

        1 ->
            Just <|
                Dict.fromList
                    [ prop i ]

        2 ->
            Just <|
                Dict.fromList
                    [ prop i
                    , prop (i + 1)
                    ]

        3 ->
            Just <|
                Dict.fromList
                    [ prop i
                    , prop (i + 1)
                    , prop (i + 2)
                    ]

        4 ->
            Just <|
                Dict.fromList
                    [ prop i
                    , prop (i + 1)
                    , prop (i + 2)
                    , prop (i + 3)
                    ]

        _ ->
            Just <|
                Dict.fromList
                    [ prop i
                    , prop (i + 1)
                    , prop (i + 2)
                    , prop (i + 3)
                    ]


dicts : List (Dict.Dict String (List ( String, String )))
dicts =
    List.map createDict range


createDict : Int -> Dict.Dict String (List ( String, String ))
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
    case i % 5 of
        0 ->
            Dict.empty

        1 ->
            Dict.fromList
                [ prop i ]

        2 ->
            Dict.fromList
                [ prop i
                , prop (i + 1)
                ]

        3 ->
            Dict.fromList
                [ prop i
                , prop (i + 1)
                , prop (i + 2)
                ]

        4 ->
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


renderDict : Dict.Dict comparable (List ( String, String )) -> String
renderDict dict =
    Dict.toList dict
        |> renderList


renderList : List ( a, List ( String, String ) ) -> String
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


listMaybe =
    List.foldr addToList [] range


list : List ( String, List ( String, String ) )
list =
    List.foldr addToList [] range


addToList : Int -> List ( String, List ( String, String ) ) -> List ( String, List ( String, String ) )
addToList i ls =
    let
        val x =
            x % 20

        name x =
            x % 150

        key x =
            x % keySize

        -- Number of unique values allowed
        class variation =
            ( toString (key variation)
            , [ ( toString (name variation), toString (val (i * variation)) )
              ]
            )
    in
    case i % 4 of
        0 ->
            class i :: ls

        1 ->
            class i
                :: class (i + 1)
                :: ls

        2 ->
            class i
                :: class (i + 1)
                :: class (i + 2)
                :: ls

        3 ->
            class i
                :: class (i + 1)
                :: class (i + 2)
                :: class (i + 3)
                :: ls

        _ ->
            [ class i
            , class (i + 1)
            , class (i + 2)
            , class (i + 3)
            ]


merge : List (Dict.Dict comparable (List ( String, String ))) -> String
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
