module Main exposing (..)

import Html exposing (Html)
import Element exposing (..)
import Element.Attributes exposing (..)
import Style exposing (..)
import Style.Color as Color
import Color


type Styles
    = Container
    | None
    | Child


stylesheet : StyleSheet Styles variations
stylesheet =
    Style.stylesheet
        [ style Container
            [ Color.background Color.red
            , Color.text Color.white
            ]
        , style Child
            [ Color.background Color.blue
            , Color.text Color.white
            ]
        ]


main : Html a
main =
    layout stylesheet <|
        (el Container [] (text "container")
            |> below
                [ el Child [ width <| fill 1 ] (text "child below")
                ]
        )
