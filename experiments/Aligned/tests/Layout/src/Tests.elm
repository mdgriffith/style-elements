module Tests exposing (..)

import Color
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Expect
import Fuzz
import Layout
import List.Extra
import Test exposing (Test)
import Test.Runner.Failure


type alias Testable msg =
    { element : Layout.Element msg
    , label : String
    , results :
        Maybe
            (List
                ( String
                , Maybe
                    { given : Maybe String
                    , description : String
                    , reason : Test.Runner.Failure.Reason
                    }
                )
            )
    }


attr tag label attr test =
    Layout.Batch
        [ Layout.Attr attr
        , Layout.AttrTest
            (\found ->
                Test.test (tag ++ ": " ++ label) <|
                    \_ -> test found
            )
        ]


widthFill tag =
    attr tag
        "width fill"
        (Element.width Element.fill)
        (\context ->
            let
                spacePerPortion =
                    context.parent.bbox.width / toFloat (List.length context.otherChildren + 1)
            in
            Expect.equal spacePerPortion context.self.bbox.width
        )


heightFill tag =
    attr tag
        "height fill"
        (Element.height Element.fill)
        (\context ->
            let
                spacePerPortion =
                    context.parent.bbox.height / toFloat (List.length context.otherChildren + 1)
            in
            Expect.equal spacePerPortion context.self.bbox.height
        )


heightPx px tag =
    attr tag
        ("height at " ++ toString px ++ "px")
        (Element.height (Element.px (round px)))
        (\found ->
            Expect.equal found.self.bbox.height px
        )


widthPx px tag =
    attr tag
        ("width at " ++ toString px ++ "px")
        (Element.width (Element.px (round px)))
        (\found ->
            Expect.equal found.self.bbox.width px
        )


type alias PossibleAttributes msg =
    { width : String -> Layout.Attr msg
    , height : String -> Layout.Attr msg
    }


possibleToList str { width, height } =
    width str :: height str :: []


availableAttributes : { width : Float, height : Float } -> Fuzz.Fuzzer (PossibleAttributes msg)
availableAttributes bounds =
    Fuzz.map2 PossibleAttributes
        (Fuzz.oneOf
            (List.map Fuzz.constant (widths bounds.width))
        )
        (Fuzz.oneOf
            (List.map Fuzz.constant (heights bounds.height))
        )


widths : Float -> List (String -> Layout.Attr msg)
widths width =
    [ \tag ->
        attr tag
            (" with width at " ++ toString width ++ "px")
            (Element.width (Element.px (round width)))
            (\found ->
                Expect.equal found.self.bbox.width width
            )
    , \tag ->
        attr tag
            " with width fill"
            (Element.width Element.fill)
            (\context ->
                let
                    -- {-|
                    -- Calculation is
                    --     totalparentwidth - (paddingLeft ++ paddingRight)
                    --      minus widths of all the other children
                    -- -}
                    otherWidth =
                        -- Debug.log "width" <|
                        List.sum <|
                            -- Debug.log "widths" <|
                            List.map (\child -> child.bbox.width) context.otherChildren

                    spacePerPortion =
                        context.parent.bbox.width - otherWidth
                in
                Expect.equal spacePerPortion context.self.bbox.width
            )
    ]


heights : Float -> List (String -> Layout.Attr msg)
heights height =
    [ \tag ->
        attr tag
            (" with height at " ++ toString height ++ "px")
            (Element.height (Element.px (round height)))
            (\found ->
                Expect.equal found.self.bbox.height height
            )
    , \tag ->
        attr tag
            " with height fill"
            (Element.height Element.fill)
            (\context ->
                let
                    -- {-|
                    -- Calculation is
                    --     totalparentwidth - (paddingLeft ++ paddingRight)
                    --      minus widths of all the other children
                    -- -}
                    otherHeight =
                        List.sum <|
                            List.map (\child -> child.bbox.height) context.otherChildren

                    spacePerPortion =
                        context.parent.bbox.height - otherHeight
                in
                Expect.equal spacePerPortion context.self.bbox.height
            )
    ]


content : Layout.Element msg
content =
    Layout.El
        [ Layout.Attr <| Element.width (Element.px 20)
        , Layout.Attr <| Element.height (Element.px 20)
        ]
        Layout.Empty


tests : List (Testable msg)
tests =
    [ { label = "Width/Height 200"
      , results = Nothing
      , element =
            Layout.El
                [ widthPx 200 "single element"
                , heightPx 200 "single element"
                ]
                Layout.Empty
      }
    , { label = "Width Fill/Height Fill - 1"
      , results = Nothing
      , element =
            Layout.El
                [ widthFill "single element"
                , heightFill "single element"
                ]
            <|
                content
      }
    , { label = "Width Fill/Height Fill - 2"
      , results = Nothing
      , element =
            Layout.El
                [ widthFill "top element"
                , heightFill "top element"
                ]
            <|
                Layout.El
                    [ widthFill "embedded element"
                    , heightFill "embedded element"
                    ]
                <|
                    content
      }
    , { label = "Row Width Fill/Height Fill"
      , results = Nothing
      , element =
            Layout.Row
                [ widthFill "on row"
                , heightFill "on row"
                ]
                [ Layout.El
                    [ widthFill "row - 1"
                    , heightFill "row - 1"
                    ]
                    content
                , Layout.El
                    [ widthFill "row - 2"
                    , heightFill "row - 2"
                    ]
                    content
                , Layout.El
                    [ widthFill "row - 3"
                    , heightFill "row - 3"
                    ]
                    content
                ]
      }
    ]



{- Generating A Complete Test Suite

-}


type LayoutElement
    = El
    | Row
    | Column


allIndividualLayouts : List (Fuzz.Fuzzer LayoutElement)
allIndividualLayouts =
    [ Fuzz.constant El
    , Fuzz.constant Row
    , Fuzz.constant Column
    ]


testableLayout : Fuzz.Fuzzer (Testable msg)
testableLayout =
    let
        asTestable layout =
            { element = layout
            , label = "A Sweet Test"
            , results = Nothing
            }
    in
    Fuzz.map asTestable layout


layout : Fuzz.Fuzzer (Layout.Element msg)
layout =
    Fuzz.map4 createContainer
        (Fuzz.tuple3
            ( availableAttributes { width = 20, height = 20 }
            , availableAttributes { width = 20, height = 20 }
            , availableAttributes { width = 20, height = 20 }
            )
        )
        (availableAttributes { width = 200, height = 200 })
        (Fuzz.oneOf allIndividualLayouts)
        (Fuzz.oneOf allIndividualLayouts)


createElement : String -> LayoutElement -> PossibleAttributes msg -> Layout.Element msg
createElement tag layout possibleAttrs =
    let
        attrs =
            possibleToList tag possibleAttrs
    in
    case layout of
        El ->
            Layout.El attrs content

        Row ->
            Layout.Row attrs
                [ content
                , content
                , content
                ]

        Column ->
            Layout.Column attrs
                [ content
                , content
                , content
                ]


createContainer : ( PossibleAttributes msg, PossibleAttributes msg, PossibleAttributes msg ) -> PossibleAttributes msg -> LayoutElement -> LayoutElement -> Layout.Element msg
createContainer ( a1, a2, a3 ) possibleAttrs parent child =
    let
        attrs =
            possibleToList "0" possibleAttrs
    in
    case parent of
        El ->
            Layout.El attrs (createElement "0-0" child a1)

        Row ->
            Layout.Row attrs
                [ createElement "0-0" child a1
                , createElement "0-1" child a2
                , createElement "0-2" child a3
                ]

        Column ->
            Layout.Column attrs
                [ createElement "0-0" child a1
                , createElement "0-1" child a2
                , createElement "0-2" child a3
                ]


{-| Given a list of a list of possibilities,

choose once from each list.

    [ [width (px 100), width fill]
    , [height (px 100), height fill]
    ]
    ->

    [ [width (px 100), height (px 100)]
    , [width (px 100), height fill]
    ]

-}
allPossibilities : List (List a) -> List (List a)
allPossibilities =
    List.Extra.cartesianProduct
