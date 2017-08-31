module Element.Input
    exposing
        ( checkbox
        , Checkbox
        , checkboxWith
        , CheckboxWith
        , text
        , TextInput
        , multiline
        , search
        , email
        , password
        , radio
        , radioRow
        , option
        , optionWith
        , Option
        , hiddenLabel
        , labelLeft
        , labelRight
        , labelAbove
        , labelBelow
        , errorBelow
        , errorAbove
        , noErrors
        , placeholder
        , dropSelect
        , menu
        , menuAbove
        , DropDown
          -- , select
          -- , Select
          -- , grid
          -- , Grid
          -- , cell
          -- , cellWith
        )

{-| Input Elements

@docs checkbox, Checkbox, checkboxWith, CheckboxWith


## Labels

@docs labelAbove, labelBelow, labelLeft, labelRight, placeholder, hiddenLabel


## Errors

@docs noErrors, errorAbove, errorBelow


## Text Input

@docs TextInput, text, multiline, search, email, password


## 'Choose One' Inputs

@docs Radio, radio, radioRow, Option, option, optionWith

@docs DropDown, dropSelect, menu, menuAbove

-}

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


valueAttr : String -> Internal.Attribute variation msg
valueAttr =
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


{-| -}
textHelper : TextKind -> style -> List (Attribute variation msg) -> TextInput style variation msg -> Element style variation msg
textHelper kind style attrs input =
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
                    (Internal.Spacing 7 7)

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
                            (type_ kindAsText :: Events.onInput input.onChange :: valueAttr input.value :: attrs)
                                |> (withPlaceholder >> withDisabled >> withError)
                        , child = Internal.Empty
                        , absolutelyPositioned = Nothing
                        }
    in
        applyLabel Nothing [ spacing ] input.label input.errors input.disabled [ inputElem ]


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
    | HiddenLabel String
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


hiddenLabel : String -> Label style variation msg
hiddenLabel =
    HiddenLabel


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

            HiddenLabel title ->
                Internal.Layout
                    { node = "label"
                    , style = style
                    , layout = Style.FlexLayout Style.Down []
                    , attrs =
                        pointer :: attrs
                    , children =
                        input
                            |> List.map (Modify.addAttr (Attr.attribute "title" title))
                            |> Internal.Normal
                    , absolutelyPositioned = Nothing
                    }

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
    | OptionWith value (Bool -> Element style variation msg)


{-| -}
option : value -> Element style variation msg -> Option value style variation msg
option =
    Option


{-| -}
optionWith : value -> (Bool -> Element style variation msg) -> Option value style variation msg
optionWith =
    OptionWith


getOptionValue : Option a style variation msg -> a
getOptionValue opt =
    case opt of
        Option value _ ->
            value

        OptionWith value _ ->
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
            radioHelper Vertical
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
        applyLabel Nothing [] config.label config.errors config.disabled [ input ]


{-| Same as `radio`, but arranges the options in a row instead of a column
-}
radioRow : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radioRow style attrs config =
    let
        input =
            radioHelper Horizontal
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
        applyLabel Nothing [] config.label config.errors config.disabled [ input ]



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


type Orientation msg
    = Horizontal
    | Vertical


radioHelper : Orientation msg -> style -> List (Attribute variation msg) -> MasterRadio option style variation msg -> Element style variation msg
radioHelper orientation style attrs config =
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
                        input =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    addSelection val
                                        [ type_ "radio"
                                        , pointer
                                        , name group
                                        , valueAttr (optionToString val)
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
                            , style = Modify.getStyle el
                            , layout = Style.FlexLayout Style.GoRight []
                            , attrs = pointer :: Attr.spacing 5 :: Modify.getAttrs el
                            , children = Internal.Normal [ input, literalLabel ]
                            , absolutelyPositioned = Nothing
                            }

                OptionWith val view ->
                    let
                        viewed =
                            view (valueIsSelected val)

                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    addSelection val
                                        [ type_ "radio"
                                        , hidden
                                        , tabindex 0
                                        , name group
                                        , valueAttr (optionToString val)
                                        , Attr.toAttr <| Html.Attributes.class "focus-override"
                                        ]
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }
                    in
                        Internal.Layout
                            { node = "label"
                            , style = Modify.getStyle viewed
                            , layout = Style.FlexLayout Style.GoRight []
                            , attrs = pointer :: Attr.spacing 5 :: Modify.getAttrs viewed
                            , children =
                                Internal.Normal
                                    [ hiddenInput
                                    , viewed
                                        |> Modify.removeAllAttrs
                                        |> Modify.addAttr (Attr.toAttr <| Html.Attributes.class "alt-icon")
                                        |> Modify.removeStyle
                                    ]
                            , absolutelyPositioned = Nothing
                            }
    in
        case orientation of
            Horizontal ->
                row style (Attr.spacing 10 :: attrs) (List.map renderOption config.options)

            Vertical ->
                column style (Attr.spacing 10 :: attrs) (List.map renderOption config.options)


arrows : Element a variation msg
arrows =
    Internal.Element
        { node = "div"
        , style = Nothing
        , attrs = [ Attr.class "arrows" ]
        , child =
            Element.empty
        , absolutelyPositioned = Nothing
        }



{-
   I'm currently under the impressiong that <select> isn't the best form element, and that usually you'd want a radio or an autocomplete instead.
   Problems:
        You can't style it and it looks terrible
        It leads to bad UX (think: a dropdown of 1,000 countrys)

-}


{-| -}



-- type alias Select option style variation msg =
--     { onChange : option -> msg
--     , options : List ( String, option )
--     , selected : Maybe option
--     , label : Label style variation msg
--     , disabled : Bool
--     , errors : Error style variation msg
--     }
-- {-| A Select Menu
-- -}
-- select : style -> List (Attribute variation msg) -> Select option style variation msg -> Element style variation msg
-- select style attrs { onChange, options, selected } =
--     let
--         renderOption ( label, option ) =
--             Html.option [ Html.Attributes.value label, Html.Attributes.selected (Just option == selected) ]
--                 [ Html.text label
--                 ]
--         event newSelection =
--             options
--                 |> List.filterMap
--                     (\( label, option ) ->
--                         if newSelection == label then
--                             Just option
--                         else
--                             Nothing
--                     )
--                 |> List.head
--                 |> \maybeOption ->
--                     case maybeOption of
--                         Nothing ->
--                             Json.fail "No Option present in Select box"
--                         Just opt ->
--                             Json.succeed opt
--         onSelect =
--             Json.map onChange
--                 (Json.andThen event Html.Events.targetValue)
--         selectElement =
--             Internal.Raw <|
--                 Html.select
--                     [ Html.Attributes.name "lunch"
--                     , Html.Events.on "change" onSelect
--                     , Html.Attributes.class "focus-override"
--                     , Html.Attributes.style [ ( "position", "absolute" ), ( "z-index", "-1" ), ( "border", "none" ) ]
--                     ]
--                     (List.map renderOption options)
--         arrows =
--             Internal.Element
--                 { node = "div"
--                 , style = Nothing
--                 , attrs = [ Attr.class "arrows" ]
--                 , child =
--                     Element.empty
--                 , absolutelyPositioned = Nothing
--                 }
--         replacement =
--             Internal.Layout
--                 { node = "div"
--                 , style = Just style
--                 , layout = Style.FlexLayout Style.GoRight []
--                 , attrs =
--                     Attr.verticalCenter :: Attr.spacing 7 :: pointer :: (Attr.toAttr <| Html.Attributes.class "alt-icon") :: attrs
--                 , children =
--                     Internal.Normal
--                         [ case selected of
--                             Nothing ->
--                                 Element.text "-"
--                             Just sel ->
--                                 Element.text (toString sel)
--                         , arrows
--                         ]
--                 , absolutelyPositioned = Nothing
--                 }
--     in
--         Internal.Layout
--             { node = "label"
--             , style = Nothing
--             , layout = Style.FlexLayout Style.GoRight []
--             , attrs =
--                 [ pointer ]
--             , children = Internal.Normal [ selectElement, replacement ]
--             , absolutelyPositioned = Nothing
--             }
-- {-| -}


type alias DropDown option style variation msg =
    { onChange : option -> msg
    , menu : Menu option style variation msg
    , selected : Maybe option
    , label : Label style variation msg
    , disabled : Bool
    , errors : Error style variation msg
    , isOpen : Bool
    , show : Bool -> msg
    }


type Menu option style variation msg
    = MenuUp style (List (Attribute variation msg)) (List (Option option style variation msg))
    | MenuDown style (List (Attribute variation msg)) (List (Option option style variation msg))


menu : style -> List (Attribute variation msg) -> List (Option option style variation msg) -> Menu option style variation msg
menu =
    MenuDown


menuAbove : style -> List (Attribute variation msg) -> List (Option option style variation msg) -> Menu option style variation msg
menuAbove =
    MenuUp


{-| A dropdown input.

    Input.dropSelect Field
        [ padding 10
        , spacing 5
        ]
        { isOpen = True
        , onChange = ChooseLunch
        , selected = Just model.lunch
        , label = Input.labelAbove (text "Lunch")
        , errors = Input.noErrors
        , disabled = False
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
                , label = Input.labelRight (text "burrito")
                }
            , Input.option Taco (text "Taco!")
            , Input.option Gyro (text "Gyro")
            ]
        }

-}
dropSelect : style -> List (Attribute variation msg) -> DropDown option style variation msg -> Element style variation msg
dropSelect style attrs input =
    let
        ( menuAbove, menuStyle, menuAttrs, options ) =
            case input.menu of
                MenuUp menuStyle menuAttrs menuOptions ->
                    ( True, menuStyle, menuAttrs, menuOptions )

                MenuDown menuStyle menuAttrs menuOptions ->
                    ( False, menuStyle, menuAttrs, menuOptions )

        placeholderText =
            case input.label of
                PlaceHolder text _ ->
                    Element.text text

                _ ->
                    Element.text " - "

        getSelectedLabel selected option =
            if getOptionValue option == selected then
                case option of
                    Option _ el ->
                        Just el

                    OptionWith _ view ->
                        Just <| view True
            else
                Nothing

        selectedText =
            case input.selected of
                Nothing ->
                    placeholderText

                Just selected ->
                    options
                        |> List.filterMap (getSelectedLabel selected)
                        |> List.head
                        |> Maybe.withDefault placeholderText

        forPadding attr =
            case attr of
                Internal.Padding _ _ _ _ ->
                    True

                _ ->
                    False

        parentPadding =
            List.filter forPadding attrs

        bar =
            Internal.Layout
                { node = "div"
                , style = Just style
                , layout = Style.FlexLayout Style.GoRight []
                , attrs =
                    Events.onClick (input.show (not input.isOpen))
                        :: Attr.verticalCenter
                        :: Attr.spacing 7
                        :: Attr.spread
                        :: Attr.width Attr.fill
                        :: pointer
                        :: attrs
                , children =
                    Internal.Normal
                        [ selectedText
                        , arrows
                        ]
                , absolutelyPositioned = Nothing
                }

        cursor =
            List.foldl
                (\option cache ->
                    let
                        next =
                            if cache.found && cache.next == Nothing then
                                Just <| getOptionValue option
                            else
                                cache.next

                        prev =
                            if currentIsSelected && cache.prev == Nothing then
                                cache.last
                            else
                                cache.prev

                        currentIsSelected =
                            case cache.selected of
                                Nothing ->
                                    False

                                Just sel ->
                                    getOptionValue option == sel

                        found =
                            if not cache.found then
                                currentIsSelected
                            else
                                cache.found

                        first =
                            case cache.first of
                                Nothing ->
                                    Just <| getOptionValue option

                                _ ->
                                    cache.first

                        last =
                            Just <| getOptionValue option
                    in
                        { cache
                            | next = next
                            , found = found
                            , prev = prev
                            , first = first
                            , last = last
                        }
                )
                { selected = input.selected
                , found = False
                , prev = Nothing
                , next = Nothing
                , first = Nothing
                , last = Nothing
                }
                options

        { next, prev } =
            if cursor.found == False then
                { next = cursor.first, prev = cursor.first }
            else if cursor.next == Nothing && cursor.prev /= Nothing then
                { next = cursor.first
                , prev = cursor.prev
                }
            else if cursor.prev == Nothing && cursor.next /= Nothing then
                { next = cursor.next
                , prev = cursor.last
                }
            else
                { next = cursor.next
                , prev = cursor.prev
                }

        renderOption option =
            case option of
                Option val el ->
                    let
                        isSelected =
                            if Just val == input.selected then
                                [ Attr.attribute "aria-selected" "true"
                                , Attr.inlineStyle [ ( "background-color", "rgba(0,0,0,0.03)" ) ]
                                ]
                                    ++ parentPadding
                            else
                                [ Attr.attribute "aria-selected" "false" ] ++ parentPadding

                        additional =
                            Events.onClick (input.onChange val)
                                :: Internal.Expand
                                :: Attr.attribute "role" "menuitemradio"
                                :: isSelected
                    in
                        el
                            |> Modify.addAttrList additional

                OptionWith val view ->
                    let
                        isSelected =
                            if Just val == input.selected then
                                [ Attr.attribute "aria-selected" "true"
                                , Attr.inlineStyle [ ( "background-color", "rgba(0,0,0,0.03)" ) ]
                                ]
                                    ++ parentPadding
                            else
                                [ Attr.attribute "aria-selected" "false" ] ++ parentPadding

                        additional =
                            Events.onClick (input.onChange val)
                                :: Internal.Expand
                                :: Attr.attribute "role" "menuitemradio"
                                :: isSelected
                    in
                        view (Just val == input.selected)
                            |> Modify.addAttrList additional

        fullElement =
            Internal.Element
                { node = "div"
                , style = Nothing
                , attrs =
                    List.filterMap identity
                        [ Just (Attr.width Attr.fill)
                        , Just (Attr.attribute "role" "menu")
                        , Just (tabindex 0)
                        , Just (Attr.inlineStyle [ ( "z-index", "20" ) ])
                        , Just (Attr.toAttr <| onFocusOut (input.show False))
                        , Just <|
                            onKeyLookup <|
                                \key ->
                                    if key == enter then
                                        Just <| input.show (not input.isOpen)
                                    else if key == downArrow && not input.isOpen then
                                        Just <| input.show True
                                    else if key == downArrow && input.isOpen then
                                        Maybe.map (input.onChange) next
                                    else if key == upArrow && not input.isOpen then
                                        Just <| input.show True
                                    else if key == upArrow && input.isOpen then
                                        Maybe.map (input.onChange) prev
                                    else
                                        Nothing
                        ]
                , child = bar
                , absolutelyPositioned = Nothing
                }
                |> (if menuAbove then
                        Element.above
                    else
                        Element.below
                   )
                    (if input.isOpen then
                        [ column menuStyle
                            (Attr.inlineStyle [ ( "z-index", "20" ), ( "background-color", "white" ) ]
                                :: pointer
                                :: Events.onClick (input.show False)
                                :: Attr.width Attr.fill
                                :: menuAttrs
                            )
                            (List.map renderOption options)
                        ]
                     else
                        []
                    )
    in
        applyLabel Nothing [] input.label input.errors input.disabled [ fullElement ]



-- Internal.Layout
-- { node = "div"
-- , style = Just style
-- , layout = Style.FlexLayout Style.GoRight []
-- , attrs =
--     Events.onClick (config.show (not config.isOpen))
--         :: Attr.verticalCenter
--         :: Attr.spacing 7
--         :: Attr.spread
--         :: pointer
--         :: attrs
-- , children =
--     Internal.Normal
--         [ Element.text emptyPlaceholder
--         , arrows
--         ]
-- , absolutelyPositioned = Nothing
-- }
-- |> Element.below
--     [ column style (Attr.inlineStyle [ ( "z-index", "20" ), ( "background-color", "white" ) ] :: Attr.width Attr.fill :: attrs) (List.map renderOption config.options)
--     ]
-- input =
--     radioHelper (DropMenu config.show emptyPlaceholder config.isOpen)
--         style
--         attrs
--         { selection =
--             Single
--                 { selected = config.selected
--                 , onChange = config.onChange
--                 }
--         , options = config.options
--         , label = config.label
--         , disabled = config.disabled
--         , errors = config.errors
--         }
-- attributes =
--     -- Attr.toAttr (onFocusIn (config.show True))
--     --     :: Attr.toAttr (onFocusOut (config.show False))
--         :: attrs
-- in
-- applyLabel Nothing attrs config.label config.errors config.disabled [ input ]
-- verifiedToWorkWithFocus style attrs config =
--     Element.html <|
--         Html.div
--             [ Html.Attributes.style [ ( "background-color", "#FAFAFA" ), ( "pointer-events", "auto" ) ]
--             , onFocusIn (config.show True)
--             , onFocusOut (config.show False)
--             ]
--             [ Html.input
--                 [ Html.Attributes.type_ "hidden"
--                 , Html.Attributes.name "test"
--                 ]
--                 []
--             , Html.div
--                 [ Html.Attributes.style [ ( "overflow", "hidden" ) ]
--                 , Html.Events.onClick (config.show (not config.isOpen))
--                 ]
--                 [ Html.text "Here is the selection, closed" ]
--             , Html.label
--                 (if config.isOpen then
--                     []
--                  else
--                     [ Html.Attributes.style [ ( "position", "absolute" ), ( "top", "-20px" ) ] ]
--                 )
--                 [ Html.input
--                     [ Html.Attributes.type_ "radio"
--                     , Html.Attributes.name "test"
--                     ]
--                     []
--                 , Html.text "Taco"
--                 ]
--             , Html.label
--                 (if config.isOpen then
--                     []
--                  else
--                     [ Html.Attributes.style [ ( "position", "absolute" ), ( "top", "-20px" ) ] ]
--                 )
--                 [ Html.input
--                     [ Html.Attributes.type_ "radio"
--                     , Html.Attributes.name "test"
--                     ]
--                     []
--                 , Html.text "Burrito"
--                 ]
--             ]
-- manualSpecifiedMenu style attrs config =
--     Element.html <|
--         Html.div
--             [ Html.Attributes.style [ ( "background-color", "white" ), ( "pointer-events", "auto" ), ( "overflow", "hidden" ) ]
--             , if config.isOpen then
--                 onFocusOut (config.show False)
--               else
--                 Html.Attributes.style []
--             , Html.Attributes.tabindex 0
--             , onEnter (config.show (not config.isOpen))
--             , onDown (config.show (not config.isOpen))
--             -- , onUp (config.show (not config.isOpen))
--             , Html.Attributes.attribute "role" "menu"
--             ]
--             [ Html.div
--                 [ Html.Events.onClick (config.show (not config.isOpen))
--                 -- , Html.Attributes.tabindex 0
--                 -- , onEnter (config.show (not config.isOpen))
--                 ]
--                 [ Html.text "Here is the selection, closed" ]
--             , Html.div
--                 [ Html.Attributes.attribute "role" "menuitemradio"
--                 , Html.Attributes.attribute "aria-selected" "true"
--                 , Html.Events.onClick (config.show (not config.isOpen))
--                 , if config.isOpen then
--                     Html.Attributes.style []
--                   else
--                     Html.Attributes.style [ ( "position", "absolute" ), ( "top", "-20px" ) ]
--                 ]
--                 [ Html.text "Taco"
--                 ]
--             , Html.div
--                 [ Html.Attributes.attribute "role" "menuitemradio"
--                 , Html.Attributes.attribute "aria-selected" "false"
--                 , Html.Events.onClick (config.show (not config.isOpen))
--                 , if config.isOpen then
--                     Html.Attributes.style []
--                   else
--                     Html.Attributes.style [ ( "position", "absolute" ), ( "top", "-20px" ) ]
--                 ]
--                 [ Html.text "Burrito"
--                 ]
--             ]


{-| -}
onEnter : msg -> Element.Attribute variation msg
onEnter msg =
    onKey 13 msg


{-| -}
onSpace : msg -> Element.Attribute variation msg
onSpace msg =
    onKey 32 msg


{-| -}
onUp : msg -> Element.Attribute variation msg
onUp msg =
    onKey 38 msg


{-| -}
onDown : msg -> Element.Attribute variation msg
onDown msg =
    onKey 40 msg


enter : Int
enter =
    13


upArrow : Int
upArrow =
    38


downArrow : Int
downArrow =
    40


space : Int
space =
    32


{-| -}
onKey : Int -> msg -> Element.Attribute variation msg
onKey desiredCode msg =
    let
        decode code =
            if code == desiredCode then
                Json.succeed msg
            else
                Json.fail "Not the enter key"

        isKey =
            Json.field "which" Json.int
                |> Json.andThen decode
    in
        Events.on "keydown" (isKey)


{-| -}
onKeyLookup : (Int -> Maybe msg) -> Element.Attribute variation msg
onKeyLookup lookup =
    let
        decode code =
            case lookup code of
                Nothing ->
                    Json.fail "No key matched"

                Just msg ->
                    Json.succeed msg

        isKey =
            Json.field "which" Json.int
                |> Json.andThen decode
    in
        Events.on "keydown" (isKey)


{-| -}
onFocusOut : msg -> Html.Attribute msg
onFocusOut msg =
    Html.Events.on "focusout" (Json.succeed msg)


{-| -}
onFocusIn : msg -> Html.Attribute msg
onFocusIn msg =
    Html.Events.on "focusin" (Json.succeed msg)



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
--     , disabled : Bool
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
--             [ Input.cell
--                 { start = ( 0, 0 )
--                 , width = 1
--                 , height = 1
--                 , value = Burrito
--                 , el =
--                 el Box [] (text "box")
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
--                     if selected then
--                     text "Burrito!"
--                     else
--                     text "Unselected burrito :("
--                 }
--             ]
--         }
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
