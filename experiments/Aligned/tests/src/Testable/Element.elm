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


px : Int -> Length
px =
    Px


fill : Length
fill =
    Fill 1


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
                                context.parent.bbox.width / toFloat (List.length context.siblings + 1)
                        in
                        Expect.equal spacePerPortion context.self.bbox.width
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
                if List.length found.siblings == 0 then
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
alignRight : Testable.Attr msg
alignRight =
    Testable.LabeledTest
        { label = "alignRight"
        , attr = Element.alignRight
        , test =
            \found _ ->
                if List.length found.siblings == 0 then
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
                if List.length found.siblings == 0 then
                    Expect.equal found.self.bbox.top (found.parent.bbox.top + found.parent.bbox.padding.top)
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal
                        found.self.bbox.right
                        (found.parent.bbox.right + found.parent.bbox.padding.right)
        }


{-| -}
alignBottom : Testable.Attr msg
alignBottom =
    Testable.LabeledTest
        { label = "alignBottom"
        , attr = Element.alignBottom
        , test =
            \found _ ->
                if List.length found.siblings == 0 then
                    Expect.equal found.self.bbox.top (found.parent.bbox.top + found.parent.bbox.padding.top)
                else
                    -- TODO
                    -- if there are siblings, then we want to be next to the nearest left element.
                    -- closest left sibling + spacing -> current left
                    Expect.equal
                        found.self.bbox.right
                        (found.parent.bbox.right + found.parent.bbox.padding.right)
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
