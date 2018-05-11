module Main exposing (..)

{-| -}

import Color exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Element.Keyed
import Element.Lazy


main =
    Element.layout
        [ Background.color blue
        , Font.color white
        , Font.size 20
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        column []
            [ paragraph
                [ --     centerX
                  -- , centerY
                  padding 100
                , Background.color white
                , Font.color black

                -- , width
                --     (px 700
                --      -- |> minimum 20
                --      -- |> maximum 80
                --     )
                ]
                [ text """Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."""
                ]
            , paragraph
                [ centerX
                , centerY
                , padding 100
                , Background.color white
                , spacing 20
                , Font.color black
                , width
                    (px 700
                     -- |> minimum 20
                     -- |> maximum 80
                    )
                ]
                [ el
                    [ width (px 40)
                    , height (px 40)
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
                        [ width (px 40)
                        , height (px 40)
                        , Background.color blue
                        ]
                        none
                    , el
                        [ width (px 40)
                        , height (px 40)
                        , Background.color blue
                        ]
                        none
                    , el
                        [ width (px 40)
                        , height (px 40)
                        , Background.color blue
                        ]
                        none
                    ]
                , text """Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."""
                ]
            ]
