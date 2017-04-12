module Style.Internal.Render exposing (stylesheet)

{-|
-}

import Murmur3
import Color exposing (Color)
import Style.Internal.Model as Internal exposing (..)
import Style.Internal.Find as Findable
import Style.Internal.Render.Property as Render
import Style.Internal.Render.Value as Value
import Style.Internal.Render.Css as Css
import Style.Internal.Selector as Selector exposing (Selector)
import Time


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


concatStyles : List (Internal.BatchedStyle class variation animation) -> List (Internal.Style class variation animation)
concatStyles batched =
    let
        flatten batch =
            case batch of
                Internal.Single style ->
                    [ style ]

                Internal.Many styles ->
                    styles
    in
        List.concatMap flatten batched


stylesheet : Bool -> List (Internal.BatchedStyle class variation animation) -> List ( String, List (Findable.Element class variation animation) )
stylesheet guard batched =
    batched
        |> concatStyles
        |> List.map (renderStyle guard << preprocess)


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


applyGuard : String -> IntermediateStyle class variation animation -> IntermediateStyle class variation animation
applyGuard guard intermediate =
    case intermediate of
        Intermediate select props ->
            Intermediate (Selector.guard guard select) props

        MediaIntermediate query select props ->
            MediaIntermediate query (Selector.guard guard select) props


renderStyle : Bool -> Style class variation animation -> ( String, List (Findable.Element class variation animation) )
renderStyle guarded style =
    case style of
        Internal.Import str ->
            ( "@import " ++ str ++ ";\n"
            , []
            )

        Internal.Style class props ->
            let
                className =
                    Selector.select class

                ( embeddedElements, renderedProps ) =
                    renderAllProps className props

                intermediates =
                    (Intermediate className renderedProps :: embeddedElements)
                        |> guard

                guard inter =
                    if guarded then
                        let
                            g =
                                calculateGuard inter
                        in
                            List.map (applyGuard g) inter
                    else
                        inter
            in
                ( intermediates
                    |> List.map renderIntermediate
                    |> String.join "\n"
                , intermediates
                    |> List.concatMap renderFindable
                )


calculateGuard : List (IntermediateStyle class variation animation) -> String
calculateGuard intermediates =
    let
        propToString ( x, y ) =
            x ++ y

        asString inter =
            case inter of
                Intermediate class props ->
                    String.concat <| List.map propToString props

                MediaIntermediate query class props ->
                    query ++ (String.concat <| List.map propToString props)
    in
        intermediates
            |> List.map asString
            |> String.concat
            |> hash


{-| -}
renderFindable : IntermediateStyle class variation animation -> List (Findable.Element class variation animation)
renderFindable intermediate =
    case intermediate of
        Intermediate selector _ ->
            Selector.getFindable selector

        _ ->
            []


{-| -}
hash : String -> String
hash value =
    Murmur3.hashString 8675309 value
        |> toString


type IntermediateStyle class variation animation
    = Intermediate (Selector class variation animation) (List ( String, String ))
      --              query  class  props  intermediates
    | MediaIntermediate String (Selector class variation animation) (List ( String, String ))


asMediaQuery : String -> IntermediateStyle class variation animation -> IntermediateStyle class variation animation
asMediaQuery query style =
    case style of
        Intermediate class props ->
            MediaIntermediate query class props

        x ->
            x


renderAllProps : Selector class variation animation -> List (Property class variation animation) -> ( List (IntermediateStyle class variation animation), List ( String, String ) )
renderAllProps parent allProps =
    let
        renderPropsAndChildren prop ( existing, rendered ) =
            let
                ( children, renderedProp ) =
                    renderProp parent prop
            in
                ( children ++ existing
                , renderedProp ++ rendered
                )
    in
        List.foldr renderPropsAndChildren ( [], [] ) allProps


renderVariationProps : Selector class variation animation -> List (Property class Never animation) -> ( List (IntermediateStyle class variation animation), List ( String, String ) )
renderVariationProps parent allProps =
    let
        renderPropsAndChildren prop ( existing, rendered ) =
            let
                ( children, renderedProp ) =
                    renderVariationProp parent prop
            in
                ( children ++ existing
                , renderedProp ++ rendered
                )
    in
        List.foldr renderPropsAndChildren ( [], [] ) allProps


renderProp : Selector class variation animation -> Property class variation animation -> ( List (IntermediateStyle class variation animation), List ( String, String ) )
renderProp parentClass prop =
    case prop of
        Child class props ->
            let
                selector =
                    Selector.child parentClass (Selector.select class)

                ( intermediates, renderedProps ) =
                    renderAllProps selector props
            in
                ( (Intermediate selector renderedProps) :: intermediates
                , []
                )

        Variation var props ->
            let
                ( intermediates, renderedProps ) =
                    renderVariationProps parentClass props
            in
                ( (Intermediate (Selector.variant parentClass var) renderedProps) :: intermediates
                , []
                )

        PseudoElement class props ->
            let
                ( intermediates, renderedProps ) =
                    renderAllProps parentClass props
            in
                ( Intermediate (Selector.pseudo class parentClass) renderedProps :: intermediates
                , []
                )

        MediaQuery query props ->
            let
                ( intermediates, renderedProps ) =
                    renderAllProps parentClass props

                mediaQueries =
                    List.map (asMediaQuery query) intermediates
            in
                ( (MediaIntermediate ("@media " ++ query) parentClass renderedProps) :: mediaQueries
                , []
                )

        Exact name val ->
            ( [], [ ( name, val ) ] )

        Visibility vis ->
            ( [], Render.visibility vis )

        Border props ->
            ( [], List.map Render.border props )

        Box props ->
            ( [], List.map Render.box props )

        Position pos ->
            ( [], Render.position pos )

        Font props ->
            ( [], List.map Render.font props )

        Layout lay ->
            ( layoutSpacing parentClass lay
            , Render.layout lay
            )

        Background props ->
            ( [], Render.background props )

        Shadows shadows ->
            ( [], Render.shadow shadows )

        Transform transformations ->
            ( [], Render.transformations transformations )

        Filters filters ->
            ( [], Render.filters filters )

        Palette colors ->
            ( [], List.map Render.colorElement colors )

        Transitions trans ->
            ( []
            , [ ( "transition"
                , trans
                    |> List.map Render.transition
                    |> String.join ", "
                )
              ]
            )


renderVariationProp : Selector class variation animation -> Property class Never animation -> ( List (IntermediateStyle class variation animation), List ( String, String ) )
renderVariationProp parentClass prop =
    case prop of
        Child class props ->
            ( []
            , []
            )

        Variation var props ->
            ( [], [] )

        PseudoElement class props ->
            let
                ( intermediates, renderedProps ) =
                    renderVariationProps parentClass props
            in
                ( Intermediate (Selector.pseudo class parentClass) renderedProps :: intermediates
                , []
                )

        MediaQuery query props ->
            let
                ( intermediates, renderedProps ) =
                    renderVariationProps parentClass props

                mediaQueries =
                    List.map (asMediaQuery query) intermediates
            in
                ( (MediaIntermediate ("@media " ++ query) parentClass renderedProps) :: mediaQueries
                , []
                )

        Exact name val ->
            ( [], [ ( name, val ) ] )

        Visibility vis ->
            ( [], Render.visibility vis )

        Border props ->
            ( [], List.map Render.border props )

        Box props ->
            ( [], List.map Render.box props )

        Position pos ->
            ( [], Render.position pos )

        Font props ->
            ( [], List.map Render.font props )

        Layout lay ->
            ( layoutSpacing parentClass lay
            , Render.layout lay
            )

        Background props ->
            ( [], Render.background props )

        Shadows shadows ->
            ( [], Render.shadow shadows )

        Transform transformations ->
            ( [], Render.transformations transformations )

        Filters filters ->
            ( [], Render.filters filters )

        Palette colors ->
            ( [], List.map Render.colorElement colors )

        Transitions trans ->
            ( []
            , [ ( "transition"
                , trans
                    |> List.map Render.transition
                    |> String.join ", "
                )
              ]
            )


renderIntermediate : IntermediateStyle class variation animation -> String
renderIntermediate intermediate =
    case intermediate of
        Intermediate class props ->
            (Selector.render Nothing class ++ Css.brace 0 (String.join "\n" <| List.map (Css.prop 2) props) ++ "\n")

        MediaIntermediate query class props ->
            query ++ Css.brace 0 ("  " ++ Selector.render Nothing class ++ Css.brace 2 (String.join "\n" <| List.map (Css.prop 4) props))


{-| -}
layoutSpacing : Selector class variation animation -> LayoutModel -> List (IntermediateStyle class variation animation)
layoutSpacing parent layout =
    case layout of
        Internal.TextLayout { spacing } ->
            case spacing of
                Nothing ->
                    []

                Just space ->
                    [ Intermediate
                        (Selector.child parent <| Selector.free "*:not(.nospacing)")
                        [ ( "margin", Value.box space ) ]
                    ]

        Internal.FlexLayout _ props ->
            let
                spacing prop =
                    case prop of
                        Spacing spaced ->
                            Just <|
                                Intermediate
                                    (Selector.child parent <| Selector.free "*:not(.nospacing)")
                                    [ ( "margin", Value.box spaced ) ]

                        _ ->
                            Nothing
            in
                List.filterMap spacing props
