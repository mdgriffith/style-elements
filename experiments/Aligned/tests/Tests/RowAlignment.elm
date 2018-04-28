module Tests.RowAlignment exposing (..)

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


box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        empty


view =
    let
        rowContainer attrs children =
            row
                ([ spacing 20
                 , height (px 100)
                 , Background.color lightGrey
                 ]
                    ++ attrs
                )
                children
    in
    column [ width (px 500), spacing 20 ]
        [ el [] (text "Alignment Within a Row")
        , rowContainer [ label "single child" ]
            [ box [] ]
        , rowContainer []
            [ box []
            , box []
            , box []
            ]
        , rowContainer []
            [ box []
            , box []
            , box [ alignRight, label "Right Child in Row" ]
            ]
        , rowContainer
            []
            [ box []
            , box [ alignRight, label "Middle Child in Row" ]
            , box []
            ]
        , rowContainer []
            [ box [ alignRight, label "Left Child in Row" ]
            , box []
            , box []
            ]
        , text "center X"
        , rowContainer []
            [ box [ centerX, label "Left Child in Row" ]
            , box []
            , box []
            ]
        , rowContainer []
            [ box []
            , box [ centerX, label "Middle Child in Row" ]
            , box []
            ]
        , rowContainer []
            [ box []
            , box []
            , box [ centerX, label "Right Child in Row" ]
            ]
        , rowContainer []
            [ box []
            , box []
            , box [ centerX, label "Middle-Right Child in Row" ]
            , box []
            ]
        , rowContainer []
            [ box []
            , box []
            , box [ centerX, label "Middle-Right Child in Row" ]
            , box [ centerX, label "Middle-Right Child in Row" ]
            , box []
            ]
        , text "left x right"
        , rowContainer []
            [ box [ alignLeft, label "Left Child in Row" ]
            , box []
            , box [ alignRight, label "Right Child in Row" ]
            ]
        , text "left center right"
        , rowContainer []
            [ box [ alignLeft, label "Left Child in Row" ]
            , box [ centerX, label "Middle Child in Row" ]
            , box [ alignRight, label "Right Child in Row" ]
            ]
        , text "vertical alignment"
        , rowContainer []
            [ box [ alignTop, label "Left Child in Row" ]
            , box [ centerY, label "Middle Child in Row" ]
            , box [ alignBottom, label "Right Child in Row" ]
            ]
        , text "x and y alignments"
        , rowContainer []
            [ box [ alignLeft, alignTop, label "Left Child" ]
            , box [ centerX, centerY, label "Middle Child" ]
            , box [ alignRight, alignBottom, label "Right Child" ]
            ]
        , text "align Top and X alignments "
        , rowContainer []
            [ box [ alignLeft, alignTop, label "Left Child" ]
            , box [ centerX, alignTop, label "Middle Child" ]
            , box [ alignRight, alignTop, label "Right Child" ]
            ]
        , text "align Bottom and X alignments "
        , rowContainer []
            [ box [ alignLeft, alignBottom, label "Left Child" ]
            , box [ centerX, alignBottom, label "Middle Child" ]
            , box [ alignRight, alignBottom, label "Right Child" ]
            ]
        , text "centerY and X alignments "
        , rowContainer []
            [ box [ alignLeft, centerY, label "Left Child" ]
            , box [ centerX, centerY, label "Middle Child" ]
            , box [ alignRight, centerY, label "Right Child" ]
            ]
        ]
