module Main exposing (..)

{-| -}

import Element exposing (..)
import Element.Device
import Element.Attributes exposing (..)
import Html.Events
import Element.Style exposing (..)
import Element.Style.Background as Background
import Element.Events exposing (..)
import Color


main =
    Element.program
        { elements = Element.elements elements
        , device = Element.Device.match
        , view = view
        , init = ( 5, Cmd.none )
        , update = update
        , subscriptions =
            (\_ ->
                Sub.none
            )
        }


view device model =
    Element.row UnStyled
        [ spacing (all 25) ]
        [ el Test
            [ width (px 500)
            , height (px 80)
            , margin (all 20)
            ]
            (text "Hello World!")
        , el Test
            [ width (px 500)
            , height (px 80)
            ]
            (text "Hello World!")
            |> onRight
                (el TestEmbed
                    [ width (px 50)
                    , height (px 50)
                    , alignBottom
                    , adjust 0 0
                    ]
                    (text "I'm right!")
                )
            |> below
                (el TestEmbed
                    [ width (px 50)
                    , height (px 50)
                    , alignRight
                    , adjust 0 0
                    ]
                    (text "I'm below!")
                )
        ]


update msg model =
    ( model, Cmd.none )


type Msg
    = Blink


type Elements
    = Test
    | UnStyled
    | TestEmbed


elements elem =
    case elem of
        UnStyled ->
            element []

        Test ->
            element
                [ background
                    [ Background.color Color.blue
                    ]
                ]

        TestEmbed ->
            element
                [ onClick Blink
                , background
                    [ Background.color Color.red
                    ]
                ]
