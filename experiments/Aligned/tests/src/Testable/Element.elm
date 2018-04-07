module Testable.Element exposing (..)

{-| This module should mirror the top level `Element` api, with one important distinction.

The resulting `Element msg` structure can either be rendered to Html or transformed into a test suite that can be run.

In order to run the test:

  - render html
  - gather information from the browser
  - generate tests

-}

import Dict
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


transparent : Bool -> Testable.Attr msg
transparent on =
    Testable.LabeledTest
        { label = "transparent-" ++ toString on
        , attr = Element.transparent on
        , test =
            \context _ ->
                let
                    selfTransparency =
                        context.self.style
                            |> Dict.get "opacity"
                            |> Maybe.withDefault "notfound"

                    value =
                        if on then
                            "0"
                        else
                            "1"
                in
                Expect.equal value selfTransparency
        }


{-| -}
alpha : Float -> Testable.Attr msg
alpha a =
    Testable.LabeledTest
        { label = "alpha-" ++ toString a
        , attr = Element.alpha a
        , test =
            \context _ ->
                let
                    selfTransparency =
                        context.self.style
                            |> Dict.get "opacity"
                            |> Maybe.withDefault "notfound"
                in
                Expect.equal (toString a) selfTransparency
        }


{-| -}
padding : Int -> Testable.Attr msg
padding pad =
    Testable.LabeledTest
        { label = "padding " ++ toString pad
        , attr = Element.padding pad
        , test =
            \found _ ->
                Expect.true ("Padding " ++ toString pad ++ " is present")
                    (List.all ((==) pad)
                        [ round found.self.bbox.padding.left
                        , round found.self.bbox.padding.right
                        , round found.self.bbox.padding.top
                        , round found.self.bbox.padding.bottom
                        ]
                    )
        }


{-| -}
paddingXY : Int -> Int -> Testable.Attr msg
paddingXY x y =
    Testable.LabeledTest
        { label = "paddingXY " ++ toString x ++ ", " ++ toString y
        , attr = Element.paddingXY x y
        , test =
            \found _ ->
                Expect.true ("PaddingXY " ++ toString ( x, y ) ++ " is present")
                    (List.all ((==) x)
                        [ round found.self.bbox.padding.left
                        , round found.self.bbox.padding.right
                        ]
                        && List.all ((==) y)
                            [ round found.self.bbox.padding.top
                            , round found.self.bbox.padding.bottom
                            ]
                    )
        }


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
                        if List.member context.location [ Testable.IsNearby Testable.OnRight, Testable.IsNearby Testable.OnLeft ] then
                            Expect.true "height fill doesn't apply to above/below elements" True
                        else
                            case context.location of
                                Testable.IsNearby _ ->
                                    expectRoundedEquality context.parent.bbox.width context.self.bbox.width

                                Testable.InColumn ->
                                    expectRoundedEquality context.parent.bbox.width context.self.bbox.width

                                Testable.InEl ->
                                    expectRoundedEquality context.parent.bbox.width context.self.bbox.width

                                _ ->
                                    let
                                        spacePerPortion =
                                            context.parent.bbox.width / toFloat (List.length context.siblings + 1)
                                    in
                                    expectRoundedEquality spacePerPortion context.self.bbox.width
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

                            spacing =
                                toFloat context.parentSpacing * (toFloat (List.length context.children) - 1)
                        in
                        if totalChildren == 0 then
                            -- TODO: The issue is that we have a hard time measuring `text` elements
                            -- So if a element has a text child, then it's width isn't going to show up in the system.
                            expectRoundedEquality context.self.bbox.width context.self.bbox.width
                        else
                            -- This fails if this element is actually a column
                            -- So we need to capture what this element is in order to do this calculation.
                            expectRoundedEquality (totalChildren + horizontalPadding + spacing) context.self.bbox.width
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
                        if List.member context.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                            Expect.true "height fill doesn't apply to above/below elements" True
                        else
                            case context.location of
                                Testable.IsNearby _ ->
                                    expectRoundedEquality context.parent.bbox.height context.self.bbox.height

                                Testable.InRow ->
                                    expectRoundedEquality context.parent.bbox.height context.self.bbox.height

                                Testable.InEl ->
                                    expectRoundedEquality context.parent.bbox.height context.self.bbox.height

                                _ ->
                                    let
                                        spacePerPortion =
                                            context.parent.bbox.height / toFloat (List.length context.siblings + 1)

                                        -- space per portion only makes sense if all the other elements are fill
                                        -- we can detect if they are not fill by comparing them to the expected fill size.
                                        -- This approach may not account for lots of weird height values.
                                        findFillable sib fillable =
                                            fillable - sib.bbox.height

                                        fillableSpace =
                                            List.foldl findFillable context.parent.bbox.height context.siblings
                                    in
                                    expectRoundedEquality fillableSpace context.self.bbox.height
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
                        if totalChildren == 0 then
                            -- TODO, see issue with Width/shrink and text elements.
                            expectRoundedEquality context.self.bbox.height context.self.bbox.height
                        else
                            expectRoundedEquality (totalChildren + horizontalPadding) context.self.bbox.height
                }


spacing : Int -> Testable.Attr msg
spacing space =
    Testable.Batch
        [ Testable.Spacing space
        , Testable.LabeledTest
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
        ]


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
                if List.member found.location [ Testable.IsNearby Testable.OnLeft, Testable.IsNearby Testable.OnRight ] then
                    Expect.true "alignLeft doesn't apply to elements that are onLeft or onRight" True
                else if List.length found.siblings == 0 then
                    Expect.equal
                        (round found.self.bbox.left)
                        (round (found.parent.bbox.left + found.parent.bbox.padding.left))
                else
                    case found.location of
                        Testable.InRow ->
                            let
                                siblingsOnLeft =
                                    List.filter (\x -> x.bbox.right < found.self.bbox.left) found.siblings

                                spacings =
                                    toFloat (List.length siblingsOnLeft * found.parentSpacing)

                                widthsOnLeft =
                                    siblingsOnLeft
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                            in
                            Expect.equal
                                (round found.self.bbox.left)
                                (round (found.parent.bbox.left + (found.parent.bbox.padding.left + widthsOnLeft + spacings)))

                        _ ->
                            Expect.equal
                                (round found.self.bbox.left)
                                (round (found.parent.bbox.left + found.parent.bbox.padding.left))
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
                    selfCenter : Float
                    selfCenter =
                        found.self.bbox.left + (found.self.bbox.width / 2)

                    parentCenter : Float
                    parentCenter =
                        found.parent.bbox.left + (found.parent.bbox.width / 2)
                in
                if List.member found.location [ Testable.IsNearby Testable.OnRight, Testable.IsNearby Testable.OnLeft ] then
                    Expect.true "centerX doesn't apply to elements that are onLeft or onRight" True
                else if List.length found.siblings == 0 then
                    Expect.equal selfCenter parentCenter
                else
                    case found.location of
                        Testable.InRow ->
                            let
                                siblingsOnLeft =
                                    List.filter (\x -> x.bbox.right < found.self.bbox.left) found.siblings

                                siblingsOnRight =
                                    List.filter (\x -> x.bbox.left > found.self.bbox.right) found.siblings

                                widthsOnLeft : Float
                                widthsOnLeft =
                                    siblingsOnLeft
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsOnLeft) * toFloat found.parentSpacing))

                                widthsOnRight =
                                    siblingsOnRight
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsOnRight) * toFloat found.parentSpacing))

                                expectedCenter : Float
                                expectedCenter =
                                    found.parent.bbox.left
                                        + widthsOnLeft
                                        + ((found.parent.bbox.width - (widthsOnRight + widthsOnLeft))
                                            / 2
                                          )
                            in
                            Expect.equal
                                (round selfCenter)
                                (round expectedCenter)

                        _ ->
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
                if List.member found.location [ Testable.IsNearby Testable.OnLeft, Testable.IsNearby Testable.OnRight ] then
                    Expect.true "alignRight doesn't apply to elements that are onLeft or onRight" True
                else if List.length found.siblings == 0 then
                    Expect.equal
                        (round found.self.bbox.right)
                        (round (found.parent.bbox.right + found.parent.bbox.padding.right))
                else
                    case found.location of
                        Testable.InRow ->
                            let
                                siblingsOnRight =
                                    List.filter (\x -> x.bbox.left > found.self.bbox.right) found.siblings

                                spacings =
                                    toFloat (List.length siblingsOnRight * found.parentSpacing)

                                widthsOnRight =
                                    siblingsOnRight
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                            in
                            Expect.equal
                                (round found.self.bbox.right)
                                (round (found.parent.bbox.right - (found.parent.bbox.padding.right + widthsOnRight + spacings)))

                        _ ->
                            Expect.equal
                                (round found.self.bbox.right)
                                (round (found.parent.bbox.right + found.parent.bbox.padding.right))
        }


{-| -}
alignTop : Testable.Attr msg
alignTop =
    Testable.LabeledTest
        { label = "alignTop"
        , attr = Element.alignTop
        , test =
            \found _ ->
                if List.member found.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    Expect.true "alignTop doesn't apply to elements that are above or below" True
                else if List.length found.siblings == 0 then
                    Expect.equal (round found.self.bbox.top) (round (found.parent.bbox.top + found.parent.bbox.padding.top))
                else
                    case found.location of
                        Testable.InColumn ->
                            let
                                siblingsAbove =
                                    List.filter (\x -> x.bbox.bottom < found.self.bbox.top) found.siblings

                                spacings =
                                    toFloat (List.length siblingsAbove * found.parentSpacing)

                                heightsAbove =
                                    siblingsAbove
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                            in
                            Expect.equal
                                (round found.self.bbox.top)
                                (round (found.parent.bbox.top + (found.parent.bbox.padding.top + heightsAbove + spacings)))

                        _ ->
                            Expect.equal
                                (round found.self.bbox.top)
                                (round found.parent.bbox.top)
        }


{-| -}
alignBottom : Testable.Attr msg
alignBottom =
    Testable.LabeledTest
        { label = "alignBottom"
        , attr = Element.alignBottom
        , test =
            \found _ ->
                if List.member found.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    Expect.true "alignBottom doesn't apply to elements that are above or below" True
                else if List.length found.siblings == 0 then
                    Expect.equal
                        (round found.self.bbox.bottom)
                        (round (found.parent.bbox.bottom + found.parent.bbox.padding.bottom))
                else
                    case found.location of
                        Testable.InColumn ->
                            let
                                siblingsBelow =
                                    List.filter (\x -> x.bbox.top > found.self.bbox.bottom) found.siblings

                                spacings =
                                    toFloat (List.length siblingsBelow * found.parentSpacing)

                                heightsBelow =
                                    siblingsBelow
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                            in
                            Expect.equal
                                (round found.self.bbox.bottom)
                                (round (found.parent.bbox.bottom - (found.parent.bbox.padding.bottom + heightsBelow + spacings)))

                        _ ->
                            Expect.equal
                                (round found.self.bbox.bottom)
                                (round (found.parent.bbox.bottom + found.parent.bbox.padding.bottom))
        }


expectRoundedEquality x y =
    Expect.equal (round x) (round y)


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
                if List.member found.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    Expect.true "centerY doesn't apply to elements that are above or below" True
                else if List.length found.siblings == 0 then
                    Expect.equal selfCenter parentCenter
                else
                    case found.location of
                        Testable.InColumn ->
                            let
                                siblingsOnTop =
                                    List.filter (\x -> x.bbox.bottom < found.self.bbox.top) found.siblings

                                siblingsBelow =
                                    List.filter (\x -> x.bbox.top > found.self.bbox.bottom) found.siblings

                                heightsAbove : Float
                                heightsAbove =
                                    siblingsOnTop
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsOnTop) * toFloat found.parentSpacing))

                                heightsBelow =
                                    siblingsBelow
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsBelow) * toFloat found.parentSpacing))

                                expectedCenter : Float
                                expectedCenter =
                                    found.parent.bbox.top
                                        + heightsAbove
                                        + ((found.parent.bbox.height - (heightsBelow + heightsAbove))
                                            / 2
                                          )
                            in
                            Expect.equal
                                (round selfCenter)
                                (round expectedCenter)

                        _ ->
                            Expect.equal (round selfCenter) (round parentCenter)
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
                expectRoundedEquality found.self.bbox.bottom found.parent.bbox.top
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
                Expect.equal (round found.self.bbox.top) (round found.parent.bbox.bottom)
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
                Expect.equal (round found.self.bbox.left) (round found.parent.bbox.right)
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
                Expect.equal (round found.self.bbox.right) (round found.parent.bbox.left)
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
                let
                    horizontalCheck =
                        if found.self.bbox.width > found.parent.bbox.width then
                            [ (found.self.bbox.right <= found.parent.bbox.right)
                                || (found.self.bbox.left >= found.parent.bbox.left)
                            ]
                        else
                            [ found.self.bbox.right <= found.parent.bbox.right
                            , found.self.bbox.left >= found.parent.bbox.left
                            ]

                    verticalCheck =
                        if found.self.bbox.width > found.parent.bbox.width then
                            [ (found.self.bbox.top >= found.parent.bbox.top)
                                || (found.self.bbox.bottom <= found.parent.bbox.bottom)
                            ]
                        else
                            [ found.self.bbox.top >= found.parent.bbox.top
                            , found.self.bbox.bottom <= found.parent.bbox.bottom
                            ]
                in
                Expect.true "within the confines of the parent"
                    (List.all ((==) True)
                        (List.concat
                            [ horizontalCheck
                            , verticalCheck
                            ]
                        )
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
                let
                    horizontalCheck =
                        if found.self.bbox.width > found.parent.bbox.width then
                            [ (found.self.bbox.right <= found.parent.bbox.right)
                                || (found.self.bbox.left >= found.parent.bbox.left)
                            ]
                        else
                            [ found.self.bbox.right <= found.parent.bbox.right
                            , found.self.bbox.left >= found.parent.bbox.left
                            ]

                    verticalCheck =
                        if found.self.bbox.width > found.parent.bbox.width then
                            [ (found.self.bbox.top >= found.parent.bbox.top)
                                || (found.self.bbox.bottom <= found.parent.bbox.bottom)
                            ]
                        else
                            [ found.self.bbox.top >= found.parent.bbox.top
                            , found.self.bbox.bottom <= found.parent.bbox.bottom
                            ]
                in
                Expect.true "within the confines of the parent"
                    (List.all ((==) True)
                        (List.concat
                            [ horizontalCheck
                            , verticalCheck
                            ]
                        )
                    )
        }
