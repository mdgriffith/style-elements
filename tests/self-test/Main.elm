module Main exposing (..)

import Html
import AutoSelfTest
import Element exposing (..)
import Element.Attributes exposing (..)
import Style exposing (style, cursor, hover, StyleSheet)
import Test exposing (Test)
import Test.Runner
import Random.Pcg
import Keyboard
import Style.Color as Color
import Color
import Style.Font as Font
import Window
import Style.Border as Border
import Style.Transition as Transition


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
            case model.results of
                Nothing ->
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

                _ ->
                    ( model, Cmd.none )


view : Model -> Html.Html msg
view model =
    let
        content =
            case model.results of
                Nothing ->
                    elems

                Just res ->
                    row None
                        [ spacing 80 ]
                        [ viewResults model.results
                        , elems
                        ]
    in
        Element.layout
            stylesheet
            content



-- type Styles
--     = None
--     | TestStyle
--     | TestResults
--     | PassingTest
--     | Blue
--     | Container


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
                    [ padding 15, spacing 25, width fill, inlineStyle [ ( "white-space", "pre" ) ] ]
                    (List.map viewResult res)


elementView : Element Styles variation msg
elementView =
    viewVisualTest



-- viewColumn


viewCenteredRow : Element Styles variation msg
viewCenteredRow =
    Element.row Container
        [ center
        , height (px 200)
        , width (px 200)
        ]
        [ el Blue
            [ height (px 100)
            , width (px 100)
            ]
            empty
        ]


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
    Element.row Container
        [ spacing 10 ]
        [ el Blue [ width (px 10), height (px 10) ] empty
        , el Blue [ width (px 10), height (px 10) ] empty
        , el Blue [ width (px 10), height (px 10) ] empty
        ]


viewColumn : Element Styles variation msg
viewColumn =
    Element.column Container
        [ spacing 10, height (px 3000) ]
        [ el Blue [ width (px 10), height (px 10) ] empty
        , el Blue [ width (px 10), height (px 10) ] empty
        , el Blue [ width (px 10), height (px 10) ] empty
        ]


viewFillRow : Element Styles variation msg
viewFillRow =
    Element.row Container
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



{-


   Brought in from Visual Test



-}


(=>) =
    (,)


type Styles
    = None
    | Main
    | Page
    | Box
    | Container
    | Label
    | Blue
    | BlackText
    | Crazy Other
    | TestStyle
    | TestResults
    | PassingTest


type Other
    = Thing Int


options =
    [ Style.unguarded
    ]


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style Main
            [ --Border.all 1
              Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            , Font.typeface [ Font.font "helvetica", Font.font "arial", Font.sansSerif ]
            , Font.size 16
            , Font.lineHeight 1.3
            ]
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
        , style Page
            [ Border.rounded 5

            -- , Border.all 5
            , Border.solid
            , Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            ]
        , style Label
            [ Font.size 25
            , Font.center
            ]
        , style Blue
            [ Color.text Color.white
            , Color.background Color.blue
            , Font.center
            ]
        , style BlackText
            [ Color.text Color.black
            ]
        , style Box
            [ Transition.all
            , Color.text Color.white
            , Color.background Color.blue
            , Color.border Color.blue
            , Border.rounded 3
            , hover
                [ Color.text Color.white
                , Color.background Color.red
                , Color.border Color.red
                , cursor "pointer"
                ]
            ]
        , style Container
            [ Color.text Color.black
            , Color.background Color.lightGrey
            , Color.border Color.lightGrey
            , hover
                [ Color.background Color.grey
                , Color.border Color.grey
                , cursor "pointer"
                ]
            ]
        , style
            (Crazy
                (Thing 5)
            )
            []
        ]



-- testForm =
--     [ Element.form <|
--         column
--             Box
--             [ spacingXY 10 20 ]
--             [ checkbox True None [] (text "Yes, Lunch pls.")
--             , label None [] (text "check this out") <|
--                 inputText None [] "The Value!"
--             , label None [] (text "check this out") <|
--                 textArea None [] "The Value!"
--             , radio "lunch"
--                 None
--                 []
--                 [ option "burrito" True (text "A Burrito!")
--                 , option "taco" False (text " A Taco!")
--                 ]
--             , select "favorite-animal"
--                 None
--                 []
--                 [ option "manatee" False (text "Manatees are pretty cool")
--                 , option "pangolin" False (text "But so are pangolins")
--                 , option "bee" True (text "Bees")
--                 ]
--             ]
--     ]


box =
    el Box [ width (px 200), height (px 200) ] empty


miniBox =
    el Box [ width (px 20), height (px 20) ] empty


viewVisualTest =
    el None
        [ center
        , width (px 800)
        ]
    <|
        column Main
            []
            (List.concat
                [ --basics
                  -- , invisibleText
                  -- , anchoredWithContent
                  -- , anchoredNoContent
                  -- , anchoredLayoutWithContent
                  -- , anchoredAboveLayout
                  -- , viewTextLayout
                  -- , [ otherTextLayout ]
                  -- -- , overflowIssue
                  -- -- , [ overFlowIssue2 ]
                  viewRowLayouts

                -- , [ verticalCenterText ]
                --   viewColumnLayouts
                -- , viewTable
                -- , viewGridLayout
                -- , viewNamedGridLayout
                -- --, testForm
                -- , [ screenExample
                --   , screenExample2
                --   ]
                ]
            )


otherTextLayout =
    textLayout Container
        [ spacing 10, paddingXY 10 10 ]
        [ el None [] <| text "A basic element is only allowed to have one child because it doesn't specify how children should be organized in a layout."
        , paragraph None
            []
            [ el None [] <| text "We also have a style identifier here, "
            , el Box [ padding 0 ] (text "MyStyle")
            , el None [] <| text ",  which we'll get into in the Style section of this guide."
            ]
        ]


screenExample =
    screen <|
        el None [ width (percent 100), alignBottom ] <|
            row Container
                [ spread
                , width (percent 60)
                , paddingXY 30 4
                ]
                [ el Box [ padding 8, width (px 200) ] (text "test")
                , el Box [ padding 8, width (px 200) ] (text "test")
                    |> above
                        [ column Container
                            [ moveUp 22, moveRight 20, spacing 8, alignRight ]
                            [ el Box [ width (px 85), height (px 30), padding 8 ] (text "AAAA")
                            , el Box [ width (px 85), height (px 30), padding 8 ] (text "BBBB")
                            , el Box [ width (px 85), height (px 30), padding 8 ] (text "CCCC")
                            ]
                        ]
                ]


screenExample2 =
    screen <|
        el Box [ padding 8, width (px 200), alignRight ] (text "test")


basics =
    [ el Container [ paddingXY 20 5 ] (text "Single Element")
    , el Container [ moveRight 20, moveDown 20, paddingXY 20 5 ] (text "Single Element")
    , el Container [ paddingLeft 20, paddingRight 5 ] (text "Single Element")
    , el Container [ paddingXY 20 5, alignLeft ] (text "Single Element")
    , el Container [ paddingXY 20 5, center, width (px 200) ] (text "Centered Element")
    , el Container [ paddingXY 20 5, alignRight ] (text "Align Right")
    , el Container [ paddingXY 20 5, center, spacing 20, width (px 200) ] (text "Centered ++ 20/20 Spacing Element")
    , el Container [ paddingXY 20 5, center, width (percent 100) ] (text "Single Element")
    ]


anchoredNoContent =
    [ row None
        [ spacingXY 150 150
        , center
        ]
        [ column None
            [ spacingXY 20 60 ]
            [ el Label [ width (px 200) ] (text "Anchored (no content)")
            , el Container [ width (px 200), height (px 200) ] empty
                |> within
                    [ el Box [ width (px 10), height (px 10), alignTop, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), alignTop, alignLeft ] empty
                    , el Box [ width (px 10), height (px 10), alignBottom, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), alignBottom, alignLeft ] empty
                    , el Box [ width (px 10), height (px 10), alignTop, center ] empty
                    , el Box [ width (px 10), height (px 10), alignBottom, center ] empty
                    , el Box [ width (px 10), height (px 10), verticalCenter, center ] empty
                    , el Box [ width (px 10), height (px 10), verticalCenter, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), verticalCenter, alignLeft ] empty
                    ]
            ]
        , article <|
            column
                None
                [ spacingXY 20 60 ]
                [ section <| el Label [ width (px 200) ] (text "Nearby (no content)")
                , el Container [ width (px 200), height (px 200) ] empty
                    |> above
                        [ el Box [ width (px 10), height (px 10) ] empty
                        , el Box [ width (px 10), height (px 10), alignRight ] empty
                        , el Box [ width (px 10), height (px 10), center ] empty
                        ]
                    |> below
                        [ el Box [ width (px 10), height (px 10) ] empty
                        , el Box [ width (px 10), height (px 10), alignRight ] empty
                        , el Box [ width (px 10), height (px 10), center ] empty
                        ]
                    |> onRight
                        [ el Box [ width (px 10), height (px 10) ] empty
                        , el Box [ width (px 10), height (px 10), alignBottom ] empty
                        , el Box [ width (px 10), height (px 10), verticalCenter ] empty
                        ]
                    |> onLeft
                        [ el Box [ width (px 10), height (px 10) ] empty
                        , el Box [ width (px 10), height (px 10), alignBottom ] empty
                        , el Box [ width (px 10), height (px 10), verticalCenter ] empty
                        ]
                ]
        ]
    , row None
        [ spacingXY 150 150
        , center
        ]
        [ column None
            [ spacingXY 20 60 ]
            [ el Label [ width (px 200) ] (text "Move 20/20 (no content)")
            , el Container [ width (px 200), height (px 200) ] empty
                |> within
                    [ el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignTop, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignTop, alignLeft ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignBottom, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignBottom, alignLeft ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignTop, center ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignBottom, center ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, verticalCenter, center ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, verticalCenter, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, verticalCenter, alignLeft ] empty
                    ]
            ]
        , column None
            [ spacingXY 20 60 ]
            [ el Label [ width (px 200) ] (text "Move 20 20 (no content)")
            , el Container [ width (px 200), height (px 200) ] empty
                |> above
                    [ el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20 ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, center ] empty
                    ]
                |> below
                    [ el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20 ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignRight ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, center ] empty
                    ]
                |> onRight
                    [ el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20 ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignBottom ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, verticalCenter ] empty
                    ]
                |> onLeft
                    [ el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20 ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, alignBottom ] empty
                    , el Box [ width (px 10), height (px 10), moveRight 20, moveDown 20, verticalCenter ] empty
                    ]
            ]
        ]
    ]


anchoredWithContent =
    [ row None
        [ spacing 150
        , center
        ]
        [ column None
            [ spacing 60 ]
            [ el Label [] (text "Anchored Elements")
            , el Container [ width (px 200), height (px 200) ] (text "Hi!")
                |> within
                    [ el Box [ alignTop, alignRight ] (text "Hi!")
                    , el Box [ alignTop, alignLeft ] (text "Hi!")
                    , el Box [ alignBottom, alignRight ] (text "Hi!")
                    , el Box [ alignBottom, alignLeft ] (text "Hi!")
                    , el Box [ alignTop, center ] (text "Hi!")
                    , el Box [ alignBottom, center ] (text "Hi!")
                    , el Box [ verticalCenter, center ] (text "Hi!")
                    , el Box [ verticalCenter, alignRight ] (text "Hi!")
                    , el Box [ verticalCenter, alignLeft ] (text "Hi!")
                    ]
            ]
        , article <|
            column
                None
                [ spacing 60 ]
                [ section <| el Label [] (text "Nearby Elements")
                , el Container [ width (px 200), height (px 200) ] (text "Hi!")
                    |> above
                        [ el Box [] (text "Hi!")
                        , el Box [ alignRight ] (text "Hi!")
                        , el Box [ center ] (text "Hi!")
                        ]
                    |> below
                        [ el Box [] (text "H!")
                        , el Box [ alignRight ] (text "Hi!")
                        , el Box [ center ] (text "Hi!")
                        ]
                    |> onRight
                        [ el Box [] (text "Hi!")
                        , el Box [ alignBottom ] (text "Hi!")
                        , el Box [ verticalCenter ] (text "Hi!")
                        ]
                    |> onLeft
                        [ el Box [] (text "Hi!")
                        , el Box [ alignBottom ] (text "Hi!")
                        , el Box [ verticalCenter ] (text "Hi!")
                        ]
                ]
        ]
    , row None
        [ spacing 100
        , center
        ]
        [ column None
            [ spacing 20 ]
            [ el Label [] (text "Move 20 20")
            , el Container [ width (px 200), height (px 200) ] empty
                |> within
                    [ el Box
                        [ moveRight 20
                        , moveDown 20
                        , alignTop
                        , alignRight
                        ]
                        (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignTop, alignLeft ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignBottom, alignRight ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignBottom, alignLeft ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignTop, center ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignBottom, center ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, verticalCenter, center ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, verticalCenter, alignRight ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, verticalCenter, alignLeft ] (text "Hi!")
                    ]
            ]
        , column None
            [ spacing 20 ]
            [ el Label [] (text "Move 20 20")
            , el Container [ width (px 200), height (px 200) ] (text "Hi!")
                |> above
                    [ el Box [ moveRight 20, moveDown 20 ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignRight ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, center ] (text "Hi!")
                    ]
                |> below
                    [ el Box [ moveRight 20, moveDown 20 ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignRight ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, center ] (text "Hi!")
                    ]
                |> onRight
                    [ el Box [ moveRight 20, moveDown 20 ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignBottom ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, verticalCenter ] (text "Hi!")
                    ]
                |> onLeft
                    [ el Box [ moveRight 20, moveDown 20 ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, alignBottom ] (text "Hi!")
                    , el Box [ moveRight 20, moveDown 20, verticalCenter ] (text "Hi!")
                    ]
            ]
        ]
    ]


anchoredLayoutWithContent =
    [ row None
        [ spacingXY 150 150
        , center
        ]
        [ column
            None
            [ spacingXY 20 60 ]
            [ section <| el Label [] (text "Nearby Layouts")
            , el Container [ width (px 200), height (px 200) ] (text "Hi!")
                |> above
                    [ row Container
                        [ moveDown -20
                        , spacing 10
                        , alignRight
                        ]
                        [ el Box [] (text "Hi!")
                        , el Box [] (text "Hi!")
                        ]
                    ]
                |> below
                    [ row Container [ moveDown 20, spacing 10 ] [ el Box [] (text "Hi!"), el Box [] (text "Hi!") ]
                    ]
                |> onRight
                    [ column Container [ moveRight 20, spacing 10, alignBottom ] [ el Box [] (text "Hi!"), el Box [] (text "Hi!") ]
                    ]
                |> onLeft
                    [ column Container [ moveRight -20, spacing 10 ] [ el Box [] (text "Hi!"), el Box [] (text "Hi!") ]
                    ]
            ]
        , column
            None
            [ spacingXY 20 60 ]
            [ section <| el Label [] (text "Nearby Layouts")
            , el Container [ width (px 200), height (px 200) ] (text "Hi!")
                |> within
                    [ row Container [ spacing 10, alignRight ] [ el Box [] (text "Hi!"), el Box [] (text "Hi!") ]
                    , row Container [ spacing 10, alignBottom, alignLeft ] [ el Box [] (text "Hi!"), el Box [] (text "Hi!") ]
                    , column Container [ spacing 10, alignRight, alignBottom ] [ el Box [] (text "Hi!"), el Box [] (text "Hi!") ]
                    , column Container [ spacing 10, alignLeft ] [ el Box [] (text "Hi!"), el Box [] (text "Hi!") ]
                    ]
            ]
        ]
    ]


anchoredAboveLayout =
    [ row None
        [ center
        , spacing 150
        ]
        [ column
            None
            [ spacing 20 ]
            [ section <| el Label [] (text "Above Layout")
            , el None [ center ] <|
                (row Container
                    [ spacing 10
                    , padding 30
                    , width (px 200)
                    , height (px 200)
                    ]
                    [ el Box [] (text "Hi!")
                    , el Box [] (text "Hi!")
                    ]
                    |> above
                        [ el Box
                            [ moveRight 20
                            , moveDown 20
                            ]
                            (text "Hi!")
                        , el Box
                            [ moveRight 20
                            , moveDown 20
                            , alignRight
                            ]
                            (text "Hi!")
                        , el Box
                            [ moveRight 20
                            , moveDown 20
                            , center
                            ]
                            (text "Hi!")
                        ]
                    |> below
                        [ el Box [ moveRight 20, moveDown 20 ] (text "Hi!")
                        , el Box [ moveRight 20, moveDown 20, alignRight ] (text "Hi!")
                        , el Box [ moveRight 20, moveDown 20, center ] (text "Hi!")
                        ]
                    |> onRight
                        [ el Box [ moveRight 20, moveDown 20 ] (text "Hi!")
                        , el Box [ moveRight 20, moveDown 20, alignBottom ] (text "Hi!")
                        , el Box [ moveRight 20, moveDown 20, verticalCenter ] (text "Hi!")
                        ]
                    |> onLeft
                        [ el Box [ moveRight 20, moveDown 20 ] (text "Hi!")
                        , el Box [ moveRight 20, moveDown 20, alignBottom ] (text "Hi!")
                        , el Box [ moveRight 20, moveDown 20, verticalCenter ] (text "Hi!")
                        ]
                )
            ]

        -- , column
        --     None
        --     [ spacing 20 ]
        --     [ section <| el Label [] (text "Raw Html Below")
        --     , el Container [ width (px 200), height (px 200) ] (text "Hi!")
        --         |> below
        --             [ html <| Html.div [] [ Html.text "This is raw HTML! (Should be Below" ]
        --             ]
        --     ]
        ]
    ]


viewTextLayout =
    [ -- el Label [] (text "Text Layout")
      textLayout Page
        [ padding 50
        , spacingXY 25 25
        ]
        [ el Box
            [ width (px 200)
            , height (px 300)
            , alignLeft
            ]
            empty
        , paragraph None
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]

        -- , hairline Container
        , paragraph None
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]

        -- , paragraph None
        --     [ width (px 500)
        --     , center
        --     ]
        --     [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        --     ]
        -- , paragraph None
        --     []
        --     [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        --     ]
        -- , el Box
        --     [ width (px 200)
        --     , height (px 300)
        --     , alignRight
        --     , spacing 100
        --     ]
        --     empty
        -- , paragraph None
        --     []
        --     [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        --     ]
        -- , paragraph None
        --     [ spacing 10 ]
        --     [ el Box [ paddingXY 5 0 ] (text "•")
        --     , el Box [ paddingXY 5 0 ] (text "•")
        --     , el Box [ paddingXY 5 0 ] (text "•")
        --     , text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        --     ]
        -- , paragraph None
        --     [ spacing 10 ]
        --     [ el Box [ paddingXY 5 0 ] (text "•")
        --     , el Box [ paddingXY 5 0 ] (text "•")
        --     , el Box [ paddingXY 5 0, spacing 0 ] (text "•")
        --     , text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        --     ]
        -- , numbered None
        --     []
        --     [ text "the first"
        --     , text "the second"
        --     , text "afterwards"
        --     ]
        -- , paragraph None
        --     []
        --     [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        --     ]
        -- , full Box [] <|
        --     text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        ]
    ]


invisibleText =
    [ row Container
        []
        [ el None [] (text "Test! (Should be visible)") ]
    , column Box
        [ width <| percent 60
        , center
        ]
        [ text "Test! (Should be visible 2)"
        ]
    ]


overflowIssue =
    let
        long =
            "something very long too long to fit on a mobile screen and should break lorem ipsum dolar sit amet lorem ipsum lorem ipsum dolar sit amet lorem ipsum lorem ipsum dolar sit amet lorem ipsum lorem ipsum dolar sit amet lorem ipsum "
    in
        [ el Label [] (text "No overflow")
        , row Container
            []
            [ el None [] (text long) ]
        , row Container
            [ width (px 800) ]
            [ el None [] (text long) ]
        , row Container
            [ width (percent 100) ]
            [ el None [] (text long) ]
        , row Container
            [ width fill ]
            [ el None [] (text long) ]
        , el Label [] (text "Overflow on purpose")
        , row Container
            []
            [ el None [ width (px 1800) ] (text long)
            ]
        , row Container
            [ width fill ]
            [ el None [ width (percent 120) ] (text long) ]
        , row Container
            [ width fill ]
            [ el None [ width (fillPortion 2) ] (text long) ]
        ]


viewRowLayouts =
    [ el Label [] (text "Row Layout")
    , row Container
        [ spacing 20 ]
        [ box
        , box
        , box
        ]
    , el Label [] (text "Row with Text Layout (should be centered and spaced with 20px)")
    , row Container
        [ spacing 20, center ]
        [ text "box"
        , text "box"
        , text "box"
        ]
    , el Label [] (text "Row with uneven content and fill widths (should match up)")
    , column Container
        [ spacing 20 ]
        [ row Container
            []
            [ el Box [ width fill ] (text ".")
            , el Box [ width fill ] (text "short")
            ]
        , row Container
            []
            [ el Box [ width fill ] (text "short")
            , el Box [ width fill ] (text "looooooooong")
            ]
        ]
    , el Label [] (text "Row Child Alignment")
    , row Container
        [ spacing 20, height (px 400) ]
        [ el Box [ width (px 100), height (px 100), alignTop ] (text "top")
        , el Box [ width (px 100), height (px 100), verticalCenter ] (text "vcenter")
        , el Box [ width (px 100), height (px 100), alignBottom ] (text "bottom")
        , el Box [ width (px 100), height (px 100), alignRight ] (text "right (no effect)")
        , el Box [ width (px 100), height (px 100), alignLeft ] (text "left (no effect)")
        , el Box [ width (px 100), height (px 100), center ] (text "center (no effect)")
        ]
    , el Label [] (text "Row Center Alignment")
    , row Container
        [ spacing 20, center ]
        [ el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        ]
    , el Label [] (text "Row Width/Heights")
    , row Container
        [ spacing 20, height (px 300) ]
        [ el Box [ width (px 200), height fill ] (text "fill height")
        , el Box [ width fill, height (px 200) ] (text "fill width")
        ]
    , el Label [] (text "Row Center ++ Spacing")
    , row Container
        [ center, spacing 20 ]
        [ el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        , full Box [ width (px 100) ] (text "full element")
        ]
    , el Label [] (text "Row Center ++ Spacing ++ padding")
    , row Container
        [ center, spacing 20, padding 50 ]
        [ el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        , full Box [ width (px 100) ] (text "full element")
        ]
    , el Label [] (text "Wrapped Row Layout")
    , wrappedRow Container
        [ spacing 20 ]
        [ el Box [ width (px 100), height (px 50) ] empty
        , el Box [ width (px 20), height (px 50) ] empty
        , el Box [ width (px 200), height (px 50) ] empty
        , el Box [ width (px 120), height (px 50) ] empty
        , el Box [ width (px 10), height (px 50) ] empty
        , el Box [ width (px 100), height (px 50) ] empty
        , el Box [ width (px 180), height (px 50) ] empty
        , el Box [ width (px 20), height (px 50) ] empty
        , el Box [ width (px 25), height (px 50) ] empty
        ]
    ]


viewColumnLayouts =
    [ --el Label [] (text "Column Layout")
      -- , column Container
      --     [ spacing 20 ]
      --     [ box
      --     , box
      --     , box
      --     ]
      -- , el Label [] (text "Column Layout, Justified")
      -- , column Container
      --     [ verticalSpread, height (px 800), width (px 800) ]
      --     [ box
      --     , box
      --     , box
      --     ]
      -- , el Label [] (text "Column ++ Spacing")
      -- , column Container
      --     [ spacing 20 ]
      --     [ el Box [ width (px 200), height (px 200) ] empty
      --     , el Box [ width (percent 100), height (px 200) ] (text "100% width")
      --     , el Box [ width (px 200), height (px 200) ] empty
      --     , full Box [ height (px 200) ] (text "full element")
      --     , el Box [ width (px 200), height (px 200) ] empty
      --     , full Box [ height (px 200) ] (text "full element")
      --     ]
      -- , el Label [] (text "Column ++ Spacing ++ Padding ++ Varying widths")
      -- , column Container
      --     [ spacing 20, padding 50 ]
      --     [ el Box [ width (px 200), height (px 200) ] (text "200px")
      --     , el Box [ width (percent 100), height (px 200) ] (text "100% width")
      --     , el Box [ width (px 200), height (px 200) ] (text "200px")
      --     , full Box [ height (px 200) ] (text "full element")
      --     ]
      -- , el Label [] (text "Column Alignments")
      -- , column Container
      --     [ spacing 20 ]
      --     [ el Box [ width (px 200), height (px 200), alignLeft ] empty
      --     , el Box [ width (px 200), height (px 200), center ] empty
      --     , el Box [ width (px 200), height (px 200), alignRight ] empty
      --     , el Box [ width (px 200), height (px 200), alignTop ] (text "No effect on purpose!")
      --     , el Box [ width (px 200), height (px 200), alignBottom ] (text "No effect on purpose!")
      --     , el Box [ width (px 200), height (px 200), verticalCenter ] (text "No effect on purpose!")
      --     ]
      -- , el Label [] (text "Column Alignments ++ Width fill")
      -- , column Container
      --     [ spacing 20 ]
      --     [ el Box [ width fill, height (px 200), alignLeft ] empty
      --     , el Box [ width fill, height (px 200), center ] empty
      --     , el Box [ width fill, height (px 200), alignRight ] empty
      --     , el Box [ width fill, height (px 200), alignTop ] empty
      --     , el Box [ width fill, height (px 200), alignBottom ] empty
      --     , el Box [ width fill, height (px 200), verticalCenter ] empty
      --     ]
      -- , el Label [] (text "Column Alignments ++ Height fill")
      column Container
        [ spacing 20, height (px 200) ]
        [ el Box
            [ width (px 200)
            , height fill
            , alignLeft
            ]
            empty
        , el Box
            [ width (px 200)
            , height fill
            , center
            ]
            empty
        , el Box [ width (px 200), height fill, alignRight ] empty
        , el Box [ width (px 200), height fill, alignTop ] empty
        , el Box [ width (px 200), height fill, alignBottom ] empty
        , el Box [ width (px 200), height fill, verticalCenter ] empty
        ]
    ]


viewGridLayout =
    [ el Label [] (text "Grid Layout")
    , grid Container
        { columns = [ px 100, px 100, px 100, px 100 ]
        , rows =
            [ px 100
            , px 100
            , px 100
            , px 100
            ]
        }
        [ spacing 20 ]
        [ area
            { start = ( 0, 0 )
            , width = 1
            , height = 1
            }
            (el Box [] (text "box"))
        , area
            { start = ( 1, 1 )
            , width = 1
            , height = 2
            }
            (el Box [ spacing 100 ] (text "box"))
        , area
            { start = ( 2, 1 )
            , width = 2
            , height = 2
            }
            (el Box [] (text "box"))
        , area
            { start = ( 1, 0 )
            , width = 1
            , height = 1
            }
            (el Box [] (text "box"))
        ]
    ]


viewTable =
    [ el Label [] (text "Table Layout")
    , table Container
        [ spacing 20 ]
        [ [ (el Box [] (text "box"))
          , (el Box [ spacing 100 ] (text "box"))
          , (el Box [] (text "box"))
          ]
        , [ el Box [] (text "reallly big box here is all the content, woohooo!!")
          , (el Box [ spacing 100 ] (text "box"))
          , (el Box [] (text "box"))
          ]
        , [ (el Box [ spacing 100 ] (text "box"))
          , el Box [] (text "reallly big box here is all the content, woohooo!!")
          , (el Box [] (text "box"))
          ]
        ]
    ]


viewNamedGridLayout =
    [ el Label [] (text "Named Grid Layout")
    , namedGrid Container
        { columns = [ px 200, px 200, px 200, fill ]
        , rows =
            [ px 200 => [ spanAll "header" ]
            , px 200 => [ span 3 "content", span 1 "sidebar" ]
            , px 200 => [ span 3 "content", span 1 "sidebar" ]
            , px 200 => [ spanAll "footer" ]
            ]
        }
        []
        [ named "header"
            (el Box [] (text "box"))
        , named "sidebar"
            (el Box [] (text "box"))
        ]
    ]


viewTransforms =
    [ el Label [] (text "Transformations")
    , row Container
        [ spacing 20 ]
        [ el Box
            [ width (px 200)
            , height fill
            ]
            empty
        ]
    ]



{- OVERFLOW ISSUE -}


overFlowIssue2 =
    let
        followingMessage =
            row Box
                [ padding 10, width (px 200) ]
                [ el BlackText [] (text lorem)
                ]

        lorem =
            "Donec interdum elementum aliquam. Maecenas cursus sem tellus, id elementum elit condimentum eget. Proin quis massa mi. In fermentum risus at quam tristique vestibulum. Quisque convallis odio in sodales euismod. Maecenas convallis nec justo nec facilisis."
    in
        column Container
            [ spacing 10, height <| px 800 ]
            [ followingMessage
            , followingMessage
            , followingMessage
            , followingMessage
            , followingMessage
            , followingMessage
            ]



{- Vertical Center text if height is set.

-}


verticalCenterText =
    row Container
        [ center, height (px 300), spacing 10 ]
        [ el Box [] (text "normal")
        , el Box [ height (px 100), verticalCenter ] <|
            (el None [ verticalCenter ] <| text "vertical centered in box")
        , el Box [] (text "normal")
        ]
