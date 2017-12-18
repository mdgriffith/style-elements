module Input exposing (..)

{-| -}

-- import Element.Attributes as Attributes

import Element exposing (Attribute, Element)
import Element.Events as Events
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
    , placeholder : Maybe (Element msg)
    , label : Label msg
    , notice : Maybe (Notice msg)
    }


textHelper : TextType -> List (Attribute msg) -> Text msg -> Element msg
textHelper textType attributes textOptions =
    let
        placeholder =
            case textOptions.placeholder of
                Nothing ->
                    []

                Just placeholder ->
                    [ Element.inFront <|
                        Element.when (textOptions.text == "") placeholder
                    ]

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

        input =
            Internal.el
                (Just "input")
                (List.concat
                    [ [ value textOptions.text
                      , Element.paddingXY 15 5
                      ]
                    , textTypeAttr
                    , behavior
                    , placeholder
                    , attributes
                    ]
                )
                Element.empty

        spacing =
            Internal.getSpacingAttribute attributes ( 5, 5 )
    in
    positionLabels
        [ spacing ]
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
multiline : List (Attribute msg) -> Text msg -> Element msg
multiline attributes textOptions =
    let
        placeholder =
            case textOptions.placeholder of
                Nothing ->
                    []

                Just placeholder ->
                    [ Element.inFront <|
                        Element.when (textOptions.text == "") placeholder
                    ]

        behavior =
            case textOptions.onChange of
                Nothing ->
                    [ Internal.Attr (Html.Attributes.disabled True) ]

                Just checkMsg ->
                    [ Internal.Attr (Html.Events.onInput checkMsg) ]

        input =
            Internal.el
                (Just "textarea")
                (List.concat
                    [ [ value textOptions.text ]
                    , behavior
                    , placeholder
                    , attributes
                    ]
                )
                (Internal.unstyled (Html.text textOptions.text))
    in
    positionLabels [] textOptions.label textOptions.notice input



-- {-| -}
-- spellchecked :  List (Attribute msg) -> Text msg -> Element msg
-- spellchecked =
--     textHelper TextArea []


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



-- positionLabels : List (Attribute msg) -> Label msg -> Maybe (Notice msg) -> Element msg -> Element msg
-- positionLabels attributes label notice input =
--     let
--         spacing =
--             Internal.getSpacing attributes ( 5, 5 )
--         row children =
--             case children of
--                 [] ->
--                     Nothing
--                 el :: [] ->
--                     Just <| el
--                 childs ->
--                     Just <| Element.row [ Element.width Element.fill, spacing ] childs
--         column children =
--             case children of
--                 [] ->
--                     Nothing
--                 el :: [] ->
--                     Just <| el
--                 childs ->
--                     Just <| Element.column [ Element.width Element.fill, spacing ] childs
--         addToPosition position el group =
--             case position of
--                 Above ->
--                     { group | above = el :: group.above }
--                 Below ->
--                     { group | below = el :: group.below }
--                 OnRight ->
--                     { group | right = el :: group.right }
--                 OnLeft ->
--                     { group | left = el :: group.left }
--         nearbyGroup =
--             case label of
--                 Label position labelAttrs child ->
--                     { above = []
--                     , below = []
--                     , right = []
--                     , left = []
--                     }
--                         |> (\group ->
--                                 case notice of
--                                     Nothing ->
--                                         group
--                                     Just (Notice position noticeAttrs child) ->
--                                         addToPosition position (Element.el (Element.alignLeft :: noticeAttrs) child) group
--                            )
--                         -- This step comes after the above because order matters for the layout
--                         |> addToPosition position (Element.el labelAttrs child)
--     in
--     if nearbyGroup.left == [] && nearbyGroup.right == [] then
--         Internal.element Internal.asColumn
--             (Just "label")
--             (Internal.htmlClass "se column"
--                 :: Element.width Element.fill
--                 :: Element.height Element.shrink
--                 :: Internal.Class "y-content-align" "content-top"
--                 -- :: Element.centerY
--                 -- :: Element.center
--                 :: attributes
--             )
--             (Internal.Unkeyed <|
--                 List.filterMap identity
--                     [ row nearbyGroup.above
--                     , Just input
--                     , row nearbyGroup.below
--                     ]
--             )
--     else if nearbyGroup.above == [] && nearbyGroup.below == [] then
--         Internal.element Internal.asRow
--             (Just "label")
--             (Internal.htmlClass "se row"
--                 :: Element.width Element.fill
--                 :: Element.height Element.shrink
--                 :: Internal.Class "y-content-align" "content-top"
--                 :: attributes
--             )
--             (Internal.Unkeyed <|
--                 Internal.rowEdgeFillers <|
--                     List.filterMap identity
--                         [ column nearbyGroup.left
--                         , Just input
--                         , column nearbyGroup.right
--                         ]
--             )
--     else
--         Internal.element Internal.asRow
--             (Just "label")
--             (Internal.htmlClass "se row"
--                 :: Element.width Element.fill
--                 :: Element.height Element.shrink
--                 :: Internal.Class "y-content-align" "content-top"
--                 :: attributes
--             )
--             (Internal.Unkeyed <|
--                 List.filterMap identity
--                     [ column nearbyGroup.left
--                     , column <|
--                         List.filterMap identity
--                             [ row nearbyGroup.above
--                             , Just input
--                             , row nearbyGroup.below
--                             ]
--                     , column nearbyGroup.right
--                     ]
--             )
