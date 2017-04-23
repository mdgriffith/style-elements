module Element.Style.Internal.Cache exposing (..)

{-| -}

import Dict exposing (Dict)
import Html
import Element.Style.Internal.Render as Render
import Element.Style.Internal.Intermediate as Intermediate exposing (Rendered(..))
import Element.Style.Internal.Model as Internal


type Cache elem
    = Cache (Dict String (Lookupable elem))


type Lookupable elem
    = Lookup elem
    | Embedded String


insert : elem -> Cache elem -> Cache elem
insert elem (Cache dict) =
    let
        key =
            toString (Lookup elem)
    in
        Cache <| Dict.insert key (Lookup elem) dict


embed : String -> String -> Cache elem -> Cache elem
embed key value (Cache dict) =
    Cache <| Dict.insert key (Embedded value) dict


combine : Cache elem -> Cache elem -> Cache elem
combine (Cache dict1) (Cache dict2) =
    Cache <| List.foldl (\( key, value ) dict -> Dict.insert key value dict) dict1 (Dict.toList dict2)


lookups : Cache elem -> List elem
lookups (Cache dict) =
    let
        forLookups x =
            case x of
                Lookup elem ->
                    Just elem

                _ ->
                    Nothing
    in
        Dict.values dict
            |> List.filterMap forLookups


empty : Cache elem
empty =
    Cache Dict.empty


partition : List (Lookupable elem) -> ( List elem, List String )
partition els =
    let
        part el ( elem, strs ) =
            case el of
                Lookup e ->
                    ( e :: elem, strs )

                Embedded str ->
                    ( elem, str :: strs )
    in
        List.foldr part ( [], [] ) els


render : Cache elem -> (elem -> a -> Internal.Style class variation animation) -> (elem -> a) -> Html.Html msg
render (Cache dict) renderStyle lookup =
    let
        ( keys, embedded ) =
            dict
                |> Dict.values
                |> partition

        rendered =
            List.map (\elem -> renderStyle elem <| lookup elem) keys
                |> Render.unbatchedStylesheet False
    in
        case rendered of
            Rendered { css } ->
                Html.node "style" [] [ Html.text ("\n" ++ String.join "\n" embedded ++ "\n" ++ css) ]



-- |> StyleCache.lookups
-- |> List.map (\elem -> renderStyle elem <| findNode elem)
-- |> Render.unbatchedStylesheet False
-- |> (\(Rendered { css }) -> Html.node "style" [] [ Html.text css ])
