module Input exposing (..)

{-| -}

import Element
import Element.Attributes as Attributes
import Element.Events as Events
import Html
import Html.Attributes
import Html.Events
import Internal.Model as Internal exposing (..)
import Json.Decode as Json
import VirtualDom


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


type alias Attribute msg =
    Internal.Attribute msg



{- Control of attributes.


   Input options should only work



   Disabled
       -> msg is easily removeable.
       -> A style change can be triggered


   FocusOnLoad
       -> Do we really care?


   Autofill
       -> Maybe provide the most common categories as direct functions like we already do for username and password

   Errors
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
    = Label Location (List (Attribute msg)) (Element msg)


type Notice msg
    = Notice Location (List (Attribute msg)) (Element msg)


labelRight : List (Attribute msg) -> Element msg -> Label msg
labelRight =
    Label OnRight


labelLeft : List (Attribute msg) -> Element msg -> Label msg
labelLeft =
    Label OnLeft


labelAbove : List (Attribute msg) -> Element msg -> Label msg
labelAbove =
    Label Above


labelBelow : List (Attribute msg) -> Element msg -> Label msg
labelBelow =
    Label Below


warningRight : List (Attribute msg) -> Element msg -> Notice msg
warningRight =
    Notice OnRight


warningLeft : List (Attribute msg) -> Element msg -> Notice msg
warningLeft =
    Notice OnLeft


warningAbove : List (Attribute msg) -> Element msg -> Notice msg
warningAbove =
    Notice Above


warningBelow : List (Attribute msg) -> Element msg -> Notice msg
warningBelow =
    Notice Below


errorRight : List (Attribute msg) -> Element msg -> Notice msg
errorRight =
    Notice OnRight


errorLeft : List (Attribute msg) -> Element msg -> Notice msg
errorLeft =
    Notice OnLeft


errorAbove : List (Attribute msg) -> Element msg -> Notice msg
errorAbove =
    Notice Above


errorBelow : List (Attribute msg) -> Element msg -> Notice msg
errorBelow =
    Notice Below


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
    element Internal.asEl
        -- We don't explicitly label this node as a button,
        -- because buttons fire a bunch of times when you hold down the enter key.
        -- We'd like to fire just once on the enter key, which means using keyup instead of keydown.
        -- Because we have no way to disable keydown, though our messages get doubled.
        Nothing
        (htmlClass "se el"
            :: Attributes.width Element.shrink
            :: Attributes.height Element.shrink
            :: Attributes.centerY
            :: Attributes.center
            :: Describe Internal.Button
            :: Attr (Html.Attributes.tabindex 0)
            :: (case onPress of
                    Nothing ->
                        Attr (Html.Attributes.disabled True) :: attrs

                    Just msg ->
                        Events.onClick msg
                            :: onEnter msg
                            :: attrs
               )
        )
        [ label ]


{-| -}
type alias Checkbox msg =
    { onChange : Maybe (Bool -> msg)
    , icon : Maybe (Element msg)
    , checked : Bool
    , label : Label msg
    , notice : Maybe (Notice msg)
    }


{-| Your basic checkbox

    Input.checkbox  []
        { onChange = Just Check
        , checked = model.checkbox
        , icon = Nothing
        , label = Input.label (text "hello!")
        }

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
                , Attributes.centerY
                ]
                Element.empty

        attributes =
            (case onChange of
                Nothing ->
                    Attr (Html.Attributes.disabled True)

                Just checkMsg ->
                    Attr (Html.Events.onCheck checkMsg)
            )
                :: attrs
    in
    positionLabels attributes label notice input


positionLabels : List (Attribute msg) -> Label msg -> Maybe (Notice msg) -> Element msg -> Element msg
positionLabels attributes label notice input =
    let
        spacing =
            Internal.getSpacing attributes ( 5, 5 )

        row children =
            case children of
                [] ->
                    Nothing

                el :: [] ->
                    Just <| el

                childs ->
                    Just <| Element.row [ Attributes.width Element.fill, spacing ] childs

        column children =
            case children of
                [] ->
                    Nothing

                el :: [] ->
                    Just <| el

                childs ->
                    Just <| Element.column [ Attributes.width Element.fill, spacing ] childs

        addToPosition position el group =
            case position of
                Above ->
                    { group | above = el :: group.above }

                Below ->
                    { group | below = el :: group.below }

                OnRight ->
                    { group | right = el :: group.right }

                OnLeft ->
                    { group | left = el :: group.left }

                Overlay ->
                    { group | overlay = el :: group.overlay }

        nearbyGroup =
            case label of
                Label position labelAttrs child ->
                    { above = []
                    , below = []
                    , right = []
                    , left = []
                    , overlay = []
                    }
                        |> (\group ->
                                case notice of
                                    Nothing ->
                                        group

                                    Just (Notice position noticeAttrs child) ->
                                        addToPosition position (Element.el (Attributes.alignLeft :: noticeAttrs) child) group
                           )
                        -- This step comes after the above because order matters for the layout
                        |> addToPosition position (Element.el labelAttrs child)
    in
    if nearbyGroup.left == [] && nearbyGroup.right == [] then
        Internal.element Internal.asColumn
            (Just "label")
            (htmlClass "se column"
                :: Attributes.width Element.shrink
                :: Attributes.height Element.shrink
                :: Attributes.centerY
                :: Attributes.center
                :: attributes
            )
            (List.filterMap identity
                [ row nearbyGroup.above
                , Just input
                , row nearbyGroup.below
                ]
            )
    else if nearbyGroup.above == [] && nearbyGroup.below == [] then
        Internal.element Internal.asRow
            (Just "label")
            (htmlClass "se row"
                :: Attributes.width Element.shrink
                :: Attributes.height Element.shrink
                :: Attributes.centerY
                :: Attributes.center
                :: attributes
            )
            (rowEdgeFillers <|
                List.filterMap identity
                    [ column nearbyGroup.left
                    , Just input
                    , column nearbyGroup.right
                    ]
            )
    else
        Internal.element Internal.asColumn
            (Just "label")
            (htmlClass "se column"
                :: Attributes.width Element.shrink
                :: Attributes.height Element.shrink
                :: Attributes.centerY
                :: Attributes.center
                :: attributes
            )
            (List.filterMap identity
                [ row nearbyGroup.above
                , row <|
                    List.filterMap identity
                        [ column nearbyGroup.left
                        , Just input
                        , column nearbyGroup.right
                        ]
                , row nearbyGroup.below
                ]
            )



-- text : List (Attribute msg) -> Text msg -> Element msg
-- text attrs { label, text, onChange, notice, placeholder } =
--     let
--         input =
--             Internal.el
--                 (Just "input")
--                 (Internal.Attr (Html.Attributes.type_ "text")
--                     :: attributes
--                 )
--                 Element.empty
--         attributes =
--             (case onChange of
--                 Nothing ->
--                     Attr (Html.Attributes.disabled True)
--                 Just checkMsg ->
--                     Attr (Html.Events.onInput checkMsg)
--             )
--                 :: attrs
--     in
--     positionLabels [] label notice input


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
textHelper textType attrs { label, text, onChange, notice, placeholder } =
    let
        textAttributes =
            case textType of
                Plain ->
                    [ Internal.Attr (Html.Attributes.type_ "text") ]

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
                (textAttributes
                    ++ attributes
                )
                Element.empty

        attributes =
            (case onChange of
                Nothing ->
                    Attr (Html.Attributes.disabled True)

                Just checkMsg ->
                    Attr (Html.Events.onInput checkMsg)
            )
                :: attrs
    in
    positionLabels [] label notice input


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



-- {-| -}
-- multiline : List (Attribute msg) -> Text msg -> Element msg
-- multiline =
--     textHelper Multiline
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
    Attr << Html.Attributes.type_


checked : Bool -> Attribute msg
checked =
    Attr << Html.Attributes.checked


selected : Bool -> Attribute msg
selected =
    Attr << Html.Attributes.selected


name : String -> Attribute msg
name =
    Attr << Html.Attributes.name


value : String -> Attribute msg
value =
    Attr << Html.Attributes.value


textValue : String -> Attribute msg
textValue =
    Attr << Html.Attributes.defaultValue


tabindex : Int -> Attribute msg
tabindex =
    Attr << Html.Attributes.tabindex


disabled : Bool -> Attribute msg
disabled =
    Attr << Html.Attributes.disabled


spellcheck : Bool -> Attribute msg
spellcheck =
    Attr << Html.Attributes.spellcheck


readonly : Bool -> Attribute msg
readonly =
    Attr << Html.Attributes.readonly


autofill : String -> Attribute msg
autofill =
    Attr << Html.Attributes.attribute "autocomplete"


autofocus : Bool -> Attribute msg
autofocus =
    Attr << Html.Attributes.autofocus
