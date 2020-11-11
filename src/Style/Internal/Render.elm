module Style.Internal.Render
    exposing
        ( class
        , spacing
        , stylesheet
          -- , unbatchedStylesheet
        )

{-| -}

import Set
import Style.Internal.Batchable as Batchable exposing (Batchable)
import Style.Internal.Intermediate as Intermediate
import Style.Internal.Model as Internal exposing (..)
import Style.Internal.Render.Css as Css
import Style.Internal.Render.Property as Render
import Style.Internal.Render.Value as Value
import Style.Internal.Selector as Selector exposing (Selector)


-- single : Bool -> Internal.Style class variation -> ( String, String )
-- single guard style =
--     Intermediate.raw << renderStyle guard << preprocess <| style


class : String -> List ( String, String ) -> String
class name props =
    let
        renderedProps =
            props
                |> List.map (Css.prop 2)
                |> String.join "\n"
    in
    "." ++ name ++ Css.brace 0 renderedProps


spacing : Internal.Box Float -> ( String, String )
spacing box =
    let
        name =
            case box of
                Internal.Box a b c d ->
                    "spacing-" ++ String.fromFloat a ++ "-" ++ String.fromFloat b ++ "-" ++ String.fromFloat c ++ "-" ++ String.fromFloat d ++ " > *:not(.nospacing)"
    in
    Css.prop 2 ( "margin", Value.box box )
        |> Css.brace 0
        |> (\cls -> ( name, "." ++ name ++ cls ))


stylesheet : String -> Bool -> List (Batchable (Internal.Style class variation)) -> Intermediate.Rendered class variation
stylesheet reset guard batched =
    batched
        |> Batchable.toList
        |> reorderImportAddReset reset
        |> List.map (renderStyle guard << preprocess)
        |> Intermediate.finalize


reorderImportAddReset : String -> List (Style class variation) -> List (Style class variation)
reorderImportAddReset reset styles =
    let
        getFontStyle style =
            case style of
                Style _ props ->
                    let
                        forFont prop =
                            case prop of
                                FontFamily fams ->
                                    let
                                        forImport font =
                                            case font of
                                                ImportFont _ url ->
                                                    Just url

                                                _ ->
                                                    Nothing
                                    in
                                    List.filterMap forImport fams

                                _ ->
                                    []
                    in
                    List.concatMap forFont props

                _ ->
                    []

        importedFonts =
            styles
                |> List.concatMap getFontStyle
                |> (Set.toList << Set.fromList)
                |> List.map (\uri -> Import ("url('" ++ uri ++ "')"))

        reorder style ( importStatements, remainingStyles ) =
            case style of
                Import _ ->
                    ( style :: importStatements, remainingStyles )

                x ->
                    ( importStatements, style :: remainingStyles )

        ( imports, allStyles ) =
            List.foldr reorder ( [], [] ) styles
    in
    imports ++ importedFonts ++ [ Reset reset ] ++ allStyles



-- unbatchedStylesheet : Bool -> List (Internal.Style class variation) -> Intermediate.Rendered class variation
-- unbatchedStylesheet guard styles =
--     styles
--         |> List.map (renderStyle guard << preprocess)
--         |> Intermediate.finalize


{-| This handles rearranging some properties before they're rendered.

Such as:

  - Move drop shadows to the filter property
  - Visibility should override layout. Visibility should override previous visibility as well.
  - Move color palettes to the end

-}
preprocess : Style class variation -> Style class variation
preprocess style =
    case style of
        Internal.Style className styleProps ->
            let
                visible prop =
                    case prop of
                        Visibility _ ->
                            True

                        _ ->
                            False

                shadows prop =
                    case prop of
                        Shadows _ ->
                            True

                        _ ->
                            False

                prioritize isPriority priorityProps =
                    let
                        ( high, low ) =
                            List.partition isPriority priorityProps
                    in
                    low ++ high

                overridePrevious overridable overrideProps =
                    let
                        eliminatePrevious prop ( existing, overridden ) =
                            if overridable prop && overridden then
                                ( existing, overridden )
                            else if overridable prop && not overridden then
                                ( prop :: existing, True )
                            else
                                ( prop :: existing, overridden )
                    in
                    List.foldr eliminatePrevious ( [], False ) overrideProps
                        |> Tuple.first

                dropShadow (ShadowModel shade) =
                    shade.kind == "drop"

                mergeTransforms mergeableProps =
                    let
                        setIfNothing x maybeX =
                            case maybeX of
                                Nothing ->
                                    Just x

                                a ->
                                    a

                        gatherTransformStack transformation gathered =
                            case transformation of
                                Translate x y z ->
                                    { gathered | translate = setIfNothing (Translate x y z) gathered.translate }

                                Rotate a ->
                                    { gathered | rotate = setIfNothing (Rotate a) gathered.rotate }

                                RotateAround x y z angle ->
                                    { gathered | rotate = setIfNothing (RotateAround x y z angle) gathered.rotate }

                                Scale x y z ->
                                    { gathered | scale = setIfNothing (Scale x y z) gathered.scale }

                        gatherTransforms prop ( transforms, gatheredProps ) =
                            case prop of
                                Transform stack ->
                                    ( List.foldr gatherTransformStack transforms stack
                                    , gatheredProps
                                    )

                                _ ->
                                    ( transforms
                                    , prop :: gatheredProps
                                    )

                        applyTransforms ( { rotate, scale, translate }, gathered ) =
                            let
                                transformations =
                                    List.filterMap identity
                                        [ translate
                                        , rotate
                                        , scale
                                        ]
                            in
                            if List.isEmpty transformations then
                                gathered
                            else
                                Transform transformations :: gathered
                    in
                    mergeableProps
                        |> List.foldr gatherTransforms
                            ( { rotate = Nothing
                              , scale = Nothing
                              , translate = Nothing
                              }
                            , []
                            )
                        |> applyTransforms

                mergeShadowsAndFilters shadowsAndFilters =
                    let
                        gather prop existing =
                            case prop of
                                Filters fs ->
                                    { existing | filters = fs ++ existing.filters }

                                Shadows ss ->
                                    { existing | shadows = ss ++ existing.shadows }

                                _ ->
                                    { existing | others = prop :: existing.others }

                        combine combineable =
                            Filters combineable.filters :: Shadows combineable.shadows :: combineable.others
                    in
                    shadowsAndFilters
                        |> List.foldr gather
                            { filters = []
                            , shadows = []
                            , others = []
                            }
                        |> combine

                processed =
                    styleProps
                        |> prioritize visible
                        |> overridePrevious visible
                        |> prioritize shadows
                        |> mergeShadowsAndFilters
                        |> mergeTransforms
            in
            Internal.Style className processed

        _ ->
            style


renderStyle : Bool -> Style class variation -> Intermediate.Class class variation
renderStyle guarded style =
    case style of
        Internal.Reset reset ->
            Intermediate.Free reset

        Internal.Import str ->
            Intermediate.Free <| "@import " ++ str ++ ";"

        Internal.RawStyle cls styleProps ->
            Intermediate.Free <| class cls styleProps

        Internal.Style cls styleProps ->
            let
                selector =
                    Selector.select cls

                inter =
                    Intermediate.Class
                        { selector = selector
                        , props = List.map (renderProp selector) styleProps
                        }

                guard i =
                    if guarded then
                        Intermediate.guard i
                    else
                        i
            in
            inter
                |> guard


renderProp : Selector class variation -> Property class variation -> Intermediate.Prop class variation
renderProp parentClass prop =
    case prop of
        Child cls styleProps ->
            (Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.child parentClass (Selector.select cls)
                , props = List.map (renderProp parentClass) styleProps
                }

        Variation var styleProps ->
            let
                selectVariation =
                    Selector.variant parentClass var variationName

                variationName =
                    case List.filterMap (renderVariationProp parentClass) styleProps of
                        [] ->
                            "v"

                        intermediates ->
                            List.concatMap Intermediate.getProps intermediates
                                |> List.map (\( x, y ) -> x ++ y)
                                |> String.concat
            in
            (Intermediate.SubClass << Intermediate.Class)
                { selector = selectVariation
                , props = List.filterMap (renderVariationProp selectVariation) styleProps
                }

        PseudoElement cls styleProps ->
            (Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.pseudo cls parentClass
                , props = List.map (renderProp parentClass) styleProps
                }

        MediaQuery query styleProps ->
            (Intermediate.SubClass << Intermediate.Media)
                { query = "@media " ++ query
                , selector = parentClass
                , props =
                    styleProps
                        |> List.map (renderProp parentClass)
                        |> List.map (Intermediate.asMediaQuery query)
                }

        Exact name val ->
            Intermediate.props <| [ ( name, val ) ]

        Visibility vis ->
            Intermediate.props <| Render.visibility vis

        Position pos ->
            Intermediate.props <| Render.position pos

        Font name val ->
            Intermediate.props <| [ ( name, val ) ]

        Layout lay ->
            Intermediate.props (Render.layout False lay)

        Background props ->
            Intermediate.props <| Render.background props

        Shadows shadows ->
            Intermediate.props <| Render.shadow shadows

        Transform transformations ->
            Intermediate.props <| Render.transformations transformations

        Filters filters ->
            Intermediate.props <| Render.filters filters

        SelectionColor color ->
            (Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.pseudo "::selection" parentClass
                , props = [ Intermediate.props [ ( "background-color", Value.color color ) ] ]
                }

        TextColor color ->
            Intermediate.props <|
                [ ( "color", Value.color color )
                ]

        Transitions trans ->
            Intermediate.props <|
                [ ( "transition"
                  , trans
                        |> List.map Render.transition
                        |> String.join ", "
                  )
                ]

        FontFamily fam ->
            Intermediate.props <|
                [ ( "font-family", Value.typeface fam )
                ]


renderVariationProp : Selector class variation -> Property class Never -> Maybe (Intermediate.Prop class variation)
renderVariationProp parentClass prop =
    case prop of
        Child _ _ ->
            Nothing

        Variation _ _ ->
            Nothing

        PseudoElement cls styleProps ->
            (Just << Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.pseudo cls parentClass
                , props = List.filterMap (renderVariationProp parentClass) styleProps
                }

        MediaQuery query styleProps ->
            (Just << Intermediate.SubClass << Intermediate.Media)
                { query = "@media " ++ query
                , selector = parentClass
                , props =
                    styleProps
                        |> List.filterMap (renderVariationProp parentClass)
                        |> List.map (Intermediate.asMediaQuery query)
                }

        Exact name val ->
            (Just << Intermediate.props) [ ( name, val ) ]

        Visibility vis ->
            (Just << Intermediate.props) <| Render.visibility vis

        Position pos ->
            (Just << Intermediate.props) <| Render.position pos

        Font name val ->
            (Just << Intermediate.props) <| [ ( name, val ) ]

        FontFamily fam ->
            (Just << Intermediate.props) <|
                [ ( "font-family", Value.typeface fam )
                ]

        Layout lay ->
            (Just << Intermediate.props) (Render.layout False lay)

        Background props ->
            (Just << Intermediate.props) <| Render.background props

        Shadows shadows ->
            (Just << Intermediate.props) <| Render.shadow shadows

        Transform transformations ->
            (Just << Intermediate.props) <| Render.transformations transformations

        Filters filters ->
            (Just << Intermediate.props) <| Render.filters filters

        TextColor color ->
            (Just << Intermediate.props) <|
                [ ( "color", Value.color color )
                ]

        SelectionColor color ->
            (Just << Intermediate.SubClass << Intermediate.Class)
                { selector = Selector.pseudo "::selection" parentClass
                , props = [ Intermediate.props [ ( "background-color", Value.color color ) ] ]
                }

        Transitions trans ->
            Just <|
                Intermediate.props
                    [ ( "transition"
                      , trans
                            |> List.map Render.transition
                            |> String.join ", "
                      )
                    ]
