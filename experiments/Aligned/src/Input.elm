module Input exposing (..)

{-| -}

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


-- {-| Base Attribute type
-- -}
-- type Attr inputOptions msg
--     = Attr inputOptions msg
-- {-| Input attributes can have errors, and can't have events attached to them.
-- -}
-- type alias InputAttribute msg =
--     Attr msg msg
-- type alias NormalAttribute msg =
--     Attr () msg
-- type alias Attribute msg =
--     Internal.Attribute msg
{- Control of attributes.


   Input options should only work



   Disabled
       -> msg is easily removeable.
       -> A style change can be triggered


   FocusOnLoad
       -> Do we really care?


   Autofill
       -> Maybe provide the most common categories as direct functions like we already do for username and password

   Errors/ Warnings
       ->

   Labels
       -> Required for all inputs


   Placeholder
        -> Optional for text inputs


-}
-- type Error msg
--     = ErrorBelow (Element msg)
--     | ErrorAbove (Element msg)
-- type Label msg
--     = LabelBelow (Element msg)
--     | LabelAbove (Element msg)
--     | LabelOnRight (Element msg)
--     | LabelOnLeft (Element msg)
--     | HiddenLabel String
-- {-|
--      Input.checkbox
--         [ Input.warning
--             [] (text "")
--         , Input.error True
--             [] (text "This box needs to be checked!")
--         , Input.required
--         ]
--         { onChange = Just Check
--         , checked = model.checkbox
--         , icon = Nothing
--         , label = Input.label [] (text "hello!")
--         }
-- -}
-- label : List (Attribute msg) -> Element msg -> Label msg
-- label attrs el =
-- placeholder : List (Attribute msg) -> Label msg -> Label msg
-- placeholder attrs label =
--     label
-- {-| -}
-- hiddenLabel : String -> Label msg
-- hiddenLabel =
--     HiddenLabel


type Placeholder msg
    = Placeholder (Element msg)


{-| -}
placeholder : List (Attribute msg) -> Element msg -> Placeholder msg
placeholder attrs child =
    Placeholder <| Internal.el Nothing (Element.height Element.fill :: attrs) child


type Label msg
    = Label Internal.Grid.RelativePosition (List (Attribute msg)) (Element msg)


type Notice msg
    = Notice Internal.Grid.RelativePosition (List (Attribute msg)) (Element msg)


labelRight : List (Attribute msg) -> Element msg -> Label msg
labelRight =
    Label Internal.Grid.OnRight


labelLeft : List (Attribute msg) -> Element msg -> Label msg
labelLeft =
    Label Internal.Grid.OnLeft


labelAbove : List (Attribute msg) -> Element msg -> Label msg
labelAbove =
    Label Internal.Grid.Above


labelBelow : List (Attribute msg) -> Element msg -> Label msg
labelBelow =
    Label Internal.Grid.Below


warningRight : List (Attribute msg) -> Element msg -> Notice msg
warningRight =
    Notice Internal.Grid.OnRight


warningLeft : List (Attribute msg) -> Element msg -> Notice msg
warningLeft =
    Notice Internal.Grid.OnLeft


warningAbove : List (Attribute msg) -> Element msg -> Notice msg
warningAbove =
    Notice Internal.Grid.Above


warningBelow : List (Attribute msg) -> Element msg -> Notice msg
warningBelow =
    Notice Internal.Grid.Below


errorRight : List (Attribute msg) -> Element msg -> Notice msg
errorRight =
    Notice Internal.Grid.OnRight


errorLeft : List (Attribute msg) -> Element msg -> Notice msg
errorLeft =
    Notice Internal.Grid.OnLeft


errorAbove : List (Attribute msg) -> Element msg -> Notice msg
errorAbove =
    Notice Internal.Grid.Above


errorBelow : List (Attribute msg) -> Element msg -> Notice msg
errorBelow =
    Notice Internal.Grid.Below


{-| -}
type alias Button msg =
    { onPress : Maybe msg
    , label : Element msg
    }


{-| A standard button.

The onPress message will be sent on either `onClick` or when the enter key has been pressed.

The message will fire exactly once per enter key press when the key is lifted.

-}
button : List (Attribute msg) -> Button msg -> Element msg
button attrs { onPress, label } =
    Internal.element Internal.asEl
        -- We don't explicitly label this node as a button,
        -- because buttons fire a bunch of times when you hold down the enter key.
        -- We'd like to fire just once on the enter key, which means using keyup instead of keydown.
        -- Because we have no way to disable keydown, though our messages get doubled.
        Nothing
        (Internal.htmlClass "se el"
            :: Element.width Element.shrink
            :: Element.height Element.shrink
            :: Element.centerY
            :: Element.center
            :: Element.pointer
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
    , notice : Maybe (Notice msg)
    }


{-| Your basic checkbox
-}
checkbox : List (Attribute msg) -> Checkbox msg -> Element msg
checkbox attrs { label, icon, checked, onChange, notice } =
    --     Desired Output
    --      <label>
    --          <input type="checkbox" checked/>
    --          <div class="label">Here is my checkbox</div>
    --          <div class="warning">This needs to be checked</div>
    --      </label>
    let
        input =
            Internal.el
                (Just "input")
                [ Internal.Attr <| Html.Attributes.type_ "checkbox"
                , Internal.Attr <| Html.Attributes.checked checked
                , Element.centerY
                ]
                Element.empty

        attributes =
            (case onChange of
                Nothing ->
                    Internal.Attr (Html.Attributes.disabled True)

                Just checkMsg ->
                    Internal.Attr (Html.Events.onCheck checkMsg)
            )
                :: attrs
    in
    positionLabels attributes label notice input


{-| -}
type alias Slider msg =
    { onChange : Maybe (Int -> msg)
    , range : ( Int, Int )
    , value : Int
    , label : Label msg
    , notice : Maybe (Notice msg)
    }


sliderX : List (Attribute msg) -> Slider msg -> Element msg
sliderX attributes input =
    let
        behavior =
            case input.onChange of
                Nothing ->
                    [ Internal.Attr (Html.Attributes.disabled True) ]

                Just changeCoord ->
                    [ Events.onMouseCoords (\{ x, y } -> changeCoord x)
                    ]

        min =
            Tuple.first input.range

        max =
            Tuple.second input.range

        percentage =
            ((toFloat input.value - toFloat min) / (toFloat max - toFloat min)) + toFloat min

        icon =
            Element.el
                [ Element.width (Element.px 10)
                , Element.height (Element.px 10)
                , Background.color lightBlue
                , Border.rounded 5
                , Element.alignLeft
                , Element.moveUp 5
                , Element.pointer
                , Element.moveRight percentage
                ]
                Element.empty

        controls =
            Internal.el
                Nothing
                ([ Background.color grey
                 , Element.width Element.fill
                 , Element.height (Element.px 1)
                 ]
                    ++ behavior
                    ++ attributes
                )
                icon
    in
    positionLabels
        [ Element.width Element.fill ]
        input.label
        input.notice
        controls


type TextType
    = Plain
    | Username
    | NewPassword
    | CurrentPassword
    | Email
    | Search


{-| -}
type alias Text msg =
    { onChange : Maybe (String -> msg)
    , text : String
    , placeholder : Maybe (Placeholder msg)
    , label : Label msg
    , notice : Maybe (Notice msg)
    }


defaultTextPadding =
    Element.paddingXY 15 5


textHelper : TextType -> List (Attribute msg) -> Text msg -> Element msg
textHelper textType attributes textOptions =
    let
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
            Internal.el
                (Just "input")
                (List.concat
                    [ [ value textOptions.text
                      , defaultTextPadding
                      ]
                    , textTypeAttr
                    , behavior
                    , attributes
                    ]
                )
                Element.empty

        input =
            case textOptions.placeholder of
                Nothing ->
                    inputElement

                Just (Placeholder placeholder) ->
                    Internal.el Nothing
                        [ Element.inFront <|
                            Element.when (textOptions.text == "") <|
                                Internal.el Nothing
                                    (Font.color charcoal
                                        :: defaultTextPadding
                                        :: Element.height Element.fill
                                        :: Element.width Element.fill
                                        :: inputPadding
                                    )
                                    placeholder
                        ]
                        inputElement
    in
    positionLabels
        parentAttributes
        textOptions.label
        textOptions.notice
        input


{-| -}
text : List (Attribute msg) -> Text msg -> Element msg
text =
    textHelper Plain


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
multilineHelper : SpellChecked -> List (Attribute msg) -> Text msg -> Element msg
multilineHelper spellchecked attributes textOptions =
    let
        behavior =
            case textOptions.onChange of
                Nothing ->
                    [ Internal.Attr (Html.Attributes.disabled True) ]

                Just checkMsg ->
                    [ Internal.Attr (Html.Events.onInput checkMsg) ]

        -- Special height calculator
        -- Height content needs to be translated into a special class
        -- descriptions are also disallowed
        ( padding, heightContent, adjustedAttributes ) =
            attributes
                |> List.foldr
                    (\attr ( pad, height, newAttrs ) ->
                        case attr of
                            Internal.Describe _ ->
                                ( pad, height, newAttrs )

                            Internal.Height Internal.Content ->
                                case height of
                                    Nothing ->
                                        ( pad, Just True, newAttrs )

                                    Just i ->
                                        ( pad, height, newAttrs )

                            Internal.Height _ ->
                                case height of
                                    Nothing ->
                                        ( pad, Just False, attr :: newAttrs )

                                    Just i ->
                                        ( pad, height, newAttrs )

                            Internal.StyleClass (Internal.PaddingStyle t r b l) ->
                                ( Just ( t, r, b, l ), height, attr :: newAttrs )

                            _ ->
                                ( pad, height, attr :: newAttrs )
                    )
                    ( Nothing, Nothing, [] )

        withHeight =
            case heightContent of
                Just True ->
                    let
                        newlineCount =
                            String.lines textOptions.text
                                |> List.length
                                -- |> ((+) 1)
                                |> toFloat

                        heightValue =
                            case padding of
                                Nothing ->
                                    toString (newlineCount * 1.5) ++ "em"

                                Just ( t, r, b, l ) ->
                                    "calc(" ++ toString (newlineCount * 1.5) ++ "em + " ++ toString (t + b) ++ "px)"

                        heightClass =
                            Internal.StyleClass
                                (Internal.Single ("textarea-height-" ++ toString newlineCount)
                                    "height"
                                    heightValue
                                )
                    in
                    Internal.class "overflow-hidden" :: heightClass :: adjustedAttributes

                _ ->
                    adjustedAttributes

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

        inputPadding =
            Internal.get attributes <|
                \attr ->
                    case attr of
                        Internal.StyleClass (Internal.PaddingStyle _ _ _ _) ->
                            True

                        _ ->
                            False

        placeholder =
            case textOptions.placeholder of
                Nothing ->
                    []

                Just (Placeholder placeholder) ->
                    [ Element.inFront <|
                        Element.when (textOptions.text == "") <|
                            Internal.el Nothing (Font.color charcoal :: inputPadding) placeholder
                    ]

        textarea =
            Internal.el
                (Just "textarea")
                (List.concat
                    [ [ value textOptions.text
                      , case spellchecked of
                            SpellChecked ->
                                spellcheck True

                            NotSpellChecked ->
                                spellcheck False
                      ]
                    , behavior
                    , withHeight
                    ]
                )
                (Internal.unstyled (Html.text textOptions.text))

        input =
            Internal.el Nothing
                placeholder
                textarea
    in
    positionLabels attributesFromChild textOptions.label textOptions.notice input


type SpellChecked
    = SpellChecked
    | NotSpellChecked


{-| -}
multiline : List (Attribute msg) -> Text msg -> Element msg
multiline =
    multilineHelper NotSpellChecked


{-| -}
spellcheckedMultiline : List (Attribute msg) -> Text msg -> Element msg
spellcheckedMultiline =
    multilineHelper SpellChecked


{-| -}
positionLabels : List (Attribute msg) -> Label msg -> Maybe (Notice msg) -> Element msg -> Element msg
positionLabels attributes label notice input =
    Internal.Grid.relative (Just "label")
        attributes
        input
        (List.filterMap identity
            [ case label of
                Label position labelAttrs child ->
                    Just
                        { layout = Internal.Grid.GridElement
                        , child = [ child ]
                        , attrs = Element.alignLeft :: labelAttrs
                        , position = position
                        , width = 1
                        , height = 1
                        }
            , case notice of
                Nothing ->
                    Nothing

                Just (Notice position labelAttrs child) ->
                    Just
                        { layout = Internal.Grid.GridElement
                        , child = [ child ]
                        , attrs = Element.alignLeft :: labelAttrs
                        , position = position
                        , width = 1
                        , height = 1
                        }
            ]
        )


{-| -}
type alias Radio option msg =
    { onChange : Maybe (option -> msg)
    , options : List (Option option msg)
    , selected : Maybe option
    , label : Label msg
    , notice : Maybe (Notice msg)
    }


{-| Add choices to your radio and select menus.
-}
type Option value msg
    = Option value (OptionState -> Element msg) (Element msg)


{-| -}
type OptionState
    = Idle
    | Focused
    | Selected
    | SelectedInBox
    | Disabled


option value text =
    Option value
        defaultRadioIcon
        text


defaultRadioIcon : OptionState -> Element msg
defaultRadioIcon status =
    case status of
        Idle ->
            Element.el
                [ Element.width (Element.px 10)
                , Element.height (Element.px 10)
                , Background.color grey
                , Border.rounded 5
                ]
                Element.empty

        Disabled ->
            Element.el
                [ Element.width (Element.px 10)
                , Element.height (Element.px 10)
                , Background.color grey
                , Border.rounded 5
                ]
                Element.empty

        Focused ->
            Element.el
                [ Element.width (Element.px 10)
                , Element.height (Element.px 10)
                , Background.color lightBlue
                , Border.rounded 5
                ]
                Element.empty

        Selected ->
            Element.el
                [ Element.width (Element.px 10)
                , Element.height (Element.px 10)
                , Background.color blue
                , Border.rounded 5
                ]
                Element.empty

        SelectedInBox ->
            Element.el
                [ Element.width (Element.px 10)
                , Element.height (Element.px 10)
                , Background.color blue
                , Border.rounded 5
                ]
                Element.empty


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


radioHelper : Orientation -> List (Attribute msg) -> Radio option msg -> Element msg
radioHelper orientation attrs input =
    let
        spacing =
            Internal.getSpacingAttribute attrs ( 5, 5 )

        renderOption (Option value icon text) =
            let
                status =
                    if Just value == input.selected then
                        Selected
                    else
                        Idle
            in
            Element.row
                [ spacing
                , case input.onChange of
                    Nothing ->
                        Internal.NoAttribute

                    Just send ->
                        Events.onClick (send value)
                ]
                [ icon status
                , Element.el [ Element.width Element.fill ] text
                ]

        optionArea =
            case orientation of
                Row ->
                    row attrs
                        (List.map renderOption input.options)

                Column ->
                    column attrs
                        (List.map renderOption input.options)
    in
    positionLabels [ Element.alignLeft ] input.label input.notice optionArea


type Orientation
    = Row
    | Column


column attrs children =
    Internal.column
        (--Internal.Class "y-content-align" "content-top"
         -- :: Internal.Class "x-content-align" "content-center-x"
         Element.height Element.shrink
            :: Element.width Element.fill
            :: attrs
        )
        (Internal.Unkeyed children)


row attrs children =
    Internal.row
        (--Internal.Class "x-content-align" "content-center-x"
         -- :: Internal.Class "y-content-align" "content-center-y"
         Element.width Element.fill
            :: attrs
        )
        (Internal.Unkeyed <| Internal.rowEdgeFillers children)



-- <| Internal.columnEdgeFillers children)
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
onUp : msg -> Attribute msg
onUp msg =
    onKey 38 msg


{-| -}
onDown : msg -> Attribute msg
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


autofocus : Bool -> Attribute msg
autofocus =
    Internal.Attr << Html.Attributes.autofocus
