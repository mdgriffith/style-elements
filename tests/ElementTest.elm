module ElementTest exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Internal.Model
import Expect
import Fuzz exposing (int, list, string)
import Html
import Html.Attributes as Html
import Style exposing (..)
import Style.Internal.Model
import Style.Internal.Render.Property as Property
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


type Styles
    = None


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.stylesheet
        [ style None [] ]


suite : Test
suite =
    describe "render"
        [ describe "flex-shrink"
            [ test "prevents fixed height child from shrinking inside a column" <|
                \() ->
                    Element.root stylesheet
                        (column None
                            []
                            [ el None [] empty
                            , el None [ height (px 200) ] empty
                            ]
                        )
                        |> Query.fromHtml
                        |> Query.has [ Selector.style [ ( "flex-shrink", "0" ) ] ]
            , test "allows child with unspecified height to shrink inside a column" <|
                \() ->
                    Element.root stylesheet
                        (row None
                            []
                            [ el None [] empty
                            , el None [] empty
                            ]
                        )
                        |> Query.fromHtml
                        |> Query.hasNot [ Selector.style [ ( "flex-shrink", "0" ) ] ]
            , test "prevents fixed width child from shrinking inside a row" <|
                \() ->
                    Element.root stylesheet
                        (row None
                            []
                            [ el None [] empty
                            , el None [ width (px 200) ] empty
                            ]
                        )
                        |> Query.fromHtml
                        |> Query.has [ Selector.style [ ( "flex-shrink", "0" ) ] ]
            , test "allows child with unspecified width to shrink inside a row" <|
                \() ->
                    Element.root stylesheet
                        (row None
                            []
                            [ el None [] empty
                            , el None [] empty
                            ]
                        )
                        |> Query.fromHtml
                        |> Query.hasNot [ Selector.style [ ( "flex-shrink", "0" ) ] ]
            ]
        ]
