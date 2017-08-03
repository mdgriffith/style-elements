module Main exposing (..)

{- This module sketches out what needs to be in place in order for style-elements to be self-testing.


   For every element we need to capture the bounding box.  The bounding box has to be calculated after the view is already generated



-}

import Element.Internal.Model as Model exposing (..)
import Element.Attributes as Attr
import Style.Internal.Model as Style exposing (Length(..))
import Html exposing (Html)
import Test exposing (Test)
import Expect


defaultPadding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float ) -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
defaultPadding ( mW, mX, mY, mZ ) ( w, x, y, z ) =
    ( Maybe.withDefault w mW
    , Maybe.withDefault x mX
    , Maybe.withDefault y mY
    , Maybe.withDefault z mZ
    )


type Tag
    = Tag String


type alias Box =
    { left : Float
    , right : Float
    , top : Float
    , bottom : Float
    , width : Float
    , height : Float
    }



-- Positive is right and down


moveBox ( x, y, z ) box =
    { left = box.left + x
    , right = box.right - x
    , top = box.top + y
    , bottom = box.bottom - y
    , width = box.width
    , height = box.height
    }


type Tagged style variation msg
    = TaggedEmpty
    | TaggedSpacer Float
    | TaggedText
        { decoration : Model.Decoration
        , content : String
        , tag : Tag
        }
    | TaggedElement
        { node : String
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , child : Tagged style variation msg
        , absolutelyPositioned : Maybe (List (Tagged style variation msg))
        , tag : Tag
        }
    | TaggedLayout
        { node : String
        , layout : Style.LayoutModel
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , children : List (Tagged style variation msg)
        , absolutelyPositioned : Maybe (List (Tagged style variation msg))
        , tag : Tag
        }
    | TaggedRaw
        { content : Html msg
        , tag : Tag
        }


type Boxed style variation msg
    = BoxedEmpty
    | BoxedSpacer Float
    | BoxedText
        { decoration : Model.Decoration
        , content : String
        , box : Box
        }
    | BoxedElement
        { node : String
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , child : Boxed style variation msg
        , absolutelyPositioned : Maybe (List (Boxed style variation msg))
        , box : Box
        }
    | BoxedLayout
        { node : String
        , layout : Style.LayoutModel
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , children : List (Boxed style variation msg)
        , absolutelyPositioned : Maybe (List (Boxed style variation msg))
        , box : Box
        }
    | BoxedRaw
        { content : Html msg
        , box : Box
        }


test : Model.Element style variation msg -> Test
test el =
    el
        |> tag [ 0 ]
        |> fetchBoxes
        |> createTest
            { box =
                { left = 0
                , right = 0
                , top = 0
                , bottom = 0
                , width = 0
                , height = 0
                }
            , inheritedPosition =
                { left = 0
                , right = 0
                , top = 0
                , bottom = 0
                , width = 0
                , height = 0
                }
            , attrs = []
            , layout = NoLayout
            }


{-| Adds an id to the element, and captures that id in the boundingbox type.

The list of int is the DOM level id that is used to generate bounding box ids.

-}
tag : List Int -> Model.Element style variation msg -> Tagged style variation msg
tag ids element =
    let
        tagName =
            tagString
                |> Tag

        tagString =
            ids
                |> List.map toString
                |> String.join "-"
                |> \str -> "bb-id-"
    in
        case element of
            Model.Empty ->
                TaggedEmpty

            Model.Spacer i ->
                TaggedSpacer i

            Model.Raw html ->
                TaggedRaw
                    { tag = tagName
                    , content = html
                    }

            Model.Text decoration content ->
                TaggedText
                    { tag = tagName
                    , content = content
                    , decoration = decoration
                    }

            Model.Element el ->
                TaggedElement
                    { node = el.node
                    , style = el.style
                    , attrs = Attr.id tagString :: el.attrs
                    , child = tag (ids ++ [ 0 ]) el.child
                    , absolutelyPositioned =
                        Maybe.map
                            (\abs ->
                                List.indexedMap (\i a -> tag (ids ++ [ i + 1 ]) a) abs
                            )
                            el.absolutelyPositioned
                    , tag = tagName
                    }

            Model.Layout layout ->
                let
                    numAbsChildren =
                        case layout.absolutelyPositioned of
                            Nothing ->
                                0

                            Just children ->
                                List.length children
                in
                    TaggedLayout
                        { node = layout.node
                        , layout = layout.layout
                        , style = layout.style
                        , attrs = Attr.id tagString :: layout.attrs
                        , children =
                            case layout.children of
                                Model.Normal children ->
                                    List.indexedMap (\i a -> tag (ids ++ [ i + numAbsChildren ]) a) children

                                Model.Keyed children ->
                                    children
                                        |> List.map Tuple.second
                                        |> List.indexedMap (\i a -> tag (ids ++ [ i + numAbsChildren ]) a)
                        , absolutelyPositioned =
                            Maybe.map
                                (\abs ->
                                    List.indexedMap (\i a -> tag (ids ++ [ i ]) a) abs
                                )
                                layout.absolutelyPositioned
                        , tag = tagName
                        }


{-| Performs the retreival of bounding boxes using Kernal code.
-}
fetchBoxes : Tagged style variation msg -> Boxed style variation msg
fetchBoxes tagged =
    let
        getBoundingBox tag =
            { left = 0
            , right = 0
            , top = 0
            , bottom = 0
            , width = 0
            , height = 0
            }
    in
        case tagged of
            TaggedEmpty ->
                BoxedEmpty

            TaggedSpacer i ->
                BoxedSpacer i

            TaggedRaw { tag, content } ->
                BoxedRaw
                    { box = getBoundingBox tag
                    , content = content
                    }

            TaggedText { decoration, content, tag } ->
                BoxedText
                    { box = getBoundingBox tag
                    , content = content
                    , decoration = decoration
                    }

            TaggedElement el ->
                BoxedElement
                    { node = el.node
                    , style = el.style
                    , attrs = el.attrs
                    , child = fetchBoxes el.child
                    , absolutelyPositioned =
                        Maybe.map
                            (List.map fetchBoxes)
                            el.absolutelyPositioned
                    , box = getBoundingBox tag
                    }

            TaggedLayout layout ->
                BoxedLayout
                    { node = layout.node
                    , layout = layout.layout
                    , style = layout.style
                    , attrs = layout.attrs
                    , children =
                        List.map fetchBoxes layout.children
                    , absolutelyPositioned =
                        Maybe.map
                            (List.map fetchBoxes)
                            layout.absolutelyPositioned
                    , box = getBoundingBox tag
                    }


{-| Put the coordinates of a box in terms of another.
-}
relative : Box -> Box -> Box
relative parent element =
    { left = element.left - parent.left
    , right = element.right - parent.right
    , top = element.top - parent.top
    , bottom = element.bottom - parent.bottom
    , width = element.width - parent.width
    , height = element.height - parent.height
    }


type ParentLayout
    = AbsolutelyPositioned
    | Layout Style.LayoutModel
    | NoLayout


type alias Parent variation msg =
    { box : Box
    , inheritedPosition : Box
    , attrs : List (Model.Attribute variation msg)
    , layout : ParentLayout
    }


{-| Generates a test suite
-}
createTest : Parent variation msg -> Boxed style variation msg -> Test
createTest parent boxed =
    let
        -- parent box is given as the box inside the padding
        -- We need to pass certain elements as there are no tests to run
        ignore =
            Test.skip <|
                Test.test
                    "A lot of attributes are skipped because there's no test to write for them."
                    (\_ -> Expect.true "alwasy true" True)
    in
        case boxed of
            BoxedEmpty ->
                ignore

            BoxedSpacer space ->
                ignore

            BoxedText { decoration, content, box } ->
                ignore

            BoxedRaw { box, content } ->
                ignore

            BoxedElement { box, attrs, child, absolutelyPositioned } ->
                let
                    local =
                        relative parent.box box

                    applyPositionAdjustment positionBox =
                        let
                            mergePos attr (( currentX, currentY, currentZ ) as pos) =
                                case attr of
                                    Position x y z ->
                                        let
                                            newX =
                                                case x of
                                                    Nothing ->
                                                        currentX

                                                    Just a ->
                                                        Just a

                                            newY =
                                                case y of
                                                    Nothing ->
                                                        currentY

                                                    Just a ->
                                                        Just a

                                            newZ =
                                                case z of
                                                    Nothing ->
                                                        currentZ

                                                    Just a ->
                                                        Just a
                                        in
                                            ( newX, newY, newZ )

                                    _ ->
                                        pos

                            withDefault ( dx, dy, dz ) ( mx, my, mz ) =
                                ( Maybe.withDefault dx mx
                                , Maybe.withDefault dy my
                                , Maybe.withDefault dz mz
                                )

                            ( x, y, z ) =
                                attrs
                                    |> List.foldl mergePos ( Nothing, Nothing, Nothing )
                                    |> withDefault ( 0, 0, 0 )
                        in
                            moveBox ( x, y, z ) positionBox

                    applyHAlignment positionBox =
                        let
                            forHAlign attr =
                                case attr of
                                    HAlign alignment ->
                                        Just <| alignment

                                    _ ->
                                        Nothing

                            hAlign =
                                List.filterMap forHAlign attrs
                                    |> List.reverse
                                    |> List.head
                        in
                            case hAlign of
                                Nothing ->
                                    positionBox

                                Just _ ->
                                    positionBox

                    applyVAlignment positionBox =
                        let
                            forVAlign attr =
                                case attr of
                                    VAlign alignment ->
                                        Just <| alignment

                                    _ ->
                                        Nothing

                            vAlign =
                                List.filterMap forVAlign attrs
                                    |> List.reverse
                                    |> List.head
                        in
                            case vAlign of
                                Nothing ->
                                    positionBox

                                Just _ ->
                                    positionBox

                    testAttribute attr =
                        case attr of
                            Height len ->
                                case len of
                                    Px px ->
                                        Test.test "pixel height should match render height" <|
                                            \_ -> Expect.equal px local.height

                                    Percent pc ->
                                        Test.test "percent height should match percent of parent" <|
                                            \_ -> Expect.equal local.height (parent.box.height * pc)

                                    Auto ->
                                        -- How can we know the size of the content?
                                        ignore

                                    Fill x ->
                                        Test.test "fill height should match parent height" <|
                                            \_ -> Expect.equal local.height parent.box.height

                                    Calc percent adjust ->
                                        Test.test "fill height should match parent height" <|
                                            \_ -> Expect.equal local.height ((parent.box.height * percent) - adjust)

                            Width len ->
                                case len of
                                    Px px ->
                                        Test.test "px width should match rendered width" <|
                                            \_ -> Expect.equal px local.height

                                    Percent pc ->
                                        Test.test "percent width should match precent of parent" <|
                                            \_ -> Expect.equal local.height (parent.box.height * pc)

                                    Auto ->
                                        -- How can we know the size of the content?
                                        ignore

                                    Fill x ->
                                        Test.test "fill width should match parent width" <|
                                            \_ -> Expect.equal local.height parent.box.height

                                    Calc percent adjust ->
                                        Test.test "calc height should be calced correctly" <|
                                            \_ -> Expect.equal local.height ((parent.box.height * percent) - adjust)

                            PositionFrame frame ->
                                case frame of
                                    Screen ->
                                        ignore

                                    Nearby Within ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby Below ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby Above ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby OnLeft ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby OnRight ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Relative ->
                                        -- used internally, not exposed to user
                                        ignore

                                    Absolute frame ->
                                        -- used internally, not exposed to user
                                        ignore

                            _ ->
                                ignore

                    attributeTests =
                        List.map testAttribute attrs

                    -- This is the calculated position of theelement
                    calculatedPosition =
                        parent.inheritedPosition
                            |> applyHAlignment
                            |> applyVAlignment
                            |> applyPositionAdjustment

                    testPosition =
                        Test.test "calculated position matches real position" <|
                            \_ ->
                                Expect.equal calculatedPosition box

                    adjustedForPadding =
                        let
                            adjustForPadding box =
                                { left = box.left + paddingLeft
                                , right = box.right + paddingRight
                                , top = box.top + paddingTop
                                , bottom = box.bottom + paddingBottom
                                , width = box.width - (paddingLeft + paddingRight)
                                , height = box.height - (paddingTop + paddingBottom)
                                }

                            ( paddingTop, paddingRight, paddingBottom, paddingLeft ) =
                                let
                                    forPadding attr =
                                        case attr of
                                            Padding top right bottom left ->
                                                Just <| defaultPadding ( top, right, bottom, left ) ( 0, 0, 0, 0 )

                                            _ ->
                                                Nothing
                                in
                                    List.filterMap forPadding attrs
                                        |> List.reverse
                                        |> List.head
                                        |> Maybe.withDefault ( 0, 0, 0, 0 )
                        in
                            adjustForPadding box

                    childTest =
                        createTest
                            { box =
                                adjustedForPadding
                            , inheritedPosition =
                                adjustedForPadding
                            , attrs = attrs
                            , layout = NoLayout
                            }
                            child

                    absChildrenTest =
                        List.map
                            (\child ->
                                createTest
                                    { box = adjustedForPadding
                                    , inheritedPosition =
                                        adjustedForPadding
                                    , attrs = attrs
                                    , layout = AbsolutelyPositioned
                                    }
                                    child
                            )
                            (Maybe.withDefault [] absolutelyPositioned)
                in
                    Test.describe "Element"
                        [ Test.describe "Attributes" (testPosition :: attributeTests)
                        , childTest
                        , Test.describe "Absolutely Positioned Children"
                            absChildrenTest
                        ]

            BoxedLayout { layout, box, attrs, children, absolutelyPositioned } ->
                let
                    local =
                        relative parent.box box

                    applyPositionAdjustment positionBox =
                        let
                            mergePos attr (( currentX, currentY, currentZ ) as pos) =
                                case attr of
                                    Position x y z ->
                                        let
                                            newX =
                                                case x of
                                                    Nothing ->
                                                        currentX

                                                    Just a ->
                                                        Just a

                                            newY =
                                                case y of
                                                    Nothing ->
                                                        currentY

                                                    Just a ->
                                                        Just a

                                            newZ =
                                                case z of
                                                    Nothing ->
                                                        currentZ

                                                    Just a ->
                                                        Just a
                                        in
                                            ( newX, newY, newZ )

                                    _ ->
                                        pos

                            withDefault ( dx, dy, dz ) ( mx, my, mz ) =
                                ( Maybe.withDefault dx mx
                                , Maybe.withDefault dy my
                                , Maybe.withDefault dz mz
                                )

                            ( x, y, z ) =
                                attrs
                                    |> List.foldl mergePos ( Nothing, Nothing, Nothing )
                                    |> withDefault ( 0, 0, 0 )
                        in
                            moveBox ( x, y, z ) positionBox

                    applyHAlignment positionBox =
                        let
                            forHAlign attr =
                                case attr of
                                    HAlign alignment ->
                                        Just <| alignment

                                    _ ->
                                        Nothing

                            hAlign =
                                List.filterMap forHAlign attrs
                                    |> List.reverse
                                    |> List.head
                        in
                            case hAlign of
                                Nothing ->
                                    positionBox

                                Just _ ->
                                    positionBox

                    applyVAlignment positionBox =
                        let
                            forVAlign attr =
                                case attr of
                                    VAlign alignment ->
                                        Just <| alignment

                                    _ ->
                                        Nothing

                            vAlign =
                                List.filterMap forVAlign attrs
                                    |> List.reverse
                                    |> List.head
                        in
                            case vAlign of
                                Nothing ->
                                    positionBox

                                Just _ ->
                                    positionBox

                    testAttribute attr =
                        case attr of
                            Height len ->
                                case len of
                                    Px px ->
                                        Test.test "pixel height should match render height" <|
                                            \_ -> Expect.equal px local.height

                                    Percent pc ->
                                        Test.test "percent height should match percent of parent" <|
                                            \_ -> Expect.equal local.height (parent.box.height * pc)

                                    Auto ->
                                        -- How can we know the size of the content?
                                        ignore

                                    Fill x ->
                                        Test.test "fill height should match parent height" <|
                                            \_ -> Expect.equal local.height parent.box.height

                                    Calc percent adjust ->
                                        Test.test "fill height should match parent height" <|
                                            \_ -> Expect.equal local.height ((parent.box.height * percent) - adjust)

                            Width len ->
                                case len of
                                    Px px ->
                                        Test.test "px width should match rendered width" <|
                                            \_ -> Expect.equal px local.height

                                    Percent pc ->
                                        Test.test "percent width should match precent of parent" <|
                                            \_ -> Expect.equal local.height (parent.box.height * pc)

                                    Auto ->
                                        -- How can we know the size of the content?
                                        ignore

                                    Fill x ->
                                        Test.test "fill width should match parent width" <|
                                            \_ -> Expect.equal local.height parent.box.height

                                    Calc percent adjust ->
                                        Test.test "calc height should be calced correctly" <|
                                            \_ -> Expect.equal local.height ((parent.box.height * percent) - adjust)

                            PositionFrame frame ->
                                case frame of
                                    Screen ->
                                        ignore

                                    Nearby Within ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby Below ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby Above ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby OnLeft ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Nearby OnRight ->
                                        Test.test "Framed Elements are Absolutely Positioned" <|
                                            \_ ->
                                                Expect.equal parent.layout AbsolutelyPositioned

                                    Relative ->
                                        -- used internally, not exposed to user
                                        ignore

                                    Absolute frame ->
                                        -- used internally, not exposed to user
                                        ignore

                            _ ->
                                ignore

                    attributeTests =
                        List.map testAttribute attrs

                    -- This is the calculated position of theelement
                    calculatedPosition =
                        parent.inheritedPosition
                            |> applyPositionAdjustment

                    testPosition =
                        Test.test "calculated position matches real position" <|
                            \_ ->
                                Expect.equal calculatedPosition box

                    adjustedForPadding =
                        let
                            adjustForPadding box =
                                { left = box.left + paddingLeft
                                , right = box.right + paddingRight
                                , top = box.top + paddingTop
                                , bottom = box.bottom + paddingBottom
                                , width = box.width - (paddingLeft + paddingRight)
                                , height = box.height - (paddingTop + paddingBottom)
                                }

                            ( paddingTop, paddingRight, paddingBottom, paddingLeft ) =
                                let
                                    forPadding attr =
                                        case attr of
                                            Padding top right bottom left ->
                                                Just <| defaultPadding ( top, right, bottom, left ) ( 0, 0, 0, 0 )

                                            _ ->
                                                Nothing
                                in
                                    List.filterMap forPadding attrs
                                        |> List.reverse
                                        |> List.head
                                        |> Maybe.withDefault ( 0, 0, 0, 0 )
                        in
                            adjustForPadding box

                    childrenTest =
                        List.map
                            (\child ->
                                createTest
                                    { box =
                                        adjustedForPadding
                                    , inheritedPosition =
                                        adjustedForPadding
                                    , attrs = attrs
                                    , layout = Layout layout
                                    }
                                    child
                            )
                            children

                    absChildrenTest =
                        List.map
                            (\child ->
                                createTest
                                    { box = adjustedForPadding
                                    , inheritedPosition =
                                        adjustedForPadding
                                    , attrs = attrs
                                    , layout = AbsolutelyPositioned
                                    }
                                    child
                            )
                            (Maybe.withDefault [] absolutelyPositioned)
                in
                    Test.describe "Layout"
                        [ Test.describe "Attributes" (testPosition :: attributeTests)
                        , Test.describe "Children" childrenTest
                        , Test.describe "Absolutely Positioned Children"
                            absChildrenTest
                        ]
