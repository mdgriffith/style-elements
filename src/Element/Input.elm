module Element.Input
    exposing
        ( checkbox
        , checkboxWith
        , option
        , optionWith
        , radio
        , radioRow
        , radioGrid
        , GridOption
        , RadioGrid
        , text
        , multiline
        , search
        , email
        , password
        , label
        )

{-| Elements for creating forms.

@docs label, text, multiline, search, email, password

@docs checkbox, checkboxWith

@docs radio, radioRow, option, optionWith

@docs radioGrid, Radiogrid, GridOption, gridOption, gridOptionWith

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


{- Attributes -}


type_ =
    Attr.toAttr << Html.Attributes.type_


checked =
    Attr.toAttr << Html.Attributes.checked


name =
    Attr.toAttr << Html.Attributes.name


value =
    Attr.toAttr << Html.Attributes.value


{-| -}
form : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
form style attrs el =
    Modify.setNode "form" <| Element.el style attrs el



-- submitButton (Does a submit button have accessibility concerns?)
{-
   button
   autocomplete (?)
   select (better name?)

   General Patterns

   input -> uses default styling
   inputWith -> hides the default element and replaces with custom element

   onChange events are mandatory
   labeling is mandatory

   Form elements take the form of:

       inputFn : style -> List Attrs -> { record with data }

       -- example
       checkbox : style -> List Attrs -> { onChange : (Bool -> Msg), value : Bool }


        text MyStyle []
            { onChange = UpdateSearch
            , value = "Hi!"
            }
            |> autocomplete AutoStyle []
                { focus = OpaqueAutoFocusType
                , options =
                    [ suggestion "Bye!" (text "Bye!")
                    , suggestion "Bye!" (text "Uhh, lunchtime")
                    ]
                }


   ?
      does button type="submit" have accessibility implications?



    Input.text inputStyle []
        { onChange = UpdateSearch
        , value = "Hi!"
        }
        |> Input.error False
            (text << String.join ", ")
        |> Input.label style [] (text "First Name")



-}


{-| -}
text : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
text elem attrs input =
    Input LabelAbove <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (type_ "text" :: value input.value :: Events.onInput input.onChange :: attrs)
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


{-| -}
type AutoComplete
    = AutoCompelte


{-| -}
type alias AutoCompleteConfig style variation msg =
    { focus : AutoComplete
    , max : Int
    , option : String -> Bool -> Element style variation msg
    }


{-| -}
autocomplete : style -> List (Attribute variation msg) -> AutoCompleteConfig style variation msg -> Input style variation msg -> Input style variation msg
autocomplete style attrs { focus, max, option } input =
    input


{-| -}
hint : Bool -> style -> List (Attribute variation msg) -> Element style variation msg -> Input style variation msg -> Input style variation msg
hint on style attrs el input =
    input


{-| Put a label above any of the text inputs.

The spacing property on the label will be the spacing between the label and the input element.

All other properties will apply normally to the label element

-}
label : style -> List (Attribute variation msg) -> Element style variation msg -> Input style variation msg -> Element style variation msg
label style attrs labelElement (Input labelPosHint inputElems) =
    let
        forSpacing posAttr =
            case posAttr of
                Internal.Spacing x y ->
                    True

                _ ->
                    False
    in
        case labelPosHint of
            LabelAbove ->
                Internal.Layout
                    { node = "label"
                    , style = Just style
                    , layout = Style.FlexLayout Style.Down []
                    , attrs = attrs
                    , children = Internal.Normal (labelElement :: inputElems)
                    , absolutelyPositioned = Nothing
                    }

            LabelOnRight ->
                Internal.Layout
                    { node = "label"
                    , style = Just style
                    , layout = Style.FlexLayout Style.GoRight []
                    , attrs =
                        Attr.spacing 5
                            :: Attr.verticalCenter
                            :: attrs
                    , children = Internal.Normal (inputElems ++ [ labelElement ])
                    , absolutelyPositioned = Nothing
                    }


{-| Rendered as a `textarea`.

Will automatically be the height and width of the content unless a height/width is set.

-}
multiline : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
multiline elem attrs { value, onChange } =
    Input LabelAbove <|
        [ Internal.Element
            { node = "textarea"
            , style = Just elem
            , attrs = (Attr.inlineStyle [ ( "resize", "none" ) ] :: Events.onInput onChange :: attrs)
            , child = Element.text value
            , absolutelyPositioned = Nothing
            }
        ]


{-| -}
password : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
password elem attrs input =
    Input LabelAbove <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (type_ "password" :: value input.value :: Events.onInput input.onChange :: attrs)
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


{-| -}
email : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
email elem attrs input =
    Input LabelAbove <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (type_ "email" :: value input.value :: Events.onInput input.onChange :: attrs)
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


{-| -}
search : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
search elem attrs input =
    Input LabelAbove <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (Attr.attribute "role" "search" :: type_ "search" :: value input.value :: Events.onInput input.onChange :: attrs)
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


type Input style variation msg
    = Input LabelPositionHint (List (Element style variation msg))


type LabelPositionHint
    = LabelAbove
    | LabelOnRight


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
checkbox : { onChange : Bool -> msg, checked : Bool } -> Input style variation msg
checkbox input =
    Input LabelOnRight
        [ Internal.Element
            { node = "input"
            , style = Nothing
            , attrs =
                (type_ "checkbox"
                    :: checked input.checked
                    :: Events.onCheck input.onChange
                    :: []
                )
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


{-| -}
checkboxWith : { onChange : Bool -> msg, checked : Bool, icon : Bool -> Element style variation msg } -> Input style variation msg
checkboxWith input =
    let
        inputElem =
            Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (type_ "checkbox"
                        :: checked input.checked
                        :: Events.onCheck input.onChange
                        :: Attr.inlineStyle [ ( "display", "none" ) ]
                        :: []
                    )
                , child = Internal.Empty
                , absolutelyPositioned = Nothing
                }
    in
        Input LabelOnRight <|
            [ input.icon input.checked
            , inputElem
            ]


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
    }


{-|

    radio MyStyle [  ]
        { onChange = ChooseLunch
        , selected = Just currentlySelected -- : Maybe Lunch
        , options =
            [ optionWith Burrito (text "A Burrito!") <|
                \selected ->
                    if selected then
                        text ":)"
                    else
                        text ":("

            , option Taco (text "A Taco!")

            ]
        }
-}
radio : style -> List (Attribute variation msg) -> Radio option style variation msg -> Input style variation msg
radio style attrs config =
    Input LabelAbove <| [ radioElement False style attrs config ]


{-| Same as `radio`, but arranges the options in a row instead of a column
-}
radioRow : style -> List (Attribute variation msg) -> Radio option style variation msg -> Input style variation msg
radioRow style attrs config =
    Input LabelAbove <|
        [ radioElement True style attrs config
        ]


{-| -}
type GridOption value style variation msg
    = GridOption
        { position : Element.GridPosition
        , value : value
        , el : Element style variation msg
        }
    | GridOptionWith
        { position : Element.GridPosition
        , value : value
        , view : Bool -> Element style variation msg
        }


{-| -}
gridOption : { el : Element style variation msg, height : Int, start : ( Int, Int ), value : a, width : Int } -> GridOption a style variation msg
gridOption { start, width, height, value, el } =
    GridOption
        { position =
            { start = start
            , width = width
            , height = height
            }
        , value = value
        , el = el
        }


{-| -}
gridOptionWith : { view : Bool -> Element style variation msg, height : Int, start : ( Int, Int ), value : a, width : Int } -> GridOption a style variation msg
gridOptionWith { start, width, height, value, view } =
    GridOptionWith
        { position =
            { start = start
            , width = width
            , height = height
            }
        , value = value
        , view = view
        }


{-| -}
type alias RadioGrid value msg =
    { onChange : value -> msg
    , selected : Maybe value
    , columns : List Length
    , rows : List Length
    }


{-| A grid radiobutton layout

    radioGrid MyGridStyle
        { onChange = ChooseLunch
        , selected = Just currentlySelected -- : Maybe Lunch
        , columns = [ px 100, px 100, px 100, px 100 ]
        , rows =
            [ px 100
            , px 100
            , px 100
            , px 100
            ]
        }
        []
        [ gridOption
            { start = ( 0, 0 )
            , width = 1
            , height = 1
            , value = Burrito
            , el =
                el Box [] (text "box")
            }
        , gridOption
            { start = ( 1, 1 )
            , width = 1
            , height = 2
            , value = Taco
            , el =
                (el Box [] (text "box"))
            }

        , gridOptionWith
            { start = ( 1, 1 )
            , width = 1
            , height = 2
            , value = Taco
            , selected =
                \selected ->
                    if selected then
                        text "Burrito!"
                    else
                        text "Unselected burrito :("
            }

        ]

-}
radioGrid : style -> RadioGrid value msg -> List (Attribute variation msg) -> List (GridOption value style variation msg) -> Element style variation msg
radioGrid style { selected, onChange, rows, columns } attrs options =
    let
        getGridOptionValue opt =
            case opt of
                GridOption { value } ->
                    value

                GridOptionWith { value } ->
                    value

        group =
            options
                |> List.map (optionToString << getGridOptionValue)
                |> String.join "-"

        renderOption option =
            case option of
                GridOption grid ->
                    let
                        style =
                            Modify.getStyle grid.el

                        attrs =
                            Modify.getAttrs grid.el

                        ( inputEvents, nonInputEventAttrs ) =
                            List.partition forInputEvents
                                (if Just grid.value /= selected then
                                    attrs ++ [ Events.onCheck (\_ -> onChange grid.value) ]
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
                            grid.el
                                |> Modify.setNode "input"
                                |> Modify.addAttrList
                                    ([ type_ "radio"
                                     , name group
                                     , value (optionToString grid.value)
                                     , checked (Just grid.value == selected)
                                     , Internal.VAlign Internal.VerticalCenter
                                     , Internal.Position Nothing (Just -2) Nothing
                                     ]
                                        ++ inputEvents
                                    )
                                |> Modify.removeContent
                                |> Modify.removeStyle

                        literalLabel =
                            grid.el
                                |> Modify.getChild
                                |> Modify.removeAllAttrs
                                |> Modify.removeStyle
                    in
                        Element.area grid.position <|
                            Internal.Layout
                                { node = "label"
                                , style = style
                                , layout = Style.FlexLayout Style.GoRight []
                                , attrs = Attr.spacing 5 :: nonInputEventAttrs
                                , children = Internal.Normal [ rune, literalLabel ]
                                , absolutelyPositioned = Nothing
                                }

                GridOptionWith grid ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    ([ type_ "radio"
                                     , Attr.inlineStyle [ ( "display", "none" ) ]
                                     , name group
                                     , value (optionToString grid.value)
                                     , checked (Just grid.value == selected)
                                     ]
                                        ++ if Just grid.value /= selected then
                                            [ Events.onCheck (\_ -> onChange grid.value) ]
                                           else
                                            []
                                    )
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }
                    in
                        Element.area grid.position <|
                            Internal.Layout
                                { node = "label"
                                , style = Nothing
                                , layout = Style.FlexLayout Style.GoRight []
                                , attrs = []
                                , children = Internal.Normal [ hiddenInput, grid.view (Just grid.value == selected) ]
                                , absolutelyPositioned = Nothing
                                }
    in
        Element.grid style { rows = rows, columns = columns } attrs (List.map renderOption options)


radioElement : Bool -> style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radioElement horizontal style attrs { onChange, options, selected } =
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
                            , attrs = Attr.spacing 5 :: nonInputEventAttrs
                            , children = Internal.Normal [ rune, literalLabel ]
                            , absolutelyPositioned = Nothing
                            }

                OptionWith val view ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    ([ type_ "radio"
                                     , Attr.inlineStyle [ ( "display", "none" ) ]
                                     , name group
                                     , value (optionToString val)
                                     , checked (Just val == selected)
                                     ]
                                        ++ if Just val /= selected then
                                            [ Events.onCheck (\_ -> onChange val) ]
                                           else
                                            []
                                    )
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }
                    in
                        hiddenInput
                            |> Modify.addChild
                                (view (Just val == selected)
                                    |> Modify.setNode "label"
                                )
    in
        if horizontal then
            row style attrs (List.map renderOption options)
        else
            column style attrs (List.map renderOption options)


{-| A Select Menu
-}
select : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
select style attrs { onChange, options, selected } =
    let
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
                                |> Modify.setNode "option"
                                |> Modify.addAttrList
                                    ([ type_ "radio"
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
                            , attrs = Attr.spacing 5 :: nonInputEventAttrs
                            , children = Internal.Normal [ rune, literalLabel ]
                            , absolutelyPositioned = Nothing
                            }

                OptionWith val view ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "option"
                                , style = Nothing
                                , attrs =
                                    ([ Attr.inlineStyle [ ( "display", "none" ) ]
                                     , value (optionToString val)
                                     , checked (Just val == selected)
                                     ]
                                        ++ if Just val /= selected then
                                            [ Events.onCheck (\_ -> onChange val) ]
                                           else
                                            []
                                    )
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }
                    in
                        hiddenInput
                            |> Modify.addChild
                                (view (Just val == selected)
                                    |> Modify.setNode "label"
                                )
    in
        Element.node "select" <| column style attrs (List.map renderOption options)
