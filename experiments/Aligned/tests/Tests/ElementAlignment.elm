module Tests.ElementAlignment exposing (..)

import Color exposing (..)
import Html
import Testable
import Testable.Element as Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Runner


{-| -}
main : Html.Html msg
main =
    Testable.Runner.show view


box : List (Testable.Attr msg) -> Testable.Element msg
box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        empty


container : Testable.Element msg -> Testable.Element msg
container =
    el
        [ width (px 100)
        , height (px 100)
        , Background.color lightGrey
        ]


view : Testable.Element msg
view =
    column []
        [ el [] (text "Alignment Within an El")
        , container <|
            box []
        , text "alignLeft, centerX, alignRight"
        , row [ spacing 20 ]
            [ container <|
                box [ alignLeft ]
            , container <|
                box [ centerX ]
            , container <|
                box [ alignRight ]
            ]
        , text "top, centerY, bottom"
        , row [ spacing 20 ]
            [ container <|
                box [ alignTop ]
            , container <|
                box [ centerY ]
            , container <|
                box [ alignBottom ]
            ]
        , text "align top ++ alignments"
        , row [ spacing 20 ]
            [ container <|
                box [ alignTop, alignLeft ]
            , container <|
                box [ alignTop, centerX ]
            , container <|
                box [ alignTop, alignRight ]
            ]
        , text "centerY ++ alignments"
        , row [ spacing 20 ]
            [ container <|
                box [ centerY, alignLeft ]
            , container <|
                box [ centerY, centerX ]
            , container <|
                box [ centerY, alignRight ]
            ]
        , text "alignBottom ++ alignments"
        , row [ spacing 20 ]
            [ container <|
                box [ alignBottom, alignLeft ]
            , container <|
                box [ alignBottom, centerX ]
            , container <|
                box [ alignBottom, alignRight ]
            ]
        ]
