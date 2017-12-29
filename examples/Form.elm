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



-- options =
--     [ Style.unguarded
--     ]


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
            []
        , style Checkbox
            [ Color.background Color.white
            , Border.all 1
            , Border.solid
            , Color.border Color.grey
            ]
        , style CheckboxChecked
            [ Color.background Color.blue
            , Border.all 1
            , Border.solid
            , Color.border Color.blue
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
              , date = ""
              , manyLunches = [ Taco, Burrito ]
              , openMenu = False
              , search = Input.autocomplete Nothing Search
              , selectMenu = Input.dropMenu Nothing SelectOne
              }
            , Cmd.none
            )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = Check Bool
    | ChooseLunch Lunch
    | ChangeText String
    | ChangeDate String
    | UpdateLunches (List Lunch)
    | ShowMenu Bool
    | Search (Input.SelectMsg Lunch)
    | SelectOne (Input.SelectMsg Lunch)


update msg model =
    case Debug.log "action" msg of
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

        ChangeDate str ->
            ( { model | date = str }
            , Cmd.none
            )

        ShowMenu isOpen ->
            ( { model | openMenu = isOpen }
            , Cmd.none
            )

        Search searchMsg ->
            ( { model | search = Input.updateSelection searchMsg model.search }
            , Cmd.none
            )

        SelectOne searchMsg ->
            ( { model | selectMenu = Input.updateSelection searchMsg model.selectMenu }
            , Cmd.none
            )


type Lunch
    = Taco
    | Burrito
    | Gyro
    | Banana


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
                    , options =
                        [ Input.errorBelow (el Error [] (text "This is an Error!"))
                        ]
                    }
                , Input.date Field []
                    { onChange = ChangeDate
                    , value = model.date
                    , label =
                        Input.labelLeft (el None [] (text "Date"))
                    , options =
                        [ Input.errorBelow (el Error [] (text "This is a date Error!"))
                        ]
                    }
                , Input.checkbox Checkbox
                    []
                    { onChange = Check
                    , checked = model.checkbox
                    , label = el None [] (text "hello!")
                    , options = []
                    }
                , Input.styledCheckbox Checkbox
                    []
                    { onChange = Check
                    , checked = model.checkbox
                    , label = el None [] (text "hello!")
                    , options = []
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
                    , options = []
                    , choices =
                        [ Input.styledSelectChoice Burrito <|
                            \state ->
                                let
                                    icon =
                                        case state of
                                            Input.Selected ->
                                                ":)"

                                            Input.Focused ->
                                                ":/"

                                            Input.Idle ->
                                                ":("

                                            Input.SelectedInBox ->
                                                ":D"
                                in
                                Element.row None
                                    [ spacing 5 ]
                                    [ el None
                                        []
                                        (text icon)
                                    , text "burrito"
                                    ]
                        , Input.choice Taco (text "Taco!")
                        , Input.choice Gyro (text "Gyro")
                        ]
                    }
                , Input.radioRow Field
                    [ padding 10, spacing 50 ]
                    { onChange = ChooseLunch
                    , selected = Just model.lunch
                    , label = Input.labelAbove <| text "Lunch"
                    , options = []
                    , choices =
                        [ Input.choice Taco (text "Taco!")
                        , Input.choice Gyro (text "Gyro")
                        , Input.styledChoice Burrito <|
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
                    { label = Input.labelAbove <| text "Lunch"
                    , with = model.selectMenu
                    , max = 5
                    , options = []
                    , menu =
                        Input.menuAbove SubMenu
                            []
                            [ Input.choice Taco (text "Taco!")
                            , Input.choice Gyro (text "Gyro")
                            , Input.styledChoice Burrito <|
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
                    , spacing 0
                    ]
                    { label = Input.hiddenLabel "Lunch"
                    , with = model.search
                    , options = [ Input.errorAbove (el Error [] (text "wut, an error?")) ]
                    , max = 5
                    , menu =
                        Input.menu SubMenu
                            []
                            [ Input.choice Taco (text "Taco!")
                            , Input.choice Gyro (text "Gyro")
                            , Input.choice Banana (text "Banana")
                            , Input.styledSelectChoice Burrito <|
                                \state ->
                                    let
                                        icon =
                                            case state of
                                                Input.Selected ->
                                                    ":)"

                                                Input.Focused ->
                                                    ":o"

                                                Input.Idle ->
                                                    ":("

                                                Input.SelectedInBox ->
                                                    ":D"
                                    in
                                    Element.row None
                                        [ spacing 5 ]
                                        [ el None
                                            []
                                            (text icon)
                                        , text "burrito"
                                        ]
                            ]
                    }
                ]
