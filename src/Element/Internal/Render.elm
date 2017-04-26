module Element.Internal.Render exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Element.Style.Internal.Model as Internal exposing (Length)
import Element.Style.Internal.Render.Value as Value
import Element.Style.Internal.Cache as StyleCache
import Element.Style.Internal.Render as Render
import Element.Style.Internal.Selector as Selector
import Element.Style.Internal.Render.Property as Property
import Element.Style.Sheet
import Element.Internal.Model exposing (..)


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


render : ElementSheet elem variation animation msg -> Element elem variation msg -> Html msg
render (ElementSheet { defaults, stylesheet }) elm =
    let
        html =
            renderElement Nothing stylesheet elm

        -- withDefaults =
        --     stylecache
        --         |> StyleCache.embed "default-typeface"
        --             (Render.class "default-typeface"
        --                 [ "font-family"
        --                     => (defaults.typeface
        --                             |> List.map (\fam -> "\"" ++ fam ++ "\"")
        --                             |> String.join ", "
        --                        )
        --                 , "color" => Value.color defaults.textColor
        --                 , "line-height" => toString defaults.lineHeight
        --                 , "font-size" => (toString defaults.fontSize ++ "px")
        --                 ]
        --             )
        --         |> StyleCache.embed "default-spacing"
        --             (Render.class "default-spacing > *:not(.nospacing)"
        --                 [ "margin" => Value.box defaults.spacing
        --                 ]
        --             )
    in
        Html.div [ Html.Attributes.class "default-typeface" ]
            [ Element.Style.Sheet.embed stylesheet
            , html
            ]


type alias Context variation msg =
    { inherited : List (Attribute variation msg)
    , layout : Internal.LayoutModel
    }


renderElement : Maybe (Context variation msg) -> Internal.StyleSheet elem variation animation msg -> Element elem variation msg -> Html msg
renderElement context stylesheet elm =
    case elm of
        Empty ->
            Html.text ""

        Text dec str ->
            case dec of
                NoDecoration ->
                    Html.text str

                Bold ->
                    Html.strong [] [ Html.text str ]

                Italic ->
                    Html.em [] [ Html.text str ]

                Underline ->
                    Html.u [] [ Html.text str ]

                Strike ->
                    Html.s [] [ Html.text str ]

        Element node element position child otherChildren ->
            let
                childHtml =
                    case otherChildren of
                        Nothing ->
                            let
                                chil =
                                    renderElement Nothing stylesheet child
                            in
                                [ chil ]

                        Just others ->
                            List.map (renderElement Nothing stylesheet) (child :: others)

                attributes =
                    case context of
                        Nothing ->
                            position

                        Just ctxt ->
                            ctxt.inherited ++ position

                htmlAttrs =
                    renderAttributes element context stylesheet attributes
            in
                node htmlAttrs childHtml

        Layout node layout element position children ->
            let
                ( spacing, attributes ) =
                    List.partition forSpacing position

                forSpacing posAttr =
                    case posAttr of
                        Spacing _ ->
                            True

                        _ ->
                            False

                childHtml =
                    List.map (renderElement (Just { inherited = spacing, layout = layout }) stylesheet) children

                htmlAttrs =
                    renderAttributes element context stylesheet (LayoutAttr layout :: attributes)
            in
                node htmlAttrs childHtml


renderAnchor : Anchor -> List ( String, String )
renderAnchor anchor =
    case anchor of
        TopRight ->
            [ ( "top", "0" )
            , ( "right", "0" )
            ]

        TopLeft ->
            [ ( "top", "0" )
            , ( "left", "0" )
            ]

        BottomRight ->
            [ ( "bottom", "0" )
            , ( "right", "0" )
            ]

        BottomLeft ->
            [ ( "bottom", "0" )
            , ( "left", "0" )
            ]


renderAttributes : Maybe elem -> Maybe (Context variation msg) -> Internal.StyleSheet elem variation animation msg -> List (Attribute variation msg) -> List (Html.Attribute msg)
renderAttributes maybeElem maybeContext stylesheet attrs =
    let
        gather adj found =
            case adj of
                LayoutAttr layout ->
                    { found | inline = Property.layout layout ++ found.inline }

                Vary vary on ->
                    if on then
                        { found | variations = ( vary, on ) :: found.variations }
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

                PositionFrame (Screen anchor) ->
                    { found | inline = ( "position", "fixed" ) :: renderAnchor anchor ++ found.inline }

                PositionFrame (Within anchor) ->
                    { found | inline = ( "position", "fixed" ) :: renderAnchor anchor ++ found.inline }

                PositionFrame (Nearby Above) ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "bottom" => "100%"
                            ]
                                ++ found.inline
                    }

                PositionFrame (Nearby Below) ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "top" => "100%"
                            ]
                                ++ found.inline
                    }

                PositionFrame (Nearby OnLeft) ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "right" => "100%"
                            ]
                                ++ found.inline
                    }

                PositionFrame (Nearby OnRight) ->
                    { found
                        | inline =
                            [ "position" => "absolute"
                            , "left" => "100%"
                            ]
                                ++ found.inline
                    }

                Align Top ->
                    { found | inline = ( "top", "0" ) :: found.inline }

                Align Bottom ->
                    { found | inline = ( "bottom", "0" ) :: found.inline }

                Align Left ->
                    case maybeContext of
                        Just { layout } ->
                            case layout of
                                Internal.TextLayout ->
                                    { found | inline = ( "float", "left" ) :: found.inline }

                                _ ->
                                    { found | inline = ( "left", "0" ) :: found.inline }

                        _ ->
                            { found | inline = ( "left", "0" ) :: found.inline }

                Align Right ->
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

        classes =
            case maybeElem of
                Nothing ->
                    Nothing

                Just elem ->
                    if List.length withProps.variations > 0 then
                        Just <| stylesheet.variations elem withProps.variations
                    else
                        Just <| stylesheet.style elem
    in
        case classes of
            Nothing ->
                Html.Attributes.style (defaults ++ withProps.inline) :: withProps.attrs

            Just cls ->
                cls :: Html.Attributes.style (defaults ++ withProps.inline) :: withProps.attrs
