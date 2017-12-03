port module ViewResults exposing (..)

{-| -}

import Color exposing (Color)
import Html
import Html.Attributes
import Json.Decode as Json
import List.Extra
import Plot
import Svg
import Svg.Attributes exposing (..)
import Time exposing (Time)


main =
    Html.program
        { init =
            ( { benchmarks = [] }
            , Cmd.none
            )
        , view = view
        , update = update
        , subscriptions =
            \model -> results Parse
        }


port results : (Json.Value -> msg) -> Sub msg


type Msg
    = NoOp
    | Parse Json.Value


type alias Model =
    { benchmarks : List Benched
    }


type alias Benched =
    { implementation : String
    , scenario : String
    , results : BenchmarkResult
    , run : Int
    }


type alias BenchmarkResult =
    { recalcStyles : Time
    , total : Time
    , layout : Time
    , updateLayerTree : Time
    , paint : Time
    , js : Time
    , garbageCollection : List GC
    , parseCSS : Time
    }


type alias GC =
    { duration : Time, reclaimed : Bytes }


type alias Bytes =
    Float


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Parse json ->
            case Json.decodeValue (Json.list benchmarkResults) json of
                Ok results ->
                    ( { model | benchmarks = results }
                    , Cmd.none
                    )

                Err error ->
                    let
                        _ =
                            Debug.log "malformed results!" error
                    in
                    ( model, Cmd.none )


benchmarkResults : Json.Decoder Benched
benchmarkResults =
    Json.map4 Benched
        (Json.field "implementation" Json.string)
        (Json.field "scenario" Json.string)
        (Json.field "results" benchmarkTimes)
        (Json.field "run" Json.int)


benchmarkTimes : Json.Decoder BenchmarkResult
benchmarkTimes =
    Json.map8 BenchmarkResult
        (Json.field "recalc_styles" timeInMs)
        (Json.field "total_time" timeInMs)
        (Json.field "layout" timeInMs)
        (Json.field "updateLayerTree" timeInMs)
        (Json.field "paint" timeInMs)
        (Json.field "js" timeInMs)
        (Json.field "gc" (Json.list garbageCollectionDecoder))
        (Json.field "parse_css" timeInMs)


timeInMs =
    Json.float
        |> Json.map (\x -> x / 1000)


garbageCollectionDecoder : Json.Decoder GC
garbageCollectionDecoder =
    Json.map2 GC
        (Json.field "duration" Json.float)
        (Json.field "reclaimed_bytes" Json.float)


view : Model -> Html.Html Msg
view { benchmarks } =
    Html.div [ Html.Attributes.style [ ( "width", "1000px" ), ( "margin", "auto" ) ] ]
        [ Plot.viewBars
            (renderGroups (List.map barGroup))
            (groupData benchmarks)
        ]


renderGroups : (data -> List Plot.BarGroup) -> Plot.Bars data msg
renderGroups toGroups =
    { axis = Plot.normalAxis
    , toGroups = toGroups
    , styles =
        [ [ fill (formatColor Color.darkGreen) ]
        , [ fill (formatColor Color.green) ]
        , [ fill (formatColor Color.yellow) ]
        , [ fill (formatColor Color.orange) ]
        , [ fill (formatColor Color.red) ]
        , [ fill (formatColor Color.purple) ]
        , [ fill (formatColor Color.blue) ]
        , [ fill (formatColor Color.yellow) ]
        , [ fill (formatColor Color.orange) ]
        ]
    , maxWidth = Plot.Percentage 65
    }


barGroup data =
    { label =
        \x ->
            { view = viewLabel data.label
            , position = x
            }
    , hint = always Nothing
    , verticalLine = always Nothing
    , bars = List.map (\( label, val ) -> { height = val, label = Just (viewVerticalLabel label) }) data.values
    }


viewVerticalLabel str =
    Svg.g
        [ Svg.Attributes.transform "rotate(-90, 0, 0) translate(2, 3)"
        , Svg.Attributes.textAnchor "start"
        , Svg.Attributes.fontSize "8px"
        ]
        [ Svg.text_ [] [ Svg.tspan [] [ Svg.text str ] ] ]


viewLabel str =
    Svg.g
        [ Svg.Attributes.transform "rotate(-30, 0, 0)"
        , Svg.Attributes.textAnchor "end"
        ]
        [ Svg.text_ [] [ Svg.tspan [] [ Svg.text str ] ] ]


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


groupData benched =
    let
        toValues benches =
            { label = List.foldr (\x y -> x.implementation) "" benches
            , topLabel = ""
            , values =
                List.foldr
                    (\bench existing ->
                        ( "js", bench.results.js )
                            :: ( "parseCss", bench.results.parseCSS )
                            :: ( "recalc styles", bench.results.recalcStyles )
                            :: ( "layout", bench.results.layout )
                            :: ( "updateLayerTree", bench.results.updateLayerTree )
                            :: ( "paint", bench.results.paint )
                            :: ( "total", bench.results.total )
                            :: ( "gc - size", gcSize bench.results.garbageCollection )
                            -- :: ( "gc - time", gcTime bench.results.garbageCollection )
                            :: existing
                    )
                    []
                    benches
            }
    in
    benched
        -- |> List.head
        -- |> (\x ->
        --         case x of
        --             Nothing ->
        --                 []
        --             Just x ->
        --                 [ x ]
        --    )
        |> List.Extra.groupWhile (\one two -> one.implementation == two.implementation)
        |> List.map toValues


type alias Aggregated =
    { label : String
    , values : List Value
    , runCount : Int
    }


type alias Value =
    { name : String
    , standardDeviation : Float
    , mean : Float
    }


gcTime : List { duration : Time, reclaimed : Bytes } -> Time
gcTime ls =
    List.foldr ((+) << .duration) 0 ls


gcSize : List { duration : Time, reclaimed : Bytes } -> Bytes
gcSize ls =
    List.foldr ((+) << .reclaimed) 0 ls
        |> (\x -> x / 100000)



-- { recalcStyles : Time
-- , total : Time
-- , layout : Time
-- , updateLayerTree : Time
-- , paint : Time
-- , js : Time
-- , garbageCollection : List GC
-- , parseCSS : Time
-- }
