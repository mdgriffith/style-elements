module Tests.Basic exposing (view)

{-| -}

import Html
import Testable
import Testable.Element exposing (..)
import Testable.Runner


{-| -}
main : Html.Html msg
main =
    Testable.Runner.show view


{-| -}
view : Testable.Element msg
view =
    Testable.Element.el
        [ Testable.Element.width (Testable.Element.px 200)
        , Testable.Element.height (Testable.Element.px 200)
        ]
        Testable.Element.empty
