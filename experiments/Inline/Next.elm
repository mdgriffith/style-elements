module Main exposing (..)

-- import Next.Internal.Model exposing (..)
-- import Next.Element.Attributes exposing (..)

import AnimationFrame
import Color exposing (Color)
import Html
import Html.Events
import Mouse
import Next.Element exposing (..)
import Next.Element.Content as Content
import Next.Element.Position as Position
import Next.Internal.Style as Internal
import Next.Style.Color as Color
import Next.Style.Font as Font
import Next.Style.Shadow as Shadow
import Time exposing (Time)


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


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



{- Revised Alignment

   alignLeft, alignRight, center, verticalCenter, alignTop, alignBottom all apply to the element they are attached to.

   spread, spreadVertically, and spacing all apply to children.



-}
-- layers =
--     layered <|
-- navWithJustContainers =
--     viewport <|
--         column []
--             [ row [ height (px 80) ]
--                 [ el [ alignleft ] (text "logo")
--                 , el [ center ]
--                     (text "Matthew Griffith")
--                 , el [ alignRight ]
--                     (text "option menu")
--                     |> below
--                         (column []
--                             [ text "option 1"
--                             , text "option 2"
--                             ]
--                         )
--                 ]
--             , mainContent []
--                 [ text "heres the content" ]
--             ]
-- navWithAlignmentBuiltIn =
--     viewport <|
--         column []
--             [ row [ height (px 80) ]
--                 [ left [] (text "logo")
--                 , center []
--                     (text "Matthew Griffith")
--                 , right []
--                     (text "option menu")
--                     |> below []
--                         (column []
--                             [ text "option 1"
--                             , text "option 2"
--                             ]
--                         )
--                 ]
--             , mainContent []
--                 [ text "heres the content" ]
--             ]


view model =
    layout
        [ Color.text Color.black
        , Color.background Color.white
        , Font.family
            [ Font.typeface "Garamond EB"
            , Font.typeface "georgia"
            , Font.serif
            ]
        ]
    <|
        -- el
        --     [ Content.center
        --     , verticalCenter
        --     , Color.background Color.blue
        --     , Color.text Color.white
        --     , width (px 200)
        --     , height (px 200)
        --     ]
        --     (text "box")
        column []
            [ row
                [ Color.background Color.white
                , height (px 80)
                , Content.verticalCenter

                -- , spaceEvenly
                -- , paddingLeft (px 20)
                -- , paddingRight (px 20)
                ]
                [ el
                    [ Content.verticalCenter
                    , Content.alignLeft
                    , Position.moveDown 80

                    --, center
                    -- , height fill
                    , Color.background Color.blue
                    , Color.text Color.white
                    ]
                    (text "My Logo")
                , el
                    [ Content.verticalCenter
                    , Content.center
                    , Font.center

                    -- , center
                    ]
                    (text "My Name is Spartacus")
                , row
                    [ Content.verticalCenter
                    , Content.alignRight
                    , Color.background Color.yellow
                    ]
                    [ text "hello!"
                    , text "hello!"
                    , el [ Content.verticalCenter ] (text "hello!")
                        |> below
                            (el [] (text "I am below, yup!"))
                    ]
                ]
            , el
                [ Font.family
                    [ Font.typeface "Inconsolata"
                    , Font.monospace
                    ]
                , Content.paddingXY 30 50
                , Position.center
                , width (px 600)
                ]
                (text Internal.rules)
            , textPage
                [ Content.spacing 10
                , Position.center
                ]
                [ el
                    [ width (px 50)
                    , height (px 50)
                    , Color.background Color.blue
                    , Position.alignRight
                    ]
                    empty
                , paragraph []
                    [ text ipsum
                    ]
                , paragraph []
                    [ text ipsum
                    ]
                , paragraph []
                    [ text ipsum
                    ]
                , el
                    [ width (px 50)
                    , height (px 50)
                    , Color.background Color.blue
                    , Position.alignRight
                    ]
                    empty
                , paragraph []
                    [ text ipsum
                    ]
                ]
            , column [ Content.spacing 20, Content.paddingAll 20, width (px 200), Color.background Color.grey ]
                [ el [ width fill, height (px 20), Color.background Color.blue ] empty
                , el [ width expand, height (px 20), Color.background Color.blue ] empty
                , el [ width fill, height (px 20), Color.background Color.blue ] empty
                ]

            -- , el [] (text "hello")
            -- , el [] (text "hello")
            -- , el [] (text "hello")
            -- , el [] (text "hello")
            -- , el [] (text "hello")
            ]



-- [ el
--     [ Color.text Color.white
--     , Color.background Color.blue
--     ]
--     (text "Box!")
-- , el
--     [ Color.text Color.white
--     , Color.background Color.blue
--     , center
--     ]
--     (text "Box!")
-- , el
--     [ Color.text Color.white
--     , Color.background Color.blue
--     ]
--     (text "Box!")
-- ]
-- column
--     [ center
--     , verticalCenter
--     , height (px 200)
--     , width (px 500)
--     , spacing 20
--     -- , verticalCenter
--     -- , spread
--     , Color.text Color.blue
--     , Color.background Color.grey
--     ]
--     [ el
--         [ Color.text Color.blue
--         , Color.background Color.white
--         -- , prop "opacity" "1"
--         ]
--         (text "First!")
--     , el
--         [ --width content
--           center
--         , Color.text Color.blue
--         , Color.background Color.white
--         ]
--         (text "Second")
--     -- , paragraph []
--     --     [ text "Hello "
--     --     , text "Hello "
--     --     , text "Hello "
--     --     , text "Hello "
--     --     , el
--     --         [ Color.text Color.blue
--     --         , Color.background Color.white
--     --         ]
--     --         (text "Second")
--     --     , text "Hello "
--     --     , text "Hello "
--     --     ]
--     ]


ipsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."


{-| Can we propogate a width or height up the tree?

In the following case, we'd like all `el`'s to get width fill

-}
mainOff =
    layout [] <|
        el [] <|
            el
                [ Color.background Color.blue
                , Color.text Color.white
                , width (px 200)
                ]
                (text "fill!")


mainNearby =
    layout
        [ Content.center
        , Content.verticalCenter
        , width (px 200)
        , height (px 200)
        ]
        (text "Hello!"
            |> below
                (el [] (text "I am below, yup!"))
        )
