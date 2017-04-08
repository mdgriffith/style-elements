module Style.Sheet exposing (embed, render, guarded, merge, map)

{-| -}

import Style.Internal.Model as Internal
import Style.Internal.Render as Render
import Style.Internal.Find as Find
import Style exposing (Style)
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
render : List (Style class variation animation) -> StyleSheet class variation animation msg
render styles =
    prepareSheet (Render.stylesheet False styles)


{-| -}
guarded : List (Style class variation animation) -> StyleSheet class variation animation msg
guarded styles =
    prepareSheet (Render.stylesheet True styles)


prepareSheet : List ( String, List (Find.Element class variation animation) ) -> StyleSheet class variation animation msg
prepareSheet rendered =
    let
        findable =
            rendered
                |> List.concatMap Tuple.second

        variations class variations =
            let
                parent =
                    Find.style class findable

                varys =
                    variations
                        |> List.filter Tuple.second
                        |> List.map ((\vary -> Find.variation class vary findable) << Tuple.first)
                        |> List.map (\cls -> ( cls, True ))
            in
                Html.Attributes.classList (( parent, True ) :: varys)
    in
        { style = \class -> Html.Attributes.class (Find.style class findable)
        , variations = \class varys -> variations class varys
        , animate = \class variations -> Html.Attributes.class "test"
        , css =
            rendered
                |> List.map Tuple.first
                |> String.join "\n"
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
