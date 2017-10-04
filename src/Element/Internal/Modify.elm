module Element.Internal.Modify
    exposing
        ( addAttr
        , addAttrList
        , addAttrPriority
        , addAttrToNonText
        , addChild
        , getAttrs
        , getChild
        , getStyle
        , getText
        , getTextList
        , makeInline
        , removeAllAttrs
        , removeAttrs
        , removeContent
        , removeStyle
        , setAttrs
        , setNode
        , wrapHtml
        )

{-| -}

import Element.Internal.Model as Internal exposing (..)


{-| Wraps Html in an element.
-}
wrapHtml : Element style variation msg -> Element style variation msg
wrapHtml el =
    case el of
        Raw h ->
            Element
                { node = "div"
                , style = Nothing
                , attrs = []
                , child = Raw h
                , absolutelyPositioned = Nothing
                }

        x ->
            x


setNode : String -> Element style variation msg -> Element style variation msg
setNode node el =
    case el of
        Empty ->
            Empty

        Raw h ->
            Raw h

        Spacer x ->
            Spacer x

        Layout elm ->
            Layout { elm | node = node }

        Element elm ->
            Element { elm | node = node }

        Text dec content ->
            Element
                { node = node
                , style = Nothing
                , attrs = []
                , child = Text dec content
                , absolutelyPositioned = Nothing
                }


makeInline : Element style variation msg -> Element style variation msg
makeInline el =
    case el of
        Empty ->
            Empty

        Raw h ->
            Raw h

        Spacer x ->
            Spacer x

        Layout elm ->
            Layout { elm | attrs = Internal.Inline :: elm.attrs }

        Element elm ->
            Element
                { elm
                    | attrs = Internal.Inline :: elm.attrs
                    , child = makeInline elm.child
                }

        Text decoration content ->
            Text { decoration | inline = True } content


addAttrToNonText : Attribute variation msg -> Element style variation msg -> Element style variation msg
addAttrToNonText prop el =
    case el of
        Empty ->
            Empty

        Raw h ->
            Raw h

        Spacer x ->
            Spacer x

        Layout elm ->
            Layout { elm | attrs = prop :: elm.attrs }

        Element elm ->
            Element { elm | attrs = prop :: elm.attrs }

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

        Layout elm ->
            Layout { elm | attrs = prop :: elm.attrs }

        Element elm ->
            Element { elm | attrs = prop :: elm.attrs }

        Text dec content ->
            Element
                { node = "div"
                , style = Nothing
                , attrs = [ prop ]
                , child = Text dec content
                , absolutelyPositioned = Nothing
                }


addAttrPriority : Attribute variation msg -> Element style variation msg -> Element style variation msg
addAttrPriority prop el =
    case el of
        Empty ->
            Empty

        Raw h ->
            Raw h

        Spacer x ->
            Spacer x

        Layout elm ->
            Layout { elm | attrs = elm.attrs ++ [ prop ] }

        Element elm ->
            Element { elm | attrs = elm.attrs ++ [ prop ] }

        Text dec content ->
            Element
                { node = "div"
                , style = Nothing
                , attrs = [ prop ]
                , child = Text dec content
                , absolutelyPositioned = Nothing
                }


addAttrList : List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
addAttrList props el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout elm ->
            Layout { elm | attrs = props ++ elm.attrs }

        Element elm ->
            Element { elm | attrs = props ++ elm.attrs }

        Text dec content ->
            Element
                { node = "div"
                , style = Nothing
                , attrs = props
                , child = Text dec content
                , absolutelyPositioned = Nothing
                }


setAttrs : List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
setAttrs props el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout elm ->
            Layout { elm | attrs = props }

        Element elm ->
            Element { elm | attrs = props }

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

        Layout elm ->
            Layout { elm | attrs = List.filter match elm.attrs }

        Element elm ->
            Element { elm | attrs = List.filter match elm.attrs }

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

        Layout elm ->
            Layout { elm | attrs = [] }

        Element elm ->
            Element { elm | attrs = [] }

        Text dec content ->
            Text dec content


addChild : Element style variation msg -> Element style variation msg -> Element style variation msg
addChild parent el =
    case parent of
        Empty ->
            Element
                { node = "div"
                , style = Nothing
                , attrs = []
                , child = Empty
                , absolutelyPositioned = Just [ el ]
                }

        Spacer x ->
            Spacer x

        Raw h ->
            Raw h

        Layout ({ absolutelyPositioned } as elm) ->
            case absolutelyPositioned of
                Nothing ->
                    Layout { elm | absolutelyPositioned = Just [ el ] }

                Just others ->
                    Layout { elm | absolutelyPositioned = Just (el :: others) }

        Element ({ absolutelyPositioned } as elm) ->
            case absolutelyPositioned of
                Nothing ->
                    Element { elm | absolutelyPositioned = Just [ el ] }

                Just others ->
                    Element { elm | absolutelyPositioned = Just (el :: others) }

        Text dec content ->
            Element
                { node = "div"
                , style = Nothing
                , attrs = []
                , child = Text dec content
                , absolutelyPositioned = Just [ el ]
                }


getAttrs : Element style variation msg -> List (Attribute variation msg)
getAttrs el =
    case el of
        Empty ->
            []

        Spacer x ->
            []

        Raw h ->
            []

        Layout { attrs } ->
            attrs

        Element { attrs } ->
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

        Layout { style } ->
            style

        Element { style } ->
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

        Layout elm ->
            Layout { elm | style = Nothing }

        Element elm ->
            Element { elm | style = Nothing }

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

        Layout elm ->
            Layout
                { elm
                    | children = Normal []
                    , absolutelyPositioned = Nothing
                }

        Element elm ->
            Element
                { elm
                    | child = Empty
                    , absolutelyPositioned = Nothing
                }

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

        Layout _ ->
            el

        Element { child } ->
            child

        Text dec content ->
            Text dec content


getText : Element style variation msg -> String
getText el =
    case el of
        Empty ->
            ""

        Spacer x ->
            ""

        Raw h ->
            ""

        Layout { children } ->
            case children of
                Normal childs ->
                    childs
                        |> List.map getText
                        |> String.join "-"

                Keyed childs ->
                    childs
                        |> List.map (getText << Tuple.second)
                        |> String.join "-"

        Element { child } ->
            getText child

        Text dec content ->
            content


getTextList : Element style variation msg -> List String
getTextList el =
    case el of
        Empty ->
            []

        Spacer x ->
            []

        Raw h ->
            []

        Layout { children } ->
            case children of
                Normal childs ->
                    childs
                        |> List.concatMap getTextList

                Keyed childs ->
                    childs
                        |> List.concatMap (getTextList << Tuple.second)

        Element { child } ->
            getTextList child

        Text dec content ->
            [ content ]
