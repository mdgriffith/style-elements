module Element.Style.Internal.Render exposing (stylesheet, unbatchedStylesheet, spacing)

{-|
-}

import Element.Style.Internal.Model as Internal exposing (..)
import Element.Style.Internal.Render.Property as Render
import Element.Style.Internal.Render.Value as Value
import Element.Style.Internal.Selector as Selector exposing (Selector)
import Element.Style.Internal.Batchable as Batchable exposing (Batchable)
import Element.Style.Internal.Intermediate as Intermediate
import Element.Style.Internal.Render.Css as Css


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


single : Bool -> Internal.Style class variation animation -> ( String, String )
single guard style =
    Intermediate.raw << renderStyle guard << preprocess <| style


spacing : ( Float, Float, Float, Float ) -> ( String, String )
spacing box =
    let
        name =
            case box of
                ( a, b, c, d ) ->
                    "spacing-" ++ toString a ++ "-" ++ toString b ++ "-" ++ toString c ++ "-" ++ toString d ++ " > *:not(.nospacing)"
    in
        Css.prop 2 ( "margin", Value.box box )
            |> Css.brace 0
            |> (\cls -> ( name, "." ++ name ++ cls ))


stylesheet : Bool -> List (Batchable (Internal.Style class variation animation)) -> Intermediate.Rendered class variation animation
stylesheet guard batched =
    batched
        |> Batchable.toList
        |> List.map (renderStyle guard << preprocess)
        |> Intermediate.finalize


unbatchedStylesheet : Bool -> List (Internal.Style class variation animation) -> Intermediate.Rendered class variation animation
unbatchedStylesheet guard styles =
    styles
        |> List.map (renderStyle guard << preprocess)
        |> Intermediate.finalize


{-| This handles rearranging some properties before they're rendered.

Such as:

  * Move drop shadows to the filter property
  * Visibility should override layout.  Visibility should override previous visibility as well.
  * Move color palettes to the end


-}
preprocess : Style class variation animation -> Style class variation animation
preprocess style =
    case style of
        Internal.Import str ->
            Internal.Import str

        Internal.Style class props ->
            let
                visible prop =
                    case prop of
                        Visibility _ ->
                            True

                        _ ->
                            False

                palette prop =
                    case prop of
                        Palette _ ->
                            True

                        _ ->
                            False

                shadows prop =
                    case prop of
                        Shadows _ ->
                            True

                        _ ->
                            False

                prioritize isPriority props =
                    let
                        ( high, low ) =
                            List.partition isPriority props
                    in
                        low ++ high

                overridePrevious overridable props =
                    let
                        eliminatePrevious prop ( existing, overridden ) =
                            if overridable prop && overridden then
                                ( existing, overridden )
                            else if overridable prop && not overridden then
                                ( prop :: existing, True )
                            else
                                ( prop :: existing, overridden )
                    in
                        List.foldr eliminatePrevious ( [], False ) props
                            |> Tuple.first

                dropShadow (ShadowModel shade) =
                    shade.kind == "drop"

                moveDropShadow props =
                    let
                        asDropShadow (ShadowModel shadow) =
                            DropShadow
                                { offset = shadow.offset
                                , size = shadow.size
                                , blur = shadow.blur
                                , color = shadow.color
                                }

                        moveDropped prop ( existing, dropped ) =
                            case prop of
                                Shadows shadows ->
                                    ( (Shadows <| List.filter (not << dropShadow) shadows) :: existing
                                    , case List.filter dropShadow shadows of
                                        [] ->
                                            Nothing

                                        d ->
                                            Just d
                                    )

                                Filters filters ->
                                    case dropped of
                                        Nothing ->
                                            ( prop :: existing
                                            , dropped
                                            )

                                        Just drop ->
                                            ( Filters (filters ++ (List.map asDropShadow drop)) :: existing
                                            , dropped
                                            )

                                _ ->
                                    ( prop :: existing, dropped )
                    in
                        List.foldr moveDropped ( [], Nothing ) props
                            |> Tuple.first

                processed =
                    props
                        |> prioritize visible
                        |> overridePrevious visible
                        |> prioritize palette
                        |> overridePrevious palette
                        |> prioritize shadows
                        |> overridePrevious shadows
                        |> moveDropShadow
            in
                Internal.Style class processed


renderStyle : Bool -> Style class variation animation -> Intermediate.Class class variation animation
renderStyle guarded style =
    case style of
        Internal.Import str ->
            Intermediate.Free <| "@import " ++ str ++ ";"

        Internal.Style class props ->
            let
                selector =
                    Selector.select class

                inter =
                    Intermediate.Class
                        { selector = selector
                        , props = List.map (renderProp selector) props
                        }

                guard i =
                    if guarded then
                        Intermediate.guard i
                    else
                        i
            in
                inter
                    |> guard


renderProp : Selector class variation animation -> Property class variation animation -> Intermediate.Prop class variation animation
renderProp parentClass prop =
    case prop of
        Child class props ->
            (Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.child parentClass (Selector.select class)
                , props = List.map (renderProp parentClass) props
                }

        Variation var props ->
            (Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.variant parentClass var
                , props = List.filterMap (renderVariationProp parentClass) props
                }

        PseudoElement class props ->
            (Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.pseudo class parentClass
                , props = List.map (renderProp parentClass) props
                }

        MediaQuery query props ->
            (Intermediate.SubClass << Intermediate.Media)
                { query = "@media " ++ query
                , selector = parentClass
                , props =
                    props
                        |> List.map (renderProp parentClass)
                        |> List.map (Intermediate.asMediaQuery query)
                }

        Exact name val ->
            Intermediate.props <| [ ( name, val ) ]

        Visibility vis ->
            Intermediate.props <| Render.visibility vis

        Border props ->
            Intermediate.props <| ( "border-style", "solid" ) :: List.map Render.border props

        Box props ->
            Intermediate.props <| List.map Render.box props

        Position pos ->
            Intermediate.props <| Render.position pos

        Font props ->
            Intermediate.props <| List.map Render.font props

        Layout lay ->
            Intermediate.props (Render.layout lay)

        Background props ->
            Intermediate.props <| Render.background props

        Shadows shadows ->
            Intermediate.props <| Render.shadow shadows

        Transform transformations ->
            Intermediate.props <| Render.transformations transformations

        Filters filters ->
            Intermediate.props <| Render.filters filters

        Palette colors ->
            Intermediate.props <| List.map Render.colorElement colors

        Transitions trans ->
            Intermediate.props <|
                [ ( "transition"
                  , trans
                        |> List.map Render.transition
                        |> String.join ", "
                  )
                ]


renderVariationProp : Selector class variation animation -> Property class Never animation -> Maybe (Intermediate.Prop class variation animation)
renderVariationProp parentClass prop =
    case prop of
        Child class props ->
            Nothing

        Variation var props ->
            Nothing

        PseudoElement class props ->
            (Just << Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.pseudo class parentClass
                , props = List.filterMap (renderVariationProp parentClass) props
                }

        MediaQuery query props ->
            (Just << Intermediate.SubClass << Intermediate.Media)
                { query = "@media " ++ query
                , selector = parentClass
                , props =
                    props
                        |> List.filterMap (renderVariationProp parentClass)
                        |> List.map (Intermediate.asMediaQuery query)
                }

        Exact name val ->
            (Just << Intermediate.props) [ ( name, val ) ]

        Visibility vis ->
            (Just << Intermediate.props) <| Render.visibility vis

        Border props ->
            (Just << Intermediate.props) <| List.map Render.border props

        Box props ->
            (Just << Intermediate.props) <| List.map Render.box props

        Position pos ->
            (Just << Intermediate.props) <| Render.position pos

        Font props ->
            (Just << Intermediate.props) <| List.map Render.font props

        Layout lay ->
            (Just << Intermediate.props) (Render.layout lay)

        Background props ->
            (Just << Intermediate.props) <| Render.background props

        Shadows shadows ->
            (Just << Intermediate.props) <| Render.shadow shadows

        Transform transformations ->
            (Just << Intermediate.props) <| Render.transformations transformations

        Filters filters ->
            (Just << Intermediate.props) <| Render.filters filters

        Palette colors ->
            (Just << Intermediate.props) <| List.map Render.colorElement colors

        Transitions trans ->
            Just <|
                Intermediate.props
                    [ ( "transition"
                      , trans
                            |> List.map Render.transition
                            |> String.join ", "
                      )
                    ]
