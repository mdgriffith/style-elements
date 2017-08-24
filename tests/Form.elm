module Form exposing (..)

import Color
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events
import Element.Input as Input
import Html
import Style exposing (..)
import Style.Background as Background
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Transition as Transition


(=>) =
    (,)


type Styles
    = None
    | Page
    | Field
    | Error
    | InputError
    | Checkbox
    | CheckboxChecked
    | LabelBox
    | Button
    | CustomRadio


type Other
    = Thing Int


options =
    [ Style.unguarded
    ]


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style Error
            [ Color.text Color.red
            ]
        , style CustomRadio
            [ Border.rounded 5
            , Border.all 1
            , Border.solid
            , Color.border Color.grey
            ]
        , style LabelBox
            [-- focus
             -- [ Color.border Color.red
             -- , Border.all 1
             -- , Border.solid
             -- , prop "outline" "none"
             -- ]
            ]
        , style Checkbox
            [ Color.background Color.white
            , Border.all 1
            , Border.solid
            , Color.border Color.grey

            -- , focus
            --     [ Color.border Color.red
            --     , prop "outline" "none"
            --     ]
            ]
        , style CheckboxChecked
            [ Color.background Color.blue
            , Border.all 1
            , Border.solid
            , Color.border Color.blue

            -- , focus
            --     [ Color.border Color.red
            --     , prop "outline" "none"
            --     ]
            ]
        , style Page
            [ Color.text Color.darkCharcoal
            , Color.background Color.white
            , Font.typeface
                [ Font.font "helvetica"
                , Font.font "arial"
                , Font.font "sans-serif"
                ]
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style Field
            [ Border.rounded 5
            , Border.all 1
            , Border.solid
            , Color.border Color.lightGrey

            -- , focus
            --     [ Color.border Color.blue
            --     , prop "outline" "none"
            --     ]
            ]
        , style Button
            [ Border.rounded 5
            , Border.all 1
            , Border.solid
            , Color.border Color.blue
            , Color.background Color.lightBlue
            ]
        ]


main =
    Html.program
        { init =
            ( { checkbox = False
              , lunch = Taco
              , text = "hi"
              }
            , Cmd.none
            )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = Log String
    | Check Bool
    | ChooseLunch Lunch
    | ChangeText String


update msg model =
    case Debug.log "action" msg of
        Log str ->
            let
                _ =
                    Debug.log "form" str
            in
                ( model, Cmd.none )

        Check checkbox ->
            ( { model | checkbox = checkbox }
            , Cmd.none
            )

        ChooseLunch lunch ->
            ( { model | lunch = lunch }
            , Cmd.none
            )

        ChangeText str ->
            ( { model | text = str }
            , Cmd.none
            )


type Lunch
    = Taco
    | Burrito
    | Gyro


view model =
    Element.layout stylesheet <|
        el None [ center, width (px 800), paddingXY 0 80 ] <|
            column Page
                [ spacing 20 ]
                [ Input.checkbox
                    { onChange = Check
                    , checked = model.checkbox
                    }
                    |> Input.error True (el Error [] <| text "you must check!")
                    |> Input.disabled True
                    |> Input.label None [] (text "hello!")
                , Input.label LabelBox [] (text "hello!") <|
                    Input.checkboxWith
                        { onChange = Check
                        , checked = model.checkbox
                        , icon =
                            \on ->
                                circle 7
                                    (if on then
                                        CheckboxChecked
                                     else
                                        Checkbox
                                    )
                                    []
                                    empty
                        }
                , Input.label None [] (text "Lunch!") <|
                    Input.radio Field
                        [ padding 10
                        , spacing 5
                        ]
                        { onChange = ChooseLunch
                        , selected = Just model.lunch
                        , options =
                            [ Input.optionWith Burrito
                                (\selected ->
                                    let
                                        icon =
                                            if selected then
                                                text ":D"
                                            else
                                                text ":("
                                    in
                                        row CustomRadio
                                            [ spacing 5 ]
                                            [ icon, text "burrito" ]
                                )
                            , Input.option Taco (text "Taco!")
                            , Input.option Gyro (text "Gyro")
                            ]
                        }
                , Input.label None [] (text "Lunch") <|
                    Input.radioRow Field
                        [ padding 10, spacing 20 ]
                        { onChange = ChooseLunch
                        , selected = Just model.lunch
                        , options =
                            [ Input.option Taco (text "Taco!")
                            , Input.option Gyro (text "Gyro")
                            , Input.optionWith Burrito
                                (\selected ->
                                    let
                                        icon =
                                            if selected then
                                                text ":D"
                                            else
                                                text ":("
                                    in
                                        row None
                                            [ spacing 5 ]
                                            [ icon, text "burrito" ]
                                )
                            ]
                        }
                , Input.label None [] (text "A Greeting") <|
                    Input.error True (el Error [] (text "DO this one")) <|
                        Input.text Field
                            [ paddingXY 10 5 ]
                            { onChange = ChangeText
                            , value = model.text
                            }
                , Input.label None [] (text "A Greeting") <|
                    Input.multiline Field
                        [ paddingXY 10 5 ]
                        { onChange = ChangeText
                        , value = model.text
                        }
                , Input.search Field
                    [ paddingXY 10 5 ]
                    { onChange = ChangeText
                    , value = model.text
                    }
                    |> Input.disabled True
                    |> Input.label None [] (text "A Greeting")
                , Input.label None [] (text "My super password") <|
                    Input.password Field
                        [ paddingXY 10 5 ]
                        { onChange = ChangeText
                        , value = model.text
                        }
                , Input.grid Field
                    { onChange = ChooseLunch
                    , selected = Just model.lunch
                    , columns = [ px 100, px 100, px 100, px 100 ]
                    , rows =
                        [ px 100
                        , px 100
                        , px 100
                        , px 100
                        ]
                    }
                    []
                    [ Input.cell
                        { start = ( 0, 0 )
                        , width = 1
                        , height = 1
                        , value = Gyro
                        , el =
                            el CustomRadio [] (text "Gyro")
                        }
                    , Input.cell
                        { start = ( 1, 1 )
                        , width = 1
                        , height = 2
                        , value = Taco
                        , el =
                            (el CustomRadio [] (text "Taco"))
                        }
                    , Input.cellWith
                        { start = ( 2, 1 )
                        , width = 1
                        , height = 2
                        , value = Burrito
                        , view =
                            \selected ->
                                if selected then
                                    text ":D Burrito!"
                                else
                                    text ":( Burrito"
                        }
                    ]
                , button Button
                    []
                    (text "Push me!")
                ]
