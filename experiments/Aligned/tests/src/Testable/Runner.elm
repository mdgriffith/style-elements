port module Testable.Runner exposing (TestableProgram, program, show)

{-| -}

import AnimationFrame
import Color
import Dict exposing (Dict)
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Random.Pcg as Random
import Test.Runner
import Test.Runner.Failure
import Testable
import Time exposing (Time)


show : Testable.Element msg -> Html msg
show =
    Testable.render


type alias TestableProgram =
    Program Never (Model Msg) Msg


port report :
    List
        { label : String
        , results :
            List
                ( String
                , Maybe
                    { given : Maybe String
                    , description : String
                    }
                )
        }
    -> Cmd msg


port analyze : List String -> Cmd msg


port styles : (List { id : String, bbox : Testable.BoundingBox, style : List ( String, String ) } -> msg) -> Sub msg


program : List ( String, Testable.Element Msg ) -> TestableProgram
program tests =
    Html.program
        { init =
            ( { current = Nothing
              , upcoming = tests
              , finished = []
              , stage = BeginRendering
              }
            , Cmd.none
            )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model msg =
    { current : Maybe ( String, Testable.Element msg )
    , upcoming : List ( String, Testable.Element msg )
    , finished : List (WithResults (Testable.Element msg))
    , stage : Stage
    }


type alias WithResults thing =
    { element : thing
    , label : String
    , results :
        List
            ( String
            , Maybe
                { given : Maybe String
                , description : String
                , reason : Test.Runner.Failure.Reason
                }
            )
    }


prepareResults :
    List (WithResults (Testable.Element msg))
    ->
        List
            { label : String
            , results :
                List
                    ( String
                    , Maybe
                        { given : Maybe String
                        , description : String
                        }
                    )
            }
prepareResults withResults =
    let
        prepareNode ( x, maybeResult ) =
            ( x
            , case maybeResult of
                Nothing ->
                    Nothing

                Just res ->
                    Just
                        { given = res.given
                        , description = res.description
                        }
            )

        prepare { label, results } =
            { label = label
            , results = List.map prepareNode results
            }
    in
    List.map prepare withResults


type Stage
    = Rendered
    | BeginRendering
    | GatherData
    | Finished


type Msg
    = NoOp
    | Tick Time
    | RefreshBoundingBox
        (List
            { id : String
            , bbox : Testable.BoundingBox
            , style : List ( String, String )
            }
        )


runTest : Dict String Testable.Found -> String -> Testable.Element msg -> WithResults (Testable.Element msg)
runTest boxes label element =
    let
        tests =
            Testable.toTest label boxes element

        seed =
            Random.initialSeed 227852860

        results =
            Testable.runTests seed tests
    in
    { element = element
    , label = label
    , results = results
    }


update : Msg -> Model Msg -> ( Model Msg, Cmd Msg )
update msg model =
    -- let
    --     -- _ =
    --     --     Debug.log "stage" model.stage
    -- in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RefreshBoundingBox boxes ->
            case model.current of
                Nothing ->
                    ( { model | stage = Finished }
                    , Cmd.none
                    )

                Just ( label, current ) ->
                    let
                        toTuple box =
                            ( box.id, { style = Dict.fromList box.style, bbox = box.bbox } )

                        foundData =
                            boxes
                                |> List.map toTuple
                                |> Dict.fromList

                        currentResults =
                            runTest foundData label current
                    in
                    case model.upcoming of
                        [] ->
                            ( { model
                                | stage = Finished
                                , current = Nothing
                                , finished = model.finished ++ [ currentResults ]
                              }
                            , report (prepareResults (currentResults :: model.finished))
                            )

                        newCurrent :: remaining ->
                            ( { model
                                | finished = model.finished ++ [ currentResults ]
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

                        Just ( label, current ) ->
                            ( { model | stage = GatherData }
                            , analyze (Testable.getIds current)
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

        Just ( label, current ) ->
            Testable.render current


viewResult : WithResults (Testable.Element Msg) -> Element.Element Msg
viewResult testable =
    let
        isPassing result =
            case Tuple.second result of
                Nothing ->
                    True

                Just _ ->
                    False

        ( passing, failing ) =
            List.partition isPassing testable.results

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
                        Element.text ("Success! - " ++ label)

                ( label, Just { given, description, reason } ) ->
                    Element.column
                        [ Background.color Color.red
                        , Font.color Color.white
                        , Element.paddingXY 20 10
                        , Element.alignLeft
                        , Element.width Element.shrink

                        -- , Element.spacing 25
                        , Border.rounded 3
                        ]
                        [ Element.el [ Element.width Element.fill ] <| Element.text label
                        , Element.el [ Element.width Element.fill ] <| Element.text description
                        , Element.el [ Element.width Element.fill ] <| Element.text (toString reason)
                        ]
    in
    Element.column
        [ Border.width 1
        , Border.color Color.lightGrey
        , Element.padding 20
        , Element.height Element.shrink
        , Element.alignLeft
        , Element.spacing 16
        ]
        [ Element.el [ Font.bold, Font.size 64 ] (Element.text testable.label)
        , Element.column [ Element.alignLeft, Element.spacing 20 ]
            (failing
                |> List.map viewSingle
            )
        , Element.el
            [ Element.alignLeft
            , Element.spacing 20
            , Background.color Color.green
            , Font.color Color.white
            , Element.paddingXY 20 10
            , Element.alignLeft
            , Border.rounded 3
            ]
            (Element.text (toString (List.length passing) ++ " tests passing!"))
        ]
