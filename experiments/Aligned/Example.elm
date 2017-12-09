module Main exposing (..)

import Color exposing (..)
import Element exposing (..)
import Element.Area as Area
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Input as Input


main =
    layout
        [ Background.color white
        , Font.color black
        ]
    <|
        el [] (text "Hello stylish friend!")
