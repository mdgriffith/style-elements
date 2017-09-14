module StyleSheet exposing (..)

import Color
import Style exposing (..)
import Style.Background as Background
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Transition as Transition
import Style.Filter as Filter


type Styles
    = None
    | Main
    | Box
    | Container
    | Shadow
    | FixedShadow


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style Main
            [ Border.all 1
            , Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            , Font.typeface [ "helvetica", "arial", "sans-serif" ]
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style Box
            [ Transition.all
            , Color.text Color.white
            , Color.background Color.blue
            , Color.border Color.blue
            , Border.rounded 3
            , hover
                [ Color.text Color.white
                , Color.background Color.red
                , Color.border Color.red
                , cursor "pointer"
                ]
            ]
        , style Container
            [ Color.text Color.black
            , Color.background Color.lightGrey
            , Color.border Color.lightGrey
            , hover
                [ Color.background Color.grey
                , Color.border Color.grey
                , cursor "pointer"
                ]
            ]
        , style Shadow
            [ Shadow.drop
                { offset = ( 0.0, 2.0 )
                , blur = 4.0
                , color = Color.rgba 0 0 0 0.8
                }
            ]
        , style FixedShadow
            [ Shadow.drop
                { offset = ( 0.0, 2.0 )
                , blur = 4.0
                , color = Color.rgba 0 0 0 0.8
                }
            , Filter.blur 0
            ]
        ]
