module Main exposing (..)

{-| -}

import Color exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


main =
    Element.layout
        [ Background.color blue
        , Font.color white
        , Font.italic
        , Font.size 32
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        el
            []
            (text "Hello stylish friend!")
