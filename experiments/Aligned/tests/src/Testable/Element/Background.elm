module Testable.Element.Background exposing (color)

{-| -}

import Color exposing (Color)
import Dict
import Element.Background as Background
import Expect
import Testable


color : Color -> Testable.Attr msg
color clr =
    Testable.LabeledTest
        { label = "background color-" ++ toString clr
        , attr = Background.color clr
        , test =
            \context _ ->
                let
                    selfBackgroundColor =
                        context.self.style
                            |> Dict.get "background-color"
                            |> Maybe.withDefault "notfound"
                in
                Expect.true ("Color Match - " ++ (Testable.formatColor clr ++ " vs " ++ selfBackgroundColor))
                    (Testable.compareFormattedColor clr selfBackgroundColor)
        }
