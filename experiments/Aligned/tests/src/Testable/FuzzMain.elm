port module Main exposing (..)

{-| -}

import AnimationFrame
import Color
import Dict exposing (Dict)
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Expect
import Html exposing (Html)
import Random.Pcg as Random
import Test
import Test.Runner
import Testable
import Tests exposing (Testable)
import Time exposing (Time)


init : ( Model Msg, Cmd Msg )
init =
    ( { current = Nothing
      , upcoming =
            Tests.tests

      -- generateTests (Random.initialSeed 227852860) 1
      , finished = []
      , stage = BeginRendering
      }
    , Cmd.none
    )


main : Program Never (Model Msg) Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model msg =
    { current : Maybe (Testable msg)
    , upcoming : List (Testable msg)
    , finished : List (Testable msg)
    , stage : Stage
    }


type Msg
    = NoOp
    | Tick Time
    | RefreshBoundingBox
        (List
            { id : String
            , bbox : Testable.BoundingBox
            , style : Testable.Style
            }
        )


type Stage
    = Rendered
    | BeginRendering
    | GatherData
    | Finished


runTest : Dict String Testable.Found -> Testable msg -> Testable msg
runTest boxes test =
    let
        tests =
            Testable.toTest test.label boxes test.element

        seed =
            Random.initialSeed 227852860

        results =
            Testable.runTests seed (Debug.log "created Tests" tests)
                |> Debug.log "run tests"
    in
    { test | results = Just results }


generateTests : Random.Seed -> Int -> List (Testable msg)
generateTests seed num =
    if num <= 0 then
        []
    else
        let
            ( testable, newSeed ) =
                generateTest seed
        in
        testable :: generateTests newSeed (num - 1)


generateTest : Random.Seed -> ( Testable msg, Random.Seed )
generateTest seed =
    Tests.testableTestable
        |> Test.Runner.fuzz
        |> flip Random.step seed
        |> (\( ( val, shrinker ), newSeed ) -> ( val, seed ))


update : Msg -> Model Msg -> ( Model Msg, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RefreshBoundingBox boxes ->
            case model.current of
                Nothing ->
                    ( { model | stage = Finished }
                    , Cmd.none
                    )

                Just current ->
                    let
                        toTuple box =
                            ( box.id, { style = box.style, bbox = box.bbox } )

                        foundData =
                            boxes
                                |> List.map toTuple
                                |> Dict.fromList

                        currentResults =
                            runTest foundData current
                    in
                    case model.upcoming of
                        [] ->
                            ( { model
                                | stage = Finished
                                , current = Nothing
                                , finished = currentResults :: model.finished
                              }
                            , Cmd.none
                            )

                        newCurrent :: remaining ->
                            ( { model
                                | finished = currentResults :: model.finished
                                , stage = BeginRendering
                              }
                            , Cmd.none
                            )

        Tick time ->
            case model.stage of
                BeginRendering ->
                    case model.upcoming of
                        [] ->
                            ( { model | stage = Rendered }
                            , Cmd.none
                            )

                        current :: remaining ->
                            ( { model
                                | stage = Rendered
                                , upcoming = remaining
                                , current = Just current
                              }
                            , Cmd.none
                            )

                Rendered ->
                    case model.current of
                        Nothing ->
                            ( { model | stage = Finished }
                            , Cmd.none
                            )

                        Just test ->
                            ( { model | stage = GatherData }
                            , analyze (Testable.getIds test.element)
                            )

                _ ->
                    ( { model | stage = Rendered }
                    , Cmd.none
                    )


subscriptions : { a | stage : Stage } -> Sub Msg
subscriptions model =
    Sub.batch
        [ styles RefreshBoundingBox
        , case model.stage of
            BeginRendering ->
                AnimationFrame.times Tick

            Rendered ->
                AnimationFrame.times Tick

            _ ->
                Sub.none
        ]


port analyze : List String -> Cmd msg


port styles : (List { id : String, bbox : Testable.BoundingBox, style : Testable.Style } -> msg) -> Sub msg


view : Model Msg -> Html Msg
view model =
    case model.current of
        Nothing ->
            if model.stage == Finished then
                Element.layout [] <|
                    Element.column
                        [ Element.spacing 20
                        , Element.padding 20
                        , Element.width (Element.px 800)

                        -- , Background.color Color.grey
                        ]
                        (List.map viewResult model.finished)
            else
                Html.text "running?"

        Just current ->
            Testable.render current.element


viewResult : Testable Msg -> Element.Element Msg
viewResult testable =
    let
        viewSingle result =
            case result of
                ( label, Nothing ) ->
                    Element.el
                        [ Background.color Color.green
                        , Font.color Color.white
                        , Element.paddingXY 20 10
                        , Element.alignLeft
                        , Border.rounded 3
                        ]
                    <|
                        Element.text (label ++ " - " ++ "Success!")

                ( label, Just { given, description, reason } ) ->
                    Element.row
                        [ Background.color Color.red
                        , Font.color Color.white
                        , Element.paddingXY 20 10
                        , Element.alignLeft
                        , Element.spacing 25
                        , Border.rounded 3
                        ]
                        [ Element.el [ Element.width Element.fill ] <| Element.text label

                        -- , Element.el [ Element.width Element.fill ] <| Element.text description
                        , Element.el [ Element.width Element.fill ] <| Element.text (toString reason)
                        ]
    in
    Element.column
        [ Border.width 1
        , Border.color Color.lightGrey
        , Element.padding 20
        , Element.height Element.shrink
        , Element.alignLeft
        ]
        [ Element.el [ Font.bold ] (Element.text testable.label)
        , Element.column [ Element.alignLeft, Element.spacing 20 ]
            (case testable.results of
                Nothing ->
                    [ Element.text "no results" ]

                Just results ->
                    List.map viewSingle results
            )
        ]
