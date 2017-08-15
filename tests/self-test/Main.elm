module Main exposing (..)

import Html
import AutoSelfTest
import Element exposing (..)
import Element.Attributes exposing (..)
import Style
import Test exposing (Test)
import Test.Runner
import Random.Pcg
import Keyboard
import Style.Color as Color
import Color
import Style.Font as Font
import Window


( elems, tests ) =
    AutoSelfTest.test elementView


main =
    Html.program
        { init =
            ( { seed = Random.Pcg.initialSeed 227852860
              , results = Nothing
              , window = Window.Size 0 0
              }
            , Cmd.none
            )
        , update = update
        , view = view
        , subscriptions =
            \_ ->
                Sub.batch
                    [ Keyboard.presses (\_ -> Refresh)
                    , Window.resizes Resize
                    ]
        }


type alias Model =
    { results :
        Maybe
            (List
                ( String
                , Maybe
                    { given : Maybe String
                    , message : String
                    }
                )
            )
    , seed : Random.Pcg.Seed
    , window : Window.Size
    }


type Msg
    = Refresh
    | Resize Window.Size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize size ->
            ( { model | window = size }, Cmd.none )

        Refresh ->
            let
                runners =
                    Test.Runner.fromTest 100 model.seed (tests model.window)

                results =
                    case runners of
                        Test.Runner.Plain rnrs ->
                            List.map run rnrs

                        Test.Runner.Only rnrs ->
                            List.map run rnrs

                        Test.Runner.Skipping rnrs ->
                            List.map run rnrs

                        Test.Runner.Invalid invalid ->
                            []

                run runner =
                    let
                        ran =
                            List.map Test.Runner.getFailure (runner.run ())
                    in
                        List.map2 (,) runner.labels ran
            in
                ( { model | results = Just (List.concat results) }
                , Cmd.none
                )


view : Model -> Html.Html msg
view model =
    Element.layout
        stylesheet
        (elems
            |> above [ screen (viewResults model.results) ]
        )


type Styles
    = None
    | TestStyle
    | TestResults
    | PassingTest
    | Blue
    | Grey


indent : Int -> String -> String
indent i str =
    str
        |> String.lines
        |> List.map (\x -> String.repeat i " " ++ x)
        |> String.join "\n"


viewResults : Maybe (List ( String, Maybe { a | message : String } )) -> Element Styles variation msg
viewResults results =
    case results of
        Nothing ->
            Element.empty

        Just res ->
            let
                viewResult ( description, finalResult ) =
                    case finalResult of
                        Nothing ->
                            el PassingTest [] (text <| description)

                        Just wrong ->
                            column None
                                [ spacing 20 ]
                                [ el None [] (text description)
                                , paragraph None [] [ text <| indent 4 wrong.message ]
                                ]
            in
                Element.column TestResults
                    [ padding 15, spacing 25, width (px 400), inlineStyle [ ( "white-space", "pre" ) ] ]
                    (List.map viewResult res)


stylesheet : Style.StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ Style.style None
            []
        , Style.style TestStyle
            [ Color.background Color.lightGrey
            ]
        , Style.style TestResults
            [ Color.background Color.white
            , Color.text Color.black
            , Font.typeface [ Font.font "Inconsolata", Font.monospace ]
            ]
        , Style.style PassingTest
            [ Color.text Color.green
            ]
        , Style.style Blue
            [ Color.background Color.blue
            , Color.text Color.white
            ]
        , Style.style Grey
            [ Color.background Color.lightGrey
            , Color.text Color.white
            ]
        ]


elementView : Element Styles variation msg
elementView =
    viewFillRow


centeredElement : Element Styles variation msg
centeredElement =
    Element.el Blue
        [ center
        , height (px 80)
        , width (percent 60)
        ]
        (text "My first Element!")


viewRow : Element Styles variation msg
viewRow =
    Element.row Grey
        [ spacing 10 ]
        [ el Blue [ width (px 10), height (px 10) ] empty
        , el Blue [ width (px 10), height (px 10) ] empty
        , el Blue [ width (px 10), height (px 10) ] empty
        ]


viewFillRow : Element Styles variation msg
viewFillRow =
    Element.row Grey
        [ spacing 10 ]
        [ el Blue [ width fill, height (px 10) ] empty
        , el Blue [ width fill, height (px 10) ] empty
        , el Blue [ width fill, height (px 10) ] empty
        ]


viewAbove : Element Styles variation msg
viewAbove =
    Element.el Blue [ width (px 200), height (px 200) ] empty
        |> above
            [ el Blue [ width (px 10), height (px 10) ] empty
            , el Blue [ width (px 10), height (px 10), alignRight ] empty
            , el Blue [ width (px 10), height (px 10), center ] empty
            ]
        |> below
            [ el Blue [ width (px 10), height (px 10) ] empty
            , el Blue [ width (px 10), height (px 10), alignRight ] empty
            , el Blue [ width (px 10), height (px 10), center ] empty
            ]
        |> onRight
            [ el Blue [ width (px 10), height (px 10) ] empty
            , el Blue [ width (px 10), height (px 10), alignBottom ] empty
            , el Blue [ width (px 10), height (px 10), verticalCenter ] empty
            ]
        |> onLeft
            [ el Blue [ width (px 10), height (px 10) ] empty
            , el Blue [ width (px 10), height (px 10), alignBottom ] empty
            , el Blue [ width (px 10), height (px 10), verticalCenter ] empty
            ]
