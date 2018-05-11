module Main exposing (..)

{-| -}

import Color exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html


main =
    Html.program
        { init = ( init, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init =
    { username = ""
    , password = ""
    , agreeTOS = False
    , comment = "Extra hot sauce?\n\n\nYes pls"
    , lunch = Gyro
    }


type alias Form =
    { username : String
    , password : String
    , agreeTOS : Bool
    , comment : String
    , lunch : Lunch
    }


type Msg
    = Update Form


update msg model =
    case Debug.log "msg" msg of
        Update new ->
            ( new, Cmd.none )


type Lunch
    = Burrito
    | Taco
    | Gyro


view model =
    Element.layout
        [ Font.size 20
        ]
    <|
        Element.column [ width (px 800), height shrink, centerY, centerX, spacing 36, padding 10 ]
            [ el
                [ Region.heading 1
                , alignLeft
                , Font.size 36
                ]
                (text "Welcome to the Stylish Elephants Lunch Emporium")

            -- , Input.radio []
            --     { selected = Just model.lunch
            --     , onChange = Just (\new -> Update { model | lunch = new })
            --     , label = Input.labelAbove [ Font.size 14 ] (text "What would you like for lunch?")
            --     , options =
            --         [ Input.option Gyro (text "Gyro")
            --         , Input.option Burrito (text "Burrito")
            --         , Input.option Taco (text "Taco")
            --         ]
            --     }
            -- , Input.username
            --     [ below
            --         (el
            --             [ Font.color red
            --             , Font.size 14
            --             , alignLeft
            --             ]
            --             (text "This one is le wrong")
            --         )
            --     ]
            --     { text = model.username
            --     , placeholder = Nothing
            --     , onChange = Just (\new -> Update { model | username = new })
            --     , label = Input.labelAbove [ Font.size 14 ] (text "Username")
            --     }
            -- , Input.currentPassword []
            --     { text = model.password
            --     , placeholder = Nothing
            --     , onChange = Just (\new -> Update { model | password = new })
            --     , label = Input.labelAbove [ Font.size 14 ] (text "Password")
            --     , show = False
            --     }
            , Input.multiline
                [ height shrink
                , spacing 12
                ]
                { text = model.comment
                , placeholder = Just (Input.placeholder [] (text "Extra hot sauce?\n\n\nYes pls"))
                , onChange = Just (\new -> Update { model | comment = new })
                , label = Input.labelAbove [ Font.size 14 ] (text "Leave a comment!")
                , spellcheck = False
                }

            -- , Element.row []
            --     [ Element.el [ Element.width Element.fill ] Element.none
            --     , Input.checkbox []
            --         { checked = model.agreeTOS
            --         , onChange = Just (\new -> Update { model | agreeTOS = new })
            --         , icon = Nothing
            --         , label = Input.labelRight [] (text "Agree to Terms of Service")
            --         }
            --     ]
            -- , Input.button
            --     [ Background.color blue
            --     , Font.color white
            --     , Border.color darkBlue
            --     , paddingXY 15 5
            --     , Border.rounded 3
            --     , width fill
            --     ]
            --     { onPress = Nothing
            --     , label = Element.text "Place your lunch order!"
            -- }
            ]
