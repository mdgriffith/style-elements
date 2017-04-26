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
        { stylesheet = Element.stylesheet stylesheet
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
    el UnStyled [] <|
        row MyRow
            [ spacing 25 25
            , padding (all 25)
            ]
            [ el Test
                [ padding (all 20)
                , width (percent 50)
                , vary Success True
                ]
                (text "Hello World!")
            , el Test
                [ padding (all 20)
                , width (percent 50)
                , vary Success True
                ]
                (text "Hello World!")
            ]


viewAround =
    el Test
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
                    , move 0 0
                    ]
                    (text "I'm below!")
            ]


update msg model =
    ( model, Cmd.none )


type Msg
    = Blink


type Elements
    = Test
    | UnStyled
    | TestEmbed
    | MyRow


type Variations
    = Success


stylesheet =
    [ style UnStyled []
    , style MyRow
        [ background
            [ Background.color Color.purple
            ]
        ]
    , style Test
        [ background
            [ Background.color Color.blue
            ]
        , variation Success
            [ background
                [ Background.color Color.green
                ]
            ]

        -- , paddingHint (all 200)
        ]
    , style TestEmbed
        [ background
            [ Background.color Color.red
            ]
        ]
    ]
