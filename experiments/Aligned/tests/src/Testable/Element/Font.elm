module Testable.Element.Font exposing (color)

{-| -}

import Color exposing (Color)
import Dict
import Element.Font as Font
import Expect
import Testable


color : Color -> Testable.Attr msg
color clr =
    Testable.LabeledTest
        { label = "font color-" ++ toString clr
        , attr = Font.color clr
        , test =
            \context _ ->
                let
                    selfFontColor =
                        context.self.style
                            |> Dict.get "color"
                            |> Maybe.withDefault "notfound"
                in
                Expect.equal (Testable.formatColor clr) selfFontColor
        }
