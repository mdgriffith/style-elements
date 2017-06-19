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


linkTest : Test
linkTest =
    describe "link creation"
        [ test "Create a normal link" <|
            \() ->
                Element.layout stylesheet
                    (link "test" <| el None [ height (px 200) ] empty)
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "a", Selector.attribute "href" "test" ]
        , test "Create a link from a layout" <|
            \() ->
                Element.layout stylesheet
                    (link "test" <| row None [ height (px 200) ] [ el None [ height (px 200) ] empty ])
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "a", Selector.attribute "href" "test" ]
        , test "Create a link from a layout, with spacing" <|
            \() ->
                Element.layout stylesheet
                    (link "test" <| row None [ height (px 200), spacing 10 ] [ el None [ height (px 200) ] empty ])
                    |> Query.fromHtml
                    |> Query.has [ Selector.tag "a", Selector.attribute "href" "test" ]
        ]


shrink : Test
shrink =
    describe "flex-shrink"
        [ test "prevents fixed height child from shrinking inside a column" <|
            \() ->
                Element.layout stylesheet
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
                Element.layout stylesheet
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
                Element.layout stylesheet
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
                Element.layout stylesheet
                    (row None
                        []
                        [ el None [] empty
                        , el None [] empty
                        ]
                    )
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.style [ ( "flex-shrink", "0" ) ] ]
        ]
