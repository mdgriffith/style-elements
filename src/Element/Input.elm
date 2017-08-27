module Element.Input
    exposing
        ( checkbox
        , Checkbox
        , checkboxWith
        , CheckboxWith
        , text
        , multiline
        , search
        , email
        , password
        , radio
        , radioRow
        , option
        , optionWith
        , Option
        , labelLeft
        , labelRight
        , labelAbove
        , labelBelow
        , errorBelow
        , errorAbove
        , noErrors
        , placeholder
        , select
        , Select
          -- , grid
          -- , Grid
          -- , cell
          -- , cellWith
        )

{-| -}

import Element.Internal.Model as Internal
import Element exposing (Element, Attribute, column, row)
import Element.Attributes as Attr
import Element.Events as Events
import Element.Internal.Modify as Modify
import Style.Internal.Model as Style exposing (Length)
import Style.Internal.Selector
import Json.Decode as Json
import Html.Attributes
import Html
import Html.Events


{- Attributes -}


pointer : Internal.Attribute variation msg
pointer =
    Attr.inlineStyle [ ( "cursor", "pointer" ) ]


type_ : String -> Internal.Attribute variation msg
type_ =
    Attr.toAttr << Html.Attributes.type_


checked : Bool -> Internal.Attribute variation msg
checked =
    Attr.toAttr << Html.Attributes.checked


selectedAttr : Bool -> Internal.Attribute variation msg
selectedAttr =
    Attr.toAttr << Html.Attributes.selected


name : String -> Internal.Attribute variation msg
name =
    Attr.toAttr << Html.Attributes.name


value : String -> Internal.Attribute variation msg
value =
    Attr.toAttr << Html.Attributes.value


tabindex : Int -> Internal.Attribute variation msg
tabindex =
    Attr.toAttr << Html.Attributes.tabindex


disabledAttr : Bool -> Internal.Attribute variation msg
disabledAttr =
    Attr.toAttr << Html.Attributes.disabled


hidden : Attribute variation msg
hidden =
    Attr.inlineStyle [ ( "position", "absolute" ), ( "opacity", "0" ) ]


{-| -}
type alias Checkbox style variation msg =
    { onChange : Bool -> msg
    , label : Element style variation msg
    , checked : Bool
    , errors : Error style variation msg
    , disabled : Bool
    }


{-| Your basic checkbox

    Input.checkbox CheckBoxStyle [ ]
        { checked = True
        , onChange = ChangeMsg
        }
        |> Input.label (text "hello!")

-- For more involved checkbox styling

    Input.checkboxWith CheckBoxStyle [ ]
        { value = True
        , onChange = ChangeMsg
        , elem =
            \checked ->
                el CheckedStyle [] (text if checked then "✓" else "x")

        }
        |> Input.label (text "hello!")

-}
checkbox : style -> List (Attribute variation msg) -> Checkbox style variation msg -> Element style variation msg
checkbox style attrs input =
    let
        withDisabled attrs =
            if input.disabled then
                Attr.class "disabled-input" :: disabledAttr True :: attrs
            else
                attrs

        withError attrs =
            case input.errors of
                NoError ->
                    attrs

                _ ->
                    Attr.attribute "aria-invalid" "true" :: attrs

        inputElem =
            [ Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (withError << withDisabled)
                        [ type_ "checkbox"
                        , checked input.checked
                        , pointer
                        , Events.onCheck input.onChange
                        ]
                , child = Internal.Empty
                , absolutelyPositioned = Nothing
                }
            ]
    in
        applyLabel Nothing (Attr.spacing 5 :: Attr.verticalCenter :: attrs) (LabelOnRight input.label) input.errors input.disabled inputElem


{-| -}
type alias CheckboxWith style variation msg =
    { onChange : Bool -> msg
    , label : Element style variation msg
    , checked : Bool
    , errors : Error style variation msg
    , disabled : Bool
    , icon : Bool -> Element style variation msg
    }


{-| -}
checkboxWith : style -> List (Attribute variation msg) -> CheckboxWith style variation msg -> Element style variation msg
checkboxWith style attrs input =
    let
        withDisabled attrs =
            if input.disabled then
                Attr.class "disabled-input" :: disabledAttr True :: attrs
            else
                attrs

        withError attrs =
            case input.errors of
                NoError ->
                    attrs

                _ ->
                    Attr.attribute "aria-invalid" "true" :: attrs

        inputElem =
            [ Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (withError << withDisabled)
                        [ type_ "checkbox"
                        , checked input.checked
                        , pointer
                        , Events.onCheck input.onChange
                        , hidden
                        , Attr.toAttr (Html.Attributes.class "focus-override")
                        ]
                , child = Internal.Empty
                , absolutelyPositioned = Nothing
                }
            , input.icon input.checked
                |> Modify.addAttr (Attr.toAttr <| Html.Attributes.class "alt-icon")
            ]
    in
        applyLabel Nothing (Attr.spacing 5 :: Attr.verticalCenter :: attrs) (LabelOnRight input.label) input.errors input.disabled inputElem



{- Text Inputs -}


type TextKind
    = Text
    | Search
    | Password
    | Email
    | TextArea


{-| -}
text : style -> List (Attribute variation msg) -> TextInput style variation msg -> Element style variation msg
text =
    textHelper Text


{-| -}
search : style -> List (Attribute variation msg) -> TextInput style variation msg -> Element style variation msg
search =
    textHelper Search


{-| -}
password : style -> List (Attribute variation msg) -> TextInput style variation msg -> Element style variation msg
password =
    textHelper Password


{-| -}
email : style -> List (Attribute variation msg) -> TextInput style variation msg -> Element style variation msg
email =
    textHelper Email


{-| -}
multiline : style -> List (Attribute variation msg) -> TextInput style variation msg -> Element style variation msg
multiline =
    textHelper TextArea



-- {-| -}
-- type alias Autocomplete style variation msg =
--     { onChange : String -> msg
--     , value : String
--     , label : Label style variation msg
--     , disabled : Disabled
--     , errors : Error style variation msg
--     , autocomplete : AutocompleteConfig style variation msg
--     }
-- {-| -}
-- type AutocompleteConfig style variation msg
--     = AutocompleteConfig
--         { max : Int
--         , options : String -> Bool -> Element style variation msg
--         }
-- {-| -}
-- autocomplete : style -> List (Attribute variation msg) -> Autocomplete style variation msg -> Element style variation msg
-- autocomplete style attrs auto =
--     Element.empty


{-| -}
textHelper : TextKind -> style -> List (Attribute variation msg) -> TextInput style variation msg -> Element style variation msg
textHelper kind style attrs input =
    let
        withPlaceholder attrs =
            case input.label of
                PlaceHolder placeholder label ->
                    (Attr.toAttr <| Html.Attributes.placeholder placeholder) :: attrs

                _ ->
                    attrs

        withDisabled attrs =
            if input.disabled then
                Attr.class "disabled-input" :: disabledAttr True :: attrs
            else
                attrs

        withError attrs =
            case input.errors of
                NoError ->
                    attrs

                _ ->
                    Attr.attribute "aria-invalid" "true" :: attrs

        kindAsText =
            case kind of
                Text ->
                    "text"

                Search ->
                    "search"

                Password ->
                    "password"

                Email ->
                    "email"

                TextArea ->
                    "text"

        inputElem =
            case kind of
                TextArea ->
                    Internal.Element
                        { node = "textarea"
                        , style = Just style
                        , attrs =
                            (Attr.inlineStyle [ ( "resize", "none" ) ] :: Events.onInput input.onChange :: attrs)
                                |> (withPlaceholder >> withDisabled >> withError)
                        , child = Internal.Text Internal.RawText input.value
                        , absolutelyPositioned = Nothing
                        }

                _ ->
                    Internal.Element
                        { node = "input"
                        , style = Just style
                        , attrs =
                            (type_ kindAsText :: Events.onInput input.onChange :: value input.value :: attrs)
                                |> (withPlaceholder >> withDisabled >> withError)
                        , child = Internal.Empty
                        , absolutelyPositioned = Nothing
                        }
    in
        applyLabel Nothing attrs input.label input.errors input.disabled [ inputElem ]


type alias TextInput style variation msg =
    { onChange : String -> msg
    , value : String
    , label : Label style variation msg
    , disabled : Bool
    , errors : Error style variation msg
    }


type Error style variation msg
    = NoError
    | ErrorBelow (Element style variation msg)
    | ErrorAbove (Element style variation msg)


type Label style variation msg
    = LabelBelow (Element style variation msg)
    | LabelAbove (Element style variation msg)
    | LabelOnRight (Element style variation msg)
    | LabelOnLeft (Element style variation msg)
    | PlaceHolder String (Label style variation msg)



-- | FloatingPlaceholder (Element style variation msg)


{-| -}
placeholder : { text : String, label : Label style variation msg } -> Label style variation msg
placeholder { text, label } =
    case label of
        PlaceHolder _ existingLabel ->
            PlaceHolder text existingLabel

        x ->
            PlaceHolder text x


labelLeft : Element style variation msg -> Label style variation msg
labelLeft =
    LabelOnLeft


labelRight : Element style variation msg -> Label style variation msg
labelRight =
    LabelOnRight


labelAbove : Element style variation msg -> Label style variation msg
labelAbove =
    LabelAbove


labelBelow : Element style variation msg -> Label style variation msg
labelBelow =
    LabelAbove


noErrors : Error style variation msg
noErrors =
    NoError


errorBelow : Element style variation msg -> Error style variation msg
errorBelow el =
    ErrorBelow <| Modify.addAttr (Attr.attribute "aria-live" "assertive") el


errorAbove : Element style variation msg -> Error style variation msg
errorAbove el =
    ErrorAbove <| Modify.addAttr (Attr.attribute "aria-live" "assertive") el


{-| Builds an input element with a label, errors, and a disabled
-}
applyLabel : Maybe style -> List (Attribute variation msg) -> Label style variation msg -> Error style variation msg -> Bool -> List (Element style variation msg) -> Element style variation msg
applyLabel style attrs label errors isDisabled input =
    let
        forSpacing attr =
            case attr of
                Internal.Spacing x y ->
                    Just attr

                _ ->
                    Nothing

        spacing =
            attrs
                |> List.filterMap forSpacing
                |> List.reverse
                |> List.head
                |> Maybe.withDefault
                    (Internal.Spacing 0 0)

        labelContainer direction children =
            Internal.Layout
                { node = "label"
                , style = style
                , layout = Style.FlexLayout direction []
                , attrs =
                    pointer :: attrs
                , children = Internal.Normal children
                , absolutelyPositioned = Nothing
                }

        orient direction children =
            Internal.Layout
                { node = "div"
                , style = Nothing
                , layout = Style.FlexLayout direction []
                , attrs =
                    [ pointer, spacing ]
                , children = Internal.Normal children
                , absolutelyPositioned = Nothing
                }
    in
        case label of
            PlaceHolder placeholder newLabel ->
                -- placeholder is set in a previous function
                applyLabel style attrs newLabel errors isDisabled input

            LabelAbove lab ->
                case errors of
                    NoError ->
                        labelContainer Style.Down (lab :: input)

                    ErrorAbove err ->
                        labelContainer Style.Down (orient Style.GoRight [ lab, err ] :: input)

                    ErrorBelow err ->
                        labelContainer Style.Down (lab :: input ++ [ err ])

            LabelBelow lab ->
                case errors of
                    NoError ->
                        labelContainer Style.Down (input ++ [ lab ])

                    ErrorBelow err ->
                        labelContainer Style.Down (input ++ [ orient Style.GoRight [ lab, err ] ])

                    ErrorAbove err ->
                        labelContainer Style.Down (err :: input ++ [ lab ])

            LabelOnRight lab ->
                case errors of
                    NoError ->
                        labelContainer Style.GoRight (input ++ [ lab ])

                    ErrorBelow err ->
                        labelContainer Style.Down [ orient Style.GoRight (input ++ [ lab ]), err ]

                    ErrorAbove err ->
                        labelContainer Style.Down [ err, orient Style.GoRight (input ++ [ lab ]) ]

            LabelOnLeft lab ->
                case errors of
                    NoError ->
                        labelContainer Style.GoRight (lab :: input)

                    ErrorBelow err ->
                        labelContainer Style.Down [ orient Style.GoRight (lab :: input), err ]

                    ErrorAbove err ->
                        labelContainer Style.Down [ err, orient Style.GoRight (lab :: input) ]



{- Radio Options -}


type Option value style variation msg
    = Option value (Element style variation msg)
    | OptionWith
        { style : style
        , attrs : List (Attribute variation msg)
        , value : value
        , icon : Bool -> Element style variation msg
        , label : Label style variation msg
        }


type alias OptionDetails value style variation msg =
    { value : value
    , icon : Bool -> Element style variation msg
    , label : Label style variation msg
    }


{-| -}
option : value -> Element style variation msg -> Option value style variation msg
option =
    Option


{-| -}
optionWith : style -> List (Attribute variation msg) -> OptionDetails value style variation msg -> Option value style variation msg
optionWith style attrs details =
    OptionWith
        { style = style
        , attrs = attrs
        , value = details.value
        , icon = details.icon
        , label = details.label
        }


getOptionValue : Option a style variation msg -> a
getOptionValue opt =
    case opt of
        Option value _ ->
            value

        OptionWith { value } ->
            value


optionToString : a -> String
optionToString =
    Style.Internal.Selector.formatName


{-| -}
type alias Radio option style variation msg =
    { onChange : option -> msg
    , options : List (Option option style variation msg)
    , selected : Maybe option
    , label : Label style variation msg
    , disabled : Bool
    , errors : Error style variation msg
    }


{-|

    Input.radio Field
        [ padding 10
        , spacing 5
        ]
        { onChange = ChooseLunch
        , selected = Just model.lunch
        , label = Input.labelAbove <| text "Lunch"
        , errors = Input.noErrors
        , disabled = Input.enabled
        , options =
            [ Input.optionWith None
                []
                { value = Burrito
                , icon =
                    (\selected ->
                        if selected then
                            text ":D"
                        else
                            text ":("
                    )
                , label = Input.labelRight <| text "burrito"
                }
            , Input.option Taco (text "Taco!")
            , Input.option Gyro (text "Gyro")
            ]
        }
-}
radio : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radio style attrs config =
    let
        input =
            radioHelper False
                style
                attrs
                { selection =
                    Single
                        { selected = config.selected
                        , onChange = config.onChange
                        }
                , options = config.options
                , label = config.label
                , disabled = config.disabled
                , errors = config.errors
                }
    in
        applyLabel Nothing attrs config.label config.errors config.disabled [ input ]


{-| Same as `radio`, but arranges the options in a row instead of a column
-}
radioRow : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radioRow style attrs config =
    let
        input =
            radioHelper True
                style
                attrs
                { selection =
                    Single
                        { selected = config.selected
                        , onChange = config.onChange
                        }
                , options = config.options
                , label = config.label
                , disabled = config.disabled
                , errors = config.errors
                }
    in
        applyLabel Nothing attrs config.label config.errors config.disabled [ input ]



-- A Multiselect can probably be handled by custom checkboxs
--
-- {-| -}
-- type alias Multiple option style variation msg =
--     { onChange : List option -> msg
--     , options : List (Option option style variation msg)
--     , selected : List option
--     , label : Label style variation msg
--     , disabled : Disabled
--     , errors : Error style variation msg
--     }
-- multiple : style -> List (Attribute variation msg) -> Multiple option style variation msg -> Element style variation msg
-- multiple style attrs config =
--     let
--         input =
--             radioHelper False
--                 style
--                 attrs
--                 { selection =
--                     Multi
--                         { selected = config.selected
--                         , onChange = config.onChange
--                         }
--                 , options = config.options
--                 , label = config.label
--                 , disabled = config.disabled
--                 , errors = config.errors
--                 }
--     in
--         applyLabel Nothing attrs config.label config.errors config.disabled [ input ]
--
--
-- multipleRow : style -> List (Attribute variation msg) -> Multiple option style variation msg -> Element style variation msg
-- multipleRow style attrs config =
--     let
--         input =
--             radioHelper True
--                 style
--                 attrs
--                 { selection =
--                     Multi
--                         { selected = config.selected
--                         , onChange = config.onChange
--                         }
--                 , options = config.options
--                 , label = config.label
--                 , disabled = config.disabled
--                 , errors = config.errors
--                 }
--     in
--         applyLabel Nothing attrs config.label config.errors config.disabled [ input ]


{-| -}
type alias MasterRadio option style variation msg =
    { selection : RadioSelection option msg
    , options : List (Option option style variation msg)
    , label : Label style variation msg
    , disabled : Bool
    , errors : Error style variation msg
    }


type RadioSelection value msg
    = Single
        { selected : Maybe value
        , onChange : value -> msg
        }
    | Multi
        { selected : List value
        , onChange : List value -> msg
        }


radioHelper : Bool -> style -> List (Attribute variation msg) -> MasterRadio option style variation msg -> Element style variation msg
radioHelper horizontal style attrs config =
    let
        group =
            config.options
                |> List.map (optionToString << getOptionValue)
                |> String.join "-"

        valueIsSelected val =
            case config.selection of
                Single single ->
                    (Just val == single.selected)

                Multi multi ->
                    List.member val multi.selected

        addSelection val attrs =
            attrs ++ isSelected val

        isSelected val =
            case config.selection of
                Single single ->
                    let
                        isSelected =
                            (Just val == single.selected)
                    in
                        if isSelected then
                            [ checked True
                            ]
                        else
                            [ checked False
                            , Events.onCheck (\_ -> single.onChange val)
                            ]

                Multi multi ->
                    let
                        isSelected =
                            List.member val multi.selected
                    in
                        [ checked isSelected
                        , if isSelected then
                            Events.onCheck (\_ -> multi.onChange (List.filter (\item -> item /= val) multi.selected))
                          else
                            Events.onCheck (\_ -> multi.onChange (val :: multi.selected))
                        ]

        renderOption option =
            case option of
                Option val el ->
                    let
                        style =
                            Modify.getStyle el

                        attrs =
                            Modify.getAttrs el

                        input =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    addSelection val
                                        [ type_ "radio"
                                        , pointer
                                        , name group
                                        , value (optionToString val)
                                        ]
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }

                        literalLabel =
                            el
                                |> Modify.getChild
                                |> Modify.removeAllAttrs
                                |> Modify.removeStyle
                    in
                        Internal.Layout
                            { node = "label"
                            , style = style
                            , layout = Style.FlexLayout Style.GoRight []
                            , attrs = pointer :: Attr.spacing 5 :: attrs
                            , children = Internal.Normal [ input, literalLabel ]
                            , absolutelyPositioned = Nothing
                            }

                OptionWith config ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    addSelection config.value
                                        [ type_ "radio"
                                        , hidden
                                        , tabindex 0
                                        , name group
                                        , value (optionToString config.value)
                                        , Attr.toAttr <| Html.Attributes.class "focus-override"
                                        ]
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }

                        inputElems =
                            [ hiddenInput
                            , config.icon (valueIsSelected config.value)
                                |> Modify.addAttr (Attr.toAttr <| Html.Attributes.class "alt-icon")
                            ]
                    in
                        applyLabel (Just config.style) config.attrs config.label noErrors False inputElems
    in
        if horizontal then
            row style attrs (List.map renderOption config.options)
        else
            column style attrs (List.map renderOption config.options)



{-
   I'm currently under the impressiong that <select> isn't the best form element, and that usually you'd want a radio or an autocomplete instead.
   Problems:
        You can't style it and it looks terrible
        It leads to bad UX (think: a dropdown of 1,000 countrys)

-}


{-| -}
type alias Select option style variation msg =
    { onChange : option -> msg
    , options : List ( String, option )
    , selected : Maybe option
    , label : Label style variation msg
    , disabled : Bool
    , errors : Error style variation msg
    }


{-| A Select Menu
-}
select : style -> List (Attribute variation msg) -> Select option style variation msg -> Element style variation msg
select style attrs { onChange, options, selected } =
    let
        renderOption ( label, option ) =
            Html.option [ Html.Attributes.value label, Html.Attributes.selected (Just option == selected) ]
                [ Html.text label
                ]

        event newSelection =
            options
                |> List.filterMap
                    (\( label, option ) ->
                        if newSelection == label then
                            Just option
                        else
                            Nothing
                    )
                |> List.head
                |> \maybeOption ->
                    case maybeOption of
                        Nothing ->
                            Json.fail "No Option present in Select box"

                        Just opt ->
                            Json.succeed opt

        onSelect =
            Json.map onChange
                (Json.andThen event Html.Events.targetValue)

        selectElement =
            Internal.Raw <|
                Html.select
                    [ Html.Attributes.name "lunch"
                    , Html.Events.on "change" onSelect
                    , Html.Attributes.class "focus-override"
                    , Html.Attributes.style [ ( "position", "absolute" ), ( "z-index", "-1" ), ( "border", "none" ) ]
                    ]
                    (List.map renderOption options)

        arrows =
            Internal.Element
                { node = "div"
                , style = Nothing
                , attrs = [ Attr.class "double-arrows" ]
                , child =
                    Element.empty
                , absolutelyPositioned = Nothing
                }

        replacement =
            Internal.Layout
                { node = "div"
                , style = Just style
                , layout = Style.FlexLayout Style.GoRight []
                , attrs =
                    Attr.verticalCenter :: Attr.spacing 7 :: pointer :: (Attr.toAttr <| Html.Attributes.class "alt-icon") :: attrs
                , children =
                    Internal.Normal
                        [ case selected of
                            Nothing ->
                                Element.text "-"

                            Just sel ->
                                Element.text (toString sel)
                        , arrows
                        ]
                , absolutelyPositioned = Nothing
                }
    in
        Internal.Layout
            { node = "div"
            , style = Nothing
            , layout = Style.FlexLayout Style.GoRight []
            , attrs =
                [ pointer ]
            , children = Internal.Normal [ selectElement, replacement ]
            , absolutelyPositioned = Nothing
            }



-- [ ( "position", "absolute" ), ( "opacity", "0" ) ]
-- {-| -}
-- type GridOption value style variation msg
--     = GridOption
--         { position : Element.GridPosition
--         , value : value
--         , el : Element style variation msg
--         }
--     | GridOptionWith
--         { position : Element.GridPosition
--         , value : value
--         , view : Bool -> Element style variation msg
--         }
-- {-| -}
-- cell : { el : Element style variation msg, height : Int, start : ( Int, Int ), value : a, width : Int } -> GridOption a style variation msg
-- cell { start, width, height, value, el } =
--     GridOption
--         { position =
--             { start = start
--             , width = width
--             , height = height
--             }
--         , value = value
--         , el = el
--         }
-- {-| -}
-- cellWith : { view : Bool -> Element style variation msg, height : Int, start : ( Int, Int ), value : a, width : Int } -> GridOption a style variation msg
-- cellWith { start, width, height, value, view } =
--     GridOptionWith
--         { position =
--             { start = start
--             , width = width
--             , height = height
--             }
--         , value = value
--         , view = view
--         }
-- {-| -}
-- type alias Grid value style variation msg =
--     { onChange : value -> msg
--     , selected : Maybe value
--     , label : Label style variation msg
--     , disabled : Disabled
--     , errors : Error style variation msg
--     , columns : List Length
--     , rows : List Length
--     , cells : List (GridOption value style variation msg)
--     }
-- {-| A grid radiobutton layout
--     import Element.Input as Input
--     Input.grid MyGridStyle []
--         { label = Input.labelAbove (text "Choose Lunch!")
--         , onChange = ChooseLunch
--         , selected = Just currentlySelected -- : Maybe Lunch
--         , errors = Input.valid
--         , disabled = Input.enabled
--         , columns = [ px 100, px 100, px 100, px 100 ]
--         , rows =
--             [ px 100
--             , px 100
--             , px 100
--             , px 100
--             ]
--         , cells =
--              [ Input.cell
--                 { start = ( 0, 0 )
--                 , width = 1
--                 , height = 1
--                 , value = Burrito
--                 , el =
--                     el Box [] (text "box")
--                 }
--             , Input.cell
--                 { start = ( 1, 1 )
--                 , width = 1
--                 , height = 2
--                 , value = Taco
--                 , el =
--                     (el Box [] (text "box"))
--                 }
--             , Input.cellWith
--                 { start = ( 1, 1 )
--                 , width = 1
--                 , height = 2
--                 , value = Taco
--                 , selected =
--                     \selected ->
--                         if selected then
--                             text "Burrito!"
--                         else
--                             text "Unselected burrito :("
--                 }
--             ]
--         }
--
-- -}
-- grid : style -> List (Attribute variation msg) -> Grid value style variation msg -> Element style variation msg
-- grid style attrs input =
--     let
--         getGridOptionValue opt =
--             case opt of
--                 GridOption { value } ->
--                     value
--                 GridOptionWith { value } ->
--                     value
--         group =
--             input.cells
--                 |> List.map (optionToString << getGridOptionValue)
--                 |> String.join "-"
--         renderOption option =
--             case option of
--                 GridOption grid ->
--                     let
--                         style =
--                             Modify.getStyle grid.el
--                         attrs =
--                             Modify.getAttrs grid.el
--                         ( inputEvents, nonInputEventAttrs ) =
--                             List.partition forInputEvents
--                                 (if Just grid.value /= input.selected then
--                                     attrs ++ [ Events.onCheck (\_ -> input.onChange grid.value) ]
--                                  else
--                                     attrs
--                                 )
--                         forInputEvents attr =
--                             case attr of
--                                 Internal.InputEvent ev ->
--                                     True
--                                 _ ->
--                                     False
--                         rune =
--                             grid.el
--                                 |> Modify.setNode "input"
--                                 |> Modify.addAttrList
--                                     ([ type_ "radio"
--                                      , name group
--                                      , value (optionToString grid.value)
--                                      , checked (Just grid.value == input.selected)
--                                      , Internal.Position Nothing (Just -2) Nothing
--                                      ]
--                                         ++ inputEvents
--                                     )
--                                 |> Modify.removeContent
--                                 |> Modify.removeStyle
--                         literalLabel =
--                             grid.el
--                                 |> Modify.getChild
--                                 |> Modify.removeAllAttrs
--                                 |> Modify.removeStyle
--                     in
--                         Element.cell grid.position <|
--                             Internal.Layout
--                                 { node = "label"
--                                 , style = style
--                                 , layout = Style.FlexLayout Style.GoRight []
--                                 , attrs =
--                                     Attr.spacing 5
--                                         :: Attr.center
--                                         :: Attr.verticalCenter
--                                         :: pointer
--                                         :: nonInputEventAttrs
--                                 , children = Internal.Normal [ rune, literalLabel ]
--                                 , absolutelyPositioned = Nothing
--                                 }
--                 GridOptionWith grid ->
--                     let
--                         hiddenInput =
--                             Internal.Element
--                                 { node = "input"
--                                 , style = Nothing
--                                 , attrs =
--                                     ([ type_ "radio"
--                                      , hidden
--                                      , tabindex 0
--                                      , name group
--                                      , value (optionToString grid.value)
--                                      , checked (Just grid.value == input.selected)
--                                      , Attr.toAttr <| Html.Attributes.class "focus-override"
--                                      ]
--                                         ++ if Just grid.value /= input.selected then
--                                             [ Events.onCheck (\_ -> input.onChange grid.value) ]
--                                            else
--                                             []
--                                     )
--                                 , child = Internal.Empty
--                                 , absolutelyPositioned = Nothing
--                                 }
--                     in
--                         Element.cell grid.position <|
--                             Internal.Layout
--                                 { node = "label"
--                                 , style = Nothing
--                                 , layout = Style.FlexLayout Style.GoRight []
--                                 , attrs = [ pointer ]
--                                 , children =
--                                     Internal.Normal
--                                         [ hiddenInput
--                                         , grid.view (Just grid.value == input.selected)
--                                             |> Modify.addAttr (Attr.toAttr <| Html.Attributes.class "alt-icon")
--                                         ]
--                                 , absolutelyPositioned = Nothing
--                                 }
--     in
--         Element.grid style
--             attrs
--             { rows = input.rows
--             , columns = input.columns
--             , cells = List.map renderOption input.cells
--             }
