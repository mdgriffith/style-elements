port module Tests.Run exposing (..)

{-| -}

import Testable.Runner
import Tests.Basic
import Tests.ColumnAlignment
import Tests.ColumnSpacing
import Tests.ElementAlignment
import Tests.Nearby
import Tests.RowAlignment
import Tests.RowSpacing
import Tests.Transparency


-- import Tests.Table


pair =
    (,)


main : Testable.Runner.TestableProgram
main =
    Testable.Runner.program
        [ pair "Basic Element" Tests.Basic.view
        , pair "Nearby" Tests.Nearby.view
        , pair "Element Alignment" Tests.ElementAlignment.view
        , pair "Transparency" Tests.Transparency.view
        , pair "Column Alignment" Tests.ColumnAlignment.view
        , pair "Row Alignment" Tests.RowAlignment.view
        , pair "Column Spacing" Tests.ColumnSpacing.view
        , pair "Row Spacing" Tests.RowSpacing.view
        ]
