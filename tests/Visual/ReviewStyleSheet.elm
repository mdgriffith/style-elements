module Visual.ReviewStyleSheet exposing (..)

import Color
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Keyed
import Html
import Style exposing (..)
import Style.Background as Background
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Transition as Transition


(=>) =
    (,)


type Styles
    = None
    | TestStyle


type Vary
    = Other


options =
    [ Style.unguarded
    ]


stylesheet : StyleSheet Styles Vary
stylesheet =
    Style.styleSheetWith options
        [ style None []
        , style TestStyle
            [ Border.all 1
            , Color.text Color.darkCharcoal
            , variation Other
                [ Color.text Color.red
                , hover
                    [ Color.text Color.blue
                    ]
                ]
            ]
        ]


main =
    Html.program
        { init = ( 0, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


update msg model =
    ( model, Cmd.none )


view model =
    Html.pre []
        [ Html.text stylesheet.css
        ]
