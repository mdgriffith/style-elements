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
            , nearbyElements
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
    column [ width (px 500) ]
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
            , box []
            , box [ alignRight ]
            ]
        , rowContainer []
            [ box []
            , box [ alignRight ]
            , box []
            ]
        , rowContainer []
            [ box [ alignRight ]
            , box []
            , box []
            ]
        , text "center X"
        , rowContainer []
            [ box [ centerX ]
            , box []
            , box []
            ]
        , rowContainer []
            [ box []
            , box [ centerX ]
            , box []
            ]
        , rowContainer []
            [ box []
            , box []
            , box [ centerX ]
            ]
        , text "left x right"
        , rowContainer []
            [ box [ alignLeft ]
            , box []
            , box [ alignRight ]
            ]
        , text "left center right"
        , rowContainer []
            [ box [ alignLeft ]
            , box [ centerX ]
            , box [ alignRight ]
            ]
        , text "vertical alignment"
        , rowContainer []
            [ box [ alignTop ]
            , box [ centerY ]
            , box [ alignBottom ]
            ]
        , text "all alignments alignment"
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
        [ width fill ]
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
                [ box [ alignLeft ]
                , box [ centerX ]
                , box [ alignRight ]
                ]
            ]
        , row []
            [ colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box []
                , box [ alignBottom ]
                , box []
                ]
            , colContainer []
                [ box [ alignBottom ]
                , box []
                , box []
                ]
            ]
        , text "with centerY override"
        , row []
            [ colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box []
                , box [ alignBottom ]
                , box [ centerY ]
                ]
            , colContainer []
                [ box [ alignBottom ]
                , box [ centerY ]
                , box [ centerY ]
                ]
            ]
        , text "centerY"
        , row []
            [ colContainer [ height fill ]
                [ box [ centerY ]
                ]
            , colContainer []
                [ box []
                , box [ centerY ]
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ centerY ]
                ]
            ]
        , text "multiple centerY"
        , row [ height (px 800) ]
            [ colContainer [ height fill ]
                [ box []
                , box [ centerY ]
                , box [ centerY ]
                , box [ centerY ]
                , box [ centerY ]
                , box [ alignBottom ]
                ]
            , colContainer [ height fill ]
                [ box []
                , box [ centerY ]
                , box []
                ]
            , colContainer [ height fill ]
                [ box []
                , box []
                , box [ centerY ]
                ]
            ]
        , text "top, center, bottom"
        , row []
            [ colContainer []
                [ box [ alignTop ]
                , box []
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
        , el [ width fill ] (text "Column in a Row")
        , row [ width fill, height fill, spacing 20 ]
            [ box [ alignLeft, alignTop ]
            , column [ alignLeft, alignTop, spacing 20, width shrink ]
                [ box []
                , box []
                , box []
                ]
            , colContainer [ alignLeft, alignTop, height shrink ]
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box [ alignRight ]
                , box [ centerX ]
                , box [ alignLeft ]
                ]
            ]
        ]


nearbyElements =
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
        [ centerX ]
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
            [ box []
            , colContainer []
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
            ]
        ]
