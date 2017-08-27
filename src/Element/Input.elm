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
        , valid
        , withPlaceholder
        , enabled
        , disabled
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



-- { onChange = Check
-- , checked = model.checkbox
-- , label = el None [] (text "hello!")
-- , errors = Nothing
-- , disabled = False
-- }


{-| -}
type alias Checkbox style variation msg =
    { onChange : Bool -> msg
    , label : Element style variation msg
    , checked : Bool
    , errors : Error style variation msg
    , disabled : Disabled
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
            case input.disabled of
                Disabled ->
                    Attr.class "disabled-input" :: disabledAttr True :: attrs

                Enabled ->
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
    , disabled : Disabled
    , icon : Bool -> Element style variation msg
    }


{-| -}
checkboxWith : style -> List (Attribute variation msg) -> CheckboxWith style variation msg -> Element style variation msg
checkboxWith style attrs input =
    let
        withDisabled attrs =
            case input.disabled of
                Disabled ->
                    Attr.class "disabled-input" :: disabledAttr True :: attrs

                Enabled ->
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
            case input.disabled of
                Disabled ->
                    Attr.class "disabled-input" :: disabledAttr True :: attrs

                Enabled ->
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
    , disabled : Disabled
    , errors : Error style variation msg
    }


type Disabled
    = Disabled
    | Enabled


enabled : Disabled
enabled =
    Enabled


disabled : Disabled
disabled =
    Disabled


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


withPlaceholder : String -> Label style variation msg -> Label style variation msg
withPlaceholder placeholder label =
    case label of
        PlaceHolder _ existingLabel ->
            PlaceHolder placeholder existingLabel

        x ->
            PlaceHolder placeholder x


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


valid : Error style variation msg
valid =
    NoError


errorBelow : Element style variation msg -> Error style variation msg
errorBelow el =
    ErrorBelow <| Modify.addAttr (Attr.attribute "aria-live" "assertive") el


errorAbove : Element style variation msg -> Error style variation msg
errorAbove el =
    ErrorAbove <| Modify.addAttr (Attr.attribute "aria-live" "assertive") el


{-| Builds an input element with a label, errors, and a disabled
-}
applyLabel : Maybe style -> List (Attribute variation msg) -> Label style variation msg -> Error style variation msg -> Disabled -> List (Element style variation msg) -> Element style variation msg
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
    , disabled : Disabled
    , errors : Error style variation msg
    }


{-|

    radio MyStyle [  ]
        { onChange = ChooseLunch
        , selected = Just currentlySelected -- : Maybe Lunch
        , options =
            [ optionWith Burrito <|
                \selected ->
                    let
                        icon =
                            if selected then
                                ":)"
                            else
                                ":("
                    in
                        text (icon ++ " A Burrito!"")

            , option Taco (text "A Taco!")

            ]
        }
-}
radio : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radio style attrs config =
    let
        input =
            radioHelper False style attrs config
    in
        applyLabel Nothing attrs config.label config.errors config.disabled [ input ]


{-| Same as `radio`, but arranges the options in a row instead of a column
-}
radioRow : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radioRow style attrs config =
    let
        input =
            radioHelper True style attrs config
    in
        applyLabel Nothing attrs config.label config.errors config.disabled [ input ]


radioHelper : Bool -> style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radioHelper horizontal style attrs { onChange, options, selected } =
    let
        group =
            options
                |> List.map (optionToString << getOptionValue)
                |> String.join "-"

        renderOption option =
            case option of
                Option val el ->
                    let
                        style =
                            Modify.getStyle el

                        attrs =
                            Modify.getAttrs el

                        ( inputEvents, nonInputEventAttrs ) =
                            List.partition forInputEvents
                                (if Just val /= selected then
                                    attrs ++ [ Events.onCheck (\_ -> onChange val) ]
                                 else
                                    attrs
                                )

                        forInputEvents attr =
                            case attr of
                                Internal.InputEvent ev ->
                                    True

                                _ ->
                                    False

                        rune =
                            el
                                |> Modify.setNode "input"
                                |> Modify.addAttrList
                                    ([ type_ "radio"
                                     , name group
                                     , pointer
                                     , value (optionToString val)
                                     , checked (Just val == selected)
                                     , Internal.VAlign Internal.VerticalCenter
                                     , Internal.Position Nothing (Just -2) Nothing
                                     ]
                                        ++ inputEvents
                                    )
                                |> Modify.removeContent
                                |> Modify.removeStyle

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
                            , attrs = pointer :: Attr.spacing 5 :: nonInputEventAttrs
                            , children = Internal.Normal [ rune, literalLabel ]
                            , absolutelyPositioned = Nothing
                            }

                OptionWith config ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    ([ type_ "radio"
                                     , hidden
                                     , tabindex 0
                                     , name group
                                     , value (optionToString config.value)
                                     , checked (Just config.value == selected)
                                     , Attr.toAttr <| Html.Attributes.class "focus-override"
                                     ]
                                        ++ if Just config.value /= selected then
                                            [ Events.onCheck (\_ -> onChange config.value) ]
                                           else
                                            []
                                    )
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }

                        inputElems =
                            [ hiddenInput
                            , config.icon (Just config.value == selected)
                                |> Modify.addAttr (Attr.toAttr <| Html.Attributes.class "alt-icon")
                            ]
                    in
                        applyLabel (Just config.style) config.attrs config.label valid Enabled inputElems
    in
        if horizontal then
            row style attrs (List.map renderOption options)
        else
            column style attrs (List.map renderOption options)
