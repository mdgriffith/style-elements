module Element.Internal.Render exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Element.Style.Internal.Model as Internal exposing (Length)
import Element.Style.Internal.Render.Value as Value
import Element.Style.Internal.Cache as StyleCache
import Element.Style.Internal.Render as Render
import Element.Style.Internal.Selector as Selector
import Element.Style.Internal.Render.Property
import Element.Internal.Model exposing (..)


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


render : ElementSheet elem variation animation msg -> Element elem variation msg -> Html msg
render (ElementSheet defaults findNode) elm =
    let
        ( html, stylecache ) =
            renderElement [] findNode elm

        withDefaults =
            stylecache
                |> StyleCache.embed "default-typeface"
                    (Render.class "default-typeface"
                        [ "font-family"
                            => (defaults.typeface
                                    |> List.map (\fam -> "\"" ++ fam ++ "\"")
                                    |> String.join ", "
                               )
                        , "color" => Value.color defaults.textColor
                        , "line-height" => toString defaults.lineHeight
                        , "font-size" => (toString defaults.fontSize ++ "px")
                        ]
                    )
                |> StyleCache.embed "default-spacing"
                    (Render.class "default-spacing > *:not(.nospacing)"
                        [ "margin" => Value.box defaults.spacing
                        ]
                    )
    in
        Html.div [ Html.Attributes.class "default-typeface" ]
            [ StyleCache.render withDefaults renderStyle findNode
            , html
            ]


renderElement : List (Attribute variation msg) -> (elem -> Styled elem variation animation msg) -> Element elem variation msg -> ( Html msg, StyleCache.Cache elem )
renderElement inherited findNode elm =
    case elm of
        Empty ->
            ( Html.text "", StyleCache.empty )

        Text dec str ->
            case dec of
                NoDecoration ->
                    ( Html.text str
                    , StyleCache.empty
                    )

                Bold ->
                    ( Html.strong [] [ Html.text str ]
                    , StyleCache.empty
                    )

                Italic ->
                    ( Html.em [] [ Html.text str ]
                    , StyleCache.empty
                    )

                Underline ->
                    ( Html.u [] [ Html.text str ]
                    , StyleCache.empty
                    )

                Strike ->
                    ( Html.s [] [ Html.text str ]
                    , StyleCache.empty
                    )

        Element element position child otherChildren ->
            let
                ( childHtml, styleset ) =
                    case otherChildren of
                        Nothing ->
                            let
                                ( chil, sty ) =
                                    renderElement [] findNode child
                            in
                                ( [ chil ]
                                , sty
                                )

                        Just others ->
                            List.foldr renderAndCombine ( [], StyleCache.empty ) (child :: others)

                renderAndCombine child ( html, styles ) =
                    let
                        ( childHtml, childStyle ) =
                            renderElement [] findNode child
                    in
                        ( childHtml :: html, StyleCache.combine childStyle styles )

                attributes =
                    inherited ++ position
            in
                case element of
                    Nothing ->
                        ( renderNode Nothing (renderInline attributes) Nothing childHtml
                        , styleset
                        )

                    Just el ->
                        ( renderNode element (renderInline attributes) (Just <| findNode el) childHtml
                        , styleset
                            |> StyleCache.insert el
                        )

        Layout layout spacingAllowed maybeElement position children ->
            let
                ( spacing, attributes ) =
                    List.partition forSpacing position

                forSpacing posAttr =
                    case posAttr of
                        Spacing _ ->
                            True

                        _ ->
                            False

                ( childHtml, styleset ) =
                    List.foldr renderAndCombine ( [], StyleCache.empty ) children

                renderAndCombine child ( html, styles ) =
                    let
                        ( childHtml, childStyle ) =
                            renderElement spacing findNode child
                    in
                        ( childHtml :: html, StyleCache.combine childStyle styles )

                parentStyle =
                    Element.Style.Internal.Render.Property.layout layout ++ renderInline attributes
            in
                case maybeElement of
                    Nothing ->
                        ( renderNode Nothing parentStyle Nothing childHtml
                        , styleset
                        )

                    Just element ->
                        ( renderNode (Just element) parentStyle (Just <| findNode element) childHtml
                        , styleset
                            |> StyleCache.insert element
                        )


renderNode : Maybe elem -> List ( String, String ) -> Maybe (Styled elem variation animation msg) -> List (Html msg) -> Html msg
renderNode maybeElem inlineStyle maybeNode children =
    let
        ( node, attrs ) =
            case maybeNode of
                Nothing ->
                    ( Html.div, [] )

                Just (El node attrs) ->
                    ( node, attrs )

        normalAttrs attr =
            case attr of
                Attr a ->
                    Just a

                _ ->
                    Nothing

        attributes =
            List.filterMap normalAttrs attrs

        renderedAttrs =
            case maybeElem of
                Nothing ->
                    (Html.Attributes.style inlineStyle :: attributes)

                Just elem ->
                    (Html.Attributes.style inlineStyle :: Html.Attributes.class (Selector.formatName elem) :: attributes)
    in
        node renderedAttrs children


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
        Internal.Style elem (List.filterMap styleProps attrs)


type WithSpacing
    = InlineSpacing
    | NoInlineSpacing


renderInline : List (Attribute variation msg) -> List ( String, String )
renderInline adjustments =
    let
        defaults =
            [ "position" => "relative"
            , "box-sizing" => "border-box"
            ]

        renderAdjustment adj =
            case adj of
                Variations variations ->
                    []

                Height len ->
                    [ "height" => Value.length len ]

                Width len ->
                    [ "width" => Value.length len ]

                Position x y ->
                    [ "transform" => ("translate(" ++ toString x ++ "px, " ++ toString y ++ "px)")
                    ]

                PositionFrame Screen ->
                    [ "position" => "fixed"
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

                Anchor Left ->
                    [ "left" => "0" ]

                Anchor Top ->
                    [ "top" => "0" ]

                Anchor Bottom ->
                    [ "bottom" => "0" ]

                Anchor Right ->
                    [ "right" => "0" ]

                Spacing box ->
                    [ "margin" => Value.box box ]

                Padding box ->
                    [ "padding" => Value.box box ]

                Hidden ->
                    [ "display" => "none" ]

                Transparency t ->
                    [ "opacity" => (toString <| 1 - t) ]

                Event ev ->
                    []
    in
        defaults ++ List.concatMap renderAdjustment adjustments
