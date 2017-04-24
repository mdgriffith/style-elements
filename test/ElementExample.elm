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
            , padding (all 20)
            ]
            (text "Hello World!")
        , el Test
            [ width (px 500)
            , height (px 80)
            ]
            (text "Hello World!")
            |> nearby
                [ onRight <|
                    el TestEmbed
                        [ width (px 50)
                        , height (px 50)
                        , alignBottom
                        , move 0 0
                        , onClick Blink
                        ]
                        (text "I'm right!")
                , below <|
                    el TestEmbed
                        [ width (px 50)
                        , height (px 50)
                        , alignRight
                        , move 0 0
                        ]
                        (text "I'm below!")
                ]
        , el Test
            [ width (px 500)
            , height (px 80)
            ]
            (text "Hello World!")
            |> nearby
                [ onRight <|
                    el TestEmbed
                        [ width (px 50)
                        , height (px 50)
                        , alignBottom
                        , move 0 0
                        , onClick Blink
                        ]
                        (text "I'm right!")
                ]
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
                , paddingHint (all 200)
                ]

        TestEmbed ->
            element
                [ background
                    [ Background.color Color.red
                    ]
                ]
