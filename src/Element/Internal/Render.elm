module Element.Internal.Render exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Style.Internal.Model as Internal exposing (Length)
import Style.Internal.Render.Value as Value
import Style.Internal.Cache as StyleCache
import Style.Internal.Render as Render
import Style.Internal.Selector as Selector
import Style.Internal.Render.Property
import Element.Internal.Model exposing (..)


(=>) =
    (,)


render : (elem -> Styled elem variation animation msg) -> Element elem variation -> Html msg
render findNode elm =
    let
        ( html, stylecache ) =
            renderElement findNode elm
    in
        Html.div []
            [ StyleCache.render stylecache renderStyle findNode
            , html
            ]


renderElement : (elem -> Styled elem variation animation msg) -> Element elem variation -> ( Html msg, StyleCache.Cache elem )
renderElement findNode elm =
    case elm of
        Empty ->
            ( Html.text "", StyleCache.empty )

        Text str ->
            ( Html.text str, StyleCache.empty )

        Element element position child ->
            let
                ( childHtml, styleset ) =
                    renderElement findNode child

                elemHtml =
                    renderNode element (renderInline InlineSpacing position) (findNode element) [ childHtml ]
            in
                ( elemHtml
                , styleset
                    |> StyleCache.insert element
                )

        Layout layout element position children ->
            let
                parentStyle =
                    Style.Internal.Render.Property.layout layout ++ renderInline NoSpacing position

                ( childHtml, styleset ) =
                    List.foldr renderAndCombine ( [], StyleCache.empty ) children

                renderAndCombine child ( html, styles ) =
                    let
                        ( childHtml, childStyle ) =
                            renderElement findNode child
                    in
                        ( childHtml :: html, StyleCache.combine childStyle styles )

                forSpacing posAttr =
                    case posAttr of
                        Spacing a b c d ->
                            Just ( a, b, c, d )

                        _ ->
                            Nothing

                spacing =
                    position
                        |> List.filterMap forSpacing
                        |> List.head

                spacingName ( a, b, c, d ) =
                    "spacing-" ++ toString a ++ "-" ++ toString b ++ "-" ++ toString c ++ "-" ++ toString d

                addSpacing cache =
                    case spacing of
                        Nothing ->
                            cache

                        Just space ->
                            let
                                ( name, rendered ) =
                                    Render.spacing space
                            in
                                StyleCache.embed name rendered cache

                parent =
                    renderLayoutNode element (Maybe.map spacingName spacing) parentStyle (findNode element) childHtml
            in
                ( parent
                , styleset
                    |> StyleCache.insert element
                    |> addSpacing
                )


renderNode : elem -> List ( String, String ) -> Styled elem variation animation msg -> List (Html msg) -> Html msg
renderNode elem inlineStyle (El node attrs) children =
    let
        normalAttrs attr =
            case attr of
                Attr a ->
                    Just a

                _ ->
                    Nothing

        attributes =
            List.filterMap normalAttrs attrs
                |> List.concat

        styleName =
            Html.Attributes.class (Selector.formatName elem)
    in
        node (Html.Attributes.style inlineStyle :: styleName :: attributes) children


renderLayoutNode : elem -> Maybe String -> List ( String, String ) -> Styled elem variation animation msg -> List (Html msg) -> Html msg
renderLayoutNode elem mSpacingClass inlineStyle (El node attrs) children =
    let
        normalAttrs attr =
            case attr of
                Attr a ->
                    Just a

                _ ->
                    Nothing

        attributes =
            List.filterMap normalAttrs attrs
                |> List.concat

        classes =
            case mSpacingClass of
                Nothing ->
                    Html.Attributes.class (Selector.formatName elem)

                Just space ->
                    Html.Attributes.class <| Selector.formatName elem ++ " " ++ space
    in
        node (Html.Attributes.style inlineStyle :: classes :: attributes) children


renderStyle : elem -> Styled elem variation animation msg -> Internal.Style elem variation animation
renderStyle elem (El node attrs) =
    let
        styleProps attr =
            case attr of
                Style a ->
                    Just a

                _ ->
                    Nothing
    in
        Internal.Style elem (List.concat <| List.filterMap styleProps attrs)


type WithSpacing
    = InlineSpacing
    | NoSpacing


renderInline : WithSpacing -> List (Attribute variation) -> List ( String, String )
renderInline spacing adjustments =
    let
        renderAdjustment adj =
            case adj of
                Variations variations ->
                    []

                Height len ->
                    [ "height" => Value.length len ]

                Width len ->
                    [ "width" => Value.length len ]

                Position x y ->
                    [ "transform" => ("translate(" ++ toString x ++ "px " ++ toString y ++ ")")
                    ]

                PositionFrame Above ->
                    [ "position" => "absolute"
                    , "bottom" => "100%"
                    ]

                PositionFrame Below ->
                    [ "position" => "absolute"
                    , "top" => "100%"
                    ]

                PositionFrame OnLeft ->
                    [ "position" => "absolute"
                    , "right" => "100%"
                    ]

                PositionFrame OnRight ->
                    [ "position" => "absolute"
                    , "left" => "100%"
                    ]

                Spacing a b c d ->
                    case spacing of
                        InlineSpacing ->
                            [ "margin" => Value.box ( a, b, c, d ) ]

                        NoSpacing ->
                            []

                Hidden ->
                    [ "display" => "none" ]

                Transparency t ->
                    [ "opacity" => (toString <| 1 - t) ]
    in
        List.concatMap renderAdjustment adjustments
