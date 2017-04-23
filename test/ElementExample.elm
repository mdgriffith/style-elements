module Main exposing (..)

{-| -}

import Elements exposing (..)
import Element.Attributes exposing (..)
import Style exposing (..)
import Style.Background as Background
import Color


main =
    Elements.program
        { elements = elements
        , view = view
        , init = ( 5, Cmd.none )
        , update = update
        , subscriptions =
            (\_ ->
                Sub.none
            )
        }


view device model =
    Elements.row UnStyled
        [ spacing (all 25) ]
        [ el Test
            [ width (px 500)
            , height (px 80)
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
                    (text "I'm below!")
                )
        ]


update msg model =
    ( model, Cmd.none )


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
                [ style
                    [ background
                        [ Background.color Color.blue
                        ]
                    ]
                ]

        TestEmbed ->
            element
                [ style
                    [ background
                        [ Background.color Color.red
                        ]
                    ]
                ]
