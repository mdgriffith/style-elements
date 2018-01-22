module Element.Input
    exposing
        ( Checkbox
        , Choice
        , ChoiceState(..)
        , Error
        , Label
        , Option
        , Radio
        , Select
        , SelectMsg
        , SelectWith
        , StyledCheckbox
        , Text
        , allowSpellcheck
        , autocomplete
        , autofill
        , autofillSection
        , checkbox
        , choice
        , clear
        , currentPassword
        , disabled
        , dropMenu
        , email
        , errorAbove
        , errorBelow
        , focusOnLoad
        , hiddenLabel
        , labelAbove
        , labelBelow
        , labelLeft
        , labelRight
        , menu
        , menuAbove
        , multiline
        , newPassword
        , placeholder
        , radio
        , radioKey
        , radioRow
        , search
        , select
        , selected
        , styledCheckbox
        , styledChoice
        , styledSelectChoice
        , text
        , textKey
        , updateSelection
        , username
        )

{-| Input Elements

@docs checkbox, Checkbox, styledCheckbox, StyledCheckbox


## Text Input

@docs Text, text, multiline, search, email

The following text inputs give hints to the browser so they can be autofilled.

@docs username, newPassword, currentPassword

@docs textKey


## 'Choose One' Inputs

@docs Radio, radio, radioRow, Choice, choice, styledChoice, styledSelectChoice, radioKey, ChoiceState

@docs select, Select, SelectWith, autocomplete, dropMenu, menu, menuAbove, selected, SelectMsg, updateSelection, clear


## Labels

@docs Label, labelAbove, labelBelow, labelLeft, labelRight, placeholder, hiddenLabel


## Options

@docs Option, Error, errorAbove, errorBelow, disabled, focusOnLoad, autofill, autofillSection, allowSpellcheck

-}

import Element exposing (Attribute, Element, column, row)
import Element.Attributes as Attr
import Element.Events as Events
import Element.Internal.Model as Internal
import Element.Internal.Modify as Modify
import Html
import Html.Attributes
import Html.Events
import Json.Decode as Json
import Style.Internal.Model as Style exposing (Length)
import Style.Internal.Selector


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


textValueAttr : String -> Internal.Attribute variation msg
textValueAttr =
    Attr.toAttr << Html.Attributes.defaultValue


tabindex : Int -> Internal.Attribute variation msg
tabindex =
    Attr.toAttr << Html.Attributes.tabindex


disabledAttr : Bool -> Internal.Attribute variation msg
disabledAttr =
    Attr.toAttr << Html.Attributes.disabled


spellcheckAttr : Bool -> Internal.Attribute variation msg
spellcheckAttr =
    Attr.toAttr << Html.Attributes.spellcheck


readonlyAttr : Bool -> Internal.Attribute variation msg
readonlyAttr =
    Attr.toAttr << Html.Attributes.readonly


autofillAttr : String -> Internal.Attribute variation msg
autofillAttr =
    Attr.attribute "autocomplete"


autofocusAttr : Bool -> Internal.Attribute variation msg
autofocusAttr =
    Attr.toAttr << Html.Attributes.autofocus


hidden : Attribute variation msg
hidden =
    Attr.inlineStyle [ ( "position", "absolute" ), ( "opacity", "0" ) ]


addOptionsAsAttrs : List (Option style variation msg) -> List (Attribute variation1 msg1) -> List (Attribute variation1 msg1)
addOptionsAsAttrs options attrs =
    let
        renderOption option attrs =
            case option of
                Key str ->
                    attrs

                FocusOnLoad ->
                    autofocusAttr True :: attrs

                SpellCheck ->
                    spellcheckAttr True :: attrs

                AutoFill fill ->
                    autofillAttr fill :: attrs

                Disabled ->
                    attrs

                ErrorOpt _ ->
                    attrs
    in
    List.foldr renderOption attrs options


{-| -}
type alias Checkbox style variation msg =
    { onChange : Bool -> msg
    , label : Element style variation msg
    , checked : Bool
    , options : List (Option style variation msg)
    }


{-| Your basic checkbox

    Input.checkbox Checkbox
        []
        { onChange = Check
        , checked = model.checkbox
        , label = el None [] (text "hello!")
        , options = []
        }

-}
checkbox : style -> List (Attribute variation msg) -> Checkbox style variation msg -> Element style variation msg
checkbox style attrs input =
    let
        withDisabled attrs =
            if isDisabled then
                Attr.class "disabled-input" :: disabledAttr True :: attrs
            else
                pointer :: attrs

        withError attrs =
            if not <| List.isEmpty errs then
                Attr.attribute "aria-invalid" "true" :: attrs
            else
                attrs

        forErrors opt =
            case opt of
                ErrorOpt err ->
                    Just err

                _ ->
                    Nothing

        errs =
            List.filterMap forErrors input.options

        isDisabled =
            List.any ((==) Disabled) input.options

        inputElem =
            [ Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (addOptionsAsAttrs input.options << withError << withDisabled)
                        [ type_ "checkbox"
                        , checked input.checked
                        , Events.onCheck input.onChange
                        ]
                , child = Internal.Empty
                , absolutelyPositioned = Nothing
                }
            ]
    in
    applyLabel Nothing Nothing (Attr.spacing 5 :: Attr.verticalCenter :: attrs) (LabelOnRight input.label) errs isDisabled True inputElem


{-| -}
type alias StyledCheckbox style variation msg =
    { onChange : Bool -> msg
    , label : Element style variation msg
    , checked : Bool
    , options : List (Option style variation msg)
    , icon : Bool -> Element style variation msg
    }


{-| A checkbox that allows you to style the actual checkbox:

    Input.styledCheckbox Checkbox
        []
        { onChange = Check
        , checked = model.checkbox
        , label = el None [] (text "hello!")
        , options = []
        , icon =
            -- A function which receives a checked bool
            -- and returns the element that represents the checkbox
            \checked ->
                let
                    checkboxStyle =
                        if checked then
                            CheckboxChecked
                        else
                            Checkbox
                in
                el checkboxStyle [] empty
        }

-}
styledCheckbox : style -> List (Attribute variation msg) -> StyledCheckbox style variation msg -> Element style variation msg
styledCheckbox style attrs input =
    let
        withDisabled attrs =
            if isDisabled then
                Attr.class "disabled-input" :: disabledAttr True :: attrs
            else
                pointer :: attrs

        withError attrs =
            if not <| List.isEmpty errs then
                Attr.attribute "aria-invalid" "true" :: attrs
            else
                attrs

        forErrors opt =
            case opt of
                ErrorOpt err ->
                    Just err

                _ ->
                    Nothing

        errs =
            List.filterMap forErrors input.options

        isDisabled =
            List.any ((==) Disabled) input.options

        inputElem =
            [ Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (addOptionsAsAttrs input.options << withError << withDisabled)
                        [ type_ "checkbox"
                        , checked input.checked
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
    applyLabel Nothing Nothing (Attr.spacing 5 :: Attr.verticalCenter :: attrs) (LabelOnRight input.label) errs isDisabled True inputElem



{- Text Inputs -}


type TextKind
    = Plain
    | Search
    | Password
    | Email
    | TextArea


{-| -}
text : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
text =
    textHelper Plain []


{-| -}
search : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
search =
    textHelper Search []


{-| A password input that allows the browser to autofill.

It's `newPassword` instead of just `password` because it gives the browser a hint on what type of password input it is.

-}
newPassword : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
newPassword =
    textHelper Password [ AutoFill "new-password" ]


{-| -}
currentPassword : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
currentPassword =
    textHelper Password [ AutoFill "current-password" ]


{-| -}
username : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
username =
    textHelper Plain [ AutoFill "username" ]


{-| -}
email : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
email =
    textHelper Email [ AutoFill "email" ]


{-| -}
multiline : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
multiline =
    textHelper TextArea []


{-| -}
textHelper : TextKind -> List (Option style variation msg) -> style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
textHelper kind addedOptions style attrs input =
    let
        options =
            List.foldr combineFill ( [], Nothing ) (addedOptions ++ input.options)
                |> (\( opts, fill ) ->
                        case fill of
                            Nothing ->
                                opts

                            Just allFills ->
                                AutoFill (String.join " " allFills) :: opts
                   )

        combineFill opt ( newOpts, existingFill ) =
            case opt of
                AutoFill fill ->
                    case existingFill of
                        Nothing ->
                            ( newOpts, Just [ fill ] )

                        Just exist ->
                            ( newOpts, Just (fill :: exist) )

                _ ->
                    ( opt :: newOpts, existingFill )

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
            if List.any ((==) Disabled) options then
                Attr.class "disabled-input" :: disabledAttr True :: attrs
            else
                attrs

        withReadonly attrs =
            if List.any ((==) Disabled) options then
                Attr.class "disabled-input" :: readonlyAttr True :: attrs
            else
                attrs

        withSpellCheck attrs =
            if List.any ((==) SpellCheck) options then
                spellcheckAttr True :: attrs
            else
                spellcheckAttr False :: attrs

        key =
            List.filterMap forKey options
                |> List.head

        forKey opt =
            case opt of
                Key str ->
                    Just str

                _ ->
                    Nothing

        forErrors opt =
            case opt of
                ErrorOpt err ->
                    Just err

                _ ->
                    Nothing

        withError attrs =
            if not <| List.isEmpty errors then
                Attr.attribute "aria-invalid" "true" :: attrs
            else
                attrs

        errors =
            List.filterMap forErrors options

        isDisabled =
            List.any ((==) Disabled) options

        kindAsText =
            case kind of
                Plain ->
                    "text"

                Search ->
                    "search"

                Password ->
                    "password"

                Email ->
                    "email"

                TextArea ->
                    "text"

        withAutofocus attrs =
            if List.any ((==) FocusOnLoad) options then
                autofocusAttr True :: attrs
            else
                attrs

        inputElem =
            case kind of
                TextArea ->
                    Internal.Element
                        { node = "textarea"
                        , style = Just style
                        , attrs =
                            (Internal.Width (Style.Fill 1) :: Attr.inlineStyle [ ( "resize", "none" ) ] :: Events.onInput input.onChange :: textValueAttr input.value :: attrs)
                                |> (withPlaceholder >> withReadonly >> withError >> withSpellCheck >> addOptionsAsAttrs options)
                        , child =
                            Internal.Text
                                { decoration = Internal.RawText
                                , inline = False
                                }
                                ""
                        , absolutelyPositioned = Nothing
                        }

                _ ->
                    Internal.Element
                        { node = "input"
                        , style = Just style
                        , attrs =
                            (Internal.Width (Style.Fill 1) :: type_ kindAsText :: Events.onInput input.onChange :: textValueAttr input.value :: attrs)
                                |> (withPlaceholder >> withDisabled >> withError >> addOptionsAsAttrs options)
                        , child = Internal.Empty
                        , absolutelyPositioned = Nothing
                        }
    in
    applyLabel key Nothing [ spacing ] input.label errors isDisabled False [ inputElem ]


{-| -}
type alias Text style variation msg =
    { onChange : String -> msg
    , value : String
    , label : Label style variation msg
    , options : List (Option style variation msg)
    }


{-| -}
type Option style variation msg
    = ErrorOpt (Error style variation msg)
    | Disabled
    | FocusOnLoad
    | AutoFill String
    | SpellCheck
    | Key String


{-| Allow spellcheck for this input. Only works on text based inputs.
-}
allowSpellcheck : Option style variation msg
allowSpellcheck =
    SpellCheck


{-| Give a hint to the browser on what data can be used to autofill this input.

This can be very useful to allow the browser to autofill address and credit card forms.

For more general information check out the [`autocomplete` attribute of `input` elements](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/Input)

-}
autofill : String -> Option style variation msg
autofill =
    AutoFill


{-| -}
autofillSection : String -> Option style variation msg
autofillSection section =
    AutoFill ("section-" ++ section)


{-| Disable an input. This means that the input will not receive focus and can't be changed by the user.

Does not change the styling of the inputs unless they're controlled by the browser like a basic checkbox or standard radio button.

-}
disabled : Option style variation msg
disabled =
    Disabled


{-| This key is needed because of the fix that is used to address [the cursor jumping bug](https://github.com/mdgriffith/style-elements/issues/91).

Style Elements renders a text input using `defaultValue`, but if the value changes in your model, but not as a result of the input `onChange` event, then your input and model will get out of sync.

So, if you manually change the value of a text input in your model, you need to ensure this key changes.

A common way to do this is to maintain increment a counter whenever you manually change the text.

**This option will be removed as soon as this bug is addressed farther upstream.**

So if it feels awkward and like a hack, it's because it is.

-}
textKey : String -> Option style variation msg
textKey =
    Key


{-| Add a key string to a radio option.

This is used to differentiate between separate radio menus.

It's not needed if the text of the labels are unique.

-}
radioKey : String -> Option style variation msg
radioKey =
    Key


{-| -}
type Error style variation msg
    = ErrorBelow (Element style variation msg)
    | ErrorAbove (Element style variation msg)


{-| -}
type Label style variation msg
    = LabelBelow (Element style variation msg)
    | LabelAbove (Element style variation msg)
    | LabelOnRight (Element style variation msg)
    | LabelOnLeft (Element style variation msg)
    | HiddenLabel String
    | PlaceHolder String (Label style variation msg)



-- | FloatingPlaceholder (Element style variation msg)


getLabelText : Label style variation msg -> String
getLabelText label =
    case label of
        LabelBelow el ->
            Modify.getText el

        LabelAbove el ->
            Modify.getText el

        LabelOnRight el ->
            Modify.getText el

        LabelOnLeft el ->
            Modify.getText el

        HiddenLabel str ->
            str

        PlaceHolder str label ->
            getLabelText label


{-| -}
placeholder : { text : String, label : Label style variation msg } -> Label style variation msg
placeholder { text, label } =
    case label of
        PlaceHolder _ existingLabel ->
            PlaceHolder text existingLabel

        x ->
            PlaceHolder text x


{-| -}
hiddenLabel : String -> Label style variation msg
hiddenLabel =
    HiddenLabel


{-| -}
labelLeft : Element style variation msg -> Label style variation msg
labelLeft =
    LabelOnLeft


{-| -}
labelRight : Element style variation msg -> Label style variation msg
labelRight =
    LabelOnRight


{-| -}
labelAbove : Element style variation msg -> Label style variation msg
labelAbove =
    LabelAbove


{-| -}
labelBelow : Element style variation msg -> Label style variation msg
labelBelow =
    LabelBelow


{-| Put the focus on this input when the page loads.

Only one input should ahve this option turned on.

-}
focusOnLoad : Option style variation msg
focusOnLoad =
    FocusOnLoad


{-| -}
errorBelow : Element style variation msg -> Option style variation msg
errorBelow el =
    ErrorOpt <| ErrorBelow <| Modify.addAttr (Attr.attribute "aria-live" "assertive") el


{-| -}
errorAbove : Element style variation msg -> Option style variation msg
errorAbove el =
    ErrorOpt <| ErrorAbove <| Modify.addAttr (Attr.attribute "aria-live" "assertive") el


type alias LabelIntermediate style variation msg =
    { style : Maybe style
    , attrs : List (Attribute variation msg)
    , label : Label style variation msg
    , error : Error style variation msg
    , isDisabled : Bool
    , input : List (Element style variation msg)
    }


type ErrorOrientation style variation msg
    = ErrorAllBelow (List (Element style variation msg))
    | ErrorAllAbove (List (Element style variation msg))
    | ErrorAboveBelow (List (Element style variation msg)) (List (Element style variation msg))


{-| Builds an input element with a label, errors, and a disabled
-}
applyLabel : Maybe String -> Maybe style -> List (Attribute variation msg) -> Label style variation msg -> List (Error style variation msg) -> Bool -> Bool -> List (Element style variation msg) -> Element style variation msg
applyLabel maybeKey style attrs label errors isDisabled hasPointer input =
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
            case maybeKey of
                Nothing ->
                    Internal.Layout
                        { node = "label"
                        , style = style
                        , layout = Style.FlexLayout direction []
                        , attrs =
                            if hasPointer then
                                Internal.Width (Style.Fill 1) :: pointer :: attrs
                            else
                                Internal.Width (Style.Fill 1) :: attrs
                        , children = Internal.Normal children
                        , absolutelyPositioned = Nothing
                        }

                Just key ->
                    Internal.Layout
                        { node = "label"
                        , style = style
                        , layout = Style.FlexLayout direction []
                        , attrs =
                            if hasPointer then
                                Internal.Width (Style.Fill 1) :: pointer :: attrs
                            else
                                Internal.Width (Style.Fill 1) :: attrs
                        , children = Internal.Keyed (List.indexedMap (\i child -> ( key ++ "-" ++ toString i, child )) children)
                        , absolutelyPositioned = Nothing
                        }

        orientedErrors =
            List.foldl
                (\currentError oriented ->
                    case oriented of
                        Nothing ->
                            Just <|
                                case currentError of
                                    ErrorAbove err ->
                                        ErrorAllAbove [ err ]

                                    ErrorBelow err ->
                                        ErrorAllBelow [ err ]

                        Just orientation ->
                            Just <|
                                case orientation of
                                    ErrorAllAbove above ->
                                        case currentError of
                                            ErrorAbove err ->
                                                ErrorAllAbove (err :: above)

                                            ErrorBelow err ->
                                                ErrorAboveBelow [ err ] above

                                    ErrorAllBelow below ->
                                        case currentError of
                                            ErrorAbove err ->
                                                ErrorAboveBelow [ err ] below

                                            ErrorBelow err ->
                                                ErrorAllBelow (err :: below)

                                    ErrorAboveBelow above below ->
                                        case currentError of
                                            ErrorAbove err ->
                                                ErrorAboveBelow (err :: above) below

                                            ErrorBelow err ->
                                                ErrorAboveBelow above (err :: below)
                )
                Nothing
                errors

        orient direction children =
            Internal.Layout
                { node = "div"
                , style = Nothing
                , layout = Style.FlexLayout direction []
                , attrs =
                    if hasPointer then
                        [ pointer, spacing ]
                    else
                        [ spacing ]
                , children = Internal.Normal children
                , absolutelyPositioned = Nothing
                }
    in
    case label of
        PlaceHolder placeholder newLabel ->
            -- placeholder is set in a previous function
            applyLabel maybeKey style attrs newLabel errors isDisabled hasPointer input

        HiddenLabel title ->
            let
                labeledInput =
                    input
                        |> List.map (Modify.addAttr (Attr.attribute "title" title))
            in
            case orientedErrors of
                Nothing ->
                    labelContainer Style.Down labeledInput

                Just (ErrorAllAbove above) ->
                    labelContainer Style.Down (orient Style.GoRight above :: labeledInput)

                Just (ErrorAllBelow below) ->
                    labelContainer Style.Down (labeledInput ++ [ orient Style.GoRight below ])

                Just (ErrorAboveBelow above below) ->
                    labelContainer Style.Down (orient Style.GoRight above :: labeledInput ++ [ orient Style.GoRight below ])

        LabelAbove lab ->
            case orientedErrors of
                Nothing ->
                    labelContainer Style.Down (lab :: input)

                Just (ErrorAllAbove above) ->
                    labelContainer Style.Down (orient Style.GoRight (lab :: above) :: input)

                Just (ErrorAllBelow below) ->
                    labelContainer Style.Down (lab :: input ++ [ orient Style.GoRight below ])

                Just (ErrorAboveBelow above below) ->
                    labelContainer Style.Down (orient Style.GoRight (lab :: above) :: input ++ [ orient Style.GoRight below ])

        LabelBelow lab ->
            case orientedErrors of
                Nothing ->
                    labelContainer Style.Down (input ++ [ lab ])

                Just (ErrorAllAbove above) ->
                    labelContainer Style.Down (orient Style.GoRight above :: input ++ [ lab ])

                Just (ErrorAllBelow below) ->
                    labelContainer Style.Down (input ++ [ orient Style.GoRight (lab :: below) ])

                Just (ErrorAboveBelow above below) ->
                    labelContainer Style.Down (orient Style.GoRight above :: input ++ [ orient Style.GoRight (lab :: below) ])

        LabelOnRight lab ->
            case orientedErrors of
                Nothing ->
                    labelContainer Style.GoRight (input ++ [ lab ])

                Just (ErrorAllAbove above) ->
                    labelContainer Style.Down (above ++ [ orient Style.GoRight (input ++ [ lab ]) ])

                Just (ErrorAllBelow below) ->
                    labelContainer Style.Down (orient Style.GoRight (input ++ [ lab ]) :: below)

                Just (ErrorAboveBelow above below) ->
                    labelContainer Style.Down (above ++ [ orient Style.GoRight (input ++ [ lab ]) ] ++ below)

        LabelOnLeft lab ->
            case orientedErrors of
                Nothing ->
                    labelContainer Style.GoRight (lab :: input)

                Just (ErrorAllAbove above) ->
                    labelContainer Style.Down (above ++ [ orient Style.GoRight (lab :: input) ])

                Just (ErrorAllBelow below) ->
                    labelContainer Style.Down (orient Style.GoRight (lab :: input) :: below)

                Just (ErrorAboveBelow above below) ->
                    labelContainer Style.Down (above ++ [ orient Style.GoRight (lab :: input) ] ++ below)



{- Radio Options -}


{-| Add choices to your radio and select menus.
-}
type Choice value style variation msg
    = Choice value (Element style variation msg)
    | ChoiceWith value (ChoiceState -> Element style variation msg)


{-| -}
type ChoiceState
    = Idle
    | Focused
    | Selected
    | SelectedInBox


{-| -}
choice : value -> Element style variation msg -> Choice value style variation msg
choice =
    Choice


{-| -}
styledChoice : value -> (Bool -> Element style variation msg) -> Choice value style variation msg
styledChoice value selected =
    let
        choose state =
            case state of
                Focused ->
                    selected False

                Selected ->
                    selected True

                SelectedInBox ->
                    selected True

                Idle ->
                    selected False
    in
    ChoiceWith value choose


{-| -}
styledSelectChoice : value -> (ChoiceState -> Element style variation msg) -> Choice value style variation msg
styledSelectChoice =
    ChoiceWith


getOptionValue : Choice a style variation msg -> a
getOptionValue opt =
    case opt of
        Choice value _ ->
            value

        ChoiceWith value _ ->
            value


{-| -}
type alias Radio option style variation msg =
    { onChange : option -> msg
    , choices : List (Choice option style variation msg)
    , selected : Maybe option
    , label : Label style variation msg
    , options : List (Option style variation msg)
    }


{-|

    Input.radio Field
        [ padding 10
        , spacing 20
        ]
        { onChange = ChooseLunch
        , selected = Just model.lunch
        , label = Input.labelAbove (text "Lunch")
        , options = []
        , choices =
            [ Input.styledChoice Burrito <|
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
            , Input.choice Taco (text "Taco!")
            , Input.choice Gyro (text "Gyro")
            ]
        }

-}
radio : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radio style attrs input =
    let
        forErrors opt =
            case opt of
                ErrorOpt err ->
                    Just err

                _ ->
                    Nothing

        errs =
            List.filterMap forErrors input.options

        isDisabled =
            List.any ((==) Disabled) input.options

        forKeys opt =
            case opt of
                Key key ->
                    Just key

                _ ->
                    Nothing

        key =
            input.options
                |> List.filterMap forKeys
                |> String.join "-"

        inputElem =
            radioHelper Vertical
                style
                attrs
                { selection =
                    Single
                        { selected = input.selected
                        , onChange = input.onChange
                        }
                , choices = input.choices
                , label = input.label
                , disabled = isDisabled
                , errors = errs
                , key =
                    if key == "" then
                        Nothing
                    else
                        Just key
                }
    in
    applyLabel Nothing Nothing [] input.label errs isDisabled (not isDisabled) [ inputElem ]


{-| Same as `radio`, but arranges the choices in a row instead of a column
-}
radioRow : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radioRow style attrs config =
    let
        forErrors opt =
            case opt of
                ErrorOpt err ->
                    Just err

                _ ->
                    Nothing

        errs =
            List.filterMap forErrors config.options

        isDisabled =
            List.any ((==) Disabled) config.options

        forKeys opt =
            case opt of
                Key key ->
                    Just key

                _ ->
                    Nothing

        key =
            config.options
                |> List.filterMap forKeys
                |> String.join "-"

        input =
            radioHelper Horizontal
                style
                attrs
                { selection =
                    Single
                        { selected = config.selected
                        , onChange = config.onChange
                        }
                , choices = config.choices
                , label = config.label
                , disabled = isDisabled
                , errors = errs
                , key =
                    if key == "" then
                        Nothing
                    else
                        Just key
                }
    in
    applyLabel Nothing Nothing [] config.label errs isDisabled (not isDisabled) [ input ]



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
    , choices : List (Choice option style variation msg)
    , label : Label style variation msg
    , disabled : Bool
    , errors : List (Error style variation msg)
    , key : Maybe String
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
            case config.key of
                Nothing ->
                    getLabelText config.label

                Just key ->
                    key

        valueIsSelected val =
            case config.selection of
                Single single ->
                    Just val == single.selected

                Multi multi ->
                    List.member val multi.selected

        addSelection val attrs =
            attrs ++ isSelected val

        withDisabled attrs =
            if config.disabled then
                disabledAttr True :: attrs
            else
                pointer :: attrs

        isSelected val =
            case config.selection of
                Single single ->
                    let
                        isSelected =
                            Just val == single.selected
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
                Choice val el ->
                    let
                        textValue =
                            case config.key of
                                Nothing ->
                                    Modify.getText el

                                Just key ->
                                    key ++ "-" ++ Modify.getText el

                        input =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    (withDisabled << addSelection val)
                                        [ type_ "radio"
                                        , name group
                                        , valueAttr textValue
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
                        , attrs =
                            if config.disabled then
                                Attr.spacing 5 :: Modify.getAttrs el
                            else
                                pointer :: Attr.spacing 5 :: Modify.getAttrs el
                        , children = Internal.Normal [ input, literalLabel ]
                        , absolutelyPositioned = Nothing
                        }

                ChoiceWith val view ->
                    let
                        viewed =
                            view <|
                                if valueIsSelected val then
                                    Selected
                                else
                                    Idle

                        textValue =
                            case config.key of
                                Nothing ->
                                    Modify.getText (view Selected)

                                Just key ->
                                    key ++ "-" ++ Modify.getText (view Selected)

                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    (withDisabled << addSelection val)
                                        [ type_ "radio"
                                        , hidden
                                        , name group
                                        , valueAttr textValue
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
                        , attrs =
                            if config.disabled then
                                Attr.spacing 5 :: Modify.getAttrs viewed
                            else
                                pointer :: Attr.spacing 5 :: Modify.getAttrs viewed
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
            row style (Attr.spacing 10 :: attrs) (List.map renderOption config.choices)

        Vertical ->
            column style (Attr.spacing 10 :: attrs) (List.map renderOption config.choices)


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


type Menu option style variation msg
    = MenuUp style (List (Attribute variation msg)) (List (Choice option style variation msg))
    | MenuDown style (List (Attribute variation msg)) (List (Choice option style variation msg))


{-| Create a dropdown menu.

This is used with `Input.select`

-}
menu : style -> List (Attribute variation msg) -> List (Choice option style variation msg) -> Menu option style variation msg
menu =
    MenuDown


{-| A dropdown menu that goes up! A dropup!
-}
menuAbove : style -> List (Attribute variation msg) -> List (Choice option style variation msg) -> Menu option style variation msg
menuAbove =
    MenuUp


{-| This function needs to be paired with either `Input.autocomplete` or `Input.dropMenu`.

    Input.select Field
        [ padding 10
        , spacing 20
        ]
        { label = Input.labelAbove <| text "Lunch"

        -- model.selection is some state(value, a Msg constructor, and the focus) we store in our model.
        -- It can be created using Input.autocomplete or Input.dropMenu
        -- Check out the Form.elm example to see a complete version.
        , with = model.selection
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

-}
select : style -> List (Attribute variation msg) -> Select option style variation msg -> Element style variation msg
select style attrs input =
    case input.with of
        Autocomplete auto ->
            searchSelect style
                attrs
                { max = input.max
                , menu = input.menu
                , label = input.label
                , options = input.options
                , onUpdate = auto.onUpdate
                , isOpen = auto.isOpen
                , selected = auto.selected
                , query = auto.query
                , focus = auto.focus
                }

        SelectMenu menu ->
            selectMenu style
                attrs
                { max = input.max
                , menu = input.menu
                , label = input.label
                , options = input.options
                , onUpdate = menu.onUpdate
                , isOpen = menu.isOpen
                , selected = menu.selected
                }


type alias SelectMenuValues option style variation msg =
    { max : Int
    , menu : Menu option style variation msg
    , label : Label style variation msg
    , options : List (Option style variation msg)
    , onUpdate : SelectMsg option -> msg
    , isOpen : Bool
    , selected : Maybe option
    }


type alias SearchMenu option style variation msg =
    { max : Int
    , menu : Menu option style variation msg
    , label : Label style variation msg
    , options : List (Option style variation msg)
    , query : String
    , selected : Maybe option
    , focus : Maybe option
    , onUpdate : SelectMsg option -> msg
    , isOpen : Bool
    }


{-| A dropdown input.

    Input.select Field
        [ padding 10
        , spacing 20
        ]
        { label = Input.labelAbove (text "Lunch")

        -- in this case, model.selectmenu is
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

-}
selectMenu : style -> List (Attribute variation msg) -> SelectMenuValues option style variation msg -> Element style variation msg
selectMenu style attrs input =
    let
        ( menuAbove, menuStyle, menuAttrs, choices ) =
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
                    Choice _ el ->
                        Just el

                    ChoiceWith _ view ->
                        Just <| view SelectedInBox
            else
                Nothing

        selectedText =
            case input.selected of
                Nothing ->
                    placeholderText

                Just selected ->
                    choices
                        |> List.filterMap (getSelectedLabel selected)
                        |> List.head
                        |> Maybe.withDefault placeholderText

        forPadding attr =
            case attr of
                Internal.Padding _ _ _ _ ->
                    True

                _ ->
                    False

        forSpacing attr =
            case attr of
                Internal.Spacing _ _ ->
                    True

                _ ->
                    False

        ( attrsWithSpacing, attrsWithoutSpacing ) =
            List.partition forSpacing attrs

        parentPadding =
            List.filter forPadding attrs

        forErrors opt =
            case opt of
                ErrorOpt err ->
                    Just err

                _ ->
                    Nothing

        errors =
            List.filterMap forErrors input.options

        isDisabled =
            List.any ((==) Disabled) input.options

        bar =
            Internal.Layout
                { node = "div"
                , style = Just style
                , layout = Style.FlexLayout Style.GoRight []
                , attrs =
                    if isDisabled then
                        Attr.verticalCenter
                            :: Attr.spread
                            :: Attr.width Attr.fill
                            :: attrsWithoutSpacing
                    else if input.isOpen && input.selected /= Nothing then
                        Events.onMouseDown (input.onUpdate CloseMenu)
                            :: pointer
                            :: Attr.verticalCenter
                            :: Attr.spread
                            :: Attr.width Attr.fill
                            :: attrsWithoutSpacing
                    else if not input.isOpen && input.selected /= Nothing then
                        Events.onMouseDown (input.onUpdate OpenMenu)
                            :: pointer
                            :: Attr.verticalCenter
                            :: Attr.spread
                            :: Attr.width Attr.fill
                            :: attrsWithoutSpacing
                    else
                        pointer
                            :: Attr.verticalCenter
                            :: Attr.spread
                            :: Attr.width Attr.fill
                            :: attrsWithoutSpacing
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
                choices

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
                Choice val el ->
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
                            if isDisabled then
                                Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected
                            else
                                Events.onClick (input.onUpdate (Batch [ CloseMenu, SelectValue (Just val) ]))
                                    :: Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected
                    in
                    el
                        |> Modify.addAttrList additional

                ChoiceWith val view ->
                    let
                        isSelected =
                            if Just val == input.selected then
                                Attr.attribute "aria-selected" "true"
                                    :: parentPadding
                            else
                                Attr.attribute "aria-selected" "false" :: parentPadding

                        additional =
                            if isDisabled then
                                Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected
                            else
                                Events.onClick (input.onUpdate (Batch [ CloseMenu, SelectValue (Just val) ]))
                                    :: Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected

                        viewState =
                            if Just val == input.selected then
                                Selected
                            else
                                Idle
                    in
                    view viewState
                        |> Modify.addAttrList additional

        fullElement =
            Internal.Element
                { node = "div"
                , style = Nothing
                , attrs =
                    List.filterMap identity
                        [ Just (Attr.width Attr.fill)
                        , Just (Attr.attribute "role" "menu")
                        , if not isDisabled then
                            Just
                                (tabindex 0)
                          else
                            Nothing
                        , Just (Attr.inlineStyle [ ( "z-index", "20" ) ])
                        , if isDisabled then
                            Nothing
                          else
                            Just
                                (Attr.toAttr <|
                                    onFocusOut
                                        (input.onUpdate CloseMenu)
                                )
                        , if isDisabled then
                            Nothing
                          else
                            Just
                                (Attr.toAttr <|
                                    onFocusIn
                                        (input.onUpdate OpenMenu)
                                )
                        , if isDisabled then
                            Nothing
                          else
                            Just <|
                                onKeyLookup <|
                                    \key ->
                                        if key == enter then
                                            Just <|
                                                input.onUpdate
                                                    (if input.isOpen then
                                                        CloseMenu
                                                     else
                                                        OpenMenu
                                                    )
                                        else if key == downArrow && not input.isOpen then
                                            Just <| input.onUpdate OpenMenu
                                        else if key == downArrow && input.isOpen then
                                            Maybe.map
                                                (\x ->
                                                    input.onUpdate (SelectValue (Just x))
                                                )
                                                next
                                        else if key == upArrow && not input.isOpen then
                                            Just <| input.onUpdate OpenMenu
                                        else if key == upArrow && input.isOpen then
                                            Maybe.map
                                                (\x ->
                                                    input.onUpdate (SelectValue (Just x))
                                                )
                                                prev
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
                    (if input.isOpen && not isDisabled then
                        [ column menuStyle
                            (Attr.inlineStyle [ ( "z-index", "20" ), ( "background-color", "white" ) ]
                                :: pointer
                                -- :: Events.onClick (input.onUpdate CloseMenu)
                                :: Attr.width Attr.fill
                                :: menuAttrs
                            )
                            (List.map renderOption choices)
                        ]
                     else
                        []
                    )
    in
    applyLabel Nothing Nothing attrsWithSpacing input.label errors isDisabled (not isDisabled) [ fullElement ]


{-| -}
type alias Select option style variation msg =
    { with : SelectWith option msg
    , max : Int
    , menu : Menu option style variation msg
    , label : Label style variation msg
    , options : List (Option style variation msg)
    }


{-| -}
type SelectWith option msg
    = Autocomplete
        { query : String
        , selected : Maybe option
        , focus : Maybe option
        , onUpdate : SelectMsg option -> msg
        , isOpen : Bool
        }
    | SelectMenu
        { onUpdate : SelectMsg option -> msg
        , isOpen : Bool
        , selected : Maybe option
        }


{-| Create a `select` menu which shows options that are filtered by the text entered.

This is the part which goes in your model.

You'll need to update it using `Input.updateSelection`.

Once you have this in your model, you can extract the current selected value from it using `Input.selected model.autocompleteState`.

-}
autocomplete : Maybe option -> (SelectMsg option -> msg) -> SelectWith option msg
autocomplete selected onUpdate =
    Autocomplete
        { query = ""
        , selected = selected
        , focus = selected
        , onUpdate = onUpdate
        , isOpen = False
        }


{-| Create a `select` menu which shows all options and allows the user to select one.

Use this if you only have 3-5 options. If you have a ton of options, use `Input.autocomplete` instead!

Once you have this in your model, you can extract the current selected value from it using `Input.selected model.dropMenuState`.

-}
dropMenu : Maybe option -> (SelectMsg option -> msg) -> SelectWith option msg
dropMenu selected onUpdate =
    SelectMenu
        { selected = selected
        , onUpdate = onUpdate
        , isOpen = False
        }


{-| Get the selected value from an `autocomplete` or a `dropMenu` type that is used for your `Input.select` element.
-}
selected : SelectWith option msg -> Maybe option
selected select =
    case select of
        Autocomplete auto ->
            auto.selected

        SelectMenu menu ->
            menu.selected


{-| -}
type SelectMsg opt
    = OpenMenu
    | CloseMenu
    | SetQuery String
    | SetFocus (Maybe opt)
    | SelectValue (Maybe opt)
    | SelectFocused
    | Clear
    | Batch (List (SelectMsg opt))


{-| Clear a selection.
-}
clear : SelectWith option msg -> SelectWith option msg
clear select =
    case select of
        Autocomplete auto ->
            Autocomplete
                { query = ""
                , selected = Nothing
                , focus = Nothing
                , onUpdate = auto.onUpdate
                , isOpen = False
                }

        SelectMenu menu ->
            SelectMenu
                { selected = Nothing
                , onUpdate = menu.onUpdate
                , isOpen = False
                }


{-| -}
updateSelection : SelectMsg option -> SelectWith option msg -> SelectWith option msg
updateSelection msg select =
    case msg of
        OpenMenu ->
            case select of
                Autocomplete auto ->
                    Autocomplete
                        { auto | isOpen = True }

                SelectMenu auto ->
                    SelectMenu
                        { auto | isOpen = True }

        CloseMenu ->
            case select of
                Autocomplete auto ->
                    Autocomplete
                        { auto | isOpen = False }

                SelectMenu auto ->
                    SelectMenu
                        { auto | isOpen = False }

        SetQuery query ->
            case select of
                Autocomplete auto ->
                    Autocomplete
                        { auto
                            | query = query
                            , isOpen = True
                            , selected =
                                if query == "" then
                                    auto.selected
                                else
                                    Nothing
                        }

                SelectMenu auto ->
                    SelectMenu
                        auto

        SetFocus val ->
            case select of
                Autocomplete auto ->
                    Autocomplete
                        { auto
                            | focus = val
                        }

                SelectMenu auto ->
                    SelectMenu
                        auto

        SelectValue val ->
            case select of
                Autocomplete auto ->
                    Autocomplete
                        { auto
                            | selected = val
                            , query = ""
                        }

                SelectMenu auto ->
                    SelectMenu
                        { auto
                            | selected = val
                        }

        SelectFocused ->
            case select of
                Autocomplete auto ->
                    Autocomplete
                        { auto
                            | selected = auto.focus
                            , query = ""
                        }

                SelectMenu auto ->
                    SelectMenu
                        auto

        Clear ->
            case select of
                Autocomplete auto ->
                    Autocomplete
                        { auto
                            | query = ""
                            , isOpen = True
                            , selected = Nothing
                            , focus = Nothing
                        }

                SelectMenu auto ->
                    SelectMenu
                        { auto | selected = Nothing }

        Batch msgs ->
            List.foldl updateSelection select msgs


defaultPadding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float ) -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
defaultPadding ( mW, mX, mY, mZ ) ( w, x, y, z ) =
    ( Maybe.withDefault w mW
    , Maybe.withDefault x mX
    , Maybe.withDefault y mY
    , Maybe.withDefault z mZ
    )


{-|

    selection is empty, query is empty, is focused
        -> show placeholder or subtitution text
        -> Open menu, show all results


    selection is empty, query is growing
        -> Show all matching results
        -> Highlight the first one
        -> Arrow Navigation
        -> Enter
            -> Select currently highlighted
            -> Clear query
            -> Close menu

    selection is made
        -> clear query
        -> Overlay selection on search area

-}
searchSelect : style -> List (Attribute variation msg) -> SearchMenu option style variation msg -> Element style variation msg
searchSelect style attrs input =
    let
        forErrors opt =
            case opt of
                ErrorOpt err ->
                    Just err

                _ ->
                    Nothing

        errors =
            List.filterMap forErrors input.options

        isDisabled =
            List.any ((==) Disabled) input.options

        ( menuAbove, menuStyle, menuAttrs, choices ) =
            case input.menu of
                MenuUp menuStyle menuAttrs menuOptions ->
                    ( True, menuStyle, menuAttrs, menuOptions )

                MenuDown menuStyle menuAttrs menuOptions ->
                    ( False, menuStyle, menuAttrs, menuOptions )

        placeholderText =
            case input.selected of
                Nothing ->
                    case input.label of
                        PlaceHolder text _ ->
                            text

                        _ ->
                            "Search..."

                _ ->
                    ""

        onlySpacing attr =
            case attr of
                Internal.Spacing x y ->
                    True

                _ ->
                    False

        ( attrsWithSpacing, attrsWithoutSpacing ) =
            List.partition onlySpacing attrs

        forPadding attr =
            case attr of
                Internal.Padding t r b l ->
                    Just ( t, r, b, l )

                _ ->
                    Nothing

        forSpacing attr =
            case attr of
                Internal.Spacing x y ->
                    Just ( x, y )

                _ ->
                    Nothing

        ( xSpacing, ySpacing ) =
            attrs
                |> List.filterMap forSpacing
                |> List.head
                |> Maybe.withDefault ( 0, 0 )

        ( ppTop, ppRight, ppBottom, ppLeft ) =
            attrs
                |> List.filterMap forPadding
                |> List.head
                |> Maybe.map (flip defaultPadding ( 0, 0, 0, 0 ))
                |> Maybe.withDefault ( 0, 0, 0, 0 )

        parentPadding =
            Internal.Padding (Just ppTop) (Just ppRight) (Just ppBottom) (Just ppLeft)

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
                { selected = input.focus
                , found = False
                , prev = Nothing
                , next = Nothing
                , first = Nothing
                , last = Nothing
                }
                (List.filter (matchesQuery input.query) choices)

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

        choiceText choice =
            case choice of
                Choice _ el ->
                    Modify.getTextList el

                ChoiceWith _ view ->
                    Modify.getTextList (view Idle)

        matchesQuery query opt =
            if query == "" then
                True
            else
                opt
                    |> choiceText
                    |> List.any (\str -> String.startsWith ((String.toLower << String.trimLeft) query) (String.toLower <| String.trimLeft str))

        getFocus query =
            choices
                |> List.filter (matchesQuery query)
                |> List.head
                |> Maybe.map getOptionValue

        renderOption option =
            case option of
                Choice val el ->
                    let
                        isSelected =
                            if Just val == input.selected then
                                [ Attr.attribute "aria-selected" "true"
                                , Attr.inlineStyle [ ( "background-color", "rgba(0,0,0,0.05)" ) ]
                                , parentPadding
                                ]
                            else if Just val == input.focus then
                                [ Attr.attribute "aria-selected" "false"
                                , Attr.inlineStyle [ ( "background-color", "rgba(0,0,0,0.03)" ) ]
                                , parentPadding
                                ]
                            else
                                [ Attr.attribute "aria-selected" "false", parentPadding ]

                        additional =
                            if isDisabled then
                                Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected
                            else
                                Events.onMouseEnter (input.onUpdate <| SetFocus (Just val))
                                    :: Events.onClick (input.onUpdate (Batch [ SetFocus (Just val), SelectFocused, CloseMenu ]))
                                    :: Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected
                    in
                    el
                        |> Modify.addAttrList additional

                ChoiceWith val view ->
                    let
                        isSelected =
                            if Just val == input.selected then
                                [ Attr.attribute "aria-selected" "true"
                                , Attr.inlineStyle [ ( "background-color", "rgba(0,0,0,0.05)" ) ]
                                , parentPadding
                                ]
                            else if Just val == input.focus then
                                [ Attr.attribute "aria-selected" "false"
                                , Attr.inlineStyle [ ( "background-color", "rgba(0,0,0,0.03)" ) ]
                                , parentPadding
                                ]
                            else
                                [ Attr.attribute "aria-selected" "false", parentPadding ]

                        additional =
                            if isDisabled then
                                Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected
                            else
                                Events.onMouseEnter (input.onUpdate <| SetFocus (Just val))
                                    :: Events.onClick (input.onUpdate (Batch [ SetFocus (Just val), SelectFocused, CloseMenu ]))
                                    :: Internal.Expand
                                    :: Attr.attribute "role" "menuitemradio"
                                    :: isSelected

                        selectedState =
                            if Just val == input.selected then
                                Selected
                            else if Just val == input.focus then
                                Focused
                            else
                                Idle
                    in
                    view selectedState
                        |> Modify.addAttrList additional

        matches =
            choices
                |> List.filter (matchesQuery input.query)
                |> List.take input.max
                |> List.map renderOption

        fullElement =
            Internal.Element
                { node = "div"
                , style = Nothing
                , attrs =
                    List.filterMap identity
                        [ Just (Attr.width Attr.fill)
                        , Just (Attr.inlineStyle [ ( "z-index", "20" ) ])
                        , if isDisabled then
                            Nothing
                          else
                            Just <|
                                onKeyLookup <|
                                    \key ->
                                        if (key == delete || key == backspace) && input.selected /= Nothing then
                                            Just <| input.onUpdate Clear
                                        else if key == tab then
                                            Just <| input.onUpdate SelectFocused
                                        else if key == enter then
                                            if input.isOpen then
                                                Just <| input.onUpdate (Batch [ CloseMenu, SelectFocused ])
                                            else
                                                Just <| input.onUpdate OpenMenu
                                        else if key == downArrow && not input.isOpen then
                                            Just <| input.onUpdate OpenMenu
                                        else if key == downArrow && input.isOpen then
                                            Maybe.map
                                                (input.onUpdate << SetFocus << Just)
                                                next
                                        else if key == upArrow && not input.isOpen then
                                            Just <| input.onUpdate OpenMenu
                                        else if key == upArrow && input.isOpen then
                                            Maybe.map
                                                (input.onUpdate << SetFocus << Just)
                                                prev
                                        else
                                            Nothing
                        ]
                , child =
                    Internal.Layout
                        { node = "div"
                        , style = Nothing
                        , layout = Style.FlexLayout Style.GoRight []
                        , attrs =
                            Attr.inlineStyle [ ( "cursor", "text" ) ]
                                :: attrsWithoutSpacing
                        , children =
                            Internal.Normal
                                [ case input.selected of
                                    Nothing ->
                                        Element.text ""

                                    Just sel ->
                                        choices
                                            |> List.filter (\opt -> sel == getOptionValue opt)
                                            |> List.map
                                                (\opt ->
                                                    case opt of
                                                        Choice _ el ->
                                                            el

                                                        ChoiceWith _ view ->
                                                            view SelectedInBox
                                                )
                                            |> List.head
                                            |> Maybe.withDefault (Element.text "")
                                , Internal.Element
                                    { node = "input"
                                    , style = Nothing
                                    , attrs =
                                        List.filterMap identity
                                            [ Just <| Attr.toAttr (Html.Attributes.placeholder placeholderText)
                                            , Just <| Attr.width Attr.fill
                                            , if isDisabled then
                                                Just (disabledAttr True)
                                              else
                                                Nothing
                                            , if isDisabled then
                                                Nothing
                                              else
                                                Just <|
                                                    Attr.toAttr
                                                        (onFocusOut
                                                            (input.onUpdate (Batch [ SelectFocused, CloseMenu ]))
                                                        )
                                            , if isDisabled then
                                                Nothing
                                              else
                                                Just <|
                                                    Attr.toAttr
                                                        (onFocusIn
                                                            (input.onUpdate OpenMenu)
                                                        )
                                            , Just <| Attr.attribute "role" "menu"
                                            , Just <| type_ "text"
                                            , Just <| Attr.toAttr (Html.Attributes.class "focus-override")
                                            , if isDisabled then
                                                Nothing
                                              else
                                                Just <|
                                                    Events.onInput
                                                        (\q ->
                                                            input.onUpdate
                                                                (Batch
                                                                    [ SetQuery q
                                                                    , SetFocus (getFocus q)
                                                                    ]
                                                                )
                                                        )
                                            , Just <| valueAttr input.query
                                            ]
                                    , child = Internal.Empty
                                    , absolutelyPositioned = Nothing
                                    }
                                , Internal.Element
                                    { node = "div"
                                    , style = Just style
                                    , attrs =
                                        Attr.width (Style.Calc 100 0)
                                            :: Attr.toAttr (Html.Attributes.class "alt-icon")
                                            :: Attr.inlineStyle
                                                [ ( "height", "100%" )
                                                , ( "position", "absolute" )
                                                , ( "top", "0" )
                                                , ( "left", "0" )
                                                ]
                                            :: []
                                    , child = Internal.Empty
                                    , absolutelyPositioned = Nothing
                                    }
                                ]
                        , absolutelyPositioned = Nothing
                        }
                , absolutelyPositioned = Nothing
                }
                |> (if menuAbove then
                        Element.above
                    else
                        Element.below
                   )
                    (if input.isOpen && not (List.isEmpty matches) && not isDisabled && (input.selected == Nothing) then
                        [ column menuStyle
                            (Attr.inlineStyle [ ( "z-index", "20" ), ( "background-color", "white" ) ]
                                :: pointer
                                :: Attr.width Attr.fill
                                :: menuAttrs
                            )
                            matches
                        ]
                     else
                        []
                    )
    in
    applyLabel Nothing Nothing ([ Attr.inlineStyle [ ( "cursor", "auto" ) ] ] ++ attrsWithSpacing) input.label errors isDisabled False [ fullElement ]


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


tab : Int
tab =
    9


delete : Int
delete =
    8


backspace : Int
backspace =
    46


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
    Events.on "keydown" isKey


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
    Events.on "keydown" isKey


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
