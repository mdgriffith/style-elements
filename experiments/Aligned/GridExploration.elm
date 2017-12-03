module Main exposing (..)

import Color exposing (..)
import Element exposing (..)
import Element.Area
import Element.Attributes exposing (..)
import Element.Color as Color
import Html exposing (Html)
import Input as Input
import Internal.Style as Internal
import Json.Decode as Json
import Mouse
import Time exposing (Time)
import VirtualDom


main =
    Html.program
        { init =
            ( Debug.log "init"
                { timeline = 0
                , trackingMouse = False
                }
            , Cmd.none
            )
        , view = view
        , update = update
        , subscriptions =
            \model -> Sub.none
        }


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view model =
    layout [] <|
        row
            [ height fill
            , width fill
            , Color.background green
            ]
            [ column [ width fill, height fill ] []
            , column [ width fill, height fill ]
                [ el [ width fill, height fill, Color.background yellow ] (text "hello")
                , el [ width fill, height fill, Color.background red ] empty
                ]
            ]
