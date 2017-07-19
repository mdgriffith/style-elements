module Element.Form
    exposing
        ( checkbox
        , checkboxWith
        , option
        , optionWith
        , radio
        )

{-| Elements for creating forms.

@docs checkbox, checkboxWith

@docs radio, option, optionWith

-}

import Element.Internal.Model as Internal
import Element exposing (Element, Attribute, column)
import Element.Attributes as Attr
import Element.Events as Events
import Element.Internal.Modify as Modify
import Style.Internal.Model as Style exposing (Length)
import Style.Internal.Selector
import Json.Decode as Json


-- email : style -> List (Attribute variation msg) -> { onChange : Maybe (Bool -> msg), value : String } -> Element style variation msg
-- search : style -> List (Attribute variation msg) -> { onChange : Maybe (Bool -> msg), value : String } -> Element style variation msg
-- text : style -> List (Attribute variation msg) -> { onChange : Maybe (Bool -> msg), value : String } -> Element style variation msg
-- multiline : style -> List (Attribute variation msg) -> { onChange : Maybe (Bool -> msg), value : String } -> Element style variation msg
-- password : style -> List (Attribute variation msg) -> { onChange : Maybe (Bool -> msg), value : String } -> Element style variation msg
-- radioRow
-- radioGrid
-- submitButton (Does a submit button have accessibility concerns?)
{-
   button
   checkbox
   radio
   radioRow
   radioGrid
   text
   multiline (textarea)
   search
   email
   password
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





   ?
      does button type="submit" have accessibility implications?
-}


{-| -}
text : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Element style variation msg
text elem attrs { value, onChange } =
    Internal.Element
        { node = "input"
        , style = Just elem
        , attrs = (Attr.type_ "text" :: Attr.value value :: Events.onInput onChange :: attrs)
        , child = Internal.Empty
        , absolutelyPositioned = Nothing
        }


{-| -}
multiline : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Element style variation msg
multiline elem attrs { value, onChange } =
    Internal.Element
        { node = "textarea"
        , style = Just elem
        , attrs = (Events.onInput onChange :: attrs)
        , child = Element.text value
        , absolutelyPositioned = Nothing
        }


{-| -}
password : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Element style variation msg
password elem attrs { value, onChange } =
    Internal.Element
        { node = "input"
        , style = Just elem
        , attrs = (Attr.type_ "password" :: Attr.value value :: Events.onInput onChange :: attrs)
        , child = Internal.Empty
        , absolutelyPositioned = Nothing
        }


{-| -}
email : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Element style variation msg
email elem attrs { value, onChange } =
    Internal.Element
        { node = "input"
        , style = Just elem
        , attrs = (Attr.type_ "email" :: Attr.value value :: Events.onInput onChange :: attrs)
        , child = Internal.Empty
        , absolutelyPositioned = Nothing
        }


{-| -}
search : style -> List (Attribute variation msg) -> { onChange : String -> msg, value : String } -> Element style variation msg
search elem attrs { value, onChange } =
    Internal.Element
        { node = "input"
        , style = Just elem
        , attrs = (Attr.type_ "search" :: Attr.value value :: Events.onInput onChange :: attrs)
        , child = Internal.Empty
        , absolutelyPositioned = Nothing
        }


type Option value style variation msg
    = Option value (Element style variation msg)
    | OptionWith value (Bool -> Element style variation msg)


option : value -> Element style variation msg -> Option value style variation msg
option =
    Option


optionWith : value -> (Bool -> Element style variation msg) -> Option value style variation msg
optionWith =
    OptionWith


type alias Radio option style variation msg =
    { onChange : option -> msg
    , options : List (Option option style variation msg)
    , selected : option
    }


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


type Input style variation msg
    = Input (List (Element style variation msg))


{-| c

    checkbox CheckBoxStyle [ ]
        { value = True
        , onChange = Just ChangeMsg
        , label = text "test"
        }

-- For more involved checkbox styling

    checkboxWith CheckBoxStyle [ ]
        { value = True
        , onChange = Just ChangeMsg
        , label = text "hello!"
        , elem =
            (\checked ->
            el CheckedStyle [] (text "✓")
            )
        }

-}
checkbox : style -> List (Attribute variation msg) -> { onChange : Bool -> msg, value : Bool, label : Element style variation msg } -> Element style variation msg
checkbox style attrs { onChange, value, label } =
    let
        inputElem =
            Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (Attr.type_ "checkbox"
                        :: Attr.checked value
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
                        (onChange (not value))
                    )
                )
                    :: Attr.spacing 5
                    :: (Internal.VAlign Internal.VerticalCenter)
                    :: attrs
            , children = Internal.Normal [ inputElem, label ]
            , absolutelyPositioned = Nothing
            }


{-| -}
checkboxWith : style -> List (Attribute variation msg) -> { onChange : Bool -> msg, value : Bool, elem : Bool -> Element style variation msg, label : Element style variation msg } -> Element style variation msg
checkboxWith style attrs { onChange, value, elem, label } =
    let
        inputElem =
            Internal.Element
                { node = "input"
                , style = Nothing
                , attrs =
                    (Attr.type_ "checkbox"
                        :: Attr.checked value
                        :: Events.onCheck onChange
                        :: Attr.hidden
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
            , attrs = Attr.spacing 5 :: (Internal.VAlign Internal.VerticalCenter) :: attrs
            , children = Internal.Normal [ inputElem, elem value, label ]
            , absolutelyPositioned = Nothing
            }


{-|

    radio [ radioStyle, attrs ]
        { onChange = Just ChangeRadio
        , options =
            [ optionWith Burrito (text "Burrito!")
                { label = text "Burrito!"
                , elem =
                    (\selected ->
                        if selected then
                            text "Burrito!"
                        else
                            text "Unselected burrito :("
                    )
                }
            , option Taco (text "A Taco!")

            ]
        , selected = currentlySelected -- : Lunch
        }
-}
radio : style -> List (Attribute variation msg) -> Radio option style variation msg -> Element style variation msg
radio style attrs { onChange, options, selected } =
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
                                (if value /= selected then
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
                                     , Attr.checked (value == selected)
                                     , Internal.VAlign Internal.VerticalCenter
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
                                     , Attr.checked (value == selected)
                                     ]
                                        ++ if selected /= value then
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
                            , children = Internal.Normal [ hiddenInput, elem (value == selected) ]
                            , absolutelyPositioned = Nothing
                            }
    in
        column style attrs (List.map renderOption options)
