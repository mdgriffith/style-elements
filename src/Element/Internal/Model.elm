module Element.Internal.Model exposing (..)

{-| -}

import Style.Internal.Model as Style
import Html exposing (Html)
import Html.Attributes


name el =
    case el of
        Empty ->
            "empty"

        Spacer _ ->
            "spacer"

        Text _ _ ->
            "text"

        Element _ _ _ _ _ ->
            "element"

        Layout _ _ _ _ _ ->
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
            Element node element position child otherChildren ->
                let
                    ( adjustedChild, childData ) =
                        adjust fn Nothing child

                    ( adjustedOthers, otherChildrenData ) =
                        case otherChildren of
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
                        fn parent (Element node element position adjustedChild adjustedOthers)
                in
                    ( adjustedEl
                    , List.foldr merge Nothing [ childData, otherChildrenData, elData ]
                    )

            Layout node layout element attrs children ->
                let
                    adjustAndMerge el ( adjustedAggregate, dataAggregate ) =
                        let
                            ( adjusted, data ) =
                                adjust fn (Just layout) el
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

                    adjustAndMergeKeyed ( key, el ) ( adjustedAggregate, dataAggregate ) =
                        let
                            ( adjusted, data ) =
                                adjust fn (Just layout) el
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
                                        List.foldr adjustAndMerge ( [], [] ) normalChildren
                                in
                                    ( Normal adjusted
                                    , maybeOnEmptyList data
                                    )

                            Keyed keyedChildren ->
                                let
                                    ( adjusted, data ) =
                                        List.foldr adjustAndMergeKeyed ( [], [] ) keyedChildren
                                in
                                    ( Keyed adjusted
                                    , maybeOnEmptyList data
                                    )

                    ( adjustedLayout, layoutData ) =
                        fn parent (Layout node layout element attrs adjustedChildren)
                in
                    ( adjustedLayout
                    , List.foldr merge Nothing [ layoutData, childrenData ]
                    )

            _ ->
                fn Nothing el


type Element style variation msg
    = Empty
    | Spacer Float
    | Text Decoration String
    | Element String (Maybe style) (List (Attribute variation msg)) (Element style variation msg) (Maybe (List (Element style variation msg)))
    | Layout String Style.LayoutModel (Maybe style) (List (Attribute variation msg)) (Children (Element style variation msg))
    | Raw (Html msg)


mapMsg : (a -> msg) -> Element style variation a -> Element style variation msg
mapMsg fn el =
    case el of
        Empty ->
            Empty

        Spacer f ->
            Spacer f

        Text dec str ->
            Text dec str

        Element node style attrs child others ->
            Element node style (List.map (mapAttr fn) attrs) (mapMsg fn child) (Maybe.map (List.map (\child -> mapMsg fn child)) others)

        Layout node layout style attrs children ->
            Layout node layout style (List.map (mapAttr fn) attrs) (mapChildren (mapMsg fn) children)

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
    | PhantomPadding ( Float, Float, Float, Float ) -- Isn't rendered as padding, but is communicated for purposes as inheritance.
    | Event (Html.Attribute msg)
    | InputEvent (Html.Attribute msg)
    | Attr (Html.Attribute msg)
    | GridArea String
    | GridCoords Style.GridPosition
    | PointerEvents Bool


type Decoration
    = NoDecoration
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
