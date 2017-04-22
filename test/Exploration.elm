module Main exposing (..)

{-| -}

import Window
import Time exposing (Time)


main =
    Html.program
        { view = view
        , model = ( 5, Cmd.none )
        , update = update
        , subscriptions =
            Sub.batch
                [ Window.resize Resize
                , AnimationFrame.diffs Tick
                ]
        }


type Msg
    = Resize Window.Resize
    | Tick Time


update msg model =
    ( model, Cmd.none )


type Elements
    = Logo


elements elem =
    case elem of
        ToDoElement element ->
            Style.elementAs button
                [ onClick (Blink element.id)
                , palette blue
                , hover
                    [ scale 1.2
                    ]
                ]

        Logo ->
            Style.element
                [ onClick Blink
                , hover
                    [ dance
                    ]
                , animation Intro
                    [ to
                    ]
                ]

        BottomNode ->
            Style.element
                [ onClick Blink
                , hover
                    [ dance
                    ]
                ]

        NavBar ->
            Style.element
                [ background
                    [ Background.gradient
                        Background.toTopRight
                        [ Background.step Color.red
                        , Background.percent Color.blue 20
                        , Background.step Color.yellow
                        ]
                    ]
                ]

        SignupMenu ->
            [ onClick Dismiss
            ]

        Button msg ->
            [ palette blue
            , padding 20
            , variation Big
                [ palette blue
                ]
            ]


view device model =
    Style.render defaults elements <|
        center Main
            []
            [ row Nav
                [ if device.phone || device.tablet then
                    hidden
                  else
                    width 800
                ]
                [ el Logo
                    [ variations
                        [ Small => window.phone
                        , Large => window.desktop
                        ]
                    ]
                    (text "style-elements")
                , el Success [] <|
                    paragraph
                        [ bold "Well done! "
                        , text "You've successfully read "
                        , bold "this important alert message. "
                        , link "/home" "Go Home!"
                        ]
                , lazy searchView model.search
                , screen <| el PullRequests [] (text "issues")
                , el Issues [] (text "issues")
                , el Gist [] (text "gist")
                , el Bell [] empty

                -- Content Switch animtion
                , animated Menu menu.states <|
                    case step of
                        Open ->
                            el Menu [] (text "profile")
                                |> (below column Menu)
                                    []
                                    [ text "Welcome!"
                                    , vary (Button SubmitSignup)
                                        [ Blue => True ]
                                        (text "Submit!")
                                    ]

                        Closed ->
                            el Menu [] (text "profile")

                -- Basic Slide out
                , animated Menu menu.states <|
                    case step of
                        Open ->
                            el Menu [ position 0 0 ] (text "profile")

                        Closed ->
                            el Menu [ position 200 0 ] (text "profile")

                -- Basic Slide out, with style change
                , animated Menu menu.states <|
                    case step of
                        Open ->
                            el Menu
                                [ position 200 0
                                , variations
                                    [ Green => True
                                    ]
                                ]
                                (text "profile")

                        Closed ->
                            el Menu
                                [ position 0 0
                                ]
                                (text "profile")

                -- An animated List of things
                , animatedColumn Menu [] <|
                    List.indexedMap
                        (\i item -> animatedItem i item.anim (el Issues [] (text "issues")))
                        model.items
                , el Menu [] (text "profile")
                    |> if model.open then
                        below <|
                            column Menu
                                []
                                [ text "Welcome!"
                                , input
                                , vary (Button SubmitSignup)
                                    [ Blue => True ]
                                    (text "Submit!")
                                ]
                       else
                        nevermind
                , when model.signingUp (overlay BackDrop signupMenu)
                , row Nav
                    [ variations
                        [ Small => window.phone
                        , Large => window.desktop
                        ]
                    ]
                    []
                ]
            , centered BottomSection
                [ height 20
                , spacing (all 20)
                ]
                [ full Introduction [] (text "yaddayadda")
                , column <| keyed .id (\item -> el ToDoElement (text item.text)) model.todoList
                , textLayout Container
                    []
                    [ floatLeft Picture [] (image "src")
                    , el Text [] (text "blah blah")
                    , text "blah blah"
                    , centered (Button SendHttpRequest) [] (text "Push Me")
                    ]
                ]
            ]


singupMenu =
    centered Menu
        [ text "Welcome!"
        , el Input [] (text "Woohoo!")
        , el (Button SubmitSignup)
            [ vary [ Blue => True ]
            ]
            (text "Submit!")
        ]


defaults =
    [ default
        [ font
            [ Font.stack [ "Open Sans" ]
            , Font.size 18
            , Font.letterSpacing 20
            , Font.light
            , Font.center
            , Font.uppercase
            ]
        , background
            [ Background.gradient
                Background.toTopRight
                [ Background.step Color.red
                , Background.percent Color.blue 20
                , Background.step Color.yellow
                ]
            ]
        , border
            [ Border.width (all 5)
            , Border.radius (all 5)
            , Border.solid
            ]
        ]
    ]



-- Search ->
--     Style.static <|
--         div [] [ text "My Logo" ]
-- PullRequests ->
--     Style.static <|
--         div [] [ text "My Logo" ]
-- Text ->
--     Style.keyedList .paragraphs
--         (\key logo ->
--             div [] [ text "My Logo" ]
--         )
-- Other ->
--     Style.keyedList .paragraphs
--         .key
--         (\logo ->
--             div [] [ text "My Logo" ]
--         )
