module Element.Input
    exposing
        ( Button
        , Checkbox
        , Label
          -- , Menu
          -- , Notice
        , Option
        , Placeholder
        , Radio
          -- , Select
        , Text
        , button
        , checkbox
        , currentPassword
        , email
          -- , errorAbove
          -- , errorBelow
          -- , errorLeft
          -- , errorRight
        , focusedOnLoad
          -- , warningAbove
          -- , warningBelow
          -- , warningLeft
          -- , warningRight
        , labelAbove
        , labelBelow
        , labelLeft
        , labelRight
          -- , menuAbove
          -- , menuBelow
        , multiline
        , newPassword
        , option
        , optionWith
        , placeholder
        , radio
        , radioRow
        , search
          -- , select
        , spellChecked
        , spellCheckedMultiline
        , text
        , username
        )

{-|


## Inputs

@docs button, Button

@docs checkbox, Checkbox

@docs text, Text, Placeholder, placeholder, username, newPassword, currentPassword, email, search, spellChecked

@docs multiline, spellCheckedMultiline

@docs radio, radioRow, Radio, Option, option, optionWith


## Labels

@docs Label, labelAbove, labelBelow, labelLeft, labelRight

@docs focusedOnLoad

-}

import Color exposing (..)
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html
import Html.Attributes
import Html.Events
import Internal.Events as Events
import Internal.Grid
import Internal.Model as Internal
import Json.Decode as Json


{-| -}
type Placeholder msg
    = Placeholder (List (Attribute msg)) (Element msg)


{-| -}
placeholder : List (Attribute msg) -> Element msg -> Placeholder msg
placeholder =
    Placeholder


{-| Every input has a required `label`.
-}
type Label msg
    = Label Internal.Grid.RelativePosition (List (Attribute msg)) (Element msg)


{-| -}
type Notice msg
    = Notice Internal.Grid.RelativePosition (List (Attribute msg)) (Element msg)


{-| -}
labelRight : List (Attribute msg) -> Element msg -> Label msg
labelRight =
    Label Internal.Grid.OnRight


{-| -}
labelLeft : List (Attribute msg) -> Element msg -> Label msg
labelLeft =
    Label Internal.Grid.OnLeft


{-| -}
labelAbove : List (Attribute msg) -> Element msg -> Label msg
labelAbove =
    Label Internal.Grid.Above


{-| -}
labelBelow : List (Attribute msg) -> Element msg -> Label msg
labelBelow =
    Label Internal.Grid.Below


{-| -}
warningRight : List (Attribute msg) -> Element msg -> Notice msg
warningRight =
    Notice Internal.Grid.OnRight


{-| -}
warningLeft : List (Attribute msg) -> Element msg -> Notice msg
warningLeft =
    Notice Internal.Grid.OnLeft


{-| -}
warningAbove : List (Attribute msg) -> Element msg -> Notice msg
warningAbove =
    Notice Internal.Grid.Above


{-| -}
warningBelow : List (Attribute msg) -> Element msg -> Notice msg
warningBelow =
    Notice Internal.Grid.Below


{-| -}
errorRight : List (Attribute msg) -> Element msg -> Notice msg
errorRight =
    Notice Internal.Grid.OnRight


{-| -}
errorLeft : List (Attribute msg) -> Element msg -> Notice msg
errorLeft =
    Notice Internal.Grid.OnLeft


{-| -}
errorAbove : List (Attribute msg) -> Element msg -> Notice msg
errorAbove =
    Notice Internal.Grid.Above


{-| -}
errorBelow : List (Attribute msg) -> Element msg -> Notice msg
errorBelow =
    Notice Internal.Grid.Below


{-| -}
type alias Button msg =
    { onPress : Maybe msg
    , label : Element msg
    }


{-| A standard button.

The `onPress` handler will be fired either `onClick` or when the element is focused and the enter key has been pressed.

    import Element.Input as Input

    Input.button []
        { onPress = Just ClickMsg
        , label = text "My Button"
        }

`onPress` takes a `Maybe msg`. If you provide the value `Nothing`, then the button will be disabled.

-}
button : List (Attribute msg) -> Button msg -> Element msg
button attrs { onPress, label } =
    Internal.element Internal.noStyleSheet
        Internal.asEl
        -- We don't explicitly label this node as a button,
        -- because buttons fire a bunch of times when you hold down the enter key.
        -- We'd like to fire just once on the enter key, which means using keyup instead of keydown.
        -- Because we have no way to disable keydown, though our messages get doubled.
        Nothing
        (Element.width Element.shrink
            :: Element.height Element.shrink
            :: Element.centerY
            :: Element.center
            :: Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: Internal.Class "button" "se-button"
            :: Element.pointer
            :: Internal.class "focusable"
            :: Internal.Describe Internal.Button
            :: Internal.Attr (Html.Attributes.tabindex 0)
            :: (case onPress of
                    Nothing ->
                        Internal.Attr (Html.Attributes.disabled True) :: attrs

                    Just msg ->
                        Events.onClick msg
                            :: onEnter msg
                            :: attrs
               )
        )
        (Internal.Unkeyed [ label ])


{-| -}
type alias Checkbox msg =
    { onChange : Maybe (Bool -> msg)
    , icon : Maybe (Element msg)
    , checked : Bool
    , label : Label msg

    -- , invalid : Bool
    -- , notice : Maybe (Notice msg)
    }


{-| -}
checkbox : List (Attribute msg) -> Checkbox msg -> Element msg
checkbox attrs { label, icon, checked, onChange } =
    let
        input =
            Internal.element Internal.noStyleSheet
                Internal.asEl
                (Just "div")
                [ Internal.Attr <|
                    Html.Attributes.attribute "role" "checkbox"
                , Internal.Attr <|
                    Html.Attributes.attribute "aria-checked" <|
                        if checked then
                            "true"
                        else
                            "false"

                -- , Internal.class "focusable"
                , Element.centerY
                ]
                (Internal.Unkeyed
                    [ case icon of
                        Nothing ->
                            defaultCheckbox checked

                        Just actualIcon ->
                            actualIcon
                    ]
                )

        attributes =
            (case onChange of
                Nothing ->
                    [ Internal.Attr (Html.Attributes.disabled True) ]

                Just checkMsg ->
                    [ Internal.Attr (Html.Events.onClick (checkMsg (not checked)))
                    , onKeyLookup <|
                        \code ->
                            if code == enter then
                                Just <| checkMsg (not checked)
                            else if code == space then
                                Just <| checkMsg (not checked)
                            else
                                Nothing
                    ]
            )
                ++ (tabindex 0 :: Element.pointer :: Element.alignLeft :: Element.width Element.fill :: attrs)
    in
    Internal.Grid.relative (Just "label")
        attributes
        ({ right = Nothing
         , left = Nothing
         , primary = input
         , primaryWidth = Internal.Content
         , defaultWidth = Internal.Fill 1
         , below = Nothing
         , above = Nothing
         }
            |> (\group ->
                    case label of
                        Label position labelAttrs child ->
                            place position
                                { layout = Internal.Grid.GridElement
                                , child = [ child ]
                                , attrs = Element.alignLeft :: labelAttrs
                                , width =
                                    case position of
                                        Internal.Grid.Above ->
                                            2

                                        Internal.Grid.Below ->
                                            2

                                        _ ->
                                            1
                                , height = 1
                                }
                                group
               )
         -- |> (\group ->
         --         -- case notice of
         --             -- Nothing ->
         --                 group
         --             -- Just (Notice position labelAttrs child) ->
         --             --     place position
         --             --         { layout = Internal.Grid.GridElement
         --             --         , child = [ child ]
         --             --         , attrs = Element.alignLeft :: labelAttrs
         --             --         , width =
         --             --             case position of
         --             --                 Internal.Grid.Above ->
         --             --                     2
         --             --                 Internal.Grid.Below ->
         --             --                     2
         --             --                 _ ->
         --             --                     1
         --             --         , height = 1
         --             --         }
         --             --         group
         --    )
        )


place : Internal.Grid.RelativePosition -> Internal.Grid.PositionedElement msg -> Internal.Grid.Around msg -> Internal.Grid.Around msg
place position el group =
    case position of
        Internal.Grid.Above ->
            case group.above of
                Nothing ->
                    { group | above = Just el }

                Just existing ->
                    { group
                        | above =
                            Just
                                { el
                                    | child = el.child ++ existing.child
                                    , layout = Internal.Grid.Row
                                }
                    }

        Internal.Grid.Below ->
            case group.below of
                Nothing ->
                    { group | below = Just el }

                Just existing ->
                    { group
                        | below =
                            Just
                                { el
                                    | child = el.child ++ existing.child
                                    , layout = Internal.Grid.Row
                                }
                    }

        Internal.Grid.OnRight ->
            case group.right of
                Nothing ->
                    { group | right = Just el }

                Just existing ->
                    { group
                        | right =
                            Just
                                { el
                                    | child = el.child ++ existing.child
                                    , layout = Internal.Grid.Column
                                }
                    }

        Internal.Grid.OnLeft ->
            case group.left of
                Nothing ->
                    { group | left = Just el }

                Just existing ->
                    { group
                        | left =
                            Just
                                { el
                                    | child = el.child ++ existing.child
                                    , layout = Internal.Grid.Column
                                }
                    }



-- {-| -}
-- type alias Slider msg =
--     { onChange : Maybe (Int -> msg)
--     , range : ( Int, Int )
--     , value : Int
--     , label : Label msg
--     , notice : Maybe (Notice msg)
--     }
-- sliderX : List (Attribute msg) -> Slider msg -> Element msg
-- sliderX attributes input =
--     let
--         behavior =
--             case input.onChange of
--                 Nothing ->
--                     [ Internal.Attr (Html.Attributes.disabled True) ]
--                 Just changeCoord ->
--                     [ Events.onMouseCoords (\{ x, y } -> changeCoord x)
--                     ]
--         min =
--             Tuple.first input.range
--         max =
--             Tuple.second input.range
--         percentage =
--             ((toFloat input.value - toFloat min) / (toFloat max - toFloat min)) + toFloat min
--         icon =
--             Element.el
--                 [ Element.width (Element.px 10)
--                 , Element.height (Element.px 10)
--                 , Background.color lightBlue
--                 , Border.rounded 5
--                 , Element.alignLeft
--                 , Element.moveUp 5
--                 , Element.pointer
--                 , Element.moveRight percentage
--                 ]
--                 Element.empty
--         controls =
--             Internal.el
--                 Nothing
--                 ([ Background.color grey
--                  , Element.width Element.fill
--                  , Element.height (Element.px 1)
--                  ]
--                     ++ behavior
--                     ++ attributes
--                 )
--                 (Internal.Unkeyed [ icon ])
--     in
--     positionLabels
--         [ Element.width Element.fill ]
--         input.label
--         input.notice
--         controls


type TextType
    = Plain
    | Username
    | NewPassword
    | CurrentPassword
    | Email
    | Search
    | SpellChecked


{-| -}
type alias Text msg =
    { onChange : Maybe (String -> msg)
    , text : String
    , placeholder : Maybe (Placeholder msg)
    , label : Label msg
    }


{-| -}
textDefault : Text msg
textDefault =
    { onChange = Nothing
    , text = ""
    , placeholder = Nothing
    , label = labelAbove [] (Element.text "My Input")
    }


textHelper : TextType -> List (Attribute msg) -> Text msg -> Element msg
textHelper textType attrs textOptions =
    let
        attributes =
            Element.width Element.fill :: attrs

        behavior =
            case textOptions.onChange of
                Nothing ->
                    [ Internal.Attr (Html.Attributes.disabled True) ]

                Just checkMsg ->
                    [ Internal.Attr (Html.Events.onInput checkMsg) ]

        textTypeAttr =
            case textType of
                Plain ->
                    [ Internal.Attr (Html.Attributes.type_ "text")
                    ]

                SpellChecked ->
                    [ Internal.Attr (Html.Attributes.type_ "text")
                    , spellcheck True
                    ]

                Username ->
                    [ Internal.Attr (Html.Attributes.type_ "text")
                    , autofill "username"
                    ]

                NewPassword ->
                    [ Internal.Attr (Html.Attributes.type_ "password")
                    , autofill "new-password"
                    ]

                CurrentPassword ->
                    [ Internal.Attr (Html.Attributes.type_ "password")
                    , autofill "current-password"
                    ]

                Email ->
                    [ Internal.Attr (Html.Attributes.type_ "email")
                    , autofill "email"
                    ]

                Search ->
                    [ Internal.Attr (Html.Attributes.type_ "search")
                    ]

        attributesFromChild =
            Internal.get attributes <|
                \attr ->
                    case attr of
                        Internal.Width (Internal.Fill _) ->
                            True

                        Internal.Height (Internal.Fill _) ->
                            True

                        Internal.AlignX _ ->
                            True

                        Internal.AlignY _ ->
                            True

                        Internal.StyleClass (Internal.SpacingStyle _ _) ->
                            True

                        Internal.StyleClass (Internal.LineHeight _) ->
                            True

                        Internal.StyleClass (Internal.FontSize _) ->
                            True

                        Internal.StyleClass (Internal.FontFamily _ _) ->
                            True

                        _ ->
                            False

        parentAttributes =
            Element.spacing 5
                :: attributesFromChild

        inputPadding =
            Internal.get attributes <|
                \attr ->
                    case attr of
                        Internal.StyleClass (Internal.PaddingStyle _ _ _ _) ->
                            True

                        _ ->
                            False

        inputElement =
            Internal.element Internal.noStyleSheet
                Internal.asEl
                Nothing
                (case textOptions.placeholder of
                    Nothing ->
                        []

                    Just (Placeholder placeholderAttrs placeholder) ->
                        [ Element.inFront (textOptions.text == "") <|
                            Internal.element Internal.noStyleSheet
                                Internal.asEl
                                Nothing
                                (Font.color charcoal
                                    :: Internal.Class "text-selection" "no-text-selection"
                                    :: defaultTextPadding
                                    :: Element.height Element.fill
                                    :: Element.width Element.fill
                                    :: (inputPadding
                                            ++ placeholderAttrs
                                       )
                                )
                                (Internal.Unkeyed
                                    [ placeholder
                                    ]
                                )
                        ]
                )
                (Internal.Unkeyed <|
                    [ Internal.element Internal.noStyleSheet
                        Internal.asEl
                        (Just "input")
                        (List.concat
                            [ [ value textOptions.text
                              , defaultTextPadding
                              , Internal.Class "focus" "focusable"
                              ]
                            , defaultTextBoxStyle
                            , textTypeAttr
                            , behavior
                            , attributes
                            ]
                        )
                        (Internal.Unkeyed [])
                    ]
                )
    in
    applyLabel
        (Internal.Class "cursor" "cursor-text" :: parentAttributes)
        textOptions.label
        inputElement


{-| -}
text : List (Attribute msg) -> Text msg -> Element msg
text =
    textHelper Plain


{-| -}
spellChecked : List (Attribute msg) -> Text msg -> Element msg
spellChecked =
    textHelper SpellChecked


{-| -}
search : List (Attribute msg) -> Text msg -> Element msg
search =
    textHelper Search


{-| A password input that allows the browser to autofill.

It's `newPassword` instead of just `password` because it gives the browser a hint on what type of password input it is.

-}
newPassword : List (Attribute msg) -> Text msg -> Element msg
newPassword =
    textHelper NewPassword


{-| -}
currentPassword : List (Attribute msg) -> Text msg -> Element msg
currentPassword =
    textHelper CurrentPassword


{-| -}
username : List (Attribute msg) -> Text msg -> Element msg
username =
    textHelper Username


{-| -}
email : List (Attribute msg) -> Text msg -> Element msg
email =
    textHelper Email


{-| -}
multilineHelper : Bool -> List (Attribute msg) -> Text msg -> Element msg
multilineHelper spellChecked attrs textOptions =
    let
        attributes =
            Element.height Element.shrink :: Element.width Element.fill :: defaultTextBoxStyle ++ attrs

        behavior =
            case textOptions.onChange of
                Nothing ->
                    [ Internal.Attr (Html.Attributes.disabled True) ]

                Just checkMsg ->
                    [ Internal.Attr (Html.Events.onInput checkMsg) ]

        -- Special height calculator
        -- Height content needs to be translated into a special class
        -- descriptions are also disallowed
        ( padding, heightContent, maybeLineHeight, adjustedAttributes ) =
            attributes
                |> List.foldr
                    (\attr ( pad, height, lh, newAttrs ) ->
                        case attr of
                            Internal.Describe _ ->
                                ( pad, height, lh, newAttrs )

                            Internal.Height val ->
                                case height of
                                    Nothing ->
                                        ( pad, Just val, lh, newAttrs )

                                    Just i ->
                                        ( pad, height, lh, newAttrs )

                            Internal.StyleClass (Internal.LineHeight lineHeight) ->
                                ( pad, height, lh, newAttrs )

                            Internal.StyleClass (Internal.PaddingStyle t r b l) ->
                                case pad of
                                    Nothing ->
                                        ( Just ( t, r, b, l ), height, lh, attr :: newAttrs )

                                    _ ->
                                        ( pad, height, lh, newAttrs )

                            _ ->
                                ( pad, height, lh, attr :: newAttrs )
                    )
                    ( Nothing, Nothing, Nothing, [] )

        withHeight =
            case heightContent of
                Just Internal.Content ->
                    let
                        lineHeight =
                            Maybe.withDefault 1.5 maybeLineHeight

                        newlineCount =
                            String.lines textOptions.text
                                |> List.length
                                |> toFloat
                                |> (\x ->
                                        if x < 1 then
                                            1
                                        else
                                            x
                                   )

                        heightValue count =
                            case padding of
                                Nothing ->
                                    toString (count * lineHeight) ++ "em"

                                Just ( t, r, b, l ) ->
                                    "calc(" ++ toString (count * lineHeight) ++ "em + " ++ toString (t + b) ++ "px)"

                        heightClass =
                            Internal.StyleClass
                                (Internal.Single ("textarea-height-" ++ toString newlineCount)
                                    "height"
                                    (heightValue newlineCount)
                                )
                    in
                    Internal.class "overflow-hidden" :: heightClass :: adjustedAttributes

                Just h ->
                    Internal.Height h :: adjustedAttributes

                _ ->
                    adjustedAttributes

        attributesFromChild =
            Internal.get (Element.width Element.fill :: attributes) <|
                \attr ->
                    case attr of
                        Internal.Width (Internal.Fill _) ->
                            True

                        Internal.Height (Internal.Fill _) ->
                            True

                        Internal.AlignX _ ->
                            True

                        Internal.AlignY _ ->
                            True

                        Internal.StyleClass (Internal.SpacingStyle _ _) ->
                            True

                        Internal.StyleClass (Internal.LineHeight _) ->
                            True

                        Internal.StyleClass (Internal.FontSize _) ->
                            True

                        Internal.StyleClass (Internal.FontFamily _ _) ->
                            True

                        _ ->
                            False

        inputPadding =
            Internal.get attributes <|
                \attr ->
                    case attr of
                        Internal.StyleClass (Internal.PaddingStyle _ _ _ _) ->
                            True

                        _ ->
                            False

        input =
            Internal.element Internal.noStyleSheet
                Internal.asEl
                Nothing
                (case textOptions.placeholder of
                    Nothing ->
                        [ Maybe.map Internal.Height heightContent
                            |> Maybe.withDefault Internal.NoAttribute
                        ]

                    Just (Placeholder placeholderAttrs placeholder) ->
                        [ Maybe.map Internal.Height heightContent
                            |> Maybe.withDefault Internal.NoAttribute
                        , Element.inFront (textOptions.text == "") <|
                            Internal.element Internal.noStyleSheet
                                Internal.asEl
                                Nothing
                                (Font.color charcoal
                                    :: Internal.Class "text-selection" "no-text-selection"
                                    :: defaultTextPadding
                                    :: Internal.Class "cursor" "cursor-text"
                                    :: Element.height Element.fill
                                    :: Element.width Element.fill
                                    :: (inputPadding
                                            ++ placeholderAttrs
                                       )
                                )
                                (Internal.Unkeyed
                                    [ placeholder
                                    ]
                                )
                        ]
                )
                (Internal.Unkeyed <|
                    [ Internal.element Internal.noStyleSheet
                        Internal.asEl
                        (Just "textarea")
                        (List.concat
                            [ [ value textOptions.text
                              , Internal.Class "focus" "focusable"
                              , spellcheck spellChecked
                              , case maybeLineHeight of
                                    Nothing ->
                                        Font.lineHeight 1.5

                                    Just i ->
                                        Font.lineHeight i
                              ]
                            , behavior
                            , withHeight
                            ]
                        )
                        (Internal.Unkeyed [ Internal.unstyled (Html.text textOptions.text) ])
                    ]
                )
    in
    applyLabel attributesFromChild textOptions.label input


{-| -}
multiline : List (Attribute msg) -> Text msg -> Element msg
multiline =
    multilineHelper False


{-| -}
spellCheckedMultiline : List (Attribute msg) -> Text msg -> Element msg
spellCheckedMultiline =
    multilineHelper True


applyLabel : List (Attribute msg) -> Label msg -> Element msg -> Element msg
applyLabel attrs label input =
    case label of
        Label position labelAttrs labelChild ->
            let
                labelElement =
                    Internal.element Internal.noStyleSheet
                        Internal.asEl
                        Nothing
                        labelAttrs
                        (Internal.Unkeyed [ labelChild ])
            in
            case position of
                Internal.Grid.Above ->
                    Internal.element Internal.noStyleSheet
                        Internal.asColumn
                        (Just "label")
                        attrs
                        (Internal.Unkeyed [ labelElement, input ])

                Internal.Grid.Below ->
                    Internal.element Internal.noStyleSheet
                        Internal.asColumn
                        (Just "label")
                        attrs
                        (Internal.Unkeyed [ input, labelElement ])

                Internal.Grid.OnRight ->
                    Internal.element Internal.noStyleSheet
                        Internal.asRow
                        (Just "label")
                        attrs
                        (Internal.Unkeyed [ input, labelElement ])

                Internal.Grid.OnLeft ->
                    Internal.element Internal.noStyleSheet
                        Internal.asRow
                        (Just "label")
                        attrs
                        (Internal.Unkeyed [ labelElement, input ])


{-| -}
positionLabels : List (Attribute msg) -> Label msg -> Maybe (Notice msg) -> Element msg -> Element msg
positionLabels attributes label notice input =
    Internal.Grid.relative (Just "label")
        attributes
        ({ right = Nothing
         , left = Nothing
         , primary = input
         , primaryWidth = Internal.Fill 1
         , defaultWidth = Internal.Content
         , below = Nothing
         , above = Nothing
         }
            |> (\group ->
                    case label of
                        Label position labelAttrs child ->
                            place position
                                { layout = Internal.Grid.GridElement
                                , child = [ child ]
                                , attrs = Element.alignLeft :: labelAttrs
                                , width = 1
                                , height = 1
                                }
                                group
               )
            |> (\group ->
                    case notice of
                        Nothing ->
                            group

                        Just (Notice position labelAttrs child) ->
                            place position
                                { layout = Internal.Grid.GridElement
                                , child = [ child ]
                                , attrs = Element.alignLeft :: labelAttrs
                                , width = 1
                                , height = 1
                                }
                                group
               )
        )


{-| -}
type alias Radio option msg =
    { onChange : Maybe (option -> msg)
    , options : List (Option option msg)
    , selected : Maybe option
    , label : Label msg

    -- , notice : Maybe (Notice msg)
    }


{-| Add choices to your radio and select menus.
-}
type Option value msg
    = Option value (OptionState -> Element msg)


{-| -}
type OptionState
    = Idle
    | Focused
    | Selected


{-| -}
option : value -> Element msg -> Option value msg
option value text =
    Option value (defaultRadioOption text)


{-| -}
optionWith : value -> (OptionState -> Element msg) -> Option value msg
optionWith value view =
    Option value view



-- case status of
--     Idle ->
--     Focused ->
--         Element.el
--             [ Element.width (Element.px 14)
--             , Element.height (Element.px 14)
--             , Background.color lightBlue
--             , Border.rounded 7
--             ]
--             Element.empty
--     Selected ->
--         Element.el
--             [ Element.width (Element.px 14)
--             , Element.height (Element.px 14)
--             , Background.color blue
--             , Border.rounded 7
--             ]
--             Element.empty


{-|

    Input.radio
        [ padding 10
        , spacing 20
        ]
        { onChange = Just ChooseLunch
        , selected = Just model.lunch
        , label = Input.labelAbove (text "Lunch")
        , options =
            [ Input.styledChoice Burrito <|
                \selected ->
                    Element.row
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

-}
radio : List (Attribute msg) -> Radio option msg -> Element msg
radio =
    radioHelper Column


{-| Same as radio, but displayed as a row
-}
radioRow : List (Attribute msg) -> Radio option msg -> Element msg
radioRow =
    radioHelper Row


defaultRadioOption optionLabel status =
    Element.row
        [ Element.spacing 10
        , Element.alignLeft
        , Element.width Element.shrink
        ]
        [ Element.el
            [ Element.width (Element.px 14)
            , Element.height (Element.px 14)
            , Background.color white
            , Border.rounded 7
            , case status of
                Selected ->
                    Internal.class "focusable"

                _ ->
                    Internal.NoAttribute

            -- , Border.shadow <|
            --     -- case status of
            --     --     Idle ->
            --     --         { offset = ( 0, 0 )
            --     --         , blur =
            --     --             1
            --     --         , color = Color.rgb 235 235 235
            --     --         }
            --     --     Focused ->
            --     --         { offset = ( 0, 0 )
            --     --         , blur =
            --     --             0
            --     --         , color = Color.rgba 235 235 235 0
            --     --         }
            --     --     Selected ->
            --     { offset = ( 0, 0 )
            --     , blur =
            --         1
            --     , color = Color.rgba 235 235 235 0
            --     }
            , Border.width <|
                case status of
                    Idle ->
                        1

                    Focused ->
                        1

                    Selected ->
                        5
            , Border.color <|
                case status of
                    Idle ->
                        Color.rgb 208 208 208

                    Focused ->
                        Color.rgb 208 208 208

                    Selected ->
                        Color.rgb 59 153 252
            ]
            Element.empty
        , Element.el [ Element.width Element.fill, Internal.class "unfocusable" ] optionLabel
        ]


radioHelper : Orientation -> List (Attribute msg) -> Radio option msg -> Element msg
radioHelper orientation attrs input =
    let
        spacing =
            Internal.getSpacingAttribute attrs ( 5, 5 )

        renderOption (Option value view) =
            let
                status =
                    if Just value == input.selected then
                        Selected
                    else
                        Idle
            in
            Element.el
                [ Element.pointer
                , Element.width Element.fill
                , case input.onChange of
                    Nothing ->
                        Internal.NoAttribute

                    Just send ->
                        Events.onClick (send value)
                , case status of
                    Selected ->
                        Internal.Attr <|
                            Html.Attributes.attribute "aria-checked"
                                "true"

                    _ ->
                        Internal.Attr <|
                            Html.Attributes.attribute "aria-checked"
                                "false"
                , Internal.Attr <|
                    Html.Attributes.attribute "role" "radio"
                ]
                (view status)

        -- Element.row
        --     [ spacing
        --     , Element.pointer
        --     , case input.onChange of
        --         Nothing ->
        --             Internal.NoAttribute
        --         Just send ->
        --             Events.onClick (send value)
        --     , case status of
        --         Selected ->
        --             Internal.class "focusable"
        --         _ ->
        --             Internal.NoAttribute
        --     , case status of
        --         Selected ->
        --             Internal.Attr <|
        --                 Html.Attributes.attribute "aria-checked"
        --                     "true"
        --         _ ->
        --             Internal.Attr <|
        --                 Html.Attributes.attribute "aria-checked"
        --                     "false"
        --     , Internal.Attr <|
        --         Html.Attributes.attribute "role" "radio"
        --     ]
        --     [ icon status
        --     , Element.el [ Element.width Element.fill, Internal.class "unfocusable" ] text
        --     ]
        optionArea =
            case orientation of
                Row ->
                    row attrs
                        (List.map renderOption input.options)

                Column ->
                    column attrs
                        (List.map renderOption input.options)

        toggleSelected =
            case input.selected of
                Nothing ->
                    Nothing

                Just selected ->
                    Nothing

        prevNext =
            case input.options of
                [] ->
                    Nothing

                (Option value _) :: _ ->
                    List.foldl track ( NotFound, value, value ) input.options
                        |> (\( found, b, a ) ->
                                case found of
                                    NotFound ->
                                        Just ( b, value )

                                    BeforeFound ->
                                        Just ( b, value )

                                    _ ->
                                        Just ( b, a )
                           )

        track option ( found, prev, nxt ) =
            case option of
                Option value _ ->
                    case found of
                        NotFound ->
                            if Just value == input.selected then
                                ( BeforeFound, prev, nxt )
                            else
                                ( found, value, nxt )

                        BeforeFound ->
                            ( AfterFound, prev, value )

                        AfterFound ->
                            ( found, prev, nxt )
    in
    applyLabel
        (case input.onChange of
            Nothing ->
                [ Element.alignLeft ]

            Just onChange ->
                List.filterMap identity
                    [ Just Element.alignLeft
                    , Just (tabindex 0)
                    , Just <|
                        Internal.Attr <|
                            Html.Attributes.attribute "role" "radiogroup"
                    , case prevNext of
                        Nothing ->
                            Nothing

                        Just ( prev, next ) ->
                            Just
                                (onKeyLookup <|
                                    \code ->
                                        if code == leftArrow then
                                            Just (onChange prev)
                                        else if code == upArrow then
                                            Just (onChange prev)
                                        else if code == rightArrow then
                                            Just (onChange next)
                                        else if code == downArrow then
                                            Just (onChange next)
                                        else if code == space then
                                            case input.selected of
                                                Nothing ->
                                                    Just (onChange prev)

                                                _ ->
                                                    Nothing
                                        else
                                            Nothing
                                )
                    ]
        )
        input.label
        optionArea


{-| -}
type alias Select option msg =
    { onChange :
        Maybe
            ({ option : Maybe option
             , menuOpen : Bool
             }
             -> msg
            )
    , selected :
        { option : Maybe option
        , menuOpen : Bool
        }
    , menu : Menu option msg
    , placeholder : Maybe (Element msg)
    , label : Label msg
    }


{-| -}
type Menu option msg
    = Menu MenuPosition (List (Attribute msg)) (List (Option option msg))


type MenuPosition
    = MenuAbove
    | MenuBelow


{-| -}
menuAbove : List (Attribute msg) -> List (Option option msg) -> Menu option msg
menuAbove attrs =
    Menu MenuAbove (defaultTextBoxStyle ++ attrs)


{-| -}
menuBelow : List (Attribute msg) -> List (Option option msg) -> Menu option msg
menuBelow attrs =
    Menu MenuBelow (defaultTextBoxStyle ++ attrs)


{-| -}
select : List (Attribute msg) -> Select option msg -> Element msg
select attrs input =
    let
        spacing =
            Internal.getSpacingAttribute attrs ( 5, 5 )

        renderOption (Option value view) =
            let
                status =
                    if Just value == input.selected.option then
                        Selected
                    else
                        Idle
            in
            Element.el
                [ Element.width Element.fill
                , Element.pointer
                , case input.onChange of
                    Nothing ->
                        Internal.NoAttribute

                    Just send ->
                        Events.onClick (send { menuOpen = False, option = Just value })
                , case status of
                    Selected ->
                        Internal.class "focusable"

                    _ ->
                        Internal.NoAttribute
                , case status of
                    Selected ->
                        Internal.Attr <|
                            Html.Attributes.attribute "aria-checked"
                                "true"

                    _ ->
                        Internal.Attr <|
                            Html.Attributes.attribute "aria-checked"
                                "false"
                , Internal.Attr <|
                    Html.Attributes.attribute "role" "radio"
                ]
                (view status)

        renderSelectedOption (Option value view) =
            let
                status =
                    if Just value == input.selected.option then
                        Selected
                    else
                        Idle
            in
            Element.el
                [ Element.width Element.fill
                , Element.pointer

                -- , case status of
                --     Selected ->
                --         Internal.class "focusable"
                --     _ ->
                --         Internal.NoAttribute
                ]
                (view status)

        toggleSelected =
            case input.selected.option of
                Nothing ->
                    Nothing

                Just selected ->
                    Nothing

        box =
            Element.el
                ((case input.menu of
                    Menu orientation attrs options ->
                        case orientation of
                            MenuAbove ->
                                Element.above True
                                    (column (Internal.class "show-on-focus" :: Background.color white :: attrs)
                                        (List.map renderOption options)
                                    )

                            MenuBelow ->
                                Element.below True
                                    (column (Internal.class "show-on-focus" :: Background.color white :: attrs)
                                        (List.map renderOption options)
                                    )
                 )
                    :: Border.width 1
                    :: Border.color lightGrey
                    :: Border.rounded 5
                    :: defaultTextPadding
                    :: Element.width Element.fill
                    :: Element.pointer
                    :: attrs
                )
                (case prevNext of
                    Nothing ->
                        Element.empty

                    Just ( prev, selected, next ) ->
                        case selected of
                            Nothing ->
                                case input.placeholder of
                                    Nothing ->
                                        Element.text "-"

                                    Just placeholder ->
                                        placeholder

                            Just sel ->
                                renderSelectedOption sel
                )

        prevNext =
            case input.menu of
                Menu _ attrs options ->
                    case options of
                        [] ->
                            Nothing

                        (Option value _) :: _ ->
                            List.foldl track ( NotFound, value, Nothing, value ) options
                                |> (\( found, b, selected, a ) ->
                                        case found of
                                            NotFound ->
                                                Just ( b, selected, value )

                                            BeforeFound ->
                                                Just ( b, selected, value )

                                            _ ->
                                                Just ( b, selected, a )
                                   )

        track option ( found, prev, selected, nxt ) =
            case option of
                Option value _ ->
                    case found of
                        NotFound ->
                            if Just value == input.selected.option then
                                ( BeforeFound, prev, Just option, nxt )
                            else
                                ( found, value, selected, nxt )

                        BeforeFound ->
                            ( AfterFound, prev, selected, value )

                        AfterFound ->
                            ( found, prev, selected, nxt )
    in
    applyLabel
        (case input.onChange of
            Nothing ->
                [ Element.width Element.fill
                , Element.alignLeft
                ]

            Just onChange ->
                List.filterMap identity
                    [ Just Element.alignLeft
                    , Just (tabindex 0)
                    , Just (Element.width Element.fill)
                    , Just <|
                        Internal.Attr <|
                            Html.Attributes.attribute "role" "radiogroup"
                    , case prevNext of
                        Nothing ->
                            Nothing

                        Just ( prev, selected, next ) ->
                            Just
                                (onKeyLookup <|
                                    \code ->
                                        -- if code == leftArrow then
                                        --     Just (onChange prev)
                                        -- else if code == upArrow then
                                        --     Just (onChange prev)
                                        -- else if code == rightArrow then
                                        --     Just (onChange next)
                                        -- else if code == downArrow then
                                        --     Just (onChange next)
                                        -- else if code == space then
                                        --     case input.selected of
                                        --         Nothing ->
                                        --             Just (onChange prev)
                                        --         _ ->
                                        --             Nothing
                                        -- else
                                        Nothing
                                )
                    ]
        )
        input.label
        box


type Found
    = NotFound
    | BeforeFound
    | AfterFound


type Orientation
    = Row
    | Column


column : List (Attribute msg) -> List (Internal.Element msg) -> Internal.Element msg
column attrs children =
    Internal.element Internal.noStyleSheet
        Internal.asColumn
        Nothing
        (Element.height Element.shrink
            :: Element.width Element.fill
            :: attrs
        )
        (Internal.Unkeyed children)


row : List (Attribute msg) -> List (Internal.Element msg) -> Internal.Element msg
row attrs children =
    Internal.element
        Internal.noStyleSheet
        Internal.asRow
        Nothing
        (Element.width Element.fill
            :: attrs
        )
        (Internal.Unkeyed <| Internal.rowEdgeFillers children)



{- Event Handlers -}


{-| -}
onEnter : msg -> Attribute msg
onEnter msg =
    onKey 13 msg


{-| -}
onSpace : msg -> Attribute msg
onSpace msg =
    onKey 32 msg


{-| -}
onUpArrow : msg -> Attribute msg
onUpArrow msg =
    onKey 38 msg


{-| -}
onRightArrow : msg -> Attribute msg
onRightArrow msg =
    onKey 39 msg


{-| -}
onLeftArrow : msg -> Attribute msg
onLeftArrow msg =
    onKey 37 msg


{-| -}
onDownArrow : msg -> Attribute msg
onDownArrow msg =
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


leftArrow : Int
leftArrow =
    37


rightArrow : Int
rightArrow =
    39


downArrow : Int
downArrow =
    40


space : Int
space =
    32


{-| -}
onKey : Int -> msg -> Attribute msg
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
    Events.onWithOptions "keyup"
        { stopPropagation = False
        , preventDefault = True
        }
        isKey


preventKeydown : Int -> a -> Internal.Attribute a
preventKeydown desiredCode msg =
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
    Events.onWithOptions "keydown"
        { stopPropagation = False
        , preventDefault = True
        }
        isKey


{-| -}
onKeyLookup : (Int -> Maybe msg) -> Attribute msg
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
    Events.on "keyup" isKey


{-| -}
onFocusOut : msg -> Attribute msg
onFocusOut msg =
    Internal.Attr <| Html.Events.on "focusout" (Json.succeed msg)


{-| -}
onFocusIn : msg -> Attribute msg
onFocusIn msg =
    Internal.Attr <| Html.Events.on "focusin" (Json.succeed msg)


type_ : String -> Attribute msg
type_ =
    Internal.Attr << Html.Attributes.type_


checked : Bool -> Attribute msg
checked =
    Internal.Attr << Html.Attributes.checked


selected : Bool -> Attribute msg
selected =
    Internal.Attr << Html.Attributes.selected


name : String -> Attribute msg
name =
    Internal.Attr << Html.Attributes.name


value : String -> Attribute msg
value =
    Internal.Attr << Html.Attributes.value


textValue : String -> Attribute msg
textValue =
    Internal.Attr << Html.Attributes.defaultValue


tabindex : Int -> Attribute msg
tabindex =
    Internal.Attr << Html.Attributes.tabindex


disabled : Bool -> Attribute msg
disabled =
    Internal.Attr << Html.Attributes.disabled


spellcheck : Bool -> Attribute msg
spellcheck =
    Internal.Attr << Html.Attributes.spellcheck


readonly : Bool -> Attribute msg
readonly =
    Internal.Attr << Html.Attributes.readonly


autofill : String -> Attribute msg
autofill =
    Internal.Attr << Html.Attributes.attribute "autocomplete"


{-| -}
focusedOnLoad : Attribute msg
focusedOnLoad =
    Internal.Attr <| Html.Attributes.autofocus True



{- Style Defaults -}


defaultTextBoxStyle : List (Attribute msg)
defaultTextBoxStyle =
    [ defaultTextPadding
    , Border.rounded 3
    , Border.color lightGrey
    , Background.color white
    , Border.width 1
    , Element.spacing 3
    ]


defaultTextPadding : Attribute msg
defaultTextPadding =
    Element.paddingXY 12 7


defaultCheckbox : Bool -> Element msg
defaultCheckbox checked =
    Element.el
        [ Internal.class "focusable"
        , Element.width (Element.px 12)
        , Element.height (Element.px 12)

        -- , Font.family
        --     [ Font.typeface "georgia"
        --     , Font.serif
        --     ]
        , Font.color white
        , Font.size 9
        , Font.center
        , Border.rounded 3
        , Border.color <|
            if checked then
                Color.rgb 59 153 252
            else
                Color.rgb 211 211 211
        , Border.shadow <|
            { offset = ( 0, 0 )
            , blur = 1
            , size = 1
            , color =
                if checked then
                    Color.rgba 238 238 238 0
                else
                    Color.rgb 238 238 238
            }
        , Background.color <|
            if checked then
                Color.rgb 59 153 252
            else
                white
        , Border.width <|
            if checked then
                0
            else
                1
        ]
        (if checked then
            Element.text "✓"
         else
            Element.empty
        )
