module Main exposing (..)

{-| -}

import Color exposing (..)
import Element exposing (..)
import Element.Area as Area
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
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
    , comment = ""
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
        , Font.color black
        , Background.color white
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        Element.column [ width (px 800), center, spacing 10 ]
            [ el [ Area.heading 1 ] (text "Welcome to Style Elements!")
            , Input.username []
                { text = model.username
                , placeholder = Nothing
                , onChange = Just (\new -> Update { model | username = new })
                , label = Input.labelAbove [] (text "Username")
                , notice = Nothing
                }
            , Input.currentPassword []
                { text = model.password
                , placeholder = Nothing
                , onChange = Just (\new -> Update { model | password = new })
                , label = Input.labelAbove [] (text "Password")
                , notice = Nothing
                }
            , Input.checkbox []
                { checked = model.agreeTOS
                , onChange = Just (\new -> Update { model | agreeTOS = new })
                , icon = Nothing
                , label = Input.labelRight [] (text "Agree to Terms of Service")
                , notice = Nothing
                }
            , Input.button
                [ Background.color blue
                , Font.color white
                , Border.color darkBlue
                , paddingXY 15 5
                , Border.rounded 3
                ]
                { onPress = Nothing
                , label = Element.text "Sign in"
                }
            , Input.multiline
                [ height shrink
                ]
                { text = model.comment
                , placeholder = Nothing
                , onChange = Just (\new -> Update { model | comment = new })
                , label = Input.labelAbove [] (text "Leave a comment!")
                , notice = Nothing
                }
            , Input.radio []
                { selected = Just model.lunch
                , onChange = Just (\new -> Update { model | lunch = new })
                , label = Input.labelAbove [] (text "Choose One")
                , notice = Nothing
                , options =
                    [ Input.option Gyro (text "Gyro")
                    , Input.option Burrito (text "Burrito")
                    , Input.option Taco (text "Taco")
                    ]
                }
            , Input.select []
                { selected = Nothing
                , onChange = Just (\new -> Update { model | lunch = new })
                , label = Input.labelAbove [] (text "Choose One")
                , notice = Nothing
                , placeholder = Just (text "-")
                , menu =
                    Input.menuBelow []
                        [ Input.option Gyro (text "Gyro")
                        , Input.option Burrito (text "Burrito")
                        , Input.option Taco (text "Taco")
                        ]
                }
            ]
