module Main exposing (..)

{-| -}

import Element exposing (..)
import Element.Device
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Html.Events
import Style exposing (..)
import Style.Background as Background
import Style.Font as Font
import Style.Color
import Color


main =
    Element.program
        { stylesheet = Element.stylesheet stylesheet
        , device = Element.Device.match
        , view = view
        , init = ( 5, Cmd.none )
        , update = update
        , subscriptions =
            (\_ ->
                Sub.none
            )
        }


view device model =
    textView


columnView =
    column UnStyled
        [ spacing 200 200
        , padding (all 20)
        ]
        [ (section <| row) MyRow
            [ spacing 25 25
            , padding (all 12.5)
            ]
            [ el Test
                [ padding (all 20)
                , width (percent 50)
                , vary Success True
                ]
                (text "Hello World!")
            , el Test
                [ padding (all 20)
                , width (percent 50)
                , vary Success True
                ]
                (text "Hello World!")
            ]
        , el Test
            [ padding (all 20)
            , width (px 500)

            -- , spacing 800 800
            , vary Success True

            -- , alignCenter
            ]
            (text "Hello World!")
        ]


exampleNavMenu =
    (nav <| row) UnStyled
        [ justify ]
        [ row UnStyled
            [ spacing 20 10 ]
            [ el UnStyled [] (text "Logo")
            ]
        , row UnStyled
            [ spacing 20 10 ]
            [ el UnStyled [] (text "Options")
            , el UnStyled [] (text "Profile")
            ]
        ]


textView =
    textLayout Test
        [ width (px 600)
        , center
        , padding (all 25)
        , spacing 25 25
        ]
        [ image UnStyled
            "http://placekitten.com/200/300"
            [ width (px 200)
            , height (px 300)
            , alignLeft
            ]
            empty
        , paragraph UnStyled
            []
            [ el Dropped [ alignLeft ] (text "L")
            , text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , hairline Hairline
        , paragraph UnStyled
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , paragraph UnStyled
            [ width (px 300)
            , center
            ]
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , full TestEmbed [ padding (all 100) ] <|
            text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        ]



-- column UnStyled
--     [ spacing 200 200
--     , padding (all 20)
--     ]
--     [ full Test [] (text "wut?")
--     , (section <| row) MyRow
--         [ spacing 25 25
--         , padding (all 12.5)
--         ]
--         [ el Test
--             [ padding (all 20)
--             , width (percent 50)
--             , vary Success True
--             ]
--             (text "Hello World!")
--         , el Test
--             [ padding (all 20)
--             , width (percent 50)
--             , vary Success True
--             ]
--             (text "Hello World!")
--         ]
--     , linked "http://wise-manate.com" <| full Test [] (text "wut?")
--     , el Test
--         [ padding (all 20)
--         , width (px 500)
--         , spacing 800 800
--         , vary Success True
--         , alignCenter
--         ]
--         (text "Hello World!")
--     ]
-- viewAround =
--     nearby Test
--         [ width (px 500)
--         , height (px 80)
--         ]
--         (text "Hello World!")
--         [ onRight <|
--             el TestEmbed
--                 [ width (px 50)
--                 , height (px 50)
--                 , alignBottom
--                 , move 0 0
--                 , onClick Blink
--                 ]
--                 (text "I'm right!")
--         , below <|
--             el TestEmbed
--                 [ width (px 50)
--                 , height (px 50)
--                 , move 0 0
--                 ]
--                 (text "I'm below!")
--         ]
-- viewAround =
--     decorated Test
--         [ width (px 500)
--         , height (px 80)
--         ]
--         (text "Hello World!")
--         [ onRight <|
--             el TestEmbed
--                 [ width (px 50)
--                 , height (px 50)
--                 , alignBottom
--                 , move 0 0
--                 , onClick Blink
--                 ]
--                 (text "I'm right!")
--         , below <|
--             el TestEmbed
--                 [ width (px 50)
--                 , height (px 50)
--                 , move 0 0
--                 ]
--                 (text "I'm below!")
--         ]


update msg model =
    ( model, Cmd.none )


type Msg
    = Blink


type Elements
    = Test
    | UnStyled
    | TestEmbed
    | MyRow
    | Hairline
    | Dropped


type Variations
    = Success


type Palette
    = BrandPrimary
    | Accent


palette kind =
    case kind of
        BrandPrimary ->
            Style.Color.palette
                { text = Color.white
                , background = Color.green
                , border = Color.green
                }

        Accent ->
            Style.Color.palette
                { text = Color.white
                , background = Color.darkGrey
                , border = Color.darkGrey
                }


mainFont =
    Font.scale 16 1.3


fullFont i =
    i * (16 * 1.3)



-- _ =
--     Debug.log "full - large" (mainFont (Font.Full 2 Font.Normal))
-- testFont =
--     Font.scaleByLineHeight 20 (1 / 1.3)
-- mainFont
-- _ =
--     Debug.log "large" (mainFont Font.Large)
-- _ =
--     Debug.log "big" (mainFont Font.Big)
-- _ =
--     Debug.log "huge" (mainFont Font.Huge)
-- 16
-- 1.3


stylesheet =
    [ style UnStyled []
    , style MyRow
        [ palette Accent
        ]
    , style Dropped
        [ mainFont Font.Normal
        , paddingHint (right 10)
        ]
    , style Hairline
        [ palette BrandPrimary
        ]
    , style Test
        [ palette Accent
        , variation Success
            [ palette BrandPrimary
            ]

        -- , paddingHint (all 200)
        ]
    , style TestEmbed
        [ palette BrandPrimary
        ]
    ]
