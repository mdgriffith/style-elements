module Main exposing (..)

import Next.Internal.Model exposing (..)
import Html
import Html.Events
import AnimationFrame
import Time exposing (Time)
import Color exposing (Color)
import Mouse


type Checkpoint
    = Start
    | Point Int
    | End
    | MousePosition


main =
    Html.program
        { init =
            ( Debug.log "init"
                { timeline = 0
                , trackingMouse = False
                }
            , Cmd.none
            )
        , view = view
        , update = update
        , subscriptions =
            \model -> Sub.none
        }


type Msg
    = NoOp



-- | StartAnim
-- | Tick Time
-- | StopMouse
-- | FollowMouse { x : Int, y : Int }


update msg model =
    case msg of
        -- Tick time ->
        --     ( { model | timeline = Animator.update time model.timeline }
        --     , Cmd.none
        --     )
        -- StartAnim ->
        --     ( { model
        --         | timeline = Animator.start timeline model.timeline
        --         , trackingMouse = True
        --       }
        --     , Cmd.none
        --     )
        NoOp ->
            ( model, Cmd.none )


{-| -}
formatColor : Color -> String
formatColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
        ("rgba(" ++ toString red)
            ++ ("," ++ toString green)
            ++ ("," ++ toString blue)
            ++ ("," ++ toString alpha ++ ")")


view model =
    viewport <|
        container
            [ center
            , verticalCenter
            , style
                [ prop "color" (formatColor Color.blue)
                , prop "background-color" (formatColor Color.green)
                ]
            ]
            (column
                [ height (px 200)
                , spacing 20
                , width (px 500)

                -- , verticalCenter
                , spread
                , style
                    [ prop "color" (formatColor Color.blue)
                    , prop "background-color" "grey"
                    ]
                ]
                [ el
                    [ style
                        [ prop "color" (formatColor Color.blue)
                        , prop "background-color" (formatColor Color.green)
                        , prop "opacity" "1"
                        ]
                    ]
                    (text "First!")
                , container
                    [ width content
                    , center
                    , style
                        [ prop "color" (formatColor Color.blue)
                        , prop "background-color" (formatColor Color.green)
                        ]
                    ]
                    (text "Second")
                , paragraph []
                    [ text "Hello "
                    , text "Hello "
                    , text "Hello "
                    , text "Hello "
                    , el
                        [ style
                            [ prop "color" (formatColor Color.blue)
                            , prop "background-color" (formatColor Color.green)
                            ]
                        ]
                        (text "Second")
                    , text "Hello "
                    , text "Hello "
                    ]
                ]
            )


{-| Can we propogate a width or height up the tree?

In the following case, we'd like all `el`'s to get width fill

-}
mainOff =
    layout <|
        el [] <|
            el [] <|
                el
                    [ style
                        [ prop "background-color" "blue"
                        , prop "color" "white"
                        ]
                    , width (px 200)
                    ]
                    (text "fill!")


mainNearby =
    layout <|
        (el [ center, verticalCenter, width (px 200), height (px 200) ] (text "Hello!")
            |> below
                (el [] (text "I am below, yup!"))
        )
