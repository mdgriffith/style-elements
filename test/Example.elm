module Main exposing (..)

import Html
import Style exposing (..)
import Style.Font as Font
import Style.Border as Border
import Style.Layout as Layout
import Style.Sheet
import Color


main : Html.Html msg
main =
    Html.pre []
        [ Html.text css ]


type Styles
    = NavBar
    | Button
    | OtherButton


type Variation
    = Warning
    | Error
    | Success


{ css } =
    Style.Sheet.render
        [ style NavBar
            [ Layout.text
            , font
                [ Font.stack [ "Open Sans" ]
                , Font.size 18
                , Font.letterSpacing 20
                , Font.light
                , Font.center
                , Font.uppercase
                ]
            , box
                [ width (px 10)
                , height (px 200)
                ]
            , border
                [ Border.width (all 5)
                , Border.radius (all 5)
                , Border.solid
                ]
            , Style.variation Error
                [ font
                    [ Font.color Color.red
                    ]
                ]
            , Style.child Button
                [ Layout.spacedText (all 10)
                , variation Error
                    [ font
                        [ Font.color Color.red
                        ]
                    ]
                ]
            ]
        ]
