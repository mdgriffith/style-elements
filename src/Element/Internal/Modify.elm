module Element.Internal.Modify
    exposing
        ( setNode
        , addAttrToNonText
        , addAttr
        , removeAttrs
        , addChild
        , addAttrList
        , removeAllAttrs
        , removeContent
        , getStyle
        , getAttrs
        , removeStyle
        , getChild
        , setAttrs
        )

{-| -}

import Element.Internal.Model as Internal exposing (..)


setNode : String -> Element style variation msg -> Element style variation msg
setNode node el =
    case el of
        Empty ->
            Empty

        Raw h ->
            Raw h

        Spacer x ->
            Spacer x

        Layout _ layout elem attrs children ->
            Layout node layout elem attrs children

        Element _ elem attrs child otherChildren ->
            Element node elem attrs child otherChildren

        Text dec content ->
            Element node Nothing [] (Text dec content) Nothing


addAttrToNonText : Attribute variation msg -> Element style variation msg -> Element style variation msg
addAttrToNonText prop el =
    case el of
        Empty ->
            Empty

        Raw h ->
            Raw h

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Text dec content


addAttr : Attribute variation msg -> Element style variation msg -> Element style variation msg
addAttr prop el =
    case el of
        Empty ->
            Empty

        Raw h ->
            Raw h

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Element "div" Nothing [ prop ] (Text dec content) Nothing


addAttrList : List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
addAttrList props el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout node layout elem attrs els ->
            Layout node layout elem (props ++ attrs) els

        Element node elem attrs el children ->
            Element node elem (props ++ attrs) el children

        Text dec content ->
            Element "div" Nothing props (Text dec content) Nothing


setAttrs : List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
setAttrs props el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout node layout elem _ els ->
            Layout node layout elem props els

        Element node elem _ el children ->
            Element node elem props el children

        Text dec content ->
            Text dec content


removeAttrs : List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
removeAttrs props el =
    let
        match p =
            not <| List.member p props
    in
        case el of
            Empty ->
                Empty

            Raw h ->
                Raw h

            Spacer x ->
                Spacer x

            Layout node layout elem attrs els ->
                Layout node layout elem (List.filter match attrs) els

            Element node elem attrs el children ->
                Element node elem (List.filter match attrs) el children

            Text dec content ->
                Text dec content


removeAllAttrs : Element style variation msg -> Element style variation msg
removeAllAttrs el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout node layout elem _ els ->
            Layout node layout elem [] els

        Element node elem _ el children ->
            Element node elem [] el children

        Text dec content ->
            Text dec content


addChild : Element style variation msg -> Element style variation msg -> Element style variation msg
addChild parent el =
    case parent of
        Empty ->
            Element "div" Nothing [] Empty (Just [ el ])

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout node layout elem attrs children ->
            case children of
                Normal childs ->
                    Layout node layout elem attrs (Normal (el :: childs))

                -- This is wrong, but this lib doesn't currently support keyed absolutely positioned children...so it's not a problem for now.
                Keyed childs ->
                    Layout node layout elem attrs (Normal (el :: List.map Tuple.second childs))

        Element node elem attrs child otherChildren ->
            case otherChildren of
                Nothing ->
                    Element node elem attrs child (Just [ el ])

                Just others ->
                    Element node elem attrs child (Just (el :: others))

        Text dec content ->
            Element "div" Nothing [] (Text dec content) (Just [ el ])


getAttrs : Element style variation msg -> List (Attribute variation msg)
getAttrs el =
    case el of
        Empty ->
            []

        Spacer x ->
            []

        Raw h ->
            []

        Layout _ _ _ attrs _ ->
            attrs

        Element _ _ attrs _ _ ->
            attrs

        Text dec content ->
            []


getStyle : Element style variation msg -> Maybe style
getStyle el =
    case el of
        Empty ->
            Nothing

        Raw h ->
            Nothing

        Spacer x ->
            Nothing

        Layout _ _ style _ _ ->
            style

        Element _ style _ _ _ ->
            style

        Text _ _ ->
            Nothing


removeStyle : Element style variation msg -> Element style variation msg
removeStyle el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout node layout _ attrs els ->
            Layout node layout Nothing attrs els

        Element node _ attrs el children ->
            Element node Nothing attrs el children

        Text dec content ->
            Text dec content


removeContent : Element style variation msg -> Element style variation msg
removeContent el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout node layout elem attrs children ->
            Layout node layout elem attrs (Normal [])

        Element node elem attrs child otherChildren ->
            Element node elem attrs Empty otherChildren

        Text _ _ ->
            Empty


getChild : Element style variation msg -> Element style variation msg
getChild el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout node layout elem attrs children ->
            el

        Element node elem attrs child otherChildren ->
            child

        Text dec content ->
            Text dec content
