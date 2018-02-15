module Main exposing (..)

{-| A file for manually inspecting layouts.
-}

import Color exposing (..)
import Dom
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html
import Html.Attributes
import Task


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
    , menuOpen = False
    , menuFocused = False
    , comment = ""
    , lunch = Gyro
    }


type alias Form =
    { username : String
    , password : String
    , agreeTOS : Bool
    , comment : String
    , menuOpen : Bool
    , menuFocused : Bool
    , lunch : Lunch
    }


type Msg
    = Update Form
    | Focus String
    | LoseFocus String
    | NoOp


update msg model =
    case Debug.log "msg" msg of
        NoOp ->
            ( model, Cmd.none )

        Update new ->
            ( new, Cmd.none )

        Focus id ->
            ( { model | menuFocused = True }
            , Task.attempt (always NoOp) (Dom.focus id)
            )

        LoseFocus id ->
            ( { model | menuFocused = False }
            , Task.attempt (always NoOp) (Dom.blur id)
            )


type Lunch
    = Burrito
    | Taco
    | Gyro


view model =
    Element.layout
        [ Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=Source+Code+Pro"
                , name = "Source Code Pro"
                }
            ]
        ]
    <|
        column
            [ Background.color lightGrey
            , width (px 800)
            , centerX
            ]
            [ textElements
            , singleAlignment
            , rowAlignment
            , columnAlignment
            , nearbyElements
            , columnSpacing
            , rowSpacing
            , tableElements
            , signInForm model
            , el [ height (px 200) ] empty
            ]


textElements : Element msg
textElements =
    let
        txt =
            text "I'm a lumberjack and I'm ok"

        short =
            text "lumber"
    in
    column [ width fill, spacing 50, paddingXY 0 100 ]
        [ txt
        , el [] txt
        , el [ width fill ] txt
        , row [ spacing 50 ]
            [ short, short, short ]
        , column [ spacing 50 ]
            [ txt, txt, txt ]
        ]


box attrs =
    el ([ width (px 50), height (px 50), Background.color blue ] ++ attrs) empty


tinyBox attrs =
    el
        ([ width (px 20)
         , height (px 20)
         , centerY
         , Background.color darkCharcoal
         ]
            ++ attrs
        )
        empty


container : Element msg -> Element msg
container =
    el [ width (px 100), height (px 100) ]


{-| Alignment of an el within an other el
-}
singleAlignment : Element msg
singleAlignment =
    column []
        [ el [] (text "Alignment Within an El")
        , container <|
            box []
        , text "alignLeft, centerX, alignRight"
        , row [ spacing 20 ]
            [ container <|
                box [ alignLeft ]
            , container <|
                box [ centerX ]
            , container <|
                box [ alignRight ]
            ]
        , text "top, centerY, bottom"
        , row [ spacing 20 ]
            [ container <|
                box [ alignTop ]
            , container <|
                box [ centerY ]
            , container <|
                box [ alignBottom ]
            ]
        , text "align top ++ alignments"
        , row [ spacing 20 ]
            [ container <|
                box [ alignTop, alignLeft ]
            , container <|
                box [ alignTop, centerX ]
            , container <|
                box [ alignTop, alignRight ]
            ]
        , text "centerY ++ alignments"
        , row [ spacing 20 ]
            [ container <|
                box [ centerY, alignLeft ]
            , container <|
                box [ centerY, centerX ]
            , container <|
                box [ centerY, alignRight ]
            ]
        , text "alignBottom ++ alignments"
        , row [ spacing 20 ]
            [ container <|
                box [ alignBottom, alignLeft ]
            , container <|
                box [ alignBottom, centerX ]
            , container <|
                box [ alignBottom, alignRight ]
            ]
        ]


rowAlignment =
    let
        rowContainer attrs children =
            row ([ spacing 20, height (px 100) ] ++ attrs) children
    in
    column [ width (px 500) ]
        [ el [] (text "Alignment Within a Row")
        , rowContainer []
            [ box [] ]
        , rowContainer []
            [ box []
            , box []
            , box []
            ]
        , rowContainer []
            [ box []
            , box []
            , box [ alignRight ]
            ]
        , rowContainer []
            [ box []
            , box [ alignRight ]
            , box []
            ]
        , rowContainer []
            [ box [ alignRight ]
            , box []
            , box []
            ]
        , text "center X"
        , rowContainer []
            [ box [ centerX ]
            , box []
            , box []
            ]
        , rowContainer []
            [ box []
            , box [ centerX ]
            , box []
            ]
        , rowContainer []
            [ box []
            , box []
            , box [ centerX ]
            ]
        , text "left x right"
        , rowContainer []
            [ box [ alignLeft ]
            , box []
            , box [ alignRight ]
            ]
        , text "left center right"
        , rowContainer []
            [ box [ alignLeft ]
            , box [ centerX ]
            , box [ alignRight ]
            ]
        , text "vertical alignment"
        , rowContainer []
            [ box [ alignTop ]
            , box [ centerY ]
            , box [ alignBottom ]
            ]
        , text "all alignments alignment"
        , rowContainer []
            [ box [ alignLeft, alignTop ]
            , box [ centerX, centerY ]
            , box [ alignRight, alignBottom ]
            ]
        ]


columnAlignment =
    let
        colContainer attrs children =
            column ([ spacing 20, width (px 100), height (px 500) ] ++ attrs) children
    in
    column
        [ width fill ]
        [ el [] (text "Alignment Within a Column")
        , row []
            [ colContainer []
                [ box [] ]
            , colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box [ alignLeft ]
                , box [ centerX ]
                , box [ alignRight ]
                ]
            ]
        , row []
            [ colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box []
                , box [ alignBottom ]
                , box []
                ]
            , colContainer []
                [ box [ alignBottom ]
                , box []
                , box []
                ]
            ]
        , text "with centerY override"
        , row []
            [ colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box []
                , box [ alignBottom ]
                , box [ centerY ]
                ]
            , colContainer []
                [ box [ alignBottom ]
                , box [ centerY ]
                , box [ centerY ]
                ]
            ]
        , text "centerY"
        , row []
            [ colContainer [ height fill ]
                [ box [ centerY ]
                ]
            , colContainer []
                [ box []
                , box [ centerY ]
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ centerY ]
                ]
            ]
        , text "multiple centerY"
        , row [ height (px 800) ]
            [ colContainer [ height fill ]
                [ box []
                , box [ centerY ]
                , box [ centerY ]
                , box [ centerY ]
                , box [ centerY ]
                , box [ alignBottom ]
                ]
            , colContainer [ height fill ]
                [ box []
                , box [ centerY ]
                , box []
                ]
            , colContainer [ height fill ]
                [ box []
                , box []
                , box [ centerY ]
                ]
            ]
        , text "top, center, bottom"
        , row []
            [ colContainer []
                [ box [ alignTop ]
                , box []
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box [ alignTop ]
                , box [ centerY ]
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box [ alignLeft, alignTop ]
                , box [ centerX, centerY ]
                , box [ alignRight, alignBottom ]
                ]
            ]
        , text "using text nodes"
        , row []
            [ colContainer []
                [ text "yup"
                ]
            , colContainer []
                [ text "yup"
                , text "yup"
                , text "yup"
                ]
            , colContainer []
                [ box [ centerY ]
                , text "yup"
                , text "yup"
                ]
            , colContainer []
                [ box [ alignBottom ]
                , text "yup"
                , text "yup"
                ]
            ]
        , el [ width fill ] (text "Column in a Row")
        , row [ width fill, height fill, spacing 20 ]
            [ box [ alignLeft, alignTop ]
            , column [ alignLeft, alignTop, spacing 20, width shrink ]
                [ box []
                , box []
                , box []
                ]
            , colContainer [ alignLeft, alignTop, height shrink ]
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box [ alignRight ]
                , box [ centerX ]
                , box [ alignLeft ]
                ]
            ]
        ]


nearbyElements =
    let
        transparentBox attrs =
            el
                ([ Font.color white
                 , width (px 50)
                 , height (px 50)
                 , Background.color (rgba 52 101 164 0.8)
                 ]
                    ++ attrs
                )
                (text "hi")

        nearby location box =
            row [ height (px 100), width fill, spacing 50 ]
                [ box []
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignLeft
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignRight
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignTop
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , alignBottom
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ width (px 20)
                            , height (px 20)
                            , centerY
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                , box
                    [ location True
                        (el
                            [ --width fill
                              width (px 20)
                            , height fill

                            -- , height (px 20)
                            , Background.color darkCharcoal
                            ]
                            empty
                        )
                    ]
                ]
    in
    column
        [ centerX ]
        [ el [] (text "Nearby Elements")
        , nearby above box
        , nearby below box
        , nearby inFront box
        , nearby onRight box
        , nearby onLeft box
        , nearby behind transparentBox
        ]


columnSpacing =
    let
        colContainer attrs children =
            column ([ spacing 20, width (px 100), height (px 500) ] ++ attrs) children
    in
    column
        []
        [ el [] (text "Spacing within a column")
        , row []
            [ colContainer []
                [ box [] ]
            , colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer [ onRight True (tinyBox []) ]
                [ box []
                , box []
                , box []
                ]
            ]
        ]


rowSpacing =
    let
        colContainer attrs children =
            row ([ spacing 20, width (px 500), height (px 120) ] ++ attrs) children
    in
    column
        []
        [ el [] (text "Spacing within a row")
        , column []
            [ box []
            , colContainer []
                [ box [] ]
            , colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer [ below True (tinyBox []) ]
                [ box []
                , box []
                , box []
                ]
            ]
        ]


tableElements =
    let
        data =
            [ { firstName = "David"
              , lastName = "Bowie"
              }
            , { firstName = "Florence"
              , lastName = "Welch"
              }
            ]
    in
    column [ spacing 20, width fill, paddingXY 1 30 ]
        [ text "Tables With Headers"
        , table []
            { data = data
            , columns =
                [ { header = text "First Name"
                  , view =
                        \row -> text row.firstName
                  }
                , { header = text "Last Name"
                  , view =
                        \row -> text row.lastName
                  }
                ]
            }
        , text "Without Headers"
        , table []
            { data = data
            , columns =
                [ { header = empty
                  , view =
                        \row -> text row.firstName
                  }
                , { header = empty
                  , view =
                        \row -> text row.lastName
                  }
                ]
            }
        , text "With Spacing and Styling"
        , table
            [ Background.color blue
            , spacing 20
            , padding 30
            ]
            { data = data
            , columns =
                [ { header =
                        el [ Font.color white ] <|
                            text "First Name"
                  , view =
                        \row -> el [ Background.color lightGrey ] <| text row.firstName
                  }
                , { header = el [ Font.color white ] <| text "Last Name"
                  , view =
                        \row ->
                            el [ Background.color lightGrey ] <|
                                text row.lastName
                  }
                ]
            }
        , text "Indexed Table With Spacing and Styling"
        , indexedTable
            [ Background.color blue
            , spacing 20
            , padding 30
            ]
            { data = data
            , columns =
                [ { header =
                        el [ Font.color white ] <|
                            text "Index"
                  , view =
                        \i row -> el [ Background.color lightGrey ] <| text (toString i)
                  }
                , { header =
                        el [ Font.color white ] <|
                            text "First Name"
                  , view =
                        \i row -> el [ Background.color lightGrey ] <| text row.firstName
                  }
                , { header = el [ Font.color white ] <| text "Last Name"
                  , view =
                        \i row ->
                            el [ Background.color lightGrey ] <|
                                text row.lastName
                  }
                ]
            }
        ]


signInForm model =
    let
        label str =
            Input.labelLeft
                [ width (fillPortion 1)
                , Font.alignRight
                , paddingXY 12 7
                , Font.bold
                ]
                (text str)
    in
    Element.column
        [ width fill
        , height shrink
        , centerY
        , centerX
        , spacing 36
        , padding 10
        , Background.color white
        ]
        [ el
            [ Region.heading 1
            , alignLeft
            , Font.size 36
            ]
            (text "Sign in and Choose Lunch!")
        , Input.radioRow
            [ width (fillPortion 4)
            , spacing 15
            ]
            { selected = Just model.lunch
            , onChange = Just (\new -> Update { model | lunch = new })
            , label =
                label "What would you like for lunch?"
            , options =
                [ Input.option Gyro (text "Gyro")
                , Input.option Burrito (text "Burrito")
                , Input.option Taco (text "Taco")
                ]
            }
        , Input.radio [ width fill, spacing 15 ]
            { selected = Just model.lunch
            , onChange = Just (\new -> Update { model | lunch = new })
            , label =
                Input.labelAbove [ Font.bold ] (text "What would you like for lunch?")
            , options =
                [ Input.option Gyro (text "Gyro")
                , Input.option Burrito (text "Burrito")
                , Input.option Taco (text "Taco")
                ]
            }
        , Input.username
            [ width (fillPortion 4)
            , focused
                [ Border.color red
                ]
            , below True
                (el
                    [ Font.color red
                    , Font.size 14
                    , alignLeft
                    ]
                    (text "This one is le wrong")
                )
            ]
            { text = model.username
            , placeholder = Nothing --Just (Input.placeholder [] (text "Extra hot sauce?"))
            , onChange = Just (\new -> Update { model | username = new })
            , label =
                label "username"
            }
        , Input.currentPassword
            [ width (fillPortion 4)
            , focused
                [ Border.glow red 5
                , Border.glow blue 5
                ]
            ]
            { text = model.password
            , placeholder = Nothing
            , onChange = Just (\new -> Update { model | password = new })
            , label = label "Password"
            , show = False
            }
        , Input.multiline
            [ height shrink
            , width (fillPortion 4)
            ]
            { text = model.comment
            , placeholder = Just (Input.placeholder [] (text "Leave a comment?"))
            , onChange = Just (\new -> Update { model | comment = new })
            , label =
                Input.labelLeft
                    [ width (fillPortion 1)
                    , Font.alignRight
                    , Font.bold
                    , paddingXY 12 7
                    ]
                    (text "Question")
            , spellcheck = False
            }
        , el
            [ Events.onClick
                (if not model.menuFocused then
                    Focus "my-select-menu"
                 else
                    LoseFocus "my-select-menu"
                )
            , below True <|
                Input.radio
                    [ width (fillPortion 4)
                    , htmlAttribute (Html.Attributes.id "my-select-menu")
                    , Events.onFocus (Update { model | menuFocused = True })
                    , Events.onLoseFocus (Update { model | menuFocused = False })
                    , Background.color white
                    , Border.color grey
                    , Border.width 1
                    , padding 15
                    , spacing 15
                    , pointer
                    , transparent True
                    , focused
                        [ transparent False
                        ]
                    ]
                    { selected = Just model.lunch
                    , onChange = Just (\new -> Update { model | lunch = new })
                    , label =
                        Input.labelAbove
                            [ hidden True
                            ]
                        <|
                            text "What would you like for lunch?"
                    , options =
                        [ Input.option Gyro (text "Gyro")
                        , Input.option Burrito (text "Burrito")
                        , Input.option Taco (text "Taco")
                        ]
                    }
            ]
          <|
            el
                [ alignLeft
                , Font.bold
                , pointer
                ]
            <|
                case model.lunch of
                    Gyro ->
                        text "What would you like for lunch? - Gyro"

                    Burrito ->
                        text "What would you like for lunch? - Burrito"

                    Taco ->
                        text "What would you like for lunch? -Taco"
        , Input.radio
            [ width (fillPortion 4)
            , Background.color white
            , Border.color grey
            , Border.width 1
            , padding 15
            , spacing 15
            , pointer
            , transparent True
            , focused
                [ transparent False
                ]
            ]
            { selected = Just model.lunch
            , onChange = Just (\new -> Update { model | lunch = new })
            , label =
                Input.labelAbove
                    []
                <|
                    el [ alignLeft, Font.bold ] <|
                        case model.lunch of
                            Gyro ->
                                text "What would you like for lunch? - Gyro"

                            Burrito ->
                                text "What would you like for lunch? - Burrito"

                            Taco ->
                                text "What would you like for lunch? -Taco"
            , options =
                [ Input.option Gyro (text "Gyro")
                , Input.option Burrito (text "Burrito")
                , Input.option Taco (text "Taco")
                ]
            }
        , Input.checkbox
            [ Border.width 1
            , focused
                [ Border.glow red 5
                ]
            ]
            { checked = model.agreeTOS
            , onChange = Just (\new -> Update { model | agreeTOS = new })
            , icon = Nothing
            , label = Input.labelRight [] (text "Agree to Terms of Service")
            }
        , Input.multiline
            [ height shrink
            ]
            { text = model.comment
            , placeholder = Just (Input.placeholder [] (text "Leave a comment?"))
            , onChange = Just (\new -> Update { model | comment = new })
            , label =
                Input.labelAbove
                    [ width (fillPortion 1)

                    -- , Font.alignRight
                    , Font.bold
                    , paddingXY 12 7
                    ]
                    (text "Question")
            , spellcheck = False
            }
        , Input.button
            [ Background.color blue
            , Font.color white
            , Border.color darkBlue
            , paddingXY 15 5
            , Border.rounded 3
            , width (fillPortion 4)
            ]
            { onPress = Nothing
            , label = el [] <| Element.text "Place your lunch order!"
            }
        ]



-- , Element.row []
--     [ Element.el [ Element.width Element.fill ] Element.empty
--     , Input.checkbox
--         [ width (fillPortion 4) ]
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
--     , alignLeft
--     -- , width fill
--     ]
--     { onPress = Nothing
--     , label = Element.text "Place your lunch order!"
--     }
