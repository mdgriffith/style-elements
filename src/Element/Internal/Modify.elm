module Element.Internal.Modify exposing (setNode, addPropToNonText, addProp, removeProps, addChild)

{-| -}

import Element.Internal.Model as Internal exposing (..)
import Html


setNode : String -> Element style variation msg -> Element style variation msg
setNode node el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout _ layout elem attrs children ->
            Layout node layout elem attrs children

        Element _ elem attrs child otherChildren ->
            Element node elem attrs child otherChildren

        Text dec content ->
            Element node Nothing [] (Text dec content) Nothing


addPropToNonText : Attribute variation msg -> Element style variation msg -> Element style variation msg
addPropToNonText prop el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Text dec content


addProp : Attribute variation msg -> Element style variation msg -> Element style variation msg
addProp prop el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Element "div" Nothing [ prop ] (Text dec content) Nothing


removeProps : List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
removeProps props el =
    let
        match p =
            not <| List.member p props
    in
        case el of
            Empty ->
                Empty

            Spacer x ->
                Spacer x

            Layout node layout elem attrs els ->
                Layout node layout elem (List.filter match attrs) els

            Element node elem attrs el children ->
                Element node elem (List.filter match attrs) el children

            Text dec content ->
                Text dec content


addChild : Element style variation msg -> Element style variation msg -> Element style variation msg
addChild parent el =
    case parent of
        Empty ->
            Element "div" Nothing [] Empty (Just [ el ])

        Spacer x ->
            Spacer x

        Layout node layout elem attrs children ->
            Layout node layout elem attrs (el :: children)

        Element node elem attrs child otherChildren ->
            case otherChildren of
                Nothing ->
                    Element node elem attrs child (Just [ el ])

                Just others ->
                    Element node elem attrs child (Just (el :: others))

        Text dec content ->
            Element "div" Nothing [] (Text dec content) (Just [ el ])
