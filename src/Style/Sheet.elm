module Style.Sheet exposing (embed, render, merge, map)

{-| -}

import Style.Internal.Model as Internal
import Html.Attributes
import Html exposing (Html)


{-| The stylesheet contains the rendered css as a string, and two functions to lookup
-}
type alias StyleSheet class variation animation msg =
    { style : class -> Html.Attribute msg
    , variations : class -> List ( variation, Bool ) -> Html.Attribute msg
    , animate : class -> List ( animation, Bool ) -> Html.Attribute msg
    , css : String
    }


type ChildSheet class variation animation
    = ChildSheet (List (Style class variation animation))


{-| -}
type alias Style class variation animation =
    Internal.BatchedStyle class variation animation


{-| -}
render : List (Style class variation animation) -> StyleSheet class variation animation msg
render styles =
    { style = (\class -> Html.Attributes.class "test")
    , variations = (\class variations -> Html.Attributes.class "test")
    , animate = (\class variations -> Html.Attributes.class "test")
    , css = ""
    }


{-| -}
embed : StyleSheet class variation animation msg -> Html msg
embed stylesheet =
    Html.node "style" [] [ Html.text "" ]


{-| -}
map : (class -> parent) -> List (Style class variation animation) -> ChildSheet parent variation animation
map toParent styles =
    let
        updateClass fn style =
            case style of
                Internal.Single internal ->
                    Internal.Single <| Internal.mapClass toParent internal

                Internal.Many styles ->
                    Internal.Many <| List.map (Internal.mapClass toParent) styles
    in
        ChildSheet (List.map (updateClass toParent) styles)


{-| Merge a child stylesheet into a parent.
-}
merge : ChildSheet class variation animation -> Style class variation animation
merge (ChildSheet styles) =
    let
        flatten node existing =
            case node of
                Internal.Single style ->
                    style :: existing

                Internal.Many styles ->
                    styles ++ existing
    in
        Internal.Many (List.foldr flatten [] styles)
