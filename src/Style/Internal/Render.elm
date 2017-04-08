module Style.Internal.Render exposing (stylesheet, box, color, length)

{-|
-}

import Murmur3
import Color exposing (Color)
import Style.Internal.Model as Internal exposing (..)
import Style.Internal.Find as Findable


(=>) : x -> y -> ( x, y )
(=>) =
    (,)


box : ( Float, Float, Float, Float ) -> String
box ( a, b, c, d ) =
    toString a ++ "px " ++ toString b ++ "px " ++ toString c ++ "px " ++ toString d ++ "px"


length : Internal.Length -> String
length l =
    case l of
        Internal.Px x ->
            toString x ++ "px"

        Internal.Percent x ->
            toString x ++ "%"

        Internal.Auto ->
            "auto"


color : Color -> String
color color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
        ("rgba(" ++ toString red)
            ++ ("," ++ toString green)
            ++ ("," ++ toString blue)
            ++ ("," ++ toString alpha ++ ")")


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


-}
preprocess : Style class variation animation -> Style class variation animation
preprocess (Internal.Style class props) =
    let
        visible prop =
            case prop of
                Visibility _ ->
                    True

                _ ->
                    False

        ( visibility, others ) =
            List.partition visible props

        lastVisible =
            case List.reverse visibility of
                [] ->
                    []

                vis :: _ ->
                    [ vis ]

        dropShadows (ShadowModel { kind }) =
            kind == "drop"

        partitionDropShadows prop ( existing, existingDropShadow ) =
            case prop of
                Shadows shadowModels ->
                    let
                        ( dropShadow, withOutDropShadows ) =
                            List.partition dropShadows shadowModels
                    in
                        ( Shadows withOutDropShadows :: existing
                        , [ dropShadow ] ++ existingDropShadow
                        )

                _ ->
                    ( prop :: existing
                    , existingDropShadow
                    )

        ( notShadows, dropped ) =
            List.foldr partitionDropShadows ( [], [] ) others

        forFilters prop =
            case prop of
                Filters _ ->
                    True

                _ ->
                    False

        notFilters =
            List.filter (not << forFilters) notShadows

        filters =
            case List.head <| List.reverse dropped of
                Nothing ->
                    List.filter forFilters notShadows

                Just dropShad ->
                    notShadows
                        |> List.filter forFilters
                        |> List.map (addToFilter (List.map asDropShadow dropShad))

        addToFilter other prop =
            case prop of
                Filters f ->
                    Filters (f ++ other)

                x ->
                    x

        asDropShadow (ShadowModel shadow) =
            DropShadow
                { offset = shadow.offset
                , size = shadow.size
                , blur = shadow.blur
                , color = shadow.color
                }
    in
        (Internal.Style class (notFilters ++ lastVisible ++ filters))


applyGuard : String -> IntermediateStyle class variation animation -> IntermediateStyle class variation animation
applyGuard guard intermediate =
    let
        addGuard str =
            str ++ "--" ++ guard

        toFindable findable =
            case findable of
                Findable.Style class name ->
                    Findable.Style class (addGuard name)

                Findable.Variation class variation name ->
                    Findable.Variation class variation (addGuard name)

                Findable.Animation class animation name ->
                    Findable.Animation class animation (addGuard name)

        toSelector selector =
            case selector of
                Select rendered findable ->
                    Select
                        (addGuard rendered)
                        (toFindable findable)

                SelectChild child ->
                    SelectChild (toSelector child)

                -- Free String
                Stack selectors ->
                    Stack (List.map toSelector selectors)

                x ->
                    x
    in
        case intermediate of
            Intermediate select props ->
                Intermediate (toSelector select) props

            MediaIntermediate query select props ->
                MediaIntermediate query (toSelector select) props


renderStyle : Bool -> Style class variation animation -> ( String, List (Findable.Element class variation animation) )
renderStyle guarded (Internal.Style class props) =
    let
        className =
            Select (formatName class) (Findable.Style class (formatName class))

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


renderFindable : IntermediateStyle class variation animation -> List (Findable.Element class variation animation)
renderFindable intermediate =
    let
        getFindable find =
            case find of
                Select _ findable ->
                    [ findable ]

                SelectChild selector ->
                    getFindable selector

                Stack selectors ->
                    List.concatMap getFindable selectors
                        |> List.reverse
                        |> List.head
                        |> Maybe.map (\x -> [ x ])
                        |> Maybe.withDefault []

                _ ->
                    []
    in
        case intermediate of
            Intermediate selector _ ->
                getFindable selector

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


type Selector class variation animation
    = Select String (Findable.Element class variation animation)
    | SelectChild (Selector class variation animation)
    | Free String
    | Stack (List (Selector class variation animation))


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


uncapitalize : String -> String
uncapitalize str =
    let
        head =
            String.left 1 str
                |> String.toLower

        tail =
            String.dropLeft 1 str
    in
        head ++ tail


formatName : a -> String
formatName x =
    toString x
        |> String.words
        |> List.map uncapitalize
        |> String.join "_"


renderProp : Selector class variation animation -> Property class variation animation -> ( List (IntermediateStyle class variation animation), List ( String, String ) )
renderProp parentClass prop =
    case prop of
        Child class props ->
            let
                selector =
                    Stack [ parentClass, SelectChild <| Select (formatName class) (Findable.Style class (formatName class)) ]

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
                ( (Intermediate (variant parentClass var) renderedProps) :: intermediates
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
            ( [], renderVisibility vis )

        Border props ->
            ( [], List.map borderProp props )

        Box props ->
            ( [], List.map boxProp props )

        Position pos ->
            ( [], position pos )

        Font props ->
            ( [], List.map fontProp props )

        Layout lay ->
            ( layoutSpacing parentClass lay
            , layout lay
            )

        Background props ->
            ( [], background props )

        Shadows shadows ->
            ( [], renderShadow shadows )

        Transform transformations ->
            ( [], renderTransformations transformations )

        Filters filters ->
            ( [], renderFilters filters )


renderVariationProp : Selector class variation animation -> Property class Never animation -> ( List (IntermediateStyle class variation animation), List ( String, String ) )
renderVariationProp parentClass prop =
    case prop of
        Child class props ->
            ( []
            , []
            )

        Variation var props ->
            ( [], [] )

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
            ( [], renderVisibility vis )

        Border props ->
            ( [], List.map borderProp props )

        Box props ->
            ( [], List.map boxProp props )

        Position pos ->
            ( [], position pos )

        Font props ->
            ( [], List.map fontProp props )

        Layout lay ->
            ( layoutSpacing parentClass lay
            , layout lay
            )

        Background props ->
            ( [], background props )

        Shadows shadows ->
            ( [], renderShadow shadows )

        Transform transformations ->
            ( [], renderTransformations transformations )

        Filters filters ->
            ( [], renderFilters filters )


renderIntermediate : IntermediateStyle class variation animation -> String
renderIntermediate intermediate =
    case intermediate of
        Intermediate class props ->
            (renderSelector Nothing class ++ brace 0 (String.join "\n" <| List.map (cssProp 2) props) ++ "\n")

        MediaIntermediate query class props ->
            query ++ brace 0 ("  " ++ renderSelector Nothing class ++ brace 2 (String.join "\n" <| List.map (cssProp 4) props))


variant : Selector class variation animation -> variation -> Selector class variation animation
variant sel var =
    case sel of
        Select single findable ->
            Select (single ++ "-" ++ formatName var)
                (Findable.toVariation
                    var
                    (single ++ "-" ++ formatName var)
                    findable
                )

        SelectChild child ->
            SelectChild (variant child var)

        Free single ->
            Free single

        Stack sels ->
            let
                lastElem =
                    sels
                        |> List.reverse
                        |> List.head

                init =
                    sels
                        |> List.reverse
                        |> List.drop 1
                        |> List.reverse
            in
                case lastElem of
                    Nothing ->
                        Stack sels

                    Just last ->
                        Stack (init ++ [ variant last var ])


renderSelector : Maybe String -> Selector class variation animation -> String
renderSelector maybeGuard selector =
    let
        guard str =
            case maybeGuard of
                Nothing ->
                    str

                Just g ->
                    str ++ "--" ++ g
    in
        case selector of
            Select single _ ->
                "." ++ guard single

            SelectChild child ->
                "> " ++ renderSelector maybeGuard child

            Free single ->
                single

            Stack sels ->
                sels
                    |> List.map (renderSelector maybeGuard)
                    |> String.join " "


renderGuardedIntermediate : String -> IntermediateStyle class variation animation -> String
renderGuardedIntermediate guard intermediate =
    case intermediate of
        Intermediate class props ->
            (renderSelector (Just guard) class ++ brace 0 (String.join "\n" <| List.map (cssProp 2) props) ++ "\n")

        MediaIntermediate query class props ->
            query ++ brace 0 ("  " ++ renderSelector (Just guard) class ++ brace 2 (String.join "\n" <| List.map (cssProp 4) props))


brace : Int -> String -> String
brace i str =
    " {\n" ++ str ++ "\n" ++ String.repeat i " " ++ "}"


cssProp : Int -> ( String, String ) -> String
cssProp i ( propName, propValue ) =
    (String.repeat i " ") ++ propName ++ ": " ++ propValue ++ ";"


boxProp : BoxElement -> ( String, String )
boxProp (BoxProp name val) =
    ( name, val )


borderProp : BorderElement -> ( String, String )
borderProp (BorderElement name val) =
    ( name, val )


fontProp : FontElement -> ( String, String )
fontProp (FontElement name val) =
    ( name, val )


renderVisibility : Visible -> List ( String, String )
renderVisibility vis =
    case vis of
        Hidden ->
            [ ( "display", "none" ) ]

        Invisible ->
            [ ( "visibility", "hidden" ) ]

        Opacity x ->
            [ ( "opacity", toString x ) ]


renderFilters : List Filter -> List ( String, String )
renderFilters filters =
    let
        filterName filtr =
            case filtr of
                FilterUrl url ->
                    "url(" ++ url ++ ")"

                Blur x ->
                    "blur(" ++ toString x ++ "px)"

                Brightness x ->
                    "brightness(" ++ toString x ++ "%)"

                Contrast x ->
                    "contrast(" ++ toString x ++ "%)"

                Grayscale x ->
                    "grayscale(" ++ toString x ++ "%)"

                HueRotate x ->
                    "hueRotate(" ++ toString x ++ "deg)"

                Invert x ->
                    "invert(" ++ toString x ++ "%)"

                OpacityFilter x ->
                    "opacity(" ++ toString x ++ "%)"

                Saturate x ->
                    "saturate(" ++ toString x ++ "%)"

                Sepia x ->
                    "sepia(" ++ toString x ++ "%)"

                DropShadow shadow ->
                    let
                        shadowModel =
                            ShadowModel
                                { kind = "drop"
                                , offset = shadow.offset
                                , size = shadow.size
                                , blur = shadow.blur
                                , color = shadow.color
                                }
                    in
                        "drop-shadow(" ++ shadowValue shadowModel ++ ")"
    in
        if List.length filters == 0 then
            []
        else
            [ "filter"
                => (String.join " " <| List.map filterName filters)
            ]


renderShadow : List ShadowModel -> List ( String, String )
renderShadow shadows =
    let
        ( text, box ) =
            List.partition (\(ShadowModel s) -> s.kind == "text") shadows

        renderedBox =
            String.join ", " (List.map shadowValue box)

        renderedText =
            String.join ", " (List.map shadowValue text)
    in
        List.filterMap identity
            [ if renderedBox == "" then
                Nothing
              else
                Just ("box-shadow" => renderedBox)
            , if renderedText == "" then
                Nothing
              else
                Just ("text-shadow" => renderedText)
            ]


shadowValue : ShadowModel -> String
shadowValue (ShadowModel shadow) =
    [ if shadow.kind == "inset" then
        Just "inset"
      else
        Nothing
    , Just <| toString (Tuple.first shadow.offset) ++ "px"
    , Just <| toString (Tuple.second shadow.offset) ++ "px"
    , Just <| toString shadow.blur ++ "px"
    , (if shadow.kind == "text" || shadow.kind == "drop" then
        Nothing
       else
        Just <| toString shadow.size ++ "px"
      )
    , Just <| color shadow.color
    ]
        |> List.filterMap identity
        |> String.join " "


renderTransformations : List Transformation -> List ( String, String )
renderTransformations transforms =
    let
        transformToString transform =
            case transform of
                Translate x y z ->
                    ("translate3d(" ++ toString x ++ "px, " ++ toString y ++ "px, " ++ toString z ++ "px)")

                Rotate x y z ->
                    ("rotateX(" ++ toString x ++ "rad) rotateY(" ++ toString y ++ "rad) rotateZ(" ++ toString z ++ "rad)")

                Scale x y z ->
                    ("scale3d(" ++ toString x ++ ", " ++ toString y ++ ", " ++ toString z ++ ")")

                _ ->
                    ""

        transformOriginToString transform =
            case transform of
                Origin x y z ->
                    Just ( "transform-origin", (toString x ++ "px  " ++ toString y ++ "px " ++ toString z ++ "px") )

                _ ->
                    Nothing

        transformString =
            (String.join " " (List.map transformToString transforms))

        renderedTransforms =
            if String.length transformString > 0 then
                [ "transform" => transformString ]
            else
                []

        renderedOrigin =
            List.filterMap transformOriginToString transforms
    in
        if List.length transforms == 0 then
            []
        else
            renderedTransforms ++ renderedOrigin


background : List BackgroundElement -> List ( String, String )
background props =
    let
        bgElement bg =
            case bg of
                BackgroundElement name val ->
                    [ ( name, val ) ]

                BackgroundImage { src, position, repeat } ->
                    [ "background-image" => src
                    , "background-repeat"
                        => case repeat of
                            RepeatX ->
                                "repeat-x"

                            RepeatY ->
                                "repeat-y"

                            Repeat ->
                                "repeat"

                            Space ->
                                "space"

                            Round ->
                                "round"

                            NoRepeat ->
                                "no-repeat"
                    , "background-position" => (toString (Tuple.first position) ++ "px " ++ toString (Tuple.second position) ++ "px")
                    ]
    in
        List.concatMap bgElement props


position : List PositionElement -> List ( String, String )
position posEls =
    let
        renderPos pos =
            case pos of
                RelativeTo Screen ->
                    ( "position", "fixed" )

                RelativeTo Parent ->
                    ( "position", "absolute" )

                RelativeTo Current ->
                    ( "position", "relative" )

                PosLeft x ->
                    ( "left", toString x ++ "px" )

                PosRight x ->
                    ( "right", toString x ++ "px" )

                PosTop x ->
                    ( "top", toString x ++ "px" )

                PosBottom x ->
                    ( "bottom", toString x ++ "px" )

                ZIndex i ->
                    ( "z-index", toString i )

                Inline ->
                    ( "display", "inline-block" )

                Float FloatLeft ->
                    ( "float", "left" )

                Float FloatRight ->
                    ( "float", "right" )

                Float FloatTopLeft ->
                    ( "float", "left" )

                Float FloatTopRight ->
                    ( "float", "right" )
    in
        List.map renderPos posEls


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
                        (Stack [ parent, SelectChild (Free "*:not(.nospacing)") ])
                        [ ( "margin", box space ) ]
                    ]

        Internal.FlexLayout _ props ->
            let
                spacing prop =
                    case prop of
                        Spacing spaced ->
                            Just <|
                                Intermediate
                                    (Stack [ parent, SelectChild (Free "*:not(.nospacing)") ])
                                    [ ( "margin", box spaced ) ]

                        _ ->
                            Nothing
            in
                List.filterMap spacing props


{-| -}
layout : LayoutModel -> List ( String, String )
layout lay =
    case lay of
        Internal.TextLayout _ ->
            [ "display" => "block" ]

        Internal.FlexLayout direction flexProps ->
            ("display" => "flex") :: renderDirection direction :: List.map (renderFlexbox direction) flexProps


renderDirection : Direction -> ( String, String )
renderDirection dir =
    case dir of
        GoRight ->
            "flex-direction" => "row"

        GoLeft ->
            "flex-direction" => "row-reverse"

        Down ->
            "flex-direction" => "column"

        Up ->
            "flex-direction" => "column-reverse"


renderFlexbox : Direction -> FlexBoxElement -> ( String, String )
renderFlexbox dir el =
    case el of
        Wrap wrap ->
            if wrap then
                "flex-wrap" => "wrap"
            else
                "flex-wrap" => "nowrap"

        Spacing _ ->
            ( "", "" )

        Horz horizontal ->
            case dir of
                GoRight ->
                    case horizontal of
                        Other Left ->
                            "justify-content" => "flex-start"

                        Other Right ->
                            "justify-content" => "flex-end"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "justify-content" => "space-between"

                GoLeft ->
                    case horizontal of
                        Other Left ->
                            "justify-content" => "flex-end"

                        Other Right ->
                            "justify-content" => "flex-start"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "justify-content" => "space-between"

                Down ->
                    case horizontal of
                        Other Left ->
                            "align-items" => "flex-start"

                        Other Right ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"

                Up ->
                    case horizontal of
                        Other Left ->
                            "align-items" => "flex-start"

                        Other Right ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"

        Vert vertical ->
            case dir of
                GoRight ->
                    case vertical of
                        Other Top ->
                            "align-items" => "flex-start"

                        Other Bottom ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"

                GoLeft ->
                    case vertical of
                        Other Top ->
                            "align-items" => "flex-start"

                        Other Bottom ->
                            "align-items" => "flex-end"

                        Center ->
                            "align-items" => "center"

                        Justify ->
                            "align-items" => "Justify"

                        JustifyAll ->
                            "align-items" => "Justify"

                Down ->
                    case vertical of
                        Other Top ->
                            "justify-content" => "flex-start"

                        Other Bottom ->
                            "justify-content" => "flex-end"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "align-items" => "Justify"

                Up ->
                    case vertical of
                        Other Top ->
                            "justify-content" => "flex-end"

                        Other Bottom ->
                            "justify-content" => "flex-start"

                        Center ->
                            "justify-content" => "center"

                        Justify ->
                            "justify-content" => "space-between"

                        JustifyAll ->
                            "align-items" => "Justify"
