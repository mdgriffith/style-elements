module Layout.Auto exposing (..)

{- This module sketches out what needs to be in place in order for style-elements to be self-testing.


   For every element we need to capture the bounding box.  The bounding box has to be calculated after the view is already generated



-}

import Element
import Element.Attributes as Attr
import Element.Internal.Model as Model exposing (..)
import Expect
import Html exposing (Html)
import Layout.Auto.BoundingBox as BoundingBox exposing (Box)
import Layout.Auto.Calc as Calc exposing (Parent, ParentLayout(..))
import Style
import Style.Internal.Model as Style exposing (Length(..))
import Test exposing (Test)
import Window


defaultPadding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float ) -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
defaultPadding ( mW, mX, mY, mZ ) ( w, x, y, z ) =
    ( Maybe.withDefault w mW
    , Maybe.withDefault x mX
    , Maybe.withDefault y mY
    , Maybe.withDefault z mZ
    )


type Tag
    = Tag String


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
        , boundingBox : Box
        , tag : Tag
        }
    | BoxedElement
        { node : String
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , child : Boxed style variation msg
        , absolutelyPositioned : Maybe (List (Boxed style variation msg))
        , boundingBox : Box
        , tag : Tag
        }
    | BoxedLayout
        { node : String
        , layout : Style.LayoutModel
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , children : List (Boxed style variation msg)
        , absolutelyPositioned : Maybe (List (Boxed style variation msg))
        , boundingBox : Box
        , tag : Tag
        }
    | BoxedRaw
        { content : Html msg
        , boundingBox : Box
        , tag : Tag
        }


test : Model.Element style variation msg -> ( Model.Element style variation msg, Window.Size -> Test )
test el =
    let
        ( taggedEls, tagged ) =
            tag [ 0 ] el

        rendered =
            taggedEls

        createTests window =
            let
                -- rootBox =
                --     Debug.log "root" <| BoundingBox.get "style-elements-root"
                root =
                    Debug.log "doc size" <| BoundingBox.documentSize ()

                -- _ =
                --     Debug.log "window" window
            in
            tagged
                |> fetchBoxes
                |> createTest
                    { box =
                        { left = 0
                        , right = root.width
                        , top = 0
                        , bottom = root.height
                        , width = root.width
                        , height = root.height
                        }
                    , childElementInitialPosition =
                        { left = 0
                        , right = root.width
                        , top = 0
                        , bottom = root.height
                        , width = root.width
                        , height = root.height
                        }
                    , attrs = []
                    , layout = NoLayout
                    , fillPortionX = root.width
                    , fillPortionY = root.height
                    , boxWithPadding =
                        { left = 0
                        , right = root.width
                        , top = 0
                        , bottom = root.height
                        , width = root.width
                        , height = root.height
                        }
                    }
                |> Test.describe "Style Elements Auto Test"
    in
    ( rendered, createTests )


{-| Adds an id to the element, and captures that id in the boundingbox type.

The list of int is the DOM level id that is used to generate bounding box ids.

-}
tag : List Int -> Model.Element style variation msg -> ( Model.Element style variation msg, Tagged style variation msg )
tag ids element =
    let
        tagName =
            tagString
                |> Tag

        tagString =
            ids
                |> List.map toString
                |> String.join "-"
                |> (\str -> "bb-id-" ++ str)
    in
    case element of
        Model.Empty ->
            ( element
            , TaggedEmpty
            )

        Model.Spacer i ->
            ( element
            , TaggedSpacer i
            )

        Model.Raw html ->
            ( element
            , TaggedRaw
                { tag = tagName
                , content = html
                }
            )

        Model.Text { decoration, inline } content ->
            ( element
            , TaggedText
                { tag = tagName
                , content = content
                , decoration = decoration
                }
            )

        Model.Element el ->
            let
                ( taggedChildEl, taggedChild ) =
                    tag (ids ++ [ 0 ]) el.child

                ( taggedAbsEls, taggedAbs ) =
                    case el.absolutelyPositioned of
                        Nothing ->
                            ( Nothing, Nothing )

                        Just children ->
                            let
                                addTag child ( i, els, taggeds ) =
                                    let
                                        ( newEl, newTagged ) =
                                            tag (ids ++ [ i ]) child
                                    in
                                    ( i + 1, els ++ [ newEl ], taggeds ++ [ newTagged ] )

                                finalize ( i, el, tagged ) =
                                    ( Just el, Just tagged )
                            in
                            List.foldl addTag ( 1, [], [] ) children
                                |> finalize
            in
            ( Model.Element
                { el
                    | attrs = Attr.id tagString :: el.attrs
                    , child = taggedChildEl
                    , absolutelyPositioned = taggedAbsEls
                }
            , TaggedElement
                { node = el.node
                , style = el.style
                , attrs = Attr.id tagString :: el.attrs
                , child = taggedChild
                , absolutelyPositioned = taggedAbs
                , tag = tagName
                }
            )

        Model.Layout layout ->
            let
                numAbsChildren =
                    case layout.absolutelyPositioned of
                        Nothing ->
                            0

                        Just children ->
                            List.length children

                ( children, taggedChildren ) =
                    case layout.children of
                        Model.Normal children ->
                            let
                                addTag child ( i, els, taggeds ) =
                                    let
                                        ( newEl, newTagged ) =
                                            tag (ids ++ [ i ]) child
                                    in
                                    ( i + 1, els ++ [ newEl ], taggeds ++ [ newTagged ] )

                                finalize ( i, el, tagged ) =
                                    ( Model.Normal el, tagged )
                            in
                            List.foldl addTag ( numAbsChildren, [], [] ) children
                                |> finalize

                        Model.Keyed children ->
                            let
                                addTag ( key, child ) ( i, els, taggeds ) =
                                    let
                                        ( newEl, newTagged ) =
                                            tag (ids ++ [ i ]) child
                                    in
                                    ( i + 1, els ++ [ ( key, newEl ) ], taggeds ++ [ newTagged ] )

                                finalize ( i, el, tagged ) =
                                    ( Model.Keyed el, tagged )
                            in
                            List.foldl addTag ( numAbsChildren, [], [] ) children
                                |> finalize

                ( taggedAbsEls, taggedAbs ) =
                    case layout.absolutelyPositioned of
                        Nothing ->
                            ( Nothing, Nothing )

                        Just children ->
                            let
                                addTag child ( i, els, taggeds ) =
                                    let
                                        ( newEl, newTagged ) =
                                            tag (ids ++ [ i ]) child
                                    in
                                    ( i + 1, els ++ [ newEl ], taggeds ++ [ newTagged ] )

                                finalize ( i, el, tagged ) =
                                    ( Just el, Just tagged )
                            in
                            List.foldl addTag ( 1, [], [] ) children
                                |> finalize
            in
            ( Model.Layout
                { layout
                    | attrs = Attr.id tagString :: layout.attrs
                    , children = children
                    , absolutelyPositioned = taggedAbsEls
                }
            , TaggedLayout
                { node = layout.node
                , layout = layout.layout
                , style = layout.style
                , attrs = Attr.id tagString :: layout.attrs
                , children = taggedChildren
                , absolutelyPositioned = taggedAbs
                , tag = tagName
                }
            )


{-| Performs the retreival of bounding boxes using Kernal code.
-}
fetchBoxes : Tagged style variation msg -> Boxed style variation msg
fetchBoxes tagged =
    let
        getBoundingBox (Tag tag) =
            BoundingBox.get tag

        emptyBox =
            { width = 0
            , height = 0
            , left = 0
            , top = 0
            , right = 0
            , bottom = 0
            }
    in
    case tagged of
        TaggedEmpty ->
            BoxedEmpty

        TaggedSpacer i ->
            BoxedSpacer i

        TaggedRaw { tag, content } ->
            BoxedRaw
                { boundingBox = getBoundingBox tag
                , content = content
                , tag = tag
                }

        TaggedText { decoration, content, tag } ->
            BoxedText
                { boundingBox = emptyBox
                , content = content
                , decoration = decoration
                , tag = tag
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
                , boundingBox = getBoundingBox el.tag
                , tag = el.tag
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
                , boundingBox = getBoundingBox layout.tag
                , tag = layout.tag
                }


{-| Put the coordinates of a box in terms of another.
-}
relative : Box -> Box -> Box
relative parent element =
    { left = element.left - parent.left
    , right = element.right - parent.left
    , top = element.top - parent.top
    , bottom = element.bottom - parent.top
    , width = element.width
    , height = element.height
    }


roundBox : Box -> Box
roundBox box =
    { left = toFloat <| round <| box.left
    , right = toFloat <| round <| box.right
    , top = toFloat <| round <| box.top
    , bottom = toFloat <| round <| box.bottom
    , width = toFloat <| round <| box.width
    , height = toFloat <| round <| box.height
    }


{-| Generates a test suite
-}
createTest : Parent variation msg -> Boxed style variation msg -> List Test
createTest parent boxed =
    case boxed of
        BoxedEmpty ->
            []

        BoxedSpacer space ->
            []

        BoxedText { decoration, content, boundingBox } ->
            []

        BoxedRaw { boundingBox, content } ->
            []

        BoxedElement { boundingBox, attrs, child, absolutelyPositioned, tag } ->
            let
                attributeTests =
                    List.filterMap (testAttribute tag parent boundingBox) attrs

                -- This is the calculated position of the element
                ( calcLabel, calculatedPosition ) =
                    Calc.position attrs parent boundingBox

                inline =
                    List.any (\a -> a == Inline) attrs

                -- _ =
                --     Debug.log (applyTag "boundingBox" tag) boundingBox
                -- _ =
                --     Debug.log (applyTag "parent" tag) parent
                -- _ =
                --     Debug.log (applyTag "parent" tag) parent
                testPosition =
                    if inline then
                        Test.test (applyTag "inline element, position test skipped!" tag) <|
                            \_ ->
                                Expect.equal True True
                    else
                        Test.test (applyTag ("calculated vs real position " ++ String.join ", " calcLabel) tag) <|
                            \_ ->
                                Expect.equal (roundBox calculatedPosition) (roundBox boundingBox)

                adjustedForPadding =
                    Calc.adjustForPadding attrs calculatedPosition

                childTest =
                    createTest
                        { box =
                            adjustedForPadding
                        , childElementInitialPosition =
                            adjustedForPadding
                        , attrs = attrs
                        , layout = NoLayout
                        , fillPortionX = adjustedForPadding.width
                        , fillPortionY = adjustedForPadding.height
                        , boxWithPadding = calculatedPosition
                        }
                        child

                absChildrenTest =
                    List.map
                        (\child ->
                            createTest
                                { box = calculatedPosition
                                , childElementInitialPosition =
                                    calculatedPosition
                                , attrs = attrs
                                , layout = AbsolutelyPositioned
                                , fillPortionX = calculatedPosition.width

                                -- QUESTION: what is the expected fill width/height for a "below" element
                                , fillPortionY = calculatedPosition.height
                                , boxWithPadding = calculatedPosition
                                }
                                child
                        )
                        (Maybe.withDefault [] absolutelyPositioned)
            in
            [ Test.describe (applyTag "Element" tag)
                (List.filterMap identity
                    [ Just <| Test.describe (applyTag "attributes" tag) (testPosition :: attributeTests)
                    , if List.length childTest == 0 then
                        Nothing
                      else
                        Just <| Test.describe (applyTag "child of " tag) childTest
                    , if List.length absChildrenTest == 0 then
                        Nothing
                      else
                        Just <|
                            Test.describe (applyTag "Absolutely Positioned Children" tag)
                                (List.concat absChildrenTest)
                    ]
                )
            ]

        BoxedLayout { layout, boundingBox, attrs, children, absolutelyPositioned, tag } ->
            let
                ( calcLabel, calculatedPosition ) =
                    Calc.position (List.filter (not << alignment) attrs) parent boundingBox

                -- _ =
                --     Debug.log (applyTag "boundingBox" tag) boundingBox
                -- _ =
                --     Debug.log (applyTag "parent" tag) parent
                testPosition =
                    Test.test (applyTag ("calculated vs real position: " ++ String.join "," calcLabel) tag) <|
                        \_ ->
                            Expect.equal calculatedPosition boundingBox

                forSpacing a =
                    case a of
                        Spacing x y ->
                            Just ( x, y )

                        _ ->
                            Nothing

                ( spacingX, spacingY ) =
                    attrs
                        |> List.filterMap forSpacing
                        |> List.reverse
                        |> List.head
                        |> Maybe.withDefault ( 0, 0 )

                ( fillPortionX, fillPortionY ) =
                    getFillPortions ( spacingX, spacingY ) calculatedPosition children

                filled =
                    { parent | fillPortionX = fillPortionX, fillPortionY = fillPortionY }

                attributeTests =
                    List.filterMap (testAttribute tag parent boundingBox) attrs

                -- The calculated position of the element
                alignment attr =
                    case attr of
                        HAlign _ ->
                            True

                        VAlign _ ->
                            True

                        _ ->
                            False

                hAlignmentAttr attr =
                    case attr of
                        HAlign a ->
                            Just a

                        _ ->
                            Nothing

                vAlignmentAttr attr =
                    case attr of
                        VAlign a ->
                            Just a

                        _ ->
                            Nothing

                adjustedForPadding =
                    Calc.adjustForPadding attrs calculatedPosition

                hAlignment =
                    List.filterMap hAlignmentAttr attrs
                        |> List.reverse
                        |> List.head

                vAlignment =
                    List.filterMap vAlignmentAttr attrs
                        |> List.reverse
                        |> List.head

                childrenTest =
                    let
                        init =
                            { tests = []
                            , x = 0
                            , y = 0
                            , i = 0
                            }

                        totalChildren =
                            toFloat <| List.length children

                        totalChildrenWidth =
                            let
                                sumWidth child total =
                                    getChildWidth filled child + total
                            in
                            children
                                |> List.foldl sumWidth 0
                                |> (+) ((totalChildren - 1) * spacingX)

                        totalChildrenHeight =
                            let
                                sumHeight child total =
                                    getChildHeight filled child + total
                            in
                            children
                                |> List.foldl sumHeight 0
                                |> (+) ((totalChildren - 1) * spacingY)

                        applyLayout child cursor =
                            let
                                width =
                                    getChildWidth filled child

                                height =
                                    getChildHeight filled child

                                leftRightAttr attr =
                                    case attr of
                                        HAlign Left ->
                                            True

                                        HAlign Right ->
                                            True

                                        _ ->
                                            False

                                hAlignmentAdjustment box =
                                    case hAlignment of
                                        Nothing ->
                                            box

                                        Just Left ->
                                            box

                                        Just Right ->
                                            Calc.move (adjustedForPadding.width - totalChildrenWidth) 0 0 box

                                        Just Center ->
                                            Calc.move ((adjustedForPadding.width - totalChildrenWidth) / 2) 0 0 box

                                        Just Justify ->
                                            Calc.move (((adjustedForPadding.width - totalChildrenWidth) / (totalChildren - 1)) * cursor.i) 0 0 box

                                vAlignmentAdjustment box =
                                    case vAlignment of
                                        Nothing ->
                                            box

                                        Just Top ->
                                            box

                                        Just Bottom ->
                                            Calc.move 0 (adjustedForPadding.height - totalChildrenHeight) 0 box

                                        Just VerticalCenter ->
                                            Calc.move 0 ((adjustedForPadding.height - totalChildrenHeight) / 2) 0 box

                                        Just VerticalJustify ->
                                            Calc.move 0 (((adjustedForPadding.height - totalChildrenHeight) / (totalChildren - 1)) * cursor.i) 0 box

                                ( newX, newY, layedOut ) =
                                    case layout of
                                        Style.TextLayout clearfixed ->
                                            let
                                                leftRightAlignment =
                                                    child
                                                        |> mapBoxAttrs (\attrs -> List.any leftRightAttr attrs)
                                            in
                                            ( cursor.x
                                            , if leftRightAlignment then
                                                cursor.y
                                              else
                                                cursor.y + height + spacingY
                                            , createTest
                                                { box =
                                                    adjustedForPadding
                                                , childElementInitialPosition =
                                                    adjustedForPadding
                                                        |> hAlignmentAdjustment
                                                        |> Calc.move cursor.x cursor.y 0
                                                , attrs = attrs
                                                , layout = Calc.Layout layout
                                                , fillPortionX = fillPortionX
                                                , fillPortionY = fillPortionY
                                                , boxWithPadding = calculatedPosition
                                                }
                                                child
                                            )

                                        Style.FlexLayout dir flexAttrs ->
                                            case dir of
                                                Style.GoRight ->
                                                    -- TODO
                                                    ( cursor.x + width + spacingX
                                                    , cursor.y
                                                    , createTest
                                                        { box =
                                                            adjustedForPadding
                                                        , childElementInitialPosition =
                                                            adjustedForPadding
                                                                |> hAlignmentAdjustment
                                                                |> Calc.move cursor.x cursor.y 0
                                                        , attrs = attrs
                                                        , layout = Calc.Layout layout

                                                        -- TODO: Calculate fillPortions!
                                                        , fillPortionX = fillPortionX
                                                        , fillPortionY = fillPortionY
                                                        , boxWithPadding = calculatedPosition
                                                        }
                                                        child
                                                    )

                                                Style.GoLeft ->
                                                    -- TODO
                                                    ( cursor.x + width + spacingX
                                                    , cursor.y
                                                    , createTest
                                                        { box =
                                                            adjustedForPadding
                                                        , childElementInitialPosition =
                                                            adjustedForPadding
                                                                |> hAlignmentAdjustment
                                                                |> Calc.move cursor.x cursor.y 0
                                                        , attrs = attrs
                                                        , layout = Calc.Layout layout

                                                        -- TODO: Calculate fillPortions!
                                                        , fillPortionX = fillPortionX
                                                        , fillPortionY = fillPortionY
                                                        , boxWithPadding = calculatedPosition
                                                        }
                                                        child
                                                    )

                                                Style.Down ->
                                                    -- TODO
                                                    ( cursor.x
                                                    , cursor.y + height + spacingY
                                                    , createTest
                                                        { box =
                                                            adjustedForPadding
                                                        , childElementInitialPosition =
                                                            adjustedForPadding
                                                                |> Calc.move cursor.x cursor.y 0
                                                                |> vAlignmentAdjustment
                                                        , attrs = attrs
                                                        , layout = Calc.Layout layout
                                                        , fillPortionX = fillPortionX
                                                        , fillPortionY = fillPortionY
                                                        , boxWithPadding = calculatedPosition
                                                        }
                                                        child
                                                    )

                                                Style.Up ->
                                                    -- TODO
                                                    ( cursor.x
                                                    , cursor.y + height + spacingY
                                                    , createTest
                                                        { box =
                                                            adjustedForPadding
                                                        , childElementInitialPosition =
                                                            adjustedForPadding
                                                                |> Calc.move cursor.x cursor.y 0
                                                                |> vAlignmentAdjustment
                                                        , attrs = attrs
                                                        , layout = Calc.Layout layout
                                                        , fillPortionX = fillPortionX
                                                        , fillPortionY = fillPortionY
                                                        , boxWithPadding = calculatedPosition
                                                        }
                                                        child
                                                    )

                                        Style.Grid template alignment ->
                                            -- TODO
                                            ( cursor.x
                                            , cursor.y
                                            , createTest
                                                { box =
                                                    adjustedForPadding
                                                , childElementInitialPosition =
                                                    adjustedForPadding
                                                , attrs = attrs
                                                , layout = Calc.Layout layout

                                                -- TODO: Calculate fillPortions!
                                                , fillPortionX = adjustedForPadding.width
                                                , fillPortionY = adjustedForPadding.height
                                                , boxWithPadding = calculatedPosition
                                                }
                                                child
                                            )
                            in
                            { cursor
                                | tests = cursor.tests ++ [ layedOut ]
                                , x = newX
                                , y = newY
                                , i = cursor.i + 1
                            }
                    in
                    List.foldl applyLayout init children
                        |> .tests

                absChildrenTest =
                    List.map
                        (\child ->
                            createTest
                                { box = calculatedPosition
                                , childElementInitialPosition =
                                    calculatedPosition
                                , attrs = attrs
                                , layout = AbsolutelyPositioned

                                -- QUESTION: what is the expected fill width/height for a "below" element
                                , fillPortionX = calculatedPosition.width
                                , fillPortionY = calculatedPosition.height
                                , boxWithPadding = calculatedPosition
                                }
                                child
                        )
                        (Maybe.withDefault [] absolutelyPositioned)
            in
            [ Test.describe (applyTag "Layout" tag)
                (List.filterMap identity
                    [ Just <| Test.describe (applyTag "Attributes" tag) (testPosition :: attributeTests)
                    , if List.length (List.concat childrenTest) == 0 then
                        Nothing
                      else
                        Just <| Test.describe (applyTag "Children" tag) (List.concat childrenTest)
                    , if List.length absChildrenTest == 0 then
                        Nothing
                      else
                        Just <|
                            Test.describe (applyTag "Absolutely Positioned Children" tag)
                                (List.concat absChildrenTest)
                    ]
                )
            ]


testAttribute : Tag -> Parent variation msg -> Box -> Attribute variation msg -> Maybe Test
testAttribute tag parent groundTruth attr =
    case attr of
        Height len ->
            case len of
                Px px ->
                    Just <|
                        Test.test (applyTag "pixel height should match render height" tag) <|
                            \_ -> Expect.equal (round px) (round groundTruth.height)

                Percent pc ->
                    Just <|
                        Test.test (applyTag "percent height should match percent of parent" tag) <|
                            \_ -> Expect.equal (parent.box.height * (pc / 100.0)) groundTruth.height

                Auto ->
                    -- How can we know the size of the content?
                    Nothing

                Fill x ->
                    Just <|
                        Test.test (applyTag ("fill " ++ toString x ++ " height vs ground truth") tag) <|
                            \_ -> Expect.equal (round <| parent.fillPortionY * x) (round groundTruth.height)

                Calc percent adjust ->
                    Just <|
                        Test.test (applyTag "fill height should match parent height" tag) <|
                            \_ -> Expect.equal (round ((parent.box.height * percent) - adjust)) (round groundTruth.height)

        Width len ->
            case len of
                Px px ->
                    Just <|
                        Test.test (applyTag "pixel width vs found" tag) <|
                            \_ -> Expect.equal (round px) (round groundTruth.width)

                Percent pc ->
                    Just <|
                        Test.test (applyTag "percent width should match precent of parent" tag) <|
                            \_ -> Expect.equal (round (parent.box.width * (pc / 100.0))) (round groundTruth.width)

                Auto ->
                    -- How can we know the size of the content?
                    Nothing

                Fill x ->
                    let
                        _ =
                            Debug.log (applyTag "fill width" tag) (parent.fillPortionX * x)

                        _ =
                            Debug.log (applyTag "fill portion" tag) parent.fillPortionX

                        _ =
                            Debug.log (applyTag "fill x" tag) x
                    in
                    Just <|
                        Test.test (applyTag ("fill " ++ toString x ++ " width vs ground truth") tag) <|
                            \_ -> Expect.equal (parent.fillPortionX * x) groundTruth.width

                Calc percent adjust ->
                    Just <|
                        Test.test (applyTag "calc height should be calced correctly" tag) <|
                            \_ -> Expect.equal ((parent.box.width * percent) - adjust) groundTruth.width

        PositionFrame frame ->
            case frame of
                Screen ->
                    Nothing

                Nearby Within ->
                    Just <|
                        Test.test (applyTag "Framed Elements are Absolutely Positioned" tag) <|
                            \_ ->
                                Expect.equal parent.layout AbsolutelyPositioned

                Nearby Below ->
                    Just <|
                        Test.test (applyTag "Framed Elements are Absolutely Positioned" tag) <|
                            \_ ->
                                Expect.equal parent.layout AbsolutelyPositioned

                Nearby Above ->
                    Just <|
                        Test.test (applyTag "Framed Elements are Absolutely Positioned" tag) <|
                            \_ ->
                                Expect.equal parent.layout AbsolutelyPositioned

                Nearby OnLeft ->
                    Just <|
                        Test.test (applyTag "Framed Elements are Absolutely Positioned" tag) <|
                            \_ ->
                                Expect.equal parent.layout AbsolutelyPositioned

                Nearby OnRight ->
                    Just <|
                        Test.test (applyTag "Framed Elements are Absolutely Positioned" tag) <|
                            \_ ->
                                Expect.equal parent.layout AbsolutelyPositioned

                Relative ->
                    -- used internally, not exposed to user
                    Nothing

                Absolute frame ->
                    -- used internally, not exposed to user
                    Nothing

        _ ->
            Nothing


applyTag : String -> Tag -> String
applyTag str (Tag tag) =
    tag ++ " - " ++ str


addFillPortions parent elem =
    case elem of
        BoxedEmpty ->
            parent

        BoxedSpacer _ ->
            parent

        BoxedRaw _ ->
            parent

        -- How can we figure this out?
        BoxedText _ ->
            parent

        BoxedElement { attrs, child } ->
            let
                ( fillPortionX, fillPortionY ) =
                    getFillPortions ( 0, 0 ) parent.box [ child ]
            in
            { parent
                | fillPortionX = fillPortionX
                , fillPortionY = fillPortionY
            }

        BoxedLayout { attrs, children } ->
            let
                forSpacing a =
                    case a of
                        Spacing x y ->
                            Just ( x, y )

                        _ ->
                            Nothing

                spacing =
                    attrs
                        |> List.filterMap forSpacing
                        |> List.reverse
                        |> List.head
                        |> Maybe.withDefault ( 0, 0 )

                ( fillPortionX, fillPortionY ) =
                    getFillPortions spacing parent.box children
            in
            { parent
                | fillPortionX = fillPortionX
                , fillPortionY = fillPortionY
            }


{-| -}
getFillPortions : ( Float, Float ) -> { a | width : Float, height : Float } -> List (Boxed style variation msg) -> ( Float, Float )
getFillPortions ( spacingX, spacingY ) parent children =
    let
        totalConcreteWidth =
            children
                |> List.map (getChildConcreteWidth parent.width)
                |> List.sum

        totalFillWidthPortions =
            children
                |> List.map getChildFillWidthPortions
                |> List.sum

        totalConcreteHeight =
            children
                |> List.map (getChildConcreteHeight parent.height)
                |> List.sum

        totalFillHeightPortions =
            children
                |> List.map getChildFillHeightPortions
                |> List.sum

        horizontalSpacing =
            spacingX * ((toFloat <| List.length children) - 1)

        verticalSpacing =
            spacingY * ((toFloat <| List.length children) - 1)
    in
    ( if totalFillWidthPortions <= 0 then
        0
      else
        ((parent.width - totalConcreteWidth) - horizontalSpacing) / totalFillWidthPortions
    , if totalFillHeightPortions <= 0 then
        0
      else
        ((parent.height - totalConcreteHeight) - verticalSpacing) / totalFillHeightPortions
    )


mapBoxAttrs fn el =
    case el of
        BoxedEmpty ->
            fn []

        BoxedSpacer _ ->
            fn []

        BoxedRaw _ ->
            fn []

        -- How can we figure this out?
        BoxedText _ ->
            fn []

        BoxedElement { attrs } ->
            fn attrs

        BoxedLayout { attrs } ->
            fn attrs


getBox el =
    case el of
        BoxedEmpty ->
            Nothing

        BoxedSpacer _ ->
            Nothing

        BoxedRaw _ ->
            Nothing

        -- How can we figure this out?
        BoxedText _ ->
            Nothing

        BoxedElement { boundingBox } ->
            Just boundingBox

        BoxedLayout { boundingBox } ->
            Just boundingBox


getChildFillWidthPortions child =
    mapBoxAttrs Calc.fillWidthPortions child


getChildFillHeightPortions child =
    mapBoxAttrs Calc.fillHeightPortions child


getChildConcreteWidth parentWidth child =
    mapBoxAttrs (Calc.concreteWidth parentWidth) child


getChildConcreteHeight parentHeight child =
    mapBoxAttrs (Calc.concreteHeight parentHeight) child


getChildWidth parent child =
    let
        auto =
            getBox child
                |> Maybe.withDefault parent.box
    in
    mapBoxAttrs (\child -> Calc.width parent child |> Maybe.withDefault auto.width) child


getChildHeight parent child =
    let
        auto =
            getBox child
                |> Maybe.withDefault parent.box
    in
    mapBoxAttrs (\child -> Calc.height parent child |> Maybe.withDefault auto.height) child
