module Internal.Model exposing (..)

{-| -}

-- import VirtualCss

import Color exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Internal.Style
import Json.Encode as Json
import Regex
import Set exposing (Set)
import VirtualDom


type Element msg
    = Unstyled (LayoutContext -> Html msg)
    | Styled
        { styles : List Style
        , html : Maybe String -> LayoutContext -> Html msg
        }
    | Text String
    | Empty


type LayoutContext
    = AsRow
    | AsColumn
    | AsEl
    | AsGrid
      -- | AsGridEl
    | AsParagraph
    | AsTextColumn



{- Constants -}


asGrid : LayoutContext
asGrid =
    AsGrid


asRow : LayoutContext
asRow =
    AsRow


asColumn : LayoutContext
asColumn =
    AsColumn


asEl : LayoutContext
asEl =
    AsEl


asParagraph : LayoutContext
asParagraph =
    AsParagraph


asTextColumn : LayoutContext
asTextColumn =
    AsTextColumn


contextClasses : LayoutContext -> Attribute msg
contextClasses context =
    case context of
        AsRow ->
            htmlClass "se row"

        AsColumn ->
            htmlClass "se column"

        AsEl ->
            htmlClass "se el"

        AsGrid ->
            htmlClass "se grid"

        AsParagraph ->
            htmlClass "se paragraph"

        AsTextColumn ->
            htmlClass "se page"


type Aligned
    = Unaligned
    | Aligned (Maybe HAlign) (Maybe VAlign)


type HAlign
    = Left
    | CenterX
    | Right


type VAlign
    = Top
    | CenterY
    | Bottom


hover : Style -> Attribute msg
hover style =
    StyleClass (PseudoSelector Hover style)


type Style
    = Style String (List Property)
      --       class  prop   val
    | LineHeight Float
    | FontFamily String (List Font)
    | FontSize Int
    | Single String String String
    | Colored String String Color
    | SpacingStyle Int Int
    | PaddingStyle Int Int Int Int
    | GridTemplateStyle
        { spacing : ( Length, Length )
        , columns : List Length
        , rows : List Length
        }
    | GridPosition
        { row : Int
        , col : Int
        , width : Int
        , height : Int
        }
    | PseudoSelector PseudoClass Style


type PseudoClass
    = Focus
    | Hover


type Font
    = Serif
    | SansSerif
    | Monospace
    | Typeface String
    | ImportFont String String


type Property
    = Property String String


type Transformation
    = Move (Maybe Float) (Maybe Float) (Maybe Float)
    | Rotate Float Float Float Float
    | Scale Float Float Float


type Attribute msg
    = Attr (Html.Attribute msg)
    | Describe Description
      -- invalidation key and literal class
    | Class String String
      -- invalidation key "border-color" as opposed to "border-color-10-10-10" that will be the key for the class
    | StyleClass Style
      -- Descriptions will add aria attributes and if the element is not a link, may set the node type.
    | AlignY VAlign
    | AlignX HAlign
    | Width Length
    | Height Length
    | Nearby Location Bool (Element msg)
    | Transform (Maybe PseudoClass) Transformation
    | TextShadow
        { offset : ( Float, Float )
        , blur : Float
        , color : Color
        }
    | BoxShadow
        { inset : Bool
        , offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }
    | Filter FilterType
    | NoAttribute


type Description
    = Main
    | Navigation
      -- | Search
    | ContentInfo
    | Complementary
    | Heading Int
    | Label String
    | LivePolite
    | LiveAssertive
    | Button


type FilterType
    = FilterUrl String
    | Blur Float
    | Brightness Float
    | Contrast Float
    | Grayscale Float
    | HueRotate Float
    | Invert Float
    | OpacityFilter Float
    | Saturate Float
    | Sepia Float
    | DropShadow
        { offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }


type Length
    = Px Int
    | Content
    | Fill Int



-- | Between
--     { value : Length
--     , min : Maybe Int
--     , max : Maybe Int
--     }


type Axis
    = XAxis
    | YAxis
    | AllAxis


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | InFront
    | Behind


map : (msg -> msg1) -> Element msg -> Element msg1
map fn el =
    case el of
        Styled styled ->
            Styled
                { styles = styled.styles
                , html = \add context -> Html.map fn <| styled.html add context
                }

        Unstyled html ->
            Unstyled (Html.map fn << html)

        Text str ->
            Text str

        Empty ->
            Empty


mapAttr : (msg -> msg1) -> Attribute msg -> Attribute msg1
mapAttr fn attr =
    case attr of
        NoAttribute ->
            NoAttribute

        Describe description ->
            Describe description

        AlignX x ->
            AlignX x

        AlignY y ->
            AlignY y

        Width x ->
            Width x

        Height x ->
            Height x

        -- invalidation key "border-color" as opposed to "border-color-10-10-10" that will be the key for the class
        Class x y ->
            Class x y

        StyleClass style ->
            StyleClass style

        Nearby location on element ->
            Nearby location on (map fn element)

        Transform pseudo trans ->
            Transform pseudo trans

        Attr htmlAttr ->
            Attr (Html.Attributes.map fn htmlAttr)

        TextShadow shadow ->
            TextShadow shadow

        BoxShadow shadow ->
            BoxShadow shadow

        Filter filter ->
            Filter filter


class : String -> Attribute msg
class x =
    Class x x


{-| -}
embed : (a -> Element msg) -> a -> LayoutContext -> Html msg
embed fn a =
    case fn a of
        Unstyled html ->
            html

        Styled styled ->
            styled.html
                (Just
                    (toStyleSheetString
                        { hover = AllowHover
                        , focus =
                            { borderColor = Nothing
                            , shadow = Nothing
                            , backgroundColor = Nothing
                            }
                        , mode = Layout
                        }
                        styled.styles
                    )
                )

        Text text ->
            always (Html.text text)

        Empty ->
            always (Html.text "")


{-| -}
unstyled : Html msg -> Element msg
unstyled =
    Unstyled << always


{-| -}
renderNode : Gathered msg -> Children (VirtualDom.Node msg) -> Maybe String -> LayoutContext -> VirtualDom.Node msg
renderNode { alignment, attributes, node, width, height } children styles context =
    let
        createNode node attrs styles =
            case children of
                Keyed keyed ->
                    VirtualDom.keyedNode node
                        attrs
                        (case styles of
                            Nothing ->
                                keyed

                            Just stylesheet ->
                                ( "stylesheet-pls-pls-pls-be-unique"
                                , VirtualDom.node "style" [ Html.Attributes.class "stylesheet" ] [ Html.text stylesheet ]
                                )
                                    :: keyed
                        )

                Unkeyed unkeyed ->
                    VirtualDom.node node
                        attrs
                        (case styles of
                            Nothing ->
                                unkeyed

                            Just stylesheet ->
                                VirtualDom.node "style" [ Html.Attributes.class "stylesheet" ] [ Html.text stylesheet ] :: unkeyed
                        )

        html =
            case node of
                Generic ->
                    createNode "div" attributes styles

                NodeName nodeName ->
                    createNode nodeName attributes styles

                Embedded nodeName internal ->
                    VirtualDom.node nodeName
                        attributes
                        [ createNode internal [ Html.Attributes.class "se el" ] styles
                        ]
    in
    case context of
        AsRow ->
            case width of
                Just (Fill _) ->
                    html

                _ ->
                    case alignment of
                        Unaligned ->
                            html

                        Aligned (Just Left) _ ->
                            VirtualDom.node "alignLeft"
                                [ Html.Attributes.class "se el container align-container-left content-center-y" ]
                                [ html ]

                        Aligned (Just Right) _ ->
                            VirtualDom.node "alignRight"
                                [ Html.Attributes.class "se el container align-container-right content-center-y" ]
                                [ html ]

                        _ ->
                            html

        AsColumn ->
            case height of
                Just (Fill _) ->
                    html

                _ ->
                    case alignment of
                        Unaligned ->
                            VirtualDom.node "alignTop"
                                [ Html.Attributes.class "se el container align-container-top" ]
                                [ html ]

                        Aligned _ Nothing ->
                            VirtualDom.node "alignTop"
                                [ Html.Attributes.class "se el container align-container-top" ]
                                [ html ]

                        Aligned _ (Just Top) ->
                            VirtualDom.node "alignTop"
                                [ Html.Attributes.class "se el container align-container-top" ]
                                [ html ]

                        Aligned _ (Just Bottom) ->
                            VirtualDom.node "alignBottom"
                                [ Html.Attributes.class "se el container align-container-bottom" ]
                                [ html ]

                        _ ->
                            html

        _ ->
            html


addNodeName : String -> NodeName -> NodeName
addNodeName newNode old =
    case old of
        Generic ->
            NodeName newNode

        NodeName name ->
            Embedded name newNode

        Embedded x y ->
            Embedded x y


alignXName : HAlign -> String
alignXName align =
    case align of
        Left ->
            "self-left"

        Right ->
            "self-right"

        CenterX ->
            "self-center-x"


alignYName : VAlign -> String
alignYName align =
    case align of
        Top ->
            "self-top"

        Bottom ->
            "self-bottom"

        CenterY ->
            "self-center-y"


noAreas : List (Attribute msg) -> List (Attribute msg)
noAreas attrs =
    let
        notAnArea a =
            case a of
                Describe _ ->
                    False

                _ ->
                    True
    in
    List.filter notAnArea attrs


gatherAttributes : Attribute msg -> Gathered msg -> Gathered msg
gatherAttributes attr gathered =
    let
        className name =
            VirtualDom.property "className" (Json.string name)

        styleName name =
            "." ++ name

        formatStyleClass style =
            case style of
                PseudoSelector selector style ->
                    PseudoSelector selector (formatStyleClass style)

                Style class props ->
                    Style (styleName class) props

                Single class name val ->
                    Single (styleName class) name val

                Colored class name val ->
                    Colored (styleName class) name val

                SpacingStyle x y ->
                    SpacingStyle x y

                PaddingStyle top right bottom left ->
                    PaddingStyle top right bottom left

                GridTemplateStyle grid ->
                    GridTemplateStyle grid

                GridPosition pos ->
                    GridPosition pos

                LineHeight i ->
                    LineHeight i

                FontFamily name fam ->
                    FontFamily name fam

                FontSize i ->
                    FontSize i
    in
    case attr of
        NoAttribute ->
            gathered

        Class key class ->
            if Set.member key gathered.has then
                gathered
            else
                { gathered
                    | attributes = className class :: gathered.attributes
                    , has = Set.insert key gathered.has
                }

        Attr attr ->
            { gathered | attributes = attr :: gathered.attributes }

        StyleClass style ->
            let
                key =
                    styleKey style
            in
            if Set.member key gathered.has then
                gathered
            else
                { gathered
                    | attributes =
                        case style of
                            PseudoSelector Hover _ ->
                                VirtualDom.property "className" (Json.string "hover-transition") :: className (getStyleName style) :: gathered.attributes

                            _ ->
                                className (getStyleName style) :: gathered.attributes
                    , styles = formatStyleClass style :: gathered.styles
                    , has = Set.insert key gathered.has
                }

        Width width ->
            if gathered.width == Nothing then
                case width of
                    Px px ->
                        { gathered
                            | width = Just width
                            , attributes = className ("width-exact width-px-" ++ toString px) :: gathered.attributes
                            , styles = Single (styleName <| "width-px-" ++ toString px) "width" (toString px ++ "px") :: gathered.styles
                        }

                    Content ->
                        { gathered
                            | width = Just width
                            , attributes = className "width-content" :: gathered.attributes
                        }

                    Fill portion ->
                        if portion == 1 then
                            { gathered
                                | width = Just width
                                , attributes = className "width-fill" :: gathered.attributes
                            }
                        else
                            { gathered
                                | width = Just width
                                , attributes = className ("width-fill-portion width-fill-" ++ toString portion) :: gathered.attributes
                                , styles =
                                    Single (".se.row > " ++ (styleName <| "width-fill-" ++ toString portion)) "flex-grow" (toString (portion * 100000)) :: gathered.styles
                            }
            else
                gathered

        Height height ->
            if gathered.height == Nothing then
                case height of
                    Px px ->
                        { gathered
                            | height = Just height
                            , attributes = className ("height-px-" ++ toString px) :: gathered.attributes
                            , styles = Single (styleName <| "height-px-" ++ toString px) "height" (toString px ++ "px") :: gathered.styles
                        }

                    Content ->
                        { gathered
                            | height = Just height
                            , attributes = className "height-content" :: gathered.attributes
                        }

                    Fill portion ->
                        if portion == 1 then
                            { gathered
                                | height = Just height
                                , attributes = className "height-fill" :: gathered.attributes
                            }
                        else
                            { gathered
                                | height = Just height
                                , attributes = className ("height-fill-portion height-fill-" ++ toString portion) :: gathered.attributes
                                , styles =
                                    Single (".se.column > " ++ (styleName <| "height-fill-" ++ toString portion)) "flex-grow" (toString (portion * 100000)) :: gathered.styles
                            }
            else
                gathered

        Describe description ->
            case description of
                Main ->
                    { gathered | node = addNodeName "main" gathered.node }

                Navigation ->
                    { gathered | node = addNodeName "nav" gathered.node }

                ContentInfo ->
                    { gathered | node = addNodeName "footer" gathered.node }

                Complementary ->
                    { gathered | node = addNodeName "aside" gathered.node }

                Heading i ->
                    if i <= 1 then
                        { gathered | node = addNodeName "h1" gathered.node }
                    else if i < 7 then
                        { gathered | node = addNodeName ("h" ++ toString i) gathered.node }
                    else
                        { gathered | node = addNodeName "h6" gathered.node }

                Button ->
                    { gathered | attributes = Html.Attributes.attribute "aria-role" "button" :: gathered.attributes }

                Label label ->
                    { gathered | attributes = Html.Attributes.attribute "aria-label" label :: gathered.attributes }

                LivePolite ->
                    { gathered | attributes = Html.Attributes.attribute "aria-live" "polite" :: gathered.attributes }

                LiveAssertive ->
                    { gathered | attributes = Html.Attributes.attribute "aria-live" "assertive" :: gathered.attributes }

        Nearby location on elem ->
            let
                nearbyGroup =
                    case gathered.nearbys of
                        Nothing ->
                            { above = Nothing
                            , below = Nothing
                            , right = Nothing
                            , left = Nothing
                            , infront = Nothing
                            , behind = Nothing
                            }

                        Just x ->
                            x

                styles =
                    case elem of
                        Empty ->
                            Nothing

                        Text str ->
                            Nothing

                        Unstyled html ->
                            Nothing

                        Styled styled ->
                            Just <| gathered.styles ++ styled.styles

                addIfEmpty existing =
                    case existing of
                        Nothing ->
                            case elem of
                                Empty ->
                                    Nothing

                                Text str ->
                                    Just ( on, textElement str )

                                Unstyled html ->
                                    Just ( on, html asEl )

                                Styled styled ->
                                    Just ( on, styled.html Nothing asEl )

                        _ ->
                            existing
            in
            { gathered
                | styles =
                    case styles of
                        Nothing ->
                            gathered.styles

                        Just newStyles ->
                            newStyles
                , nearbys =
                    Just <|
                        case location of
                            Above ->
                                { nearbyGroup
                                    | above = addIfEmpty nearbyGroup.above
                                }

                            Below ->
                                { nearbyGroup
                                    | below = addIfEmpty nearbyGroup.below
                                }

                            OnRight ->
                                { nearbyGroup
                                    | right = addIfEmpty nearbyGroup.right
                                }

                            OnLeft ->
                                { nearbyGroup
                                    | left = addIfEmpty nearbyGroup.left
                                }

                            InFront ->
                                { nearbyGroup
                                    | infront = addIfEmpty nearbyGroup.infront
                                }

                            Behind ->
                                { nearbyGroup
                                    | behind = addIfEmpty nearbyGroup.behind
                                }
            }

        AlignX x ->
            case gathered.alignment of
                Unaligned ->
                    { gathered
                        | attributes = className (alignXName x) :: gathered.attributes
                        , alignment = Aligned (Just x) Nothing
                    }

                Aligned (Just _) _ ->
                    gathered

                Aligned _ y ->
                    { gathered
                        | attributes = className (alignXName x) :: gathered.attributes
                        , alignment = Aligned (Just x) y
                    }

        AlignY y ->
            case gathered.alignment of
                Unaligned ->
                    { gathered
                        | attributes = className (alignYName y) :: gathered.attributes
                        , alignment = Aligned Nothing (Just y)
                    }

                Aligned _ (Just _) ->
                    gathered

                Aligned x _ ->
                    { gathered
                        | attributes = className (alignYName y) :: gathered.attributes
                        , alignment = Aligned x (Just y)
                    }

        Filter filter ->
            case gathered.filters of
                Nothing ->
                    { gathered | filters = Just (filterName filter) }

                Just existing ->
                    { gathered | filters = Just (filterName filter ++ " " ++ existing) }

        BoxShadow shadow ->
            case gathered.boxShadows of
                Nothing ->
                    { gathered | boxShadows = Just (formatBoxShadow shadow) }

                Just existing ->
                    { gathered | boxShadows = Just (formatBoxShadow shadow ++ ", " ++ existing) }

        TextShadow shadow ->
            case gathered.textShadows of
                Nothing ->
                    { gathered | textShadows = Just (formatTextShadow shadow) }

                Just existing ->
                    { gathered | textShadows = Just (formatTextShadow shadow ++ ", " ++ existing) }

        Transform pseudoClass transform ->
            case transform of
                Move mx my mz ->
                    case pseudoClass of
                        Nothing ->
                            case gathered.transform of
                                Nothing ->
                                    { gathered
                                        | transform =
                                            Just
                                                { translate =
                                                    Just ( mx, my, mz )
                                                , scale = Nothing
                                                , rotate = Nothing
                                                }
                                    }

                                Just transformation ->
                                    { gathered
                                        | transform = Just (addTranslate mx my mz transformation)
                                    }

                        Just Hover ->
                            case gathered.transformHover of
                                Nothing ->
                                    { gathered
                                        | transformHover =
                                            Just
                                                { translate =
                                                    Just ( mx, my, mz )
                                                , scale = Nothing
                                                , rotate = Nothing
                                                }
                                    }

                                Just transformation ->
                                    { gathered
                                        | transformHover = Just (addTranslate mx my mz transformation)
                                    }

                        Just Focus ->
                            gathered

                Rotate x y z angle ->
                    case pseudoClass of
                        Nothing ->
                            case gathered.transform of
                                Nothing ->
                                    { gathered
                                        | transform =
                                            Just
                                                { rotate =
                                                    Just ( x, y, z, angle )
                                                , scale = Nothing
                                                , translate = Nothing
                                                }
                                    }

                                Just transformation ->
                                    { gathered
                                        | transform = Just (addRotate x y z angle transformation)
                                    }

                        Just Hover ->
                            case gathered.transformHover of
                                Nothing ->
                                    { gathered
                                        | transformHover =
                                            Just
                                                { rotate =
                                                    Just ( x, y, z, angle )
                                                , scale = Nothing
                                                , translate = Nothing
                                                }
                                    }

                                Just transformation ->
                                    { gathered
                                        | transformHover = Just (addRotate x y z angle transformation)
                                    }

                        Just Focus ->
                            gathered

                Scale x y z ->
                    case pseudoClass of
                        Nothing ->
                            case gathered.transform of
                                Nothing ->
                                    { gathered
                                        | transform =
                                            Just
                                                { scale =
                                                    Just ( x, y, z )
                                                , rotate = Nothing
                                                , translate = Nothing
                                                }
                                    }

                                Just transformation ->
                                    { gathered
                                        | transform = Just (addScale x y z transformation)
                                    }

                        Just Hover ->
                            case gathered.transformHover of
                                Nothing ->
                                    { gathered
                                        | transformHover =
                                            Just
                                                { scale =
                                                    Just ( x, y, z )
                                                , rotate = Nothing
                                                , translate = Nothing
                                                }
                                    }

                                Just transformation ->
                                    { gathered
                                        | transformHover = Just (addScale x y z transformation)
                                    }

                        Just Focus ->
                            gathered


floorAtZero : Int -> Int
floorAtZero x =
    if x > 0 then
        x
    else
        0


{-| Paragraph's use a slightly different mode of spacing, which is that it's gives every child a margin of 1/2 of the spacing value for that axis.

This means paragraph's with spacing must have padding that is at least the same size

-}
adjustParagraphSpacing : List (Attribute msg) -> List (Attribute msg)
adjustParagraphSpacing attrs =
    let
        adjust ( x, y ) attribute =
            case attribute of
                StyleClass (PaddingStyle top right bottom left) ->
                    StyleClass
                        (PaddingStyle
                            (floorAtZero (top - (y // 2)))
                            (floorAtZero (right - (x // 2)))
                            (floorAtZero (bottom - (y // 2)))
                            (floorAtZero (left - (x // 2)))
                        )

                _ ->
                    attribute

        spacing =
            attrs
                |> List.foldr
                    (\x acc ->
                        case acc of
                            Just x ->
                                Just x

                            Nothing ->
                                case x of
                                    StyleClass (SpacingStyle x y) ->
                                        Just ( x, y )

                                    _ ->
                                        Nothing
                    )
                    Nothing
    in
    case spacing of
        Nothing ->
            attrs

        Just ( x, y ) ->
            List.map (adjust ( x, y )) attrs


type alias TransformationAlias a =
    { a
        | rotate : Maybe ( Float, Float, Float, Float )
        , translate : Maybe ( Maybe Float, Maybe Float, Maybe Float )
        , scale : Maybe ( Float, Float, Float )
    }


addScale : a -> b -> c -> { d | scale : Maybe ( a, b, c ) } -> { d | scale : Maybe ( a, b, c ) }
addScale x y z transformation =
    case transformation.scale of
        Nothing ->
            { transformation
                | scale =
                    Just ( x, y, z )
            }

        _ ->
            transformation


addRotate : a -> b -> c -> d -> { e | rotate : Maybe ( a, b, c, d ) } -> { e | rotate : Maybe ( a, b, c, d ) }
addRotate x y z angle transformation =
    case transformation.rotate of
        Nothing ->
            { transformation
                | rotate =
                    Just ( x, y, z, angle )
            }

        _ ->
            transformation


addTranslate : Maybe a -> Maybe a1 -> Maybe a2 -> { b | translate : Maybe ( Maybe a, Maybe a1, Maybe a2 ) } -> { b | translate : Maybe ( Maybe a, Maybe a1, Maybe a2 ) }
addTranslate mx my mz transformation =
    case transformation.translate of
        Nothing ->
            { transformation
                | translate =
                    Just ( mx, my, mz )
            }

        Just ( existingX, existingY, existingZ ) ->
            let
                addIfNothing val existing =
                    case existing of
                        Nothing ->
                            val

                        x ->
                            x
            in
            { transformation
                | translate =
                    Just
                        ( addIfNothing mx existingX
                        , addIfNothing my existingY
                        , addIfNothing mz existingZ
                        )
            }


type NodeName
    = Generic
    | NodeName String
    | Embedded String String


type alias NearbyGroup msg =
    { above : Maybe ( Bool, Html msg )
    , below : Maybe ( Bool, Html msg )
    , right : Maybe ( Bool, Html msg )
    , left : Maybe ( Bool, Html msg )
    , infront : Maybe ( Bool, Html msg )
    , behind : Maybe ( Bool, Html msg )
    }


type Borders
    = NoBorders
    | AllBorders Int
    | EachBorders
        { left : Int
        , top : Int
        , bottom : Int
        , right : Int
        }


type alias Gathered msg =
    { attributes : List (Html.Attribute msg)
    , styles : List Style
    , alignment : Aligned
    , borders : Borders
    , width : Maybe Length
    , height : Maybe Length
    , nearbys : Maybe (NearbyGroup msg)
    , node : NodeName
    , filters : Maybe String
    , boxShadows : Maybe String
    , textShadows : Maybe String
    , transform : Maybe TransformationGroup
    , transformHover : Maybe TransformationGroup
    , has : Set String
    }


initGathered : Maybe String -> Gathered msg
initGathered maybeNodeName =
    { attributes = []
    , styles = []
    , width = Nothing
    , height = Nothing
    , borders = NoBorders
    , alignment = Unaligned
    , node =
        case maybeNodeName of
            Nothing ->
                Generic

            Just name ->
                NodeName name
    , nearbys = Nothing
    , transform = Nothing
    , transformHover = Nothing
    , filters = Nothing
    , boxShadows = Nothing
    , textShadows = Nothing
    , has = Set.empty
    }


type alias TransformationGroup =
    { rotate : Maybe ( Float, Float, Float, Float )
    , translate : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , scale : Maybe ( Float, Float, Float )
    }


{-| Because of how it's constructed, we know that NearbyGroup is nonempty
-}
renderNearbyGroupAbsolute : NearbyGroup msg -> Html msg
renderNearbyGroupAbsolute nearby =
    let
        create ( location, node ) =
            case node of
                Nothing ->
                    Nothing

                Just ( on, el ) ->
                    Just <|
                        Html.div
                            [ Html.Attributes.class <|
                                locationClass location
                                    ++ (if not on then
                                            " hidden"
                                        else
                                            ""
                                       )
                            ]
                            [ el ]
    in
    Html.div [ Html.Attributes.class "se el nearby" ]
        (List.filterMap create
            [ ( Above, nearby.above )
            , ( Below, nearby.below )
            , ( OnLeft, nearby.left )
            , ( OnRight, nearby.right )
            , ( InFront, nearby.infront )
            , ( Behind, nearby.behind )
            ]
        )


{-| -}
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


{-| -}
className : String -> String
className x =
    x
        |> uncapitalize
        |> Regex.replace Regex.All (Regex.regex "[^a-zA-Z0-9_-]") (\_ -> "")
        |> Regex.replace Regex.All (Regex.regex "[A-Z0-9]+") (\{ match } -> " " ++ String.toLower match)
        |> Regex.replace Regex.All (Regex.regex "[\\s+]") (\_ -> "")


{-| -}
renderTransformationGroup : Maybe ( String, String ) -> { a | rotate : Maybe ( Float, Float, Float, Float ), scale : Maybe ( Float, Float, Float ), translate : Maybe ( Maybe Float, Maybe Float, Maybe Float ) } -> Maybe ( String, Style )
renderTransformationGroup maybePostfix group =
    let
        translate =
            flip Maybe.map
                group.translate
                (\( x, y, z ) ->
                    "translate3d("
                        ++ toString (Maybe.withDefault 0 x)
                        ++ "px, "
                        ++ toString (Maybe.withDefault 0 y)
                        ++ "px, "
                        ++ toString (Maybe.withDefault 0 z)
                        ++ "px)"
                )

        scale =
            flip Maybe.map
                group.scale
                (\( x, y, z ) ->
                    "scale3d(" ++ toString x ++ ", " ++ toString y ++ ", " ++ toString z ++ ")"
                )

        rotate =
            flip Maybe.map
                group.rotate
                (\( x, y, z, angle ) ->
                    "rotate3d(" ++ toString x ++ "," ++ toString y ++ "," ++ toString z ++ "," ++ toString angle ++ "rad)"
                )

        transformations =
            List.filterMap identity
                [ scale
                , translate
                , rotate
                ]

        name =
            String.join "-" <|
                List.filterMap identity
                    [ flip Maybe.map
                        group.translate
                        (\( x, y, z ) ->
                            "move-"
                                ++ floatClass (Maybe.withDefault 0 x)
                                ++ "-"
                                ++ floatClass (Maybe.withDefault 0 y)
                                ++ "-"
                                ++ floatClass (Maybe.withDefault 0 z)
                        )
                    , flip Maybe.map
                        group.scale
                        (\( x, y, z ) ->
                            "scale" ++ floatClass x ++ "-" ++ floatClass y ++ "-" ++ floatClass z
                        )
                    , flip Maybe.map
                        group.rotate
                        (\( x, y, z, angle ) ->
                            "rotate-" ++ floatClass x ++ "-" ++ floatClass y ++ "-" ++ floatClass z ++ "-" ++ floatClass angle
                        )
                    ]
    in
    case transformations of
        [] ->
            Nothing

        trans ->
            let
                transforms =
                    String.join " " trans

                ( classOnElement, classInStylesheet ) =
                    case maybePostfix of
                        Nothing ->
                            ( "transform-" ++ name
                            , ".transform-" ++ name
                            )

                        Just ( postfix, pseudostate ) ->
                            ( "transform-" ++ name ++ "-" ++ postfix
                            , "." ++ "transform-" ++ name ++ "-" ++ postfix ++ ":" ++ pseudostate
                            )
            in
            Just ( classOnElement, Single classInStylesheet "transform" transforms )


formatTransformations : Gathered msg -> Gathered msg
formatTransformations gathered =
    let
        addTransform ( classes, styles ) =
            case gathered.transform of
                Nothing ->
                    ( classes, styles )

                Just transform ->
                    case renderTransformationGroup Nothing transform of
                        Nothing ->
                            ( classes, styles )

                        Just ( name, transformStyle ) ->
                            ( name :: classes
                            , transformStyle :: styles
                            )

        addHoverTransform ( classes, styles ) =
            case gathered.transformHover of
                Nothing ->
                    ( classes, styles )

                Just transform ->
                    case renderTransformationGroup (Just ( "hover", "hover" )) transform of
                        Nothing ->
                            ( classes, styles )

                        Just ( name, transformStyle ) ->
                            ( name :: classes
                            , transformStyle :: styles
                            )

        addFilters ( classes, styles ) =
            case gathered.filters of
                Nothing ->
                    ( classes, styles )

                Just filter ->
                    let
                        name =
                            "filter-" ++ className filter
                    in
                    ( name :: classes
                    , Single ("." ++ name) "filter" filter
                        :: styles
                    )

        addBoxShadows ( classes, styles ) =
            case gathered.boxShadows of
                Nothing ->
                    ( classes, styles )

                Just shades ->
                    let
                        name =
                            "box-shadow-" ++ className shades
                    in
                    ( name :: classes
                    , Single ("." ++ name) "box-shadow" shades
                        :: styles
                    )

        addTextShadows ( classes, styles ) =
            case gathered.textShadows of
                Nothing ->
                    ( classes, styles )

                Just shades ->
                    let
                        name =
                            "text-shadow-" ++ className shades
                    in
                    ( name :: classes
                    , Single ("." ++ name) "text-shadow" shades
                        :: styles
                    )

        ( classes, styles ) =
            ( [], gathered.styles )
                |> addFilters
                |> addBoxShadows
                |> addTextShadows
                |> addTransform
                |> addHoverTransform
    in
    { gathered
        | styles = styles
        , attributes =
            Html.Attributes.class (String.join " " classes) :: gathered.attributes
    }


type EmbedStyle
    = NoStyleSheet
    | StaticRootAndDynamic OptionRecord
    | OnlyDynamic OptionRecord


noStyleSheet : EmbedStyle
noStyleSheet =
    NoStyleSheet


element : EmbedStyle -> LayoutContext -> Maybe String -> List (Attribute msg) -> Children (Element msg) -> Element msg
element embedMode context node attributes children =
    (contextClasses context :: attributes)
        |> List.foldr gatherAttributes (initGathered node)
        |> formatTransformations
        |> asElement embedMode children context


asElement : EmbedStyle -> Children (Element msg) -> LayoutContext -> Gathered msg -> Element msg
asElement embedMode children context rendered =
    let
        ( htmlChildren, styleChildren ) =
            case children of
                Keyed keyedChildren ->
                    List.foldr gatherKeyed ( [], rendered.styles ) keyedChildren
                        |> Tuple.mapFirst Keyed

                Unkeyed unkeyedChildren ->
                    List.foldr gather ( [], rendered.styles ) unkeyedChildren
                        |> Tuple.mapFirst Unkeyed

        gather child ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    ( html context :: htmls
                    , existingStyles
                    )

                Styled styled ->
                    ( styled.html Nothing context :: htmls
                    , styled.styles ++ existingStyles
                    )

                Text str ->
                    -- TEXT OPTIMIZATION
                    -- You can have raw text if the element is an el, and has `width-content` and `height-content`
                    -- Same if it's a column or row with one child and width-content, height-content
                    if rendered.width == Just Content && rendered.height == Just Content && context == asEl then
                        ( Html.text str
                            :: htmls
                        , existingStyles
                        )
                    else if context == asEl then
                        ( textElementFill str
                            :: htmls
                        , existingStyles
                        )
                    else
                        ( textElement str
                            :: htmls
                        , existingStyles
                        )

                Empty ->
                    ( htmls, existingStyles )

        gatherKeyed ( key, child ) ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    ( ( key, html context ) :: htmls
                    , existingStyles
                    )

                Styled styled ->
                    ( ( key, styled.html Nothing context ) :: htmls
                    , styled.styles ++ existingStyles
                    )

                Text str ->
                    -- TEXT OPTIMIZATION
                    -- You can have raw text if the element is an el, and has `width-content` and `height-content`
                    -- Same if it's a column or row with one child and width-content, height-content
                    if rendered.width == Just Content && rendered.height == Just Content && context == asEl then
                        ( ( key, Html.text str )
                            :: htmls
                        , existingStyles
                        )
                    else
                        ( ( key, textElement str )
                            :: htmls
                        , existingStyles
                        )

                Empty ->
                    ( htmls, existingStyles )
    in
    case embedMode of
        NoStyleSheet ->
            let
                renderedChildren =
                    case Maybe.map renderNearbyGroupAbsolute rendered.nearbys of
                        Nothing ->
                            htmlChildren

                        Just nearby ->
                            case htmlChildren of
                                Keyed keyed ->
                                    Keyed <| ( "nearby-elements-pls-pls-pls-pls-be-unique", nearby ) :: keyed

                                Unkeyed unkeyed ->
                                    Unkeyed (nearby :: unkeyed)
            in
            case styleChildren of
                [] ->
                    Unstyled (renderNode rendered renderedChildren Nothing)

                _ ->
                    Styled
                        { styles = styleChildren
                        , html = renderNode rendered renderedChildren
                        }

        StaticRootAndDynamic options ->
            let
                styles =
                    styleChildren
                        |> List.foldr reduceStyles ( Set.empty, [ renderFocusStyle options.focus ] )
                        |> Tuple.second

                renderedChildren =
                    case Maybe.map renderNearbyGroupAbsolute rendered.nearbys of
                        Nothing ->
                            case htmlChildren of
                                Keyed keyed ->
                                    Keyed <|
                                        ( "static-stylesheet", Internal.Style.rulesElement )
                                            :: ( "dynamic-stylesheet", toStyleSheet options styles )
                                            :: keyed

                                Unkeyed unkeyed ->
                                    Unkeyed
                                        (Internal.Style.rulesElement
                                            :: toStyleSheet options styles
                                            :: unkeyed
                                        )

                        Just nearby ->
                            case htmlChildren of
                                Keyed keyed ->
                                    Keyed <|
                                        ( "static-stylesheet", Internal.Style.rulesElement )
                                            :: ( "dynamic-stylesheet", toStyleSheet options styles )
                                            :: ( "nearby-elements-pls-pls-pls-pls-be-unique", nearby )
                                            :: keyed

                                Unkeyed unkeyed ->
                                    Unkeyed
                                        (Internal.Style.rulesElement
                                            :: toStyleSheet options styles
                                            :: nearby
                                            :: unkeyed
                                        )
            in
            Unstyled
                (renderNode rendered
                    renderedChildren
                    Nothing
                )

        OnlyDynamic options ->
            let
                styles =
                    styleChildren
                        |> List.foldr reduceStyles ( Set.empty, [ renderFocusStyle options.focus ] )
                        |> Tuple.second

                renderedChildren =
                    case Maybe.map renderNearbyGroupAbsolute rendered.nearbys of
                        Nothing ->
                            case htmlChildren of
                                Keyed keyed ->
                                    Keyed <|
                                        ( "dynamic-stylesheet", toStyleSheet options styles )
                                            :: keyed

                                Unkeyed unkeyed ->
                                    Unkeyed
                                        (Internal.Style.rulesElement
                                            :: toStyleSheet options styles
                                            :: unkeyed
                                        )

                        Just nearby ->
                            case htmlChildren of
                                Keyed keyed ->
                                    Keyed <|
                                        ( "dynamic-stylesheet", toStyleSheet options styles )
                                            :: ( "nearby-elements-pls-pls-pls-pls-be-unique", nearby )
                                            :: keyed

                                Unkeyed unkeyed ->
                                    Unkeyed
                                        (toStyleSheet options styles
                                            :: nearby
                                            :: unkeyed
                                        )
            in
            Unstyled
                (renderNode rendered
                    renderedChildren
                    Nothing
                )


rowEdgeFillers : List (Element msg) -> List (Element msg)
rowEdgeFillers children =
    unstyled
        (VirtualDom.node "alignLeft"
            [ Html.Attributes.class "se container align-container-left content-center-y spacer unfocusable" ]
            []
        )
        :: children
        ++ [ unstyled
                (VirtualDom.node "alignRight"
                    [ Html.Attributes.class "se container align-container-right content-center-y spacer unfocusable" ]
                    []
                )
           ]


keyedRowEdgeFillers : List ( String, Element msg ) -> List ( String, Element msg )
keyedRowEdgeFillers children =
    ( "left-filler-node-pls-pls-pls-be-unique"
    , unstyled
        (VirtualDom.node "alignLeft"
            [ Html.Attributes.class "se container align-container-left content-center-y spacer unfocusable" ]
            []
        )
    )
        :: children
        ++ [ ( "right-filler-node-pls-pls-pls-be-unique"
             , unstyled
                (VirtualDom.node "alignRight"
                    [ Html.Attributes.class "se container align-container-right content-center-y spacer unfocusable" ]
                    []
                )
             )
           ]


columnEdgeFillers : List (Element msg) -> List (Element msg)
columnEdgeFillers children =
    -- unstyled <|
    -- (VirtualDom.node "alignTop"
    --     [ Html.Attributes.class "se container align-container-top spacer" ]
    --     []
    -- ) ::
    children
        ++ [ unstyled
                (VirtualDom.node "div"
                    [ Html.Attributes.class "se container align-container-top teleporting-spacer unfocusable" ]
                    []
                )
           , unstyled
                (VirtualDom.node "alignBottom"
                    [ Html.Attributes.class "se container align-container-bottom spacer unfocusable" ]
                    []
                )
           ]


keyedColumnEdgeFillers : List ( String, Element msg ) -> List ( String, Element msg )
keyedColumnEdgeFillers children =
    -- unstyled <|
    -- (VirtualDom.node "alignTop"
    --     [ Html.Attributes.class "se container align-container-top spacer" ]
    --     []
    -- ) ::
    children
        ++ [ ( "teleporting-top-filler-node-pls-pls-pls-be-unique"
             , unstyled
                (VirtualDom.node "div"
                    [ Html.Attributes.class "se container align-container-top teleporting-spacer" ]
                    []
                )
             )
           , ( "bottom-filler-node-pls-pls-pls-be-unique"
             , unstyled
                (VirtualDom.node "alignBottom"
                    [ Html.Attributes.class "se container align-container-bottom spacer" ]
                    []
                )
             )
           ]


{-| TODO:

This doesn't reduce equivalent attributes completely.

-}
filter : List (Attribute msg) -> List (Attribute msg)
filter attrs =
    Tuple.first <|
        List.foldr
            (\x ( found, has ) ->
                case x of
                    NoAttribute ->
                        ( found, has )

                    Class key class ->
                        ( x :: found, has )

                    Attr attr ->
                        ( x :: found, has )

                    StyleClass style ->
                        ( x :: found, has )

                    Width width ->
                        if Set.member "width" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "width" has )

                    Height height ->
                        if Set.member "height" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "height" has )

                    Describe description ->
                        if Set.member "described" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "described" has )

                    Nearby location on elem ->
                        ( x :: found, has )

                    AlignX _ ->
                        if Set.member "align-x" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "align-x" has )

                    AlignY _ ->
                        if Set.member "align-y" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "align-y" has )

                    Filter filter ->
                        ( x :: found, has )

                    BoxShadow shadow ->
                        ( x :: found, has )

                    TextShadow shadow ->
                        ( x :: found, has )

                    Transform _ _ ->
                        ( x :: found, has )
            )
            ( [], Set.empty )
            attrs


get : List (Attribute msg) -> (Attribute msg -> Bool) -> List (Attribute msg)
get attrs isAttr =
    attrs
        |> filter
        |> List.foldr
            (\x found ->
                if isAttr x then
                    x :: found
                else
                    found
            )
            []


getSpacing : List (Attribute msg) -> ( Int, Int ) -> ( Int, Int )
getSpacing attrs default =
    attrs
        |> List.foldr
            (\x acc ->
                case acc of
                    Just x ->
                        Just x

                    Nothing ->
                        case x of
                            StyleClass (SpacingStyle x y) ->
                                Just ( x, y )

                            _ ->
                                Nothing
            )
            Nothing
        |> Maybe.withDefault default


getSpacingAttribute : List (Attribute msg) -> ( Int, Int ) -> Attribute msg1
getSpacingAttribute attrs default =
    attrs
        |> List.foldr
            (\x acc ->
                case acc of
                    Just x ->
                        Just x

                    Nothing ->
                        case x of
                            StyleClass (SpacingStyle x y) ->
                                Just ( x, y )

                            _ ->
                                Nothing
            )
            Nothing
        |> Maybe.withDefault default
        |> (\( x, y ) -> StyleClass (SpacingStyle x y))


textElement : String -> VirtualDom.Node msg
textElement str =
    VirtualDom.node "div"
        [ VirtualDom.property "className"
            (Json.string "se text width-content height-content")
        ]
        [ VirtualDom.text str ]


textElementFill : String -> VirtualDom.Node msg
textElementFill str =
    VirtualDom.node "div"
        [ VirtualDom.property "className"
            (Json.string "se text width-fill height-fill")
        ]
        [ VirtualDom.text str ]


type Children x
    = Unkeyed (List x)
    | Keyed (List ( String, x ))


toHtml : OptionRecord -> Element msg -> Html msg
toHtml options el =
    case el of
        Unstyled html ->
            html asEl

        Styled { styles, html } ->
            let
                styleSheet =
                    styles
                        |> List.foldr reduceStyles ( Set.empty, [ renderFocusStyle options.focus ] )
                        |> Tuple.second
                        |> toStyleSheetString options
            in
            html (Just styleSheet) asEl

        Text text ->
            textElement text

        Empty ->
            textElement ""


{-| -}
renderRoot : List Option -> List (Attribute msg) -> Element msg -> Html msg
renderRoot optionList attributes child =
    let
        options =
            optionsToRecord optionList
    in
    element (StaticRootAndDynamic options) asEl Nothing attributes (Unkeyed [ child ])
        |> toHtml options


type RenderMode
    = Viewport
    | Layout
    | NoStaticStyleSheet
    | WithVirtualCss


type alias OptionRecord =
    { hover : HoverSetting
    , focus : FocusStyle
    , mode : RenderMode
    }


type HoverSetting
    = NoHover
    | AllowHover
    | ForceHover


type Option
    = HoverOption HoverSetting
    | FocusStyleOption FocusStyle
    | RenderModeOption RenderMode


type alias FocusStyle =
    { borderColor : Maybe Color
    , shadow : Maybe Shadow
    , backgroundColor : Maybe Color
    }


type alias Shadow =
    { color : Color
    , offset : ( Int, Int )
    , blur : Int
    , size : Int
    }



-- renderStyles : Element msg -> ( Set String, List Style ) -> ( Set String, List Style )
-- renderStyles el ( cache, existing ) =
--     case el of
--         Unstyled html ->
--             ( cache, existing )
--         Styled styled ->
--             let
--                 reduced =
--                     List.foldr reduceStyles ( cache, existing ) styled.styles
--             in
--             List.foldr renderStyles reduced styled.children


renderFocusStyle :
    FocusStyle
    -> Style
renderFocusStyle focus =
    Style ".se:focus .focusable > *:not(.unfocusable), .se.focus-exactly:focus"
        (List.filterMap identity
            [ Maybe.map (\color -> Property "border-color" (formatColor color)) focus.borderColor
            , Maybe.map (\color -> Property "background-color" (formatColor color)) focus.backgroundColor
            , Maybe.map
                (\shadow ->
                    Property "box-shadow"
                        (formatBoxShadow
                            { color = shadow.color
                            , offset = shadow.offset
                            , inset = False
                            , blur = shadow.blur
                            , size = shadow.size
                            }
                        )
                )
                focus.shadow
            , Just <| Property "outline" "none"
            ]
        )


focusDefaultStyle : { backgroundColor : Maybe Color, borderColor : Maybe Color, shadow : Maybe Shadow }
focusDefaultStyle =
    { backgroundColor = Nothing
    , borderColor = Nothing
    , shadow =
        Just
            { color = Color.rgb 155 203 255
            , offset = ( 0, 0 )
            , blur = 3
            , size = 3
            }
    }


optionsToRecord : List Option -> OptionRecord
optionsToRecord options =
    let
        combine opt record =
            case opt of
                HoverOption hoverable ->
                    case record.hover of
                        Nothing ->
                            { record | hover = Just hoverable }

                        _ ->
                            record

                FocusStyleOption focusStyle ->
                    case record.focus of
                        Nothing ->
                            { record | focus = Just focusStyle }

                        _ ->
                            record

                RenderModeOption renderMode ->
                    case record.mode of
                        Nothing ->
                            { record | mode = Just renderMode }

                        _ ->
                            record

        finalize record =
            { hover =
                case record.hover of
                    Nothing ->
                        AllowHover

                    Just hoverable ->
                        hoverable
            , focus =
                case record.focus of
                    Nothing ->
                        focusDefaultStyle

                    Just focusable ->
                        focusable
            , mode =
                case record.mode of
                    Nothing ->
                        Layout

                    Just actualMode ->
                        actualMode
            }
    in
    finalize <|
        List.foldr combine
            { hover = Nothing
            , focus = Nothing
            , mode = Nothing
            }
            options


htmlClass : String -> Attribute msg
htmlClass cls =
    Attr <| VirtualDom.property "className" (Json.string cls)


renderFont : List Font -> String
renderFont families =
    let
        fontName font =
            case font of
                Serif ->
                    "serif"

                SansSerif ->
                    "sans-serif"

                Monospace ->
                    "monospace"

                Typeface name ->
                    "\"" ++ name ++ "\""

                ImportFont name url ->
                    "\"" ++ name ++ "\""
    in
    families
        |> List.map fontName
        |> String.join ", "


reduceStyles : Style -> ( Set String, List Style ) -> ( Set String, List Style )
reduceStyles style ( cache, existing ) =
    let
        styleName =
            getStyleName style
    in
    if Set.member styleName cache then
        ( cache, existing )
    else
        ( Set.insert styleName cache
        , style :: existing
        )


toStyleSheet : OptionRecord -> List Style -> VirtualDom.Node msg
toStyleSheet options styleSheet =
    VirtualDom.node "style" [] [ Html.text (toStyleSheetString options styleSheet) ]


toStyleSheetString : OptionRecord -> List Style -> String
toStyleSheetString options stylesheet =
    let
        renderProps force (Property key val) existing =
            if force then
                existing ++ "\n  " ++ key ++ ": " ++ val ++ " !important;"
            else
                existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

        renderStyle force maybePseudo selector props =
            case maybePseudo of
                Nothing ->
                    selector ++ "{" ++ List.foldl (renderProps force) "" props ++ "\n}"

                Just pseudo ->
                    selector ++ ":" ++ pseudo ++ " {" ++ List.foldl (renderProps force) "" props ++ "\n}"

        renderStyleRule rule maybePseudo force =
            case rule of
                Style selector props ->
                    renderStyle force maybePseudo selector props

                FontSize i ->
                    renderStyle force
                        maybePseudo
                        (".font-size-" ++ intToString i)
                        [ Property "font-size" (intToString i)
                        ]

                FontFamily name typefaces ->
                    renderStyle force
                        maybePseudo
                        ("." ++ name)
                        [ Property "font-family" (renderFont typefaces)
                        ]

                LineHeight i ->
                    renderStyle force
                        maybePseudo
                        (".line-height-" ++ floatClass i)
                        [ Property "line-height" (toString i)
                        ]

                Single class prop val ->
                    renderStyle force
                        maybePseudo
                        class
                        [ Property prop val
                        ]

                Colored class prop color ->
                    renderStyle force
                        maybePseudo
                        class
                        [ Property prop (formatColor color)
                        ]

                SpacingStyle x y ->
                    let
                        class =
                            ".spacing-" ++ toString x ++ "-" ++ toString y
                    in
                    List.foldl (++)
                        ""
                        [ renderStyle force maybePseudo (class ++ ".row > .se") [ Property "margin-left" (toString x ++ "px") ]
                        , renderStyle force maybePseudo (class ++ ".column > .se") [ Property "margin-top" (toString y ++ "px") ]
                        , renderStyle force maybePseudo (class ++ ".page > .se") [ Property "margin-top" (toString y ++ "px") ]
                        , renderStyle force maybePseudo (class ++ ".page > .self-left") [ Property "margin-right" (toString x ++ "px") ]
                        , renderStyle force maybePseudo (class ++ ".page > .self-right") [ Property "margin-left" (toString x ++ "px") ]
                        , renderStyle force
                            maybePseudo
                            (class ++ ".paragraph > .se")
                            [ Property "margin-right" (toString (toFloat x / 2) ++ "px")
                            , Property "margin-left" (toString (toFloat x / 2) ++ "px")
                            ]
                        , renderStyle force
                            maybePseudo
                            (class ++ ".paragraph > .se")
                            [ Property "margin-bottom" (toString (toFloat y / 2) ++ "px")
                            , Property "margin-top" (toString (toFloat y / 2) ++ "px")
                            ]
                        ]

                PaddingStyle top right bottom left ->
                    let
                        class =
                            ".pad-"
                                ++ toString top
                                ++ "-"
                                ++ toString right
                                ++ "-"
                                ++ toString bottom
                                ++ "-"
                                ++ toString left
                    in
                    renderStyle force
                        maybePseudo
                        class
                        [ Property "padding"
                            (toString top
                                ++ "px "
                                ++ toString right
                                ++ "px "
                                ++ toString bottom
                                ++ "px "
                                ++ toString left
                                ++ "px"
                            )
                        ]

                GridTemplateStyle template ->
                    let
                        class =
                            ".grid-rows-"
                                ++ String.join "-" (List.map lengthClassName template.rows)
                                ++ "-cols-"
                                ++ String.join "-" (List.map lengthClassName template.columns)
                                ++ "-space-x-"
                                ++ lengthClassName (Tuple.first template.spacing)
                                ++ "-space-y-"
                                ++ lengthClassName (Tuple.second template.spacing)

                        ySpacing =
                            toGridLength (Tuple.second template.spacing)

                        xSpacing =
                            toGridLength (Tuple.first template.spacing)

                        toGridLength x =
                            case x of
                                Px px ->
                                    toString px ++ "px"

                                Content ->
                                    "auto"

                                Fill i ->
                                    toString i ++ "fr"

                        msColumns =
                            template.columns
                                |> List.map toGridLength
                                |> String.join ySpacing
                                |> (\x -> "-ms-grid-columns: " ++ x ++ ";")

                        msRows =
                            template.columns
                                |> List.map toGridLength
                                |> String.join ySpacing
                                |> (\x -> "-ms-grid-rows: " ++ x ++ ";")

                        base =
                            class ++ "{" ++ msColumns ++ msRows ++ "}"

                        columns =
                            template.columns
                                |> List.map toGridLength
                                |> String.join " "
                                |> (\x -> "grid-template-columns: " ++ x ++ ";")

                        rows =
                            template.rows
                                |> List.map toGridLength
                                |> String.join " "
                                |> (\x -> "grid-template-rows: " ++ x ++ ";")

                        gapX =
                            "grid-column-gap:" ++ toGridLength (Tuple.first template.spacing) ++ ";"

                        gapY =
                            "grid-row-gap:" ++ toGridLength (Tuple.first template.spacing) ++ ";"

                        modernGrid =
                            class ++ "{" ++ columns ++ rows ++ gapX ++ gapY ++ "}"

                        supports =
                            "@supports (display:grid) {" ++ modernGrid ++ "}"
                    in
                    base ++ supports

                GridPosition position ->
                    let
                        class =
                            ".grid-pos-"
                                ++ intToString position.row
                                ++ "-"
                                ++ intToString position.col
                                ++ "-"
                                ++ intToString position.width
                                ++ "-"
                                ++ intToString position.height

                        msPosition =
                            String.join " "
                                [ "-ms-grid-row: "
                                    ++ intToString position.row
                                    ++ ";"
                                , "-ms-grid-row-span: "
                                    ++ intToString position.height
                                    ++ ";"
                                , "-ms-grid-column: "
                                    ++ intToString position.col
                                    ++ ";"
                                , "-ms-grid-column-span: "
                                    ++ intToString position.width
                                    ++ ";"
                                ]

                        base =
                            class ++ "{" ++ msPosition ++ "}"

                        modernPosition =
                            String.join " "
                                [ "grid-row: "
                                    ++ intToString position.row
                                    ++ " / "
                                    ++ intToString (position.row + position.height)
                                    ++ ";"
                                , "grid-column: "
                                    ++ intToString position.col
                                    ++ " / "
                                    ++ intToString (position.col + position.width)
                                    ++ ";"
                                ]

                        modernGrid =
                            class ++ "{" ++ modernPosition ++ "}"

                        supports =
                            "@supports (display:grid) {" ++ modernGrid ++ "}"
                    in
                    base ++ supports

                PseudoSelector class style ->
                    case class of
                        Focus ->
                            renderStyleRule style (Just "focus") False

                        Hover ->
                            case options.hover of
                                NoHover ->
                                    ""

                                AllowHover ->
                                    renderStyleRule style (Just "hover") False

                                ForceHover ->
                                    renderStyleRule style Nothing True

        renderTopLevels rule =
            case rule of
                FontFamily name typefaces ->
                    let
                        getImports font =
                            case font of
                                ImportFont _ url ->
                                    Just ("@import url('" ++ url ++ "');")

                                _ ->
                                    Nothing
                    in
                    typefaces
                        |> List.filterMap getImports
                        |> String.join "\n"
                        |> Just

                _ ->
                    Nothing

        combine style rendered =
            { rendered
                | rules = rendered.rules ++ renderStyleRule style Nothing False
                , topLevel =
                    case renderTopLevels style of
                        Nothing ->
                            rendered.topLevel

                        Just topLevel ->
                            rendered.topLevel ++ topLevel
            }
    in
    List.foldl combine { rules = "", topLevel = "" } stylesheet
        |> (\{ rules, topLevel } -> topLevel ++ rules)


lengthClassName : Length -> String
lengthClassName x =
    case x of
        Px px ->
            intToString px ++ "px"

        Content ->
            "auto"

        Fill i ->
            intToString i ++ "fr"



-- Between { value, min, max } ->
--     case (min, max) ->
--         (Nothing, Nothing) ->
--             lengthClassName value
--         (Just minimum, Nothing) ->
--             lengthClassName value ++ "-min-" ++ intToString minimum
--         (Nothing, Just maximum) ->
--             lengthClassName value ++ "-max-" ++ intToString maximum
--         (Just minimum, Just maximum) ->
--             lengthClassName value ++ "-min-" ++ intToString minimum ++ "-max-" ++ intToString maximum


formatDropShadow : { d | blur : a, color : Color, offset : ( b, c ) } -> String
formatDropShadow shadow =
    String.join " "
        [ toString (Tuple.first shadow.offset) ++ "px"
        , toString (Tuple.second shadow.offset) ++ "px"
        , toString shadow.blur ++ "px"
        , formatColor shadow.color
        ]


formatTextShadow : { d | blur : a, color : Color, offset : ( b, c ) } -> String
formatTextShadow shadow =
    String.join " "
        [ toString (Tuple.first shadow.offset) ++ "px"
        , toString (Tuple.second shadow.offset) ++ "px"
        , toString shadow.blur ++ "px"
        , formatColor shadow.color
        ]


formatBoxShadow : { e | blur : a, color : Color, inset : Bool, offset : ( b, c ), size : d } -> String
formatBoxShadow shadow =
    String.join " " <|
        List.filterMap identity
            [ if shadow.inset then
                Just "inset"
              else
                Nothing
            , Just <| toString (Tuple.first shadow.offset) ++ "px"
            , Just <| toString (Tuple.second shadow.offset) ++ "px"
            , Just <| toString shadow.blur ++ "px"
            , Just <| toString shadow.size ++ "px"
            , Just <| formatColor shadow.color
            ]


filterName : FilterType -> String
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
                    { offset = shadow.offset
                    , size = shadow.size
                    , blur = shadow.blur
                    , color = shadow.color
                    }
            in
            "drop-shadow(" ++ formatDropShadow shadowModel ++ ")"


floatClass : Float -> String
floatClass x =
    intToString (round (x * 100))


intToString : Int -> String
intToString i =
    case i of
        0 ->
            "0"

        1 ->
            "1"

        2 ->
            "2"

        3 ->
            "3"

        4 ->
            "4"

        5 ->
            "5"

        100 ->
            "100"

        255 ->
            -- included because of colors
            "255"

        _ ->
            toString i


formatColor : Color -> String
formatColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    ("rgba(" ++ intToString red)
        ++ ("," ++ intToString green)
        ++ ("," ++ intToString blue)
        ++ ("," ++ toString alpha ++ ")")


formatColorClass : Color -> String
formatColorClass color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    intToString red
        ++ "-"
        ++ intToString green
        ++ "-"
        ++ intToString blue
        ++ "-"
        ++ floatClass alpha



-- toStyleSheetVirtualCss : List Style -> ()
-- toStyleSheetVirtualCss stylesheet =
--     case stylesheet of
--         [] ->
--             ()
--         styles ->
--             let
--                 renderProps (Property key val) existing =
--                     existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"
--                 renderStyle selector props =
--                     selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"
--                 _ =
--                     VirtualCss.clear ()
--                 combine style cache =
--                     case style of
--                         Style selector props ->
--                             let
--                                 _ =
--                                     VirtualCss.insert (renderStyle selector props) 0
--                             in
--                             cache
--                         Single class prop val ->
--                             if Set.member class cache then
--                                 cache
--                             else
--                                 let
--                                     _ =
--                                         VirtualCss.insert (class ++ "{" ++ prop ++ ":" ++ val ++ "}") 0
--                                 in
--                                 Set.insert class cache
--                         Colored class prop color ->
--                             if Set.member class cache then
--                                 cache
--                             else
--                                 let
--                                     _ =
--                                         VirtualCss.insert (class ++ "{" ++ prop ++ ":" ++ formatColor color ++ "}") 0
--                                 in
--                                 Set.insert class cache
--                         SpacingStyle x y ->
--                             let
--                                 class =
--                                     ".spacing-" ++ toString x ++ "-" ++ toString y
--                             in
--                             if Set.member class cache then
--                                 cache
--                             else
--                                 -- TODO!
--                                 cache
--                         -- ( rendered ++ spacingClasses class x y
--                         -- , Set.insert class cache
--                         -- )
--                         PaddingStyle top right bottom left ->
--                             let
--                                 class =
--                                     ".pad-"
--                                         ++ toString top
--                                         ++ "-"
--                                         ++ toString right
--                                         ++ "-"
--                                         ++ toString bottom
--                                         ++ "-"
--                                         ++ toString left
--                             in
--                             if Set.member class cache then
--                                 cache
--                             else
--                                 -- TODO!
--                                 cache
--                         LineHeight _ ->
--                             cache
--                         GridTemplateStyle _ ->
--                             cache
--                         GridPosition _ ->
--                             cache
--                         FontFamily _ _ ->
--                             cache
--                         FontSize _ ->
--                             cache
--                         PseudoSelector _ _ ->
--                             cache
--                 -- ( rendered ++ paddingClasses class top right bottom left
--                 -- , Set.insert class cache
--                 -- )
--             in
--             List.foldl combine Set.empty styles
--                 |> always ()


psuedoClassName class =
    case class of
        Focus ->
            "focus"

        Hover ->
            "hover"


{-| This is a key to know which styles should override which other styles.
-}
styleKey : Style -> String
styleKey style =
    case style of
        Style class _ ->
            class

        FontSize i ->
            "fontsize"

        FontFamily _ _ ->
            "fontfamily"

        Single _ prop _ ->
            prop

        LineHeight _ ->
            "lineheight"

        Colored _ prop _ ->
            prop

        SpacingStyle _ _ ->
            "spacing"

        PaddingStyle _ _ _ _ ->
            "padding"

        GridTemplateStyle _ ->
            "grid-template"

        GridPosition _ ->
            "grid-position"

        PseudoSelector class style ->
            psuedoClassName class ++ styleKey style


isInt : Int -> Int
isInt x =
    x


getStyleName : Style -> String
getStyleName style =
    case style of
        Style class _ ->
            class

        LineHeight i ->
            "line-height-" ++ floatClass i

        FontFamily name _ ->
            name

        FontSize i ->
            "font-size-" ++ toString (isInt i)

        Single class _ _ ->
            class

        Colored class _ _ ->
            class

        SpacingStyle x y ->
            "spacing-" ++ toString (isInt x) ++ "-" ++ toString (isInt y)

        PaddingStyle top right bottom left ->
            "pad-"
                ++ toString top
                ++ "-"
                ++ toString right
                ++ "-"
                ++ toString bottom
                ++ "-"
                ++ toString left

        GridTemplateStyle template ->
            "grid-rows-"
                ++ String.join "-" (List.map lengthClassName template.rows)
                ++ "-cols-"
                ++ String.join "-" (List.map lengthClassName template.columns)
                ++ "-space-x-"
                ++ lengthClassName (Tuple.first template.spacing)
                ++ "-space-y-"
                ++ lengthClassName (Tuple.second template.spacing)

        GridPosition pos ->
            "grid-pos-"
                ++ toString pos.row
                ++ "-"
                ++ toString pos.col
                ++ "-"
                ++ toString pos.width
                ++ "-"
                ++ toString pos.height

        PseudoSelector selector subStyle ->
            getStyleName subStyle


locationClass : Location -> String
locationClass location =
    case location of
        Above ->
            "se el above"

        Below ->
            "se el below"

        OnRight ->
            "se el on-right"

        OnLeft ->
            "se el on-left"

        InFront ->
            "se el infront"

        Behind ->
            "se el behind"
