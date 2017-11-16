module Next.Slim.Input exposing (..)

{-| -}

import Html.Attributes
import Html.Events
import Next.Slim.Element as Element
import Next.Slim.Element.Attributes as Attributes
import Next.Slim.Internal.Model exposing (..)
import VirtualDom


type Error msg
    = ErrorBelow (Element msg)
    | ErrorAbove (Element msg)


type Label msg
    = LabelBelow (Element msg)
    | LabelAbove (Element msg)
    | LabelOnRight (Element msg)
    | LabelOnLeft (Element msg)
    | HiddenLabel String


{-| -}
type Option msg
    = ErrorOpt (Error msg)
    | Disabled
    | FocusOnLoad
    | AutoFill String


{-| -}
type alias Checkbox msg =
    { onChange : Bool -> msg
    , checked : Bool
    , label : Element msg
    }


{-| Your basic checkbox

    Input.checkbox  []
        { onChange = Check
        , checked = model.checkbox
        , label = text "hello!"
        }

Desired Output

    <label>
        <input type="checkbox" checked/>
        Here is my checkbox
    </label>

-}
checkbox : List (Attribute msg) -> Checkbox msg -> Element msg
checkbox attrs checkbox =
    Element.empty


{-| -}
type alias Text msg =
    { onChange : String -> msg
    , text : String
    , placeholder : Maybe (Element msg)
    , label : Label msg
    }


{-| -}
text : List (Attribute msg) -> Text msg -> Element msg
text attrs context =
    let
        input =
            Unstyled <|
                VirtualDom.node "label"
                    [ Html.Attributes.class "se el width-fill height-fill" ]
                    [ VirtualDom.node "input"
                        [ Html.Attributes.class "se el width-fill height-fill"
                        , Html.Attributes.type_ "text"
                        , Html.Attributes.value context.text
                        , Html.Attributes.spellcheck False
                        , Html.Events.onInput context.onChange
                        ]
                        []
                    ]

        layout =
            case context.label of
                LabelBelow label ->
                    column attrs [ input, label ]

                LabelAbove label ->
                    column attrs [ input, label ]

                LabelOnRight label ->
                    row attrs [ input, label ]

                LabelOnLeft label ->
                    row attrs [ input, label ]

                HiddenLabel string ->
                    el attrs input
    in
    render
        (htmlClass "se el"
            :: Attributes.width Element.shrink
            :: Attributes.height Element.shrink
            :: Attributes.centerY
            :: Attributes.center
            :: attrs
        )
        []



-- {-| -}
-- text : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- text =
--     textHelper Plain []
-- {-| -}
-- search : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- search =
--     textHelper Search []
-- {-| A password input that allows the browser to autofill.
-- It's `newPassword` instead of just `password` because it gives the browser a hint on what type of password input it is.
-- -}
-- newPassword : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- newPassword =
--     textHelper Password [ AutoFill "new-password" ]
-- {-| -}
-- currentPassword : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- currentPassword =
--     textHelper Password [ AutoFill "current-password" ]
-- {-| -}
-- username : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- username =
--     textHelper Plain [ AutoFill "username" ]
-- {-| -}
-- email : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- email =
--     textHelper Email [ AutoFill "email" ]
-- {-| -}
-- multiline : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- multiline =
--     textHelper TextArea []
-- {-| -}
-- spellchecked : style -> List (Attribute variation msg) -> Text style variation msg -> Element style variation msg
-- spellchecked =
--     textHelper TextArea []
