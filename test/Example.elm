module Main exposing (..)

import Html
import Style exposing (..)
import Style.Font as Font
import Style.Border as Border
import Style.Background as Background
import Style.Shadow as Shadow
import Style.Filter as Filter
import Style.Transform as Transform
import Style.Transitions as Transitions
import Style.Media
import Style.Sheet
import Color


main : Html.Html msg
main =
    Html.pre []
        [ Html.div [ Debug.log "button" (stylesheet.style Button) ] []
        , Html.div [ Debug.log "button" (stylesheet.variations Button [ ( Error, True ) ]) ] []
        , Html.text stylesheet.css
        ]


type Styles
    = Button
    | OtherButton
    | Navigation NavStyles


type NavStyles
    = Bar
    | Logo


type Variation
    = Warning
    | Error
    | Success


stylesheet =
    Style.Sheet.renderWith [ Style.Sheet.guard ]
        [ style Button
            [ Transitions.performant
            , hidden
            , invisible
            , block
            , font
                [ Font.stack [ "Open Sans" ]
                , Font.size 18
                , Font.letterSpacing 20
                , Font.light
                , Font.center
                , Font.uppercase
                ]
            , background
                [ Background.gradient
                    Background.toTopRight
                    [ Background.step Color.red
                    , Background.percent Color.blue 20
                    , Background.step Color.yellow
                    ]
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
            , shadows
                [ Shadow.drop
                    { offset = ( 2, 5 )
                    , blur = 5
                    , color = Color.grey
                    }
                ]
            , transforms
                [ Transform.rotate 0
                , Transform.origin 50 50 50
                , Transform.translate 0 0 0
                ]
            , filters
                [ Filter.sepia 0.5
                ]
            , variation Error
                [ font
                    [ Font.color Color.red
                    ]
                ]
            , child OtherButton
                [ blockSpaced (all 10)
                , variation Error
                    [ font
                        [ Font.color Color.red
                        ]
                    ]
                ]
            , hover
                [ font
                    [ Font.color Color.blue ]
                ]
            , Style.Media.phoneOnly
                [ block
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
                ]
            ]
        , Style.Sheet.merge otherStyleSheet
        ]


otherStyleSheet =
    Style.Sheet.map Navigation
        [ style Bar
            [ hidden
            , invisible
            , block
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
            , shadows
                [ Shadow.drop
                    { offset = ( 2, 5 )
                    , blur = 5
                    , color = Color.grey
                    }
                ]
            , filters
                [ Filter.sepia 0.5
                ]
            , Style.variation Error
                [ font
                    [ Font.color Color.red
                    ]
                ]
            , Style.child Logo
                [ blockSpaced (all 10)
                , variation Error
                    [ font
                        [ Font.color Color.red
                        ]
                    ]
                ]
            , Style.Media.phoneOnly
                [ block
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
                ]
            ]
        ]
