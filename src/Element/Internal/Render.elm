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
import Element.Style.Sheet
import Element.Internal.Model exposing (..)


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


render : ElementSheet elem variation animation msg -> Element elem variation msg -> Html msg
render (ElementSheet { defaults, stylesheet }) elm =
    let
        ( html, stylecache ) =
            renderElement Nothing elm

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
            [ Element.Style.Sheet.embed stylesheet
            , html
            ]


type alias Context variation msg =
    { inherited : List (Attribute variation msg)
    , layout : Internal.LayoutModel
    }


renderElement : Maybe (Context variation msg) -> Element elem variation msg -> ( Html msg, StyleCache.Cache elem )
renderElement context elm =
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
                                    renderElement Nothing child
                            in
                                ( [ chil ]
                                , sty
                                )

                        Just others ->
                            List.foldr renderAndCombine ( [], StyleCache.empty ) (child :: others)

                renderAndCombine child ( html, styles ) =
                    let
                        ( childHtml, childStyle ) =
                            renderElement Nothing child
                    in
                        ( childHtml :: html, StyleCache.combine childStyle styles )

                attributes =
                    case context of
                        Nothing ->
                            position

                        Just ctxt ->
                            ctxt.inherited ++ position
            in
                case element of
                    Nothing ->
                        ( renderNode Nothing (renderInline context attributes) childHtml
                        , styleset
                        )

                    Just el ->
                        ( renderNode element (renderInline context attributes) childHtml
                        , styleset
                            |> StyleCache.insert el
                        )

        Layout layout maybeElement position children ->
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
                            renderElement (Just { inherited = spacing, layout = layout }) child
                    in
                        ( childHtml :: html, StyleCache.combine childStyle styles )

                intermediate =
                    renderInline context attributes

                parentStyle =
                    { intermediate
                        | inline = intermediate.inline ++ Element.Style.Internal.Render.Property.layout layout
                    }
            in
                case maybeElement of
                    Nothing ->
                        ( renderNode Nothing parentStyle childHtml
                        , styleset
                        )

                    Just element ->
                        ( renderNode (Just element) parentStyle childHtml
                        , styleset
                            |> StyleCache.insert element
                        )


renderNode : Maybe elem -> IntermediateProps variation msg -> List (Html msg) -> Html msg
renderNode maybeElem intermediate children =
    let
        node =
            Html.div

        normalAttrs attr =
            case attr of
                Attr a ->
                    Just a

                _ ->
                    Nothing

        variationClasses =
            if List.length intermediate.variations > 0 then
                List.map Selector.formatName intermediate.variations
                    |> String.join " "
            else
                ""

        renderedAttrs =
            case maybeElem of
                Nothing ->
                    (Html.Attributes.style intermediate.inline
                        :: intermediate.attrs
                    )

                Just elem ->
                    (Html.Attributes.style intermediate.inline
                        :: Html.Attributes.class (Selector.formatName elem ++ variationClasses)
                        :: intermediate.attrs
                    )
    in
        node renderedAttrs children


renderStyle : elem -> Styled elem variation animation msg -> Internal.Style elem variation animation
renderStyle elem (El node attrs) =
    -- let
    --     -- styleProps attr =
    --     --     case attr of
    --     --         Style a ->
    --     --             Just a
    --     --         _ ->
    --     --             Nothing
    -- in
    Internal.Style elem attrs


type alias IntermediateProps variation msg =
    { inline : List ( String, String )
    , variations : List variation
    , attrs : List (Html.Attribute msg)
    }


renderInline : Maybe (Context variation msg) -> List (Attribute variation msg) -> IntermediateProps variation msg
renderInline maybeContext attrs =
    let
        gather adj found =
            case adj of
                Vary vary on ->
                    if on then
                        { found | variations = vary :: found.variations }
                    else
                        found

                Height len ->
                    { found | inline = ( "height", Value.length len ) :: found.inline }

                Width len ->
                    { found | inline = ( "width", Value.length len ) :: found.inline }

                Position x y ->
                    { found
                        | inline =
                            ( "transform"
                            , ("translate(" ++ toString x ++ "px, " ++ toString y ++ "px)")
                            )
                                :: found.inline
                    }

                PositionFrame Screen ->
                    { found | inline = ( "position", "fixed" ) :: found.inline }

                PositionFrame Above ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "bottom" => "100%"
                            ]
                                ++ found.inline
                    }

                PositionFrame Below ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "top" => "100%"
                            ]
                                ++ found.inline
                    }

                PositionFrame OnLeft ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "right" => "100%"
                            ]
                                ++ found.inline
                    }

                PositionFrame OnRight ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "left" => "100%"
                            ]
                                ++ found.inline
                    }

                Anchor Top ->
                    { found | inline = ( "top", "0" ) :: found.inline }

                Anchor Bottom ->
                    { found | inline = ( "bottom", "0" ) :: found.inline }

                Anchor Left ->
                    case maybeContext of
                        Just { layout } ->
                            case layout of
                                Internal.TextLayout ->
                                    { found | inline = ( "float", "left" ) :: found.inline }

                                _ ->
                                    { found | inline = ( "left", "0" ) :: found.inline }

                        _ ->
                            { found | inline = ( "left", "0" ) :: found.inline }

                Anchor Right ->
                    case maybeContext of
                        Just { layout } ->
                            case layout of
                                Internal.TextLayout ->
                                    { found | inline = ( "float", "right" ) :: found.inline }

                                _ ->
                                    { found | inline = ( "right", "0" ) :: found.inline }

                        _ ->
                            { found | inline = ( "right", "0" ) :: found.inline }

                Spacing box ->
                    { found | inline = ( "margin", Value.box box ) :: found.inline }

                Padding box ->
                    { found | inline = ( "padding", Value.box box ) :: found.inline }

                Hidden ->
                    { found | inline = ( "display", "none" ) :: found.inline }

                Transparency t ->
                    { found | inline = ( "opacity", (toString <| 1 - t) ) :: found.inline }

                Event ev ->
                    { found | attrs = ev :: found.attrs }

                Attr attr ->
                    { found | attrs = attr :: found.attrs }

        defaults =
            [ "position" => "relative"
            , "box-sizing" => "border-box"
            ]

        empty =
            { inline = []
            , variations = []
            , attrs = []
            }

        withProps =
            List.foldr gather empty attrs
    in
        { withProps | inline = defaults ++ withProps.inline }
