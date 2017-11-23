module Main exposing (..)

{-| -}

import Html
import Time exposing (Time)


main =
    Html.program
        { init = ( 0, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { results : List BenchmarkResult
    }


type alias BenchmarkResult =
    { description : String
    , layout : Time
    , paint : Time
    , recalc_styles : Time
    , updateLayerTree : Time
    , js : Time
    , parse_css : Time
    , garbage_collection : GarbageCollection
    }


type alias GarbageCollection =
    { number_events : Int
    , reclaimed_bytes : Int
    , total_duration : Time
    }


update msg model =
    ( model, Cmd.none )


view model =
    Html.div [] []
