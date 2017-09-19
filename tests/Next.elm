module Main exposing (..)

import Next.Internal.Model exposing (..)
import Html


main =
    layout <|
        container
            [ center
            , verticalCenter
            , style
                [ prop "color" "blue"
                , prop "background-color" "yellow"
                ]
            ]
        <|
            column
                [ height (px 200)
                , spacing 20
                , width (px 500)

                -- , verticalCenter
                , spread
                , style
                    [ prop "color" "blue"
                    , prop "background-color" "grey"
                    ]
                ]
                [ el
                    [ alignBottom
                    , style
                        [ prop "color" "blue"
                        , prop "background-color" "yellow"
                        ]
                    ]
                    (text "First!")

                -- , spacer 5
                , el
                    [ style
                        [ prop "color" "blue"
                        , prop "background-color" "yellow"
                        ]
                    ]
                    (text "Second")
                , paragraph [ width (px 200) ]
                    [ text "Hellow "
                    , text "Hellow "
                    , text "Hellow "
                    , text "Hellow "
                    , el
                        [ style
                            [ prop "color" "blue"
                            , prop "background-color" "yellow"
                            ]
                        ]
                        (text "Second")
                    , text "Hellow "
                    , text "Hellow "
                    ]
                ]


{-| Can we propogate a width or height up the tree?

In the following case, we'd like all `el`'s to get width fill

-}
mainOff =
    layout <|
        el [] <|
            el [] <|
                el
                    [ style
                        [ prop "background-color" "blue"
                        , prop "color" "white"
                        ]
                    , width (px 200)
                    ]
                    (text "fill!")


mainNearby =
    layout <|
        (el [ center, verticalCenter, width (px 200), height (px 200) ] (text "Hello!")
            |> below
                (el [] (text "I am below, yup!"))
        )
