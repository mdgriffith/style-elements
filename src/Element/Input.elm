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
        , labelBelow
        , labelLeft
        , labelRight
        )

{-| Elements for creating forms.

@docs label, labelBelow, labelLeft, labelRight, text, multiline, search, email, password

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


{-| -}
form : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
form =
    (Modify.setNode "form" << Element.el)



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
text elem attrs { value, onChange } =
    Input <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (Attr.type_ "text" :: Attr.value value :: Events.onInput onChange :: attrs)
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


{-| Put a label above any of the text inputs.

The spacing property on the label will be the spacing between the label and the input element.

All other properties will apply normally to the label element

-}
label : Element style variation msg -> Input style variation msg -> Element style variation msg
label el (Input inputElems) =
    let
        forSpacing posAttr =
            case posAttr of
                Internal.Spacing x y ->
                    True

                _ ->
                    False
    in
        Internal.Layout
            { node = "label"
            , style = Nothing
            , layout = Style.FlexLayout Style.Down []
            , attrs =
                el
                    |> Modify.getAttrs
                    |> List.filter forSpacing
            , children = Internal.Normal (el :: inputElems)
            , absolutelyPositioned = Nothing
            }


{-| -}
labelBelow : Element style variation msg -> Input style variation msg -> Element style variation msg
labelBelow el (Input inputElems) =
    let
        forSpacing posAttr =
            case posAttr of
                Internal.Spacing x y ->
                    True

                _ ->
                    False
    in
        Internal.Layout
            { node = "label"
            , style = Nothing
            , layout = Style.FlexLayout Style.Down []
            , attrs =
                el
                    |> Modify.getAttrs
                    |> List.filter forSpacing
            , children = Internal.Normal (inputElems ++ [ el ])
            , absolutelyPositioned = Nothing
            }


{-| -}
labelRight : Element style variation msg -> Input style variation msg -> Element style variation msg
labelRight el (Input inputElems) =
    let
        forSpacing posAttr =
            case posAttr of
                Internal.Spacing x y ->
                    True

                _ ->
                    False
    in
        Internal.Layout
            { node = "label"
            , style = Nothing
            , layout = Style.FlexLayout Style.GoRight []
            , attrs =
                el
                    |> Modify.getAttrs
                    |> List.filter forSpacing
            , children = Internal.Normal (inputElems ++ [ el ])
            , absolutelyPositioned = Nothing
            }


{-| -}
labelLeft : Element style variation msg -> Input style variation msg -> Element style variation msg
labelLeft el (Input inputElems) =
    let
        forSpacing posAttr =
            case posAttr of
                Internal.Spacing x y ->
                    True

                _ ->
                    False
    in
        Internal.Layout
            { node = "label"
            , style = Nothing
            , layout = Style.FlexLayout Style.GoRight []
            , attrs =
                el
                    |> Modify.getAttrs
                    |> List.filter forSpacing
            , children = Internal.Normal (el :: inputElems)
            , absolutelyPositioned = Nothing
            }


{-| Rendered as a `textarea`.

Will automatically be the height and width of the content unless a height/width is set.

-}
multiline : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
multiline elem attrs { value, onChange } =
    Input <|
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
password elem attrs { value, onChange } =
    Input <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (Attr.type_ "password" :: Attr.value value :: Events.onInput onChange :: attrs)
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


{-| -}
email : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
email elem attrs { value, onChange } =
    Input <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (Attr.type_ "email" :: Attr.value value :: Events.onInput onChange :: attrs)
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


{-| -}
search : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Input style variation msg
search elem attrs { value, onChange } =
    Input <|
        [ Internal.Element
            { node = "input"
            , style = Just elem
            , attrs = (Attr.attribute "role" "search" :: Attr.type_ "search" :: Attr.value value :: Events.onInput onChange :: attrs)
            , child = Internal.Empty
            , absolutelyPositioned = Nothing
            }
        ]


type Input style variation msg
    = Input (List (Element style variation msg))


{-| Your basic checkbox

    Input.checkbox CheckBoxStyle [ ]
        { checked = True
        , onChange = ChangeMsg
        , label = text "test"
        }

-- For more involved checkbox styling

    Input.checkboxWith CheckBoxStyle [ ]
        { value = True
        , onChange = ChangeMsg
        , label = text "hello!"
        , elem =
            \checked ->
                el CheckedStyle [] (text if checked then "✓" else "x")

        }

-}
checkbox : style -> List (Attribute variation msg) -> { onChange : Bool -> msg, checked : Bool, label : Element style variation msg } -> Element style variation msg
checkbox style attrs { onChange, checked, label } =
    let
        inputElem =
            Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (Attr.type_ "checkbox"
                        :: Attr.checked checked
                        -- :: Events.onCheck onChange
                        :: attrs
                    )
                , child = Internal.Empty
                , absolutelyPositioned = Nothing
                }
    in
        Internal.Layout
            { node = "label"
            , style = Just style
            , layout = Style.FlexLayout Style.GoRight []
            , attrs =
                (Events.onWithOptions "click"
                    { stopPropagation = True
                    , preventDefault = True
                    }
                    (Json.succeed
                        (onChange (not checked))
                    )
                )
                    :: Attr.spacing 5
                    :: (Internal.VAlign Internal.VerticalCenter)
                    :: attrs
            , children = Internal.Normal [ inputElem, label ]
            , absolutelyPositioned = Nothing
            }


{-| -}
checkboxWith : style -> List (Attribute variation msg) -> { onChange : Bool -> msg, checked : Bool, elem : Bool -> Element style variation msg } -> Element style variation msg
checkboxWith style attrs { onChange, checked, elem } =
    let
        inputElem =
            Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (Attr.type_ "checkbox"
                        :: Attr.checked checked
                        :: Events.onCheck onChange
                        :: Attr.hidden
                        :: attrs
                    )
                , child = Internal.Empty
                , absolutelyPositioned = Nothing
                }
    in
        inputElem
            |> Modify.addChild
                (elem checked
                    |> Modify.setNode "label"
                )


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
            [ optionWith Burrito <|
                \selected ->
                    if selected then
                        text "Burrito!"
                    else
                        text "Unselected burrito :("

            , option Taco (text "A Taco!")

            ]
        }
-}
radio : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radio style attrs config =
    radioElement False style attrs config


{-| Same as `radio`, but arranges the options in a row instead of a column
-}
radioRow : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radioRow style attrs config =
    radioElement True style attrs config


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
        , viewElement : Bool -> Element style variation msg
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
        , viewElement = view
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
                GridOption { position, value, el } ->
                    let
                        style =
                            Modify.getStyle el

                        attrs =
                            Modify.getAttrs el

                        ( inputEvents, nonInputEventAttrs ) =
                            List.partition forInputEvents
                                (if Just value /= selected then
                                    attrs ++ [ Events.onCheck (\_ -> onChange value) ]
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
                                    ([ Attr.type_ "radio"
                                     , Attr.name group
                                     , Attr.value (optionToString value)
                                     , Attr.checked (Just value == selected)
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
                        Element.area position <|
                            Internal.Layout
                                { node = "label"
                                , style = style
                                , layout = Style.FlexLayout Style.GoRight []
                                , attrs = Attr.spacing 5 :: nonInputEventAttrs
                                , children = Internal.Normal [ rune, literalLabel ]
                                , absolutelyPositioned = Nothing
                                }

                GridOptionWith { position, value, viewElement } ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    ([ Attr.type_ "radio"
                                     , Attr.hidden
                                     , Attr.name group
                                     , Attr.value (optionToString value)
                                     , Attr.checked (Just value == selected)
                                     ]
                                        ++ if Just value /= selected then
                                            [ Events.onCheck (\_ -> onChange value) ]
                                           else
                                            []
                                    )
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }
                    in
                        Element.area position <|
                            Internal.Layout
                                { node = "label"
                                , style = Nothing
                                , layout = Style.FlexLayout Style.GoRight []
                                , attrs = []
                                , children = Internal.Normal [ hiddenInput, viewElement (Just value == selected) ]
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
                Option value el ->
                    let
                        style =
                            Modify.getStyle el

                        attrs =
                            Modify.getAttrs el

                        ( inputEvents, nonInputEventAttrs ) =
                            List.partition forInputEvents
                                (if Just value /= selected then
                                    attrs ++ [ Events.onCheck (\_ -> onChange value) ]
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
                                    ([ Attr.type_ "radio"
                                     , Attr.name group
                                     , Attr.value (optionToString value)
                                     , Attr.checked (Just value == selected)
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

                OptionWith value elem ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "input"
                                , style = Nothing
                                , attrs =
                                    ([ Attr.type_ "radio"
                                     , Attr.hidden
                                     , Attr.name group
                                     , Attr.value (optionToString value)
                                     , Attr.checked (Just value == selected)
                                     ]
                                        ++ if Just value /= selected then
                                            [ Events.onCheck (\_ -> onChange value) ]
                                           else
                                            []
                                    )
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }
                    in
                        Internal.Layout
                            { node = "label"
                            , style = Nothing
                            , layout = Style.FlexLayout Style.GoRight []
                            , attrs = []
                            , children = Internal.Normal [ hiddenInput, elem (Just value == selected) ]
                            , absolutelyPositioned = Nothing
                            }
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
                Option value el ->
                    let
                        style =
                            Modify.getStyle el

                        attrs =
                            Modify.getAttrs el

                        ( inputEvents, nonInputEventAttrs ) =
                            List.partition forInputEvents
                                (if Just value /= selected then
                                    attrs ++ [ Events.onCheck (\_ -> onChange value) ]
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
                                    ([ Attr.type_ "radio"
                                     , Attr.value (optionToString value)
                                     , Attr.checked (Just value == selected)
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

                OptionWith value elem ->
                    let
                        hiddenInput =
                            Internal.Element
                                { node = "option"
                                , style = Nothing
                                , attrs =
                                    ([ Attr.hidden
                                     , Attr.value (optionToString value)
                                     , Attr.checked (Just value == selected)
                                     ]
                                        ++ if Just value /= selected then
                                            [ Events.onCheck (\_ -> onChange value) ]
                                           else
                                            []
                                    )
                                , child = Internal.Empty
                                , absolutelyPositioned = Nothing
                                }
                    in
                        Internal.Layout
                            { node = "label"
                            , style = Nothing
                            , layout = Style.FlexLayout Style.GoRight []
                            , attrs = []
                            , children = Internal.Normal [ hiddenInput, elem (Just value == selected) ]
                            , absolutelyPositioned = Nothing
                            }
    in
        Element.node "select" <| column style attrs (List.map renderOption options)
