module Main exposing (..)

{-| -}

import Color exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Html.Attributes


pair =
    (,)


correctedFont size =
    let
        correction =
            0.8
    in
    Element.htmlAttribute
        (Html.Attributes.style
            [ pair "font-size" (toString size ++ "px")
            , pair "line-height" (toString size ++ "px")
            ]
        )


pSpacing =
    10


baseFontSize =
    64


main =
    Element.layout
        [ Background.color blue
        , Font.color white
        , Font.size baseFontSize
        , padding 20
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        column
            [ spacing 20
            ]
            [ el
                [ centerX
                , centerY
                , onLeft <|
                    el
                        [ height (px baseFontSize)
                        , width (px 10)
                        , Border.widthEach { top = 1, bottom = 1, left = 1, right = 0 }
                        , Border.color black
                        , moveRight 100
                        , centerY
                        ]
                        none
                , inFront <|
                    el
                        [ Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
                        , Border.color black
                        , width fill
                        , height (px 1)
                        , alignTop
                        , alignLeft
                        , moveDown 100
                        ]
                        none
                , inFront <|
                    el
                        [ Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
                        , Border.color black
                        , width fill
                        , height (px 1)
                        , alignBottom
                        , alignLeft
                        , moveUp 100
                        ]
                        none
                , padding 100
                , Font.color black
                , Background.color white
                , spacing 20
                , width
                    (px 700
                     -- |> minimum 20
                     -- |> maximum 80
                    )
                ]
                (text """Lorem Ipsum is simply dummy """)
            , el
                [ padding 100
                , Background.color white
                , centerX
                , centerY
                , inFront <|
                    el
                        [ Border.widthEach { top = 1, bottom = 1, left = 1, right = 0 }
                        , Border.color black
                        , width (px 20)
                        , height (px 100)
                        , alignTop
                        , alignLeft
                        , moveRight 150
                        ]
                        none
                , inFront <|
                    el
                        [ Border.widthEach { top = 1, bottom = 1, left = 1, right = 0 }
                        , Border.color black
                        , width (px 20)
                        , height (px 100)
                        , alignBottom
                        , alignLeft
                        , moveRight 150
                        ]
                        none
                ]
              <|
                paragraph
                    [ spacing pSpacing
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 20)
                            , height (px baseFontSize)
                            ]
                            none
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 10)
                            , height (px pSpacing)
                            , moveDown baseFontSize
                            ]
                            none
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 20)
                            , height (px baseFontSize)
                            , moveDown (baseFontSize + pSpacing)
                            ]
                            none
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 10)
                            , height (px pSpacing)
                            , moveDown (baseFontSize + baseFontSize + pSpacing)
                            ]
                            none
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 20)
                            , height (px baseFontSize)
                            , moveDown (baseFontSize + pSpacing + baseFontSize + pSpacing)
                            ]
                            none
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 10)
                            , height (px pSpacing)
                            , moveDown (baseFontSize + pSpacing + baseFontSize + pSpacing + baseFontSize)
                            ]
                            none
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 20)
                            , height (px baseFontSize)
                            , moveDown (baseFontSize + pSpacing + baseFontSize + pSpacing + baseFontSize + pSpacing)
                            ]
                            none
                    , onLeft <|
                        el
                            [ Border.widthEach { top = 1, bottom = 1, left = 2, right = 0 }
                            , Border.color black
                            , width (px 10)
                            , height (px pSpacing)
                            , moveDown (baseFontSize + baseFontSize + pSpacing + baseFontSize + pSpacing + baseFontSize + pSpacing)
                            ]
                            none

                    -- , padding 100
                    , Font.color black
                    , Background.color white

                    -- , spacing 0
                    , width
                        (px 800
                         -- |> minimum 20
                         -- |> maximum 80
                        )
                    ]
                    [ text """Lorem Ipsum is simply dummy """
                    , el [ Font.bold ] (text "I'm BOLD ")
                    , text """Lorem Ipsum is simply dummy """
                    , el [ Font.size 24 ] (text "I'm a small font ")
                    , text """text of the printing and typesetting industry. jdlajflkajfkdjkl"""
                    , text """Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."""
                    ]
            , paragraph
                [ centerX
                , centerY
                , inFront <|
                    el
                        [ Border.widthEach { top = 1, bottom = 1, left = 1, right = 0 }
                        , Border.color black
                        , width (px 20)
                        , height (px 100)
                        , alignTop
                        , alignLeft
                        , moveRight 150
                        ]
                        none
                , inFront <|
                    el
                        [ Border.widthEach { top = 1, bottom = 1, left = 1, right = 0 }
                        , Border.color black
                        , width (px 20)
                        , height (px 100)
                        , alignBottom
                        , alignLeft
                        , moveRight 150
                        ]
                        none
                , padding 100
                , Font.color black
                , Background.color white
                , spacing 30
                , width
                    (px 700
                     -- |> minimum 20
                     -- |> maximum 80
                    )
                ]
                [ el
                    [ width (px baseFontSize)
                    , height (px baseFontSize)
                    , alignLeft
                    , Background.color blue
                    ]
                    none
                , text """Lorem Ipsum is simply dummy """
                , el [ Font.bold ] (text "I'm BOLD ")
                , text """Lorem Ipsum is simply dummy """
                , el [ Font.italic ] (text "I'm BOLD ")
                , text """text of the printing and typesetting industry. jdlajflkajfkdjkl"""
                , row [ spacing 10, padding 5 ]
                    [ el
                        [ width (px baseFontSize)
                        , height (px baseFontSize)
                        , Background.color blue
                        ]
                        none
                    , el
                        [ width (px baseFontSize)
                        , height (px baseFontSize)
                        , Background.color blue
                        ]
                        none
                    , el
                        [ width (px baseFontSize)
                        , height (px baseFontSize)
                        , Background.color blue
                        ]
                        none
                    ]
                , text """Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."""
                ]
            ]
