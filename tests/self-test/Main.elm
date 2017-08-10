module Main exposing (..)

import Html
import Html.Events exposing (..)
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


-- run test =


( elems, tests ) =
    AutoSelfTest.test elementView


main =
    Html.program
        { init =
            ( { seed = Random.Pcg.initialSeed 227852860
              , results = Nothing
              }
            , Cmd.none
            )
        , update = update
        , view = view
        , subscriptions = \_ -> Keyboard.presses (\_ -> Refresh)
        }


type Msg
    = Refresh


update msg model =
    case msg of
        Refresh ->
            let
                runners =
                    Test.Runner.fromTest 100 model.seed (tests ())

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


indent : Int -> String -> String
indent i str =
    str
        |> String.lines
        |> List.map (\x -> String.repeat i " " ++ x)
        |> String.join "\n"


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
        ]


elementView =
    Element.el Blue
        [ center
        , height (px 80)
        , width (percent 60)
        ]
        (text "My first Element!")
