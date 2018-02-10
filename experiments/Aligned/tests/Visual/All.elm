module Main exposing (..)

{-| A file for manually inspecting layouts.
-}

import Color exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


main =
    Element.layout
        [ Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=Source+Code+Pro"
                , name = "Source Code Pro"
                }
            ]
        ]
    <|
        column
            [ Background.color lightGrey
            , width (px 800)
            , centerX
            ]
            [ singleAlignment
            , rowAlignment
            , columnAlignment
            , aboveElement
            , columnSpacing
            , rowSpacing
            , el [ height (px 200) ] empty
            ]


box attrs =
    el ([ width (px 50), height (px 50), Background.color blue ] ++ attrs) empty


tinyBox attrs =
    el
        ([ width (px 20)
         , height (px 20)
         , centerY
         , Background.color darkCharcoal
         ]
            ++ attrs
        )
        empty


container =
    el [ width (px 100), height (px 100) ]


{-| Alignment of an el within an other el
-}
singleAlignment =
    column []
        [ el [] (text "Alignment Within an El")
        , container <|
            box []
        , row [ spacing 20 ]
            [ container <|
                box [ centerX ]
            , container <|
                box [ alignLeft ]
            , container <|
                box [ alignRight ]
            ]
        , row [ spacing 20 ]
            [ container <|
                box [ alignTop ]
            , container <|
                box [ centerY ]
            , container <|
                box [ alignBottom ]
            ]
        , row [ spacing 20 ]
            [ container <|
                box [ alignTop, centerX ]
            , container <|
                box [ alignTop, alignLeft ]
            , container <|
                box [ alignTop, alignRight ]
            ]
        , row [ spacing 20 ]
            [ container <|
                box [ centerY, centerX ]
            , container <|
                box [ centerY, alignLeft ]
            , container <|
                box [ centerY, alignRight ]
            ]
        , row [ spacing 20 ]
            [ container <|
                box [ alignBottom, centerX ]
            , container <|
                box [ alignBottom, alignLeft ]
            , container <|
                box [ alignBottom, alignRight ]
            ]
        ]


rowAlignment =
    let
        rowContainer attrs children =
            row ([ spacing 20, height (px 100) ] ++ attrs) children
    in
    column []
        [ el [] (text "Alignment Within a Row")
        , rowContainer []
            [ box [] ]
        , rowContainer []
            [ box []
            , box []
            , box []
            ]
        , rowContainer []
            [ box []
            , box [ alignLeft ]
            , box [ centerX ]
            ]
        , rowContainer []
            [ box []
            , box [ alignRight ]
            , box []
            ]
        , rowContainer []
            [ box []
            , box [ alignLeft ]
            , box [ centerX ]
            , box [ alignRight ]
            ]
        , rowContainer []
            [ box [ alignTop ]
            , box [ centerY ]
            , box [ alignBottom ]
            ]
        , rowContainer []
            [ box [ alignLeft, alignTop ]
            , box [ centerX, centerY ]
            , box [ alignRight, alignBottom ]
            ]
        ]


columnAlignment =
    let
        colContainer attrs children =
            column ([ spacing 20, width (px 100), height (px 500) ] ++ attrs) children
    in
    column
        []
        [ el [] (text "Alignment Within a Column")
        , row []
            [ colContainer []
                [ box [] ]
            , colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box [ alignRight ]
                , box [ alignLeft ]
                , box [ centerX ]
                ]
            ]
        , row []
            [ colContainer []
                [ box []
                , box [ alignBottom ]
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ centerY ]
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box [ alignTop ]
                , box [ centerY ]
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box [ alignLeft, alignTop ]
                , box [ centerX, centerY ]
                , box [ alignRight, alignBottom ]
                ]
            ]
        ]


aboveElement =
    let
        transparentBox attrs =
            el ([ width (px 50), height (px 50), Background.color (rgba 52 101 164 0.8) ] ++ attrs) empty

        nearby location box =
            row [ height (px 100), width fill, spacing 50 ]
                [ box []
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignLeft
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignRight
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignTop
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignBottom
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , centerY
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ --width fill
                              width (px 20)
                            , height fill

                            -- , height (px 20)
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                ]
    in
    column
        []
        [ el [] (text "Nearby Elements")
        , nearby above box
        , nearby below box
        , nearby inFront box
        , nearby onRight box
        , nearby onLeft box
        , nearby behind transparentBox
        ]


columnSpacing =
    let
        colContainer attrs children =
            column ([ spacing 20, width (px 100), height (px 500) ] ++ attrs) children
    in
    column
        []
        [ el [] (text "Spacing within a column")
        , row []
            [ colContainer []
                [ box [] ]
            , colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer [ onRight True (tinyBox []) ]
                [ box []
                , box []
                , box []
                ]
            ]
        ]


rowSpacing =
    let
        colContainer attrs children =
            row ([ spacing 20, width (px 500), height (px 120) ] ++ attrs) children
    in
    column
        []
        [ el [] (text "Spacing within a row")
        , column []
            [ colContainer []
                [ box [] ]
            , colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer [ below True (tinyBox []) ]
                [ box []
                , box []
                , box []
                ]
            , box []
            ]
        ]
