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
    | SubMenu
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
        , style SubMenu
            [ Border.rounded 5
            , Border.all 2
            , Border.solid
            , Color.border Color.blue

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
              , manyLunches = [ Taco, Burrito ]
              , openMenu = False
              , search = Input.autocomplete Nothing Search
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
    | UpdateLunches (List Lunch)
    | ShowMenu Bool
    | Search (Input.AutocompleteMsg Lunch)


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

        UpdateLunches lunches ->
            ( { model | manyLunches = lunches }
            , Cmd.none
            )

        ChangeText str ->
            ( { model | text = str }
            , Cmd.none
            )

        ShowMenu isOpen ->
            ( { model | openMenu = isOpen }
            , Cmd.none
            )

        Search searchMsg ->
            ( { model | search = Input.updateAutocomplete searchMsg model.search }
            , Cmd.none
            )


type Lunch
    = Taco
    | Burrito
    | Gyro


view model =
    Element.layout stylesheet <|
        el None [ center, width (px 800) ] <|
            column Page
                [ spacing 20 ]
                [ Input.text Field
                    [ padding 10 ]
                    { onChange = ChangeText
                    , value = model.text
                    , label =
                        Input.placeholder
                            { label = Input.labelLeft (el None [ verticalCenter ] (text "Yup"))
                            , text = "Placeholder!"
                            }
                    , disabled = False
                    , errors =
                        Input.errorAbove (el Error [] (text "DO this one"))

                    -- Input.error (el Error [] (text "DO this one") | Input.noErrors | Input.errorBelow
                    }
                , Input.search Field
                    [ spacing 5, padding 5 ]
                    { onChange = ChangeText
                    , value = model.text
                    , label =
                        Input.placeholder
                            { label = Input.labelLeft (text "Yup")
                            , text = "Placeholder!"
                            }
                    , disabled = False
                    , errors =
                        Input.noErrors

                    -- Input.error (el Error [] (text "DO this one") | Input.noErrors | Input.errorBelow
                    }
                , Input.multiline Field
                    [ spacing 5, padding 10 ]
                    { onChange = ChangeText
                    , value = model.text
                    , label =
                        Input.placeholder
                            { label = Input.labelLeft (text "Yup")
                            , text = "Placeholder!"
                            }
                    , disabled = False
                    , errors =
                        Input.errorAbove (el Error [] (text "DO this one"))

                    -- Input.error (el Error [] (text "DO this one") | Input.noErrors | Input.errorBelow
                    }
                , Input.checkbox Checkbox
                    []
                    { onChange = Check
                    , checked = model.checkbox
                    , label = el None [] (text "hello!")
                    , errors = Input.noErrors
                    , disabled = False
                    }
                , Input.checkboxWith Checkbox
                    []
                    { onChange = Check
                    , checked = model.checkbox
                    , label = el None [] (text "hello!")
                    , errors = Input.noErrors
                    , disabled = False
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
                , Input.radio Field
                    [ padding 10
                    , spacing 20
                    ]
                    { onChange = ChooseLunch
                    , selected = Just model.lunch
                    , label = Input.labelAbove (text "Lunch")
                    , errors = Input.noErrors
                    , disabled = False
                    , options =
                        [ Input.optionWith Burrito <|
                            \selected ->
                                Element.row None
                                    [ spacing 5 ]
                                    [ el None [] <|
                                        if selected then
                                            text ":D"
                                        else
                                            text ":("
                                    , text "burrito"
                                    ]
                        , Input.option Taco (text "Taco!")
                        , Input.option Gyro (text "Gyro")
                        ]
                    }
                , Input.radioRow Field
                    [ padding 10, spacing 50 ]
                    { onChange = ChooseLunch
                    , selected = Just model.lunch
                    , label = Input.labelAbove <| text "Lunch"
                    , errors = Input.noErrors
                    , disabled = False
                    , options =
                        [ Input.option Taco (text "Taco!")
                        , Input.option Gyro (text "Gyro")
                        , Input.optionWith Burrito <|
                            \selected ->
                                Element.row None
                                    [ spacing 5 ]
                                    [ el None [] <|
                                        if selected then
                                            text ":D"
                                        else
                                            text ":("
                                    , text "burrito"
                                    ]
                        ]
                    }
                , Input.select Field
                    [ padding 10
                    , spacing 20
                    ]
                    { onChange = ChooseLunch
                    , isOpen = model.openMenu
                    , show = ShowMenu
                    , selected = Just model.lunch
                    , label = Input.labelAbove <| text "Lunch"
                    , errors = Input.noErrors
                    , disabled = False
                    , menu =
                        Input.menuAbove SubMenu
                            []
                            [ Input.option Taco (text "Taco!")
                            , Input.option Gyro (text "Gyro")
                            , Input.optionWith Burrito <|
                                \selected ->
                                    Element.row None
                                        [ spacing 5 ]
                                        [ el None [] <|
                                            if selected then
                                                text ":D"
                                            else
                                                text ":("
                                        , text "burrito"
                                        ]
                            ]
                    }
                , Input.searchSelect Field
                    [ padding 10
                    , spacing 0
                    ]
                    { max = 5
                    , label = Input.hiddenLabel "Lunch" -- (el None [ paddingRight 20 ] (text "Lunch"))
                    , errors = Input.errorAbove (text "wut")
                    , disabled = False
                    , autocomplete = model.search
                    , menu =
                        Input.menu SubMenu
                            []
                            [ Input.option Taco (text "Taco!")
                            , Input.option Gyro (text "Gyro")
                            , Input.optionWith Burrito <|
                                \selected ->
                                    Element.row None
                                        [ spacing 5 ]
                                        [ el None [] <|
                                            if selected then
                                                text ":D"
                                            else
                                                text ":("
                                        , text "burrito"
                                        ]
                            ]
                    }
                , Input.checkbox Checkbox
                    []
                    { onChange = Check
                    , checked = model.checkbox
                    , label = el None [] (text "hello!")
                    , errors = Input.noErrors
                    , disabled = False
                    }
                , Input.checkbox Checkbox
                    []
                    { onChange = Check
                    , checked = model.checkbox
                    , label = el None [] (text "hello!")
                    , errors = Input.noErrors
                    , disabled = False
                    }
                , Input.checkbox Checkbox
                    []
                    { onChange = Check
                    , checked = model.checkbox
                    , label = el None [] (text "hello!")
                    , errors = Input.noErrors
                    , disabled = False
                    }

                -- , Input.select Field
                --     [ padding 10 ]
                --     { onChange = ChooseLunch
                --     , options =
                --         [ ( "Burrito", Burrito )
                --         , ( "Gyro", Gyro )
                --         , ( "Taco", Taco )
                --         ]
                --     , selected = Just model.lunch
                --     , label = Input.labelAbove (text "Choose Lunch")
                --     , disabled = False
                --     , errors = Input.noErrors
                --     }
                -- , Input.grid Field
                --     []
                --     { onChange = ChooseLunch
                --     , selected = Just model.lunch
                --     , errors = Input.noErrors
                --     , label = Input.labelAbove (text "Choose Lunch!")
                --     , disabled = False
                --     , columns = [ px 100, px 100, px 100, px 100 ]
                --     , rows =
                --         [ px 100
                --         , px 100
                --         , px 100
                --         , px 100
                --         ]
                --     , cells =
                --         [ Input.cell
                --             { start = ( 0, 0 )
                --             , width = 1
                --             , height = 1
                --             , value = Gyro
                --             , el =
                --                 el CustomRadio [] (text "Gyro")
                --             }
                --         , Input.cell
                --             { start = ( 1, 1 )
                --             , width = 1
                --             , height = 2
                --             , value = Taco
                --             , el =
                --                 (el CustomRadio [] (text "Taco"))
                --             }
                --         , Input.cellWith
                --             { start = ( 2, 1 )
                --             , width = 1
                --             , height = 2
                --             , value = Burrito
                --             , view =
                --                 \selected ->
                --                     if selected then
                --                         text ":D Burrito!"
                --                     else
                --                         text ":( Burrito"
                --             }
                --         ]
                --     }
                -- , Input.checkbox LabelBox
                --     { onChange = Check
                --     , checked = model.checkbox
                --     , errors = Nothing
                --     , label = el None [] (text "hello!")
                --     }
                -- -- |> Input.error True (el Error [] <| text "you must check!")
                -- -- |> Input.label None [] (text "hello!")
                -- , Input.label <|
                --     Input.checkboxWith LabelBox
                --         []
                --         { onChange = Check
                --         , checked = model.checkbox
                --         , label = el LabelBox [] (text "hello!")
                --         , errors = Nothing
                --         , icon =
                --             \on ->
                --                 circle 7
                --                     (if on then
                --                         CheckboxChecked
                --                      else
                --                         Checkbox
                --                     )
                --                     []
                --                     empty
                --         }
                -- , Input.label None [] (text "Lunch!") <|
                --     Input.radio Field
                --         [ padding 10
                --         , spacing 5
                --         ]
                --         { onChange = ChooseLunch
                --         , selected = Just model.lunch
                --         , options =
                --             [ Input.optionWith Burrito
                --                 (\selected ->
                --                     let
                --                         icon =
                --                             if selected then
                --                                 text ":D"
                --                             else
                --                                 text ":("
                --                     in
                --                         row CustomRadio
                --                             [ spacing 5 ]
                --                             [ icon, text "burrito" ]
                --                 )
                --             , Input.option Taco (text "Taco!")
                --             , Input.option Gyro (text "Gyro")
                --             ]
                --         }
                -- , Input.label None [] (text "Lunch") <|
                --     Input.radioRow Field
                --         [ padding 10, spacing 20 ]
                --         { onChange = ChooseLunch
                --         , selected = Just model.lunch
                --         , options =
                --             [ Input.option Taco (text "Taco!")
                --             , Input.option Gyro (text "Gyro")
                --             , Input.optionWith Burrito
                --                 (\selected ->
                --                     let
                --                         icon =
                --                             if selected then
                --                                 text ":D"
                --                             else
                --                                 text ":("
                --                     in
                --                         row None
                --                             [ spacing 5 ]
                --                             [ icon, text "burrito" ]
                --                 )
                --             ]
                --         }
                -- , Input.label None [] (text "A Greeting") <|
                --     Input.error True (el Error [] (text "DO this one")) <|
                --         Input.text Field
                --             [ paddingXY 10 5 ]
                --             { onChange = ChangeText
                --             , value = model.text
                --             }
                -- , Input.label None [] (text "A Greeting") <|
                --     Input.multiline Field
                --         [ paddingXY 10 5 ]
                --         { onChange = ChangeText
                --         , value = model.text
                --         }
                -- , Input.search Field
                --     [ paddingXY 10 5 ]
                --     { onChange = ChangeText
                --     , value = model.text
                --     }
                --     |> Input.label None [] (text "A Greeting")
                -- , Input.label None [] (text "My super password") <|
                --     Input.password Field
                --         [ paddingXY 10 5 ]
                --         { onChange = ChangeText
                --         , value = model.text
                --         }
                -- , Input.grid Field
                --     { onChange = ChooseLunch
                --     , selected = Just model.lunch
                --     , columns = [ px 100, px 100, px 100, px 100 ]
                --     , rows =
                --         [ px 100
                --         , px 100
                --         , px 100
                --         , px 100
                --         ]
                --     }
                --     []
                --     [ Input.cell
                --         { start = ( 0, 0 )
                --         , width = 1
                --         , height = 1
                --         , value = Gyro
                --         , el =
                --             el CustomRadio [] (text "Gyro")
                --         }
                --     , Input.cell
                --         { start = ( 1, 1 )
                --         , width = 1
                --         , height = 2
                --         , value = Taco
                --         , el =
                --             (el CustomRadio [] (text "Taco"))
                --         }
                --     , Input.cellWith
                --         { start = ( 2, 1 )
                --         , width = 1
                --         , height = 2
                --         , value = Burrito
                --         , view =
                --             \selected ->
                --                 if selected then
                --                     text ":D Burrito!"
                --                 else
                --                     text ":( Burrito"
                --         }
                --     ]
                -- , button Button
                --     []
                --     (text "Push me!")
                ]
