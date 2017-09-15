module Main exposing (..)

import Next.Internal.Model exposing (..)
import Html


main =
    layout <|
        el
            [ height (px 200)
            , style
                [ prop "color" "blue"
                , prop "background-color" "yellow"
                ]
            ]
        <|
            column
                [ height (px 200)
                , spacing 20
                , verticalCenter
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
                , spacer 5
                , el
                    [ style
                        [ prop "color" "blue"
                        , prop "background-color" "yellow"
                        ]
                    ]
                    (text "Second")
                , paragraph [ width (px 100) ]
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
