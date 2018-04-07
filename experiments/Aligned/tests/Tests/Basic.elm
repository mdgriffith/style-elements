module Tests.Basic exposing (view)

{-| -}

import Color exposing (Color)
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


{-| -}
view : Testable.Element msg
view =
    row [ spacing 50, alignTop ]
        [ el
            [ width (px 200)
            , height (px 200)
            , Background.color Color.blue
            , Font.color Color.white
            ]
            (text "Hello!")
        , el
            [ width (px 200)
            , height (px 200)
            , Background.color Color.blue
            , Font.color Color.white
            ]
            (text "Hello!")
        , el
            [ width (px 200)
            , height (px 200)
            , Background.color Color.blue
            , Font.color Color.white
            , below
                (el
                    [ Background.color Color.grey
                    , width (px 50)
                    , height (px 50)
                    ]
                    empty
                )
            ]
            (text "Hello!")
        ]
