module Main exposing (..)

import AnimationFrame
import Color exposing (Color)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Color as Color
import Element.Font as Font
import Element.Shadow as Shadow
import Html
import Html.Attributes
import Html.Events
import Input as Input
import Internal.Style as Internal
import Mouse
import Time exposing (Time)


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


view model =
    layout [] <|
        column []
            [ row
                [ height (px 100)
                , Color.background Color.green
                , Color.text Color.white
                , spaceEvenly
                ]
                [ el
                    [ link "http://zombo.com"

                    --height (px 8000)
                    --   alignTop
                    ]
                    (text "Hello World!!")
                , el
                    [--height (px 8000)
                     --   alignTop
                    ]
                    (text "Hello World!!")
                , el
                    [--height (px 8000)
                     --   alignTop
                    ]
                    (text "Hello World!! BLABLABLABLABLABLBALA")
                ]
            , el [] (text "MAIN CONTENT")
            , Input.text [ center, width (px 800) ]
                { text = "Helloooooo!"
                , onChange = always NoOp
                , placeholder = Nothing
                , label = Input.LabelOnRight empty
                }
            ]



-- column []
--     [ row
--         [ Color.background Color.white
--         , height (px 80)
--         , center
--         -- , Content.verticalCenter
--         ]
--         [ el
--             [ --Content.verticalCenter
--               -- , Content.alignLeft
--               moveDown 80
--             , Color.background Color.blue
--             , Color.text Color.white
--             ]
--             (text "My Logo")
--         , el
--             [ --Content.verticalCenter
--               -- , Content.center
--               Font.center
--             -- , center
--             ]
--             (text "My Name is Spartacus")
--         , row
--             [ --Content.verticalCenter
--               -- , Content.alignRight
--               Color.background Color.yellow
--             ]
--             [ text "hello!"
--             , text "hello!"
--             , el
--                 [ --Content.verticalCenter
--                   below
--                     (el [ Color.background Color.blue ] (text "I am below, yup!"))
--                 ]
--                 (text "hello!")
--             ]
--         ]
--     , el
--         [ Font.family
--             [ Font.typeface "Inconsolata"
--             , Font.monospace
--             ]
--         , Color.background Color.blue
--         , Color.text Color.white
--         , paddingXY 30 50
--         , center
--         , width (px 600)
--         ]
--         (text Internal.rules)
--     , textPage
--         [ spacing 10
--         , center
--         , Color.background Color.lightGrey
--         ]
--         [ el
--             [ width (px 50)
--             , height (px 50)
--             , Color.background Color.blue
--             , alignLeft
--             ]
--             empty
--         , paragraph []
--             [ text ipsum
--             ]
--         , paragraph []
--             [ text ipsum
--             ]
--         , paragraph []
--             [ text ipsum
--             ]
--         , el
--             [ width (px 50)
--             , height (px 50)
--             , Color.background Color.blue
--             , alignLeft
--             ]
--             empty
--         , paragraph []
--             [ text ipsum
--             ]
--         ]
--     , column [ spacing 20, padding 20, width (px 200), Color.background Color.grey ]
--         [ el [ width fill, height (px 20), Color.background Color.blue ] empty
--         , el [ width expand, height (px 20), Color.background Color.blue ] empty
--         , el [ width fill, height (px 20), Color.background Color.blue ] empty
--         ]
--     ]
-- view model =
--     layoutWith []
--         { modal = el [] empty
--         , content =
--             column []
--         }
-- view model =
--     layoutWith
--         { modal = el [] empty
--         , attributes = []
--         }
--     <|
--         column [] []
