module AutoSelfTest exposing (..)

{- This module sketches out what needs to be in place in order for style-elements to be self-testing.


   For every element we need to capture the bounding box.  The bounding box has to be calculated after the view is already generated



-}

import Element
import Element.Internal.Model as Model exposing (..)
import Element.Attributes as Attr
import Style.Internal.Model as Style exposing (Length(..))
import Html exposing (Html)
import Test exposing (Test)
import Expect
import BoundingBox exposing (Box)
import Style
import Calc


defaultPadding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float ) -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
defaultPadding ( mW, mX, mY, mZ ) ( w, x, y, z ) =
    ( Maybe.withDefault w mW
    , Maybe.withDefault x mX
    , Maybe.withDefault y mY
    , Maybe.withDefault z mZ
    )


type Tag
    = Tag String



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
        , tag : Tag
        }
    | BoxedElement
        { node : String
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , child : Boxed style variation msg
        , absolutelyPositioned : Maybe (List (Boxed style variation msg))
        , box : Box
        , tag : Tag
        }
    | BoxedLayout
        { node : String
        , layout : Style.LayoutModel
        , style : Maybe style
        , attrs : List (Model.Attribute variation msg)
        , children : List (Boxed style variation msg)
        , absolutelyPositioned : Maybe (List (Boxed style variation msg))
        , box : Box
        , tag : Tag
        }
    | BoxedRaw
        { content : Html msg
        , box : Box
        , tag : Tag
        }


test : Model.Element style variation msg -> ( Model.Element style variation msg, () -> Test )
test el =
    let
        ( taggedEls, tagged ) =
            tag [ 0 ] el

        rendered =
            taggedEls

        createTests _ =
            tagged
                |> fetchBoxes
                |> createTest
                    { box = BoundingBox.get "style-elements-root"
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
                |> \str -> "bb-id-" ++ str
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

            Model.Text decoration content ->
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
                    , tag = tag
                    }

            TaggedText { decoration, content, tag } ->
                BoxedText
                    { box = getBoundingBox tag
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
                    , box = getBoundingBox el.tag
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
                    , box = getBoundingBox layout.tag
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
createTest : Parent variation msg -> Boxed style variation msg -> List Test
createTest parent boxed =
    case boxed of
        BoxedEmpty ->
            []

        BoxedSpacer space ->
            []

        BoxedText { decoration, content, box } ->
            []

        BoxedRaw { box, content } ->
            []

        BoxedElement { box, attrs, child, absolutelyPositioned, tag } ->
            let
                local =
                    relative parent.box box

                attributeTests =
                    List.filterMap (testAttribute tag parent local) attrs

                -- This is the calculated position of the element
                ( calcLabel, calculatedPosition ) =
                    Calc.position attrs parent local

                testPosition =
                    Test.test (applyTag ("Calculated position matches real position: " ++ String.join "," calcLabel) tag) <|
                        \_ ->
                            Expect.equal (roundBox calculatedPosition) (roundBox box)

                adjustedForPadding =
                    Calc.adjustForPadding attrs box

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
                [ Test.describe (applyTag "Element" tag)
                    (List.filterMap identity
                        [ Just <| Test.describe (applyTag "Attributes" tag) (testPosition :: attributeTests)
                        , if List.length childTest == 0 then
                            Nothing
                          else
                            Just <| Test.describe (applyTag "Child of " tag) childTest
                        , if List.length absChildrenTest == 0 then
                            Nothing
                          else
                            Just <|
                                Test.describe (applyTag "Absolutely Positioned Children" tag)
                                    (List.concat absChildrenTest)
                        ]
                    )
                ]

        BoxedLayout { layout, box, attrs, children, absolutelyPositioned, tag } ->
            let
                local =
                    Calc.relative parent.box box

                attributeTests =
                    List.filterMap (testAttribute tag parent local) attrs

                -- The calculated position of the element
                alignment attr =
                    case attr of
                        HAlign _ ->
                            True

                        VAlign _ ->
                            True

                        _ ->
                            False

                ( calcLabel, calculatedPosition ) =
                    Calc.position (List.filter (not << alignment) attrs) parent local

                testPosition =
                    Test.test (applyTag ("Calculated position matches real position: " ++ String.join "," calcLabel) tag) <|
                        \_ ->
                            Expect.equal calculatedPosition box

                adjustedForPadding =
                    Calc.adjustForPadding attrs box

                childrenTest =
                    let
                        init =
                            { tests = []
                            , x = 0
                            , y = 0
                            }

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

                        applyLayout child cursor =
                            let
                                width =
                                    getChildWidth adjustedForPadding child

                                height =
                                    getChildHeight adjustedForPadding child

                                layedOut =
                                    case layout of
                                        Style.TextLayout clearfixed ->
                                            -- TODO
                                            createTest
                                                { box =
                                                    adjustedForPadding
                                                , inheritedPosition =
                                                    adjustedForPadding
                                                , attrs = attrs
                                                , layout = Layout layout
                                                }
                                                child

                                        Style.FlexLayout dir flexAttrs ->
                                            case dir of
                                                Style.GoRight ->
                                                    -- TODO
                                                    createTest
                                                        { box =
                                                            adjustedForPadding
                                                        , inheritedPosition =
                                                            adjustedForPadding
                                                        , attrs = attrs
                                                        , layout = Layout layout
                                                        }
                                                        child

                                                _ ->
                                                    -- TODO
                                                    createTest
                                                        { box =
                                                            adjustedForPadding
                                                        , inheritedPosition =
                                                            adjustedForPadding
                                                        , attrs = attrs
                                                        , layout = Layout layout
                                                        }
                                                        child

                                        Style.Grid template alignment ->
                                            -- TODO
                                            createTest
                                                { box =
                                                    adjustedForPadding
                                                , inheritedPosition =
                                                    adjustedForPadding
                                                , attrs = attrs
                                                , layout = Layout layout
                                                }
                                                child
                            in
                                { cursor | tests = cursor.tests ++ [ layedOut ] }
                    in
                        List.foldl applyLayout init children
                            |> .tests

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
                [ Test.describe (applyTag "Layout" tag)
                    [ Test.describe (applyTag "Attributes" tag) (testPosition :: attributeTests)
                    , Test.describe (applyTag "Children" tag) (List.concat childrenTest)
                    , Test.describe (applyTag "Absolutely Positioned Children" tag)
                        (List.concat absChildrenTest)
                    ]
                ]


testAttribute : Tag -> Parent variation msg -> Box -> Attribute variation msg -> Maybe Test
testAttribute tag parent local attr =
    case attr of
        Height len ->
            case len of
                Px px ->
                    Just <|
                        Test.test (applyTag "pixel height should match render height" tag) <|
                            \_ -> Expect.equal px local.height

                Percent pc ->
                    Just <|
                        Test.test (applyTag "percent height should match percent of parent" tag) <|
                            \_ -> Expect.equal local.height (parent.box.height * (pc / 100.0))

                Auto ->
                    -- How can we know the size of the content?
                    Nothing

                Fill x ->
                    Just <|
                        Test.test (applyTag "fill height should match parent height" tag) <|
                            \_ -> Expect.equal local.height parent.box.height

                Calc percent adjust ->
                    Just <|
                        Test.test (applyTag "fill height should match parent height" tag) <|
                            \_ -> Expect.equal (round local.height) (round ((parent.box.height * percent) - adjust))

        Width len ->
            case len of
                Px px ->
                    Just <|
                        Test.test (applyTag "px width should match rendered width" tag) <|
                            \_ -> Expect.equal px local.width

                Percent pc ->
                    Just <|
                        Test.test (applyTag "percent width should match precent of parent" tag) <|
                            \_ -> Expect.equal (round local.width) (round (parent.box.width * (pc / 100.0)))

                Auto ->
                    -- How can we know the size of the content?
                    Nothing

                Fill x ->
                    Just <|
                        Test.test (applyTag "fill width should match parent width" tag) <|
                            \_ -> Expect.equal local.width parent.box.width

                Calc percent adjust ->
                    Just <|
                        Test.test (applyTag "calc height should be calced correctly" tag) <|
                            \_ -> Expect.equal local.width ((parent.box.width * percent) - adjust)

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


getChildWidth : { a | width : Float } -> Boxed style variation msg -> number
getChildWidth parentBox child =
    case child of
        BoxedEmpty ->
            0

        BoxedSpacer _ ->
            0

        BoxedRaw _ ->
            200

        -- How can we figure this out?
        BoxedText _ ->
            0

        BoxedElement { attrs } ->
            let
                attrWidth attr =
                    case attr of
                        Width len ->
                            case len of
                                Px px ->
                                    Just px

                                Percent pc ->
                                    Just (parentBox.width * pc)

                                Auto ->
                                    -- How can we know the size of the content?
                                    -- In the meantime, it will always be 200
                                    Just 200

                                Fill x ->
                                    Just parentBox.width

                                Calc percent adjust ->
                                    Just ((parentBox.width * percent) - adjust)

                        _ ->
                            Nothing
            in
                200

        BoxedLayout { attrs } ->
            0


getChildHeight : { a | height : Float } -> Boxed style variation msg -> number
getChildHeight parentBox child =
    case child of
        BoxedEmpty ->
            0

        BoxedSpacer _ ->
            0

        BoxedRaw _ ->
            200

        -- How can we figure this out?
        BoxedText _ ->
            0

        BoxedElement { attrs } ->
            let
                attrWidth attr =
                    case attr of
                        Height len ->
                            case len of
                                Px px ->
                                    Just px

                                Percent pc ->
                                    Just (parentBox.height * pc)

                                Auto ->
                                    -- How can we know the size of the content?
                                    -- In the meantime, it will always be 200
                                    Just 200

                                Fill x ->
                                    Just parentBox.height

                                Calc percent adjust ->
                                    Just ((parentBox.height * percent) - adjust)

                        _ ->
                            Nothing
            in
                200

        BoxedLayout { attrs } ->
            0
