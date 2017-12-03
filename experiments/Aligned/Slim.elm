module Main exposing (..)

import AnimationFrame
import Color exposing (Color)
import Element exposing (..)
import Element.Attributes exposing (..)
import Html
import Html.Events
import Internal.Style as Internal
import Mouse
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
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
        column []
            [ row
                [ Color.background Color.white
                , height (px 80)
                , center

                -- , Content.verticalCenter
                ]
                [ el
                    [ --Content.verticalCenter
                      -- , Content.alignLeft
                      moveDown 80
                    , Color.background Color.blue
                    , Color.text Color.white
                    ]
                    (text "My Logo")
                , el
                    [ --Content.verticalCenter
                      -- , Content.center
                      Font.center

                    -- , center
                    ]
                    (text "My Name is Spartacus")
                , row
                    [ --Content.verticalCenter
                      -- , Content.alignRight
                      Color.background Color.yellow
                    ]
                    [ text "hello!"
                    , text "hello!"
                    , el
                        [ --Content.verticalCenter
                          below
                            (el [ Color.background Color.blue ] (text "I am below, yup!"))
                        ]
                        (text "hello!")
                    ]
                ]
            , el
                [ Font.family
                    [ Font.typeface "Inconsolata"
                    , Font.monospace
                    ]
                , Color.background Color.blue
                , Color.text Color.white
                , paddingXY 30 50
                , center
                , width (px 600)
                ]
                (text Internal.rules)
            , textPage
                [ spacing 10
                , center
                , Color.background Color.lightGrey
                ]
                [ el
                    [ width (px 50)
                    , height (px 50)
                    , Color.background Color.blue
                    , alignLeft
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
                    , alignLeft
                    ]
                    empty
                , paragraph []
                    [ text ipsum
                    ]
                ]
            , column [ spacing 20, padding 20, width (px 200), Color.background Color.grey ]
                [ el [ width fill, height (px 20), Color.background Color.blue ] empty
                , el [ width expand, height (px 20), Color.background Color.blue ] empty
                , el [ width fill, height (px 20), Color.background Color.blue ] empty
                ]
            ]


ipsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
