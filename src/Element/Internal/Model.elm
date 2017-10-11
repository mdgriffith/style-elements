module Element.Internal.Model exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Style.Internal.Model as Style


name el =
    case el of
        Empty ->
            "empty"

        Spacer _ ->
            "spacer"

        Text _ _ ->
            "text"

        Element _ ->
            "element"

        Layout _ ->
            "layout"

        Raw _ ->
            "html"


adjust : (Maybe Style.LayoutModel -> Element style variation msg -> ( Element style variation msg, Maybe (List (Element style variation msg)) )) -> Maybe Style.LayoutModel -> Element style variation msg -> ( Element style variation msg, Maybe (List (Element style variation msg)) )
adjust fn parent el =
    let
        merge el current =
            case el of
                Nothing ->
                    current

                Just something ->
                    case current of
                        Nothing ->
                            el

                        Just cur ->
                            Just (something ++ cur)

        maybeOnEmptyList list =
            if List.isEmpty list then
                Nothing
            else
                Just list
    in
    case el of
        Element ({ child, absolutelyPositioned } as elm) ->
            let
                ( adjustedChild, childData ) =
                    adjust fn Nothing child

                ( adjustedOthers, otherChildrenData ) =
                    case absolutelyPositioned of
                        Nothing ->
                            ( Nothing, Nothing )

                        Just others ->
                            List.foldr adjustAndMerge ( [], [] ) others
                                |> (\( children, onScreen ) -> ( maybeOnEmptyList children, maybeOnEmptyList onScreen ))

                adjustAndMerge el ( adjustedAggregate, dataAggregate ) =
                    let
                        ( adjusted, data ) =
                            adjust fn Nothing el
                    in
                    case data of
                        Nothing ->
                            ( adjusted :: adjustedAggregate
                            , dataAggregate
                            )

                        Just d ->
                            ( adjusted :: adjustedAggregate
                            , d ++ dataAggregate
                            )

                ( adjustedEl, elData ) =
                    fn parent
                        (Element
                            { elm
                                | child = adjustedChild
                                , absolutelyPositioned = adjustedOthers
                            }
                        )
            in
            ( adjustedEl
            , List.foldr merge Nothing [ childData, otherChildrenData, elData ]
            )

        Layout ({ layout, children, absolutelyPositioned } as elm) ->
            let
                adjustAndMerge usingParent el ( adjustedAggregate, dataAggregate ) =
                    let
                        ( adjusted, data ) =
                            adjust fn usingParent el
                    in
                    case data of
                        Nothing ->
                            ( adjusted :: adjustedAggregate
                            , dataAggregate
                            )

                        Just d ->
                            ( adjusted :: adjustedAggregate
                            , d ++ dataAggregate
                            )

                adjustAndMergeKeyed usingParent ( key, el ) ( adjustedAggregate, dataAggregate ) =
                    let
                        ( adjusted, data ) =
                            adjust fn usingParent el
                    in
                    case data of
                        Nothing ->
                            ( ( key, adjusted ) :: adjustedAggregate
                            , dataAggregate
                            )

                        Just d ->
                            ( ( key, adjusted ) :: adjustedAggregate
                            , d ++ dataAggregate
                            )

                ( adjustedChildren, childrenData ) =
                    case children of
                        Normal normalChildren ->
                            let
                                ( adjusted, data ) =
                                    List.foldr (adjustAndMerge (Just layout)) ( [], [] ) normalChildren
                            in
                            ( Normal adjusted
                            , maybeOnEmptyList data
                            )

                        Keyed keyedChildren ->
                            let
                                ( adjusted, data ) =
                                    List.foldr (adjustAndMergeKeyed (Just layout)) ( [], [] ) keyedChildren
                            in
                            ( Keyed adjusted
                            , maybeOnEmptyList data
                            )

                ( adjustedOthers, otherChildrenData ) =
                    case absolutelyPositioned of
                        Nothing ->
                            ( Nothing, Nothing )

                        Just others ->
                            List.foldr (adjustAndMerge Nothing) ( [], [] ) others
                                |> (\( children, onScreen ) -> ( maybeOnEmptyList children, maybeOnEmptyList onScreen ))

                ( adjustedLayout, layoutData ) =
                    fn parent
                        (Layout
                            { elm
                                | children = adjustedChildren
                                , absolutelyPositioned = adjustedOthers
                            }
                        )
            in
            ( adjustedLayout
            , List.foldr merge Nothing [ layoutData, childrenData, otherChildrenData ]
            )

        _ ->
            fn Nothing el


type Element style variation msg
    = Empty
    | Spacer Float
    | Text
        { decoration : Decoration
        , inline : Bool
        }
        String
    | Element
        { node : String
        , style : Maybe style
        , attrs : List (Attribute variation msg)
        , child : Element style variation msg
        , absolutelyPositioned : Maybe (List (Element style variation msg))
        }
    | Layout
        { node : String
        , layout : Style.LayoutModel
        , style : Maybe style
        , attrs : List (Attribute variation msg)
        , children : Children (Element style variation msg)
        , absolutelyPositioned : Maybe (List (Element style variation msg))
        }
    | Raw (Html msg)


mapAll : (msgA -> msgB) -> (styleA -> styleB) -> (variationA -> variationB) -> Element styleA variationA msgA -> Element styleB variationB msgB
mapAll onMsg onStyle onVariation el =
    case el of
        Empty ->
            Empty

        Spacer f ->
            Spacer f

        Text dec str ->
            Text dec str

        Element ({ attrs, child, absolutelyPositioned, style } as elm) ->
            Element
                { elm
                    | attrs = List.map (mapAllAttr onMsg onVariation) attrs
                    , style = Maybe.map onStyle style
                    , child = mapAll onMsg onStyle onVariation child
                    , absolutelyPositioned =
                        Maybe.map (List.map (\child -> mapAll onMsg onStyle onVariation child)) absolutelyPositioned
                }

        Layout ({ attrs, children, absolutelyPositioned, style } as elm) ->
            Layout
                { elm
                    | attrs = List.map (mapAllAttr onMsg onVariation) attrs
                    , style = Maybe.map onStyle style
                    , children = mapChildren (\child -> mapAll onMsg onStyle onVariation child) children
                    , absolutelyPositioned =
                        Maybe.map (List.map (\child -> mapAll onMsg onStyle onVariation child)) absolutelyPositioned
                }

        Raw html ->
            Raw (Html.map onMsg html)


mapAllAttr : (msg -> msg1) -> (variationA -> variationB) -> Attribute variationA msg -> Attribute variationB msg1
mapAllAttr fnMsg fnVar attr =
    case attr of
        Event htmlAttr ->
            Event (Html.Attributes.map fnMsg htmlAttr)

        InputEvent htmlAttr ->
            InputEvent (Html.Attributes.map fnMsg htmlAttr)

        Attr htmlAttr ->
            Attr (Html.Attributes.map fnMsg htmlAttr)

        Vary v b ->
            Vary (fnVar v) b

        Height len ->
            Height len

        Width len ->
            Width len

        Inline ->
            Inline

        HAlign align ->
            HAlign align

        VAlign align ->
            VAlign align

        Position x y z ->
            Position x y z

        PositionFrame fr ->
            PositionFrame fr

        Hidden ->
            Hidden

        Opacity o ->
            Opacity o

        Spacing x y ->
            Spacing x y

        Margin m ->
            Margin m

        Expand ->
            Expand

        Padding t r b l ->
            Padding t r b l

        PhantomPadding x ->
            PhantomPadding x

        GridArea str ->
            GridArea str

        GridCoords pos ->
            GridCoords pos

        PointerEvents on ->
            PointerEvents on

        Shrink i ->
            Shrink i

        Overflow x ->
            Overflow x


mapMsg : (a -> msg) -> Element style variation a -> Element style variation msg
mapMsg fn el =
    case el of
        Empty ->
            Empty

        Spacer f ->
            Spacer f

        Text dec str ->
            Text dec str

        Element ({ attrs, child, absolutelyPositioned } as elm) ->
            Element
                { elm
                    | attrs = List.map (mapAttr fn) attrs
                    , child = mapMsg fn child
                    , absolutelyPositioned =
                        Maybe.map (List.map (\child -> mapMsg fn child)) absolutelyPositioned
                }

        Layout ({ attrs, children, absolutelyPositioned } as elm) ->
            Layout
                { elm
                    | attrs = List.map (mapAttr fn) attrs
                    , children = mapChildren (mapMsg fn) children
                    , absolutelyPositioned =
                        Maybe.map (List.map (\child -> mapMsg fn child)) absolutelyPositioned
                }

        Raw html ->
            Raw (Html.map fn html)


mapAttr : (msg -> msg1) -> Attribute variation msg -> Attribute variation msg1
mapAttr fn attr =
    case attr of
        Event htmlAttr ->
            Event (Html.Attributes.map fn htmlAttr)

        InputEvent htmlAttr ->
            InputEvent (Html.Attributes.map fn htmlAttr)

        Attr htmlAttr ->
            Attr (Html.Attributes.map fn htmlAttr)

        Vary v b ->
            Vary v b

        Height len ->
            Height len

        Width len ->
            Width len

        Inline ->
            Inline

        HAlign align ->
            HAlign align

        VAlign align ->
            VAlign align

        Position x y z ->
            Position x y z

        PositionFrame fr ->
            PositionFrame fr

        Hidden ->
            Hidden

        Opacity o ->
            Opacity o

        Spacing x y ->
            Spacing x y

        Margin m ->
            Margin m

        Expand ->
            Expand

        Padding t r b l ->
            Padding t r b l

        PhantomPadding x ->
            PhantomPadding x

        GridArea str ->
            GridArea str

        GridCoords pos ->
            GridCoords pos

        PointerEvents on ->
            PointerEvents on

        Shrink i ->
            Shrink i

        Overflow x ->
            Overflow x


type Children child
    = Normal (List child)
    | Keyed (List ( String, child ))


mapChildren fn children =
    case children of
        Normal c ->
            Normal (List.map fn c)

        Keyed keyed ->
            Keyed (List.map (Tuple.mapSecond fn) keyed)


{-| -}
type OnGrid thing
    = OnGrid thing


{-| -}
type NamedOnGrid thing
    = NamedOnGrid thing


type Attribute variation msg
    = Vary variation Bool
    | Height Style.Length
    | Width Style.Length
    | Inline
    | HAlign HorizontalAlignment
    | VAlign VerticalAlignment
    | Position (Maybe Float) (Maybe Float) (Maybe Float)
    | PositionFrame Frame
    | Hidden
    | Opacity Float
    | Spacing Float Float
    | Margin ( Float, Float, Float, Float )
    | Expand
    | Padding (Maybe Float) (Maybe Float) (Maybe Float) (Maybe Float)
      -- Phandom padding isn't rendered as padding, but is communicated for purposes as inheritance.
    | PhantomPadding ( Float, Float, Float, Float )
    | Event (Html.Attribute msg)
    | InputEvent (Html.Attribute msg)
    | Attr (Html.Attribute msg)
    | GridArea String
    | GridCoords Style.GridPosition
    | PointerEvents Bool
    | Shrink Int
    | Overflow Axis


type Axis
    = XAxis
    | YAxis
    | AllAxis


type Decoration
    = NoDecoration
    | RawText
    | Bold
    | Italic
    | Underline
    | Strike
    | Super
    | Sub


type Frame
    = Screen
    | Relative
    | Absolute Anchor
    | Nearby Close


type Anchor
    = TopLeft
    | BottomLeft


type Close
    = Below
    | Above
    | OnLeft
    | OnRight
    | Within


type HorizontalAlignment
    = Left
    | Right
    | Center
    | Justify


type VerticalAlignment
    = Top
    | Bottom
    | VerticalCenter
    | VerticalJustify
