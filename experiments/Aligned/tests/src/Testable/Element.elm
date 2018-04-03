module Testable.Element exposing (..)

{-| This module should mirror the top level `Element` api, with one important distinction.

The resulting `Element msg` structure can either be rendered to Html or transformed into a test suite that can be run.

In order to run the test:

  - render html
  - gather information from the browser
  - generate tests

-}

import Element
import Expect
import Testable


text : String -> Testable.Element msg
text =
    Testable.Text


el : List (Testable.Attr msg) -> Testable.Element msg -> Testable.Element msg
el =
    Testable.El


row : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
row =
    Testable.Row


column : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
column =
    Testable.Column


empty : Testable.Element msg
empty =
    Testable.Empty


paragraph : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
paragraph =
    Testable.Paragraph


textColumn : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
textColumn =
    Testable.TextColumn


type Length
    = Px Int
    | Fill Int
    | Shrink


px : Int -> Length
px =
    Px


fill : Length
fill =
    Fill 1


shrink : Length
shrink =
    Shrink


fillPortion : Int -> Length
fillPortion =
    Fill


label : String -> Testable.Attr msg
label =
    Testable.Label


width : Length -> Testable.Attr msg
width len =
    case len of
        Px px ->
            Testable.LabeledTest
                { label = "width " ++ toString px ++ "px"
                , attr = Element.width (Element.px px)
                , test =
                    \found _ ->
                        Expect.equal (round found.self.bbox.width) px
                }

        Fill portion ->
            Testable.LabeledTest
                { label = "width fill-" ++ toString portion
                , attr = Element.width (Element.fillPortion portion)
                , test =
                    \context _ ->
                        let
                            spacePerPortion =
                                context.parent.bbox.width / toFloat (List.length context.siblings)
                        in
                        Expect.equal spacePerPortion context.self.bbox.width
                }

        Shrink ->
            Testable.LabeledTest
                { label = "width shrink"
                , attr = Element.width Element.shrink
                , test =
                    \context _ ->
                        let
                            childWidth child =
                                -- TODO: add margin values to widths
                                child.bbox.width

                            totalChildren =
                                context.children
                                    |> List.map childWidth
                                    |> List.sum

                            horizontalPadding =
                                context.self.bbox.padding.left + context.self.bbox.padding.right
                        in
                        Expect.equal (totalChildren + horizontalPadding) context.self.bbox.width
                }


height : Length -> Testable.Attr msg
height len =
    case len of
        Px px ->
            Testable.LabeledTest
                { label = "height " ++ toString px ++ "px"
                , attr = Element.height (Element.px px)
                , test =
                    \found _ ->
                        Expect.equal (round found.self.bbox.height) px
                }

        Fill portion ->
            Testable.LabeledTest
                { label = "height fill:" ++ toString portion
                , attr = Element.height (Element.fillPortion portion)
                , test =
                    \context _ ->
                        let
                            spacePerPortion =
                                context.parent.bbox.height / toFloat (List.length context.siblings + 1)
                        in
                        Expect.equal spacePerPortion context.self.bbox.height
                }

        Shrink ->
            Testable.LabeledTest
                { label = "height shrink"
                , attr = Element.height Element.shrink
                , test =
                    \context _ ->
                        let
                            childHeight child =
                                -- TODO: add margin values to heights
                                child.bbox.height

                            totalChildren =
                                context.children
                                    |> List.map childHeight
                                    |> List.sum

                            horizontalPadding =
                                context.self.bbox.padding.left + context.self.bbox.padding.right
                        in
                        Expect.equal (totalChildren + horizontalPadding) context.self.bbox.height
                }


spacing : Int -> Testable.Attr msg
spacing space =
    Testable.LabeledTest
        { label = "spacing: " ++ toString space
        , attr = Element.spacing space
        , test =
            \found _ ->
                let
                    findDistance child distances =
                        List.concatMap
                            (\otherChild ->
                                let
                                    horizontal =
                                        child.bbox.left - otherChild.bbox.right

                                    vertical =
                                        child.bbox.top - otherChild.bbox.bottom
                                in
                                [ if horizontal > 0 then
                                    horizontal
                                  else
                                    space
                                , if vertical > 0 then
                                    vertical
                                  else
                                    space
                                ]
                            )
                            found.children
                            ++ distances

                    distances =
                        List.foldl findDistance [] found.children
                in
                Expect.true ("All children are at least " ++ toString space ++ " pixels apart.")
                    (List.all (\x -> x >= space) distances)
        }


{-| alignLeft needs to account for

  - parent padding
  - elements to the left
  - spacing value

in order to calculate the expected result.

Also need parent rendering context if this is to work with wrapped rows in the future.

All sibling elements

-}
alignLeft : Testable.Attr msg
alignLeft =
    Testable.LabeledTest
        { label = "alignLeft"
        , attr = Element.alignLeft
        , test =
            \found _ ->
                if List.any ((==) found.location) [ Just Testable.OnLeft, Just Testable.OnRight ] then
                    Expect.true "alignLeft doesn't apply to elements that are onLeft or onRight" True
                else if List.length found.siblings == 0 then
                    Expect.equal found.self.bbox.left (found.parent.bbox.left + found.parent.bbox.padding.left)
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal
                        found.self.bbox.left
                        (found.parent.bbox.left + found.parent.bbox.padding.left)
        }


{-| -}
centerX : Testable.Attr msg
centerX =
    Testable.LabeledTest
        { label = "centerX"
        , attr = Element.centerX
        , test =
            \found _ ->
                let
                    selfCenter =
                        found.self.bbox.left + (found.self.bbox.width / 2)

                    parentCenter =
                        found.parent.bbox.left + (found.parent.bbox.width / 2)
                in
                if List.any ((==) found.location) [ Just Testable.OnRight, Just Testable.OnLeft ] then
                    Expect.true "centerY doesn't apply to elements that are onLeft or onRight" True
                else if List.length found.siblings == 0 then
                    Expect.equal selfCenter parentCenter
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal selfCenter parentCenter
        }


{-| -}
alignRight : Testable.Attr msg
alignRight =
    Testable.LabeledTest
        { label = "alignRight"
        , attr = Element.alignRight
        , test =
            \found _ ->
                if List.any ((==) found.location) [ Just Testable.OnLeft, Just Testable.OnRight ] then
                    Expect.true "alignRight doesn't apply to elements that are onLeft or onRight" True
                else if List.length found.siblings == 0 then
                    Expect.equal found.self.bbox.left (found.parent.bbox.right + found.parent.bbox.padding.right)
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal
                        found.self.bbox.right
                        (found.parent.bbox.right + found.parent.bbox.padding.right)
        }


{-| -}
alignTop : Testable.Attr msg
alignTop =
    Testable.LabeledTest
        { label = "alignTop"
        , attr = Element.alignTop
        , test =
            \found _ ->
                if List.any ((==) found.location) [ Just Testable.Above, Just Testable.Below ] then
                    Expect.true "alignTop doesn't apply to elements that are above or below" True
                else if List.length found.siblings == 0 then
                    Expect.equal found.self.bbox.top (found.parent.bbox.top + found.parent.bbox.padding.top)
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal
                        found.self.bbox.bottom
                        found.parent.bbox.top
        }


{-| -}
alignBottom : Testable.Attr msg
alignBottom =
    Testable.LabeledTest
        { label = "alignBottom"
        , attr = Element.alignBottom
        , test =
            \found _ ->
                if List.any ((==) found.location) [ Just Testable.Above, Just Testable.Below ] then
                    Expect.true "alignBottom doesn't apply to elements that are above or below" True
                else if List.length found.siblings == 0 then
                    Expect.equal found.self.bbox.top (found.parent.bbox.top + found.parent.bbox.padding.top)
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal
                        found.self.bbox.top
                        found.parent.bbox.bottom
        }


{-| -}
centerY : Testable.Attr msg
centerY =
    Testable.LabeledTest
        { label = "centerY"
        , attr = Element.centerY
        , test =
            \found _ ->
                let
                    selfCenter =
                        found.self.bbox.top + (found.self.bbox.height / 2)

                    parentCenter =
                        found.parent.bbox.top + (found.parent.bbox.height / 2)
                in
                if List.any ((==) found.location) [ Just Testable.Above, Just Testable.Below ] then
                    Expect.true "centerY doesn't apply to elements that are above or below" True
                else if List.length found.siblings == 0 then
                    Expect.equal selfCenter parentCenter
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal selfCenter parentCenter
        }


{-| -}
above : Testable.Element msg -> Testable.Attr msg
above el =
    Testable.Nearby
        { location = Testable.Above
        , element = el
        , label = "above"
        , test =
            \found _ ->
                Expect.equal found.self.bbox.bottom found.parent.bbox.top
        }


{-| -}
below : Testable.Element msg -> Testable.Attr msg
below el =
    Testable.Nearby
        { location = Testable.Below
        , element = el
        , label = "below"
        , test =
            \found _ ->
                Expect.equal found.self.bbox.top found.parent.bbox.bottom
        }


{-| -}
onRight : Testable.Element msg -> Testable.Attr msg
onRight el =
    Testable.Nearby
        { location = Testable.OnRight
        , element = el
        , label = "onRight"
        , test =
            \found _ ->
                Expect.equal found.self.bbox.left found.parent.bbox.right
        }


{-| -}
onLeft : Testable.Element msg -> Testable.Attr msg
onLeft el =
    Testable.Nearby
        { location = Testable.OnLeft
        , element = el
        , label = "onLeft"
        , test =
            \found _ ->
                Expect.equal found.self.bbox.right found.parent.bbox.left
        }


{-| -}
inFront : Testable.Element msg -> Testable.Attr msg
inFront el =
    Testable.Nearby
        { location = Testable.InFront
        , element = el
        , label = "inFront"
        , test =
            \found _ ->
                Expect.true "within the confines of the parent"
                    (List.all ((==) True)
                        [ found.self.bbox.right <= found.parent.bbox.right
                        , found.self.bbox.left <= found.parent.bbox.left
                        , found.self.bbox.top <= found.parent.bbox.top
                        , found.self.bbox.bottom <= found.parent.bbox.bottom
                        ]
                    )
        }


{-| -}
behind : Testable.Element msg -> Testable.Attr msg
behind el =
    Testable.Nearby
        { location = Testable.Behind
        , element = el
        , label = "behind"
        , test =
            \found _ ->
                Expect.true "within the confines of the parent"
                    (List.all ((==) True)
                        [ found.self.bbox.right <= found.parent.bbox.right
                        , found.self.bbox.left <= found.parent.bbox.left
                        , found.self.bbox.top <= found.parent.bbox.top
                        , found.self.bbox.bottom <= found.parent.bbox.bottom
                        ]
                    )
        }
