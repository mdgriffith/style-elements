module Main exposing (..)

{-| -}

import Element exposing (..)
import Element.Device
import Element.Attributes exposing (..)
import Html.Events
import Element.Style exposing (..)
import Element.Style.Background as Background
import Element.Style.Font
import Element.Style.Color
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
    column UnStyled
        [ spacing 200 200
        , padding (all 20)
        ]
        [ full Test [] (text "wut?")
        , (section <| row) MyRow
            [ spacing 25 25
            , padding (all 12.5)
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
        , full Test [] (text "wut?")
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
        [ Element.Style.Color.text Color.purple
        ]
    , style Test
        [ Element.Style.Color.text Color.blue
        , variation Success
            [ Element.Style.Color.text Color.green
            ]

        -- , paddingHint (all 200)
        ]
    , style TestEmbed
        [ Element.Style.Color.text Color.red
        ]
    ]
