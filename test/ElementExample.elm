module Main exposing (..)

{-| -}

import Elements exposing (..)
import Style exposing (..)
import Style.Background as Background
import Color


main =
    Elements.render elements <|
        Elements.row UnStyled
            [ Spacing 25 25 25 25 ]
            [ el Test
                [ Width (px 500), Height (px 80) ]
                (text "Hello World!")
            , el Test
                [ Width (px 500), Height (px 80) ]
                (text "Hello World!")
            ]


type Elements
    = Test
    | UnStyled


elements elem =
    case elem of
        UnStyled ->
            element []

        Test ->
            element
                [ Elements.style <|
                    background
                        [ Background.color Color.blue
                        ]
                ]
