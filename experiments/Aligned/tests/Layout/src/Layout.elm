module Layout exposing (..)

{-| -}

import Dict exposing (Dict)
import Element
import Expect
import Html exposing (Html)
import Html.Attributes
import Random.Pcg
import Test exposing (Test)
import Test.Runner
import Test.Runner.Failure


type Analyzed element
    = Analyzed element Found


type alias Found =
    { bbox : BoundingBox
    , style : Style
    }


type alias Style =
    List ( String, String )


type alias BoundingBox =
    { width : Float
    , height : Float
    , left : Float
    , top : Float
    , right : Float
    , bottom : Float
    }


type alias Surroundings =
    { otherChildren : List Found
    , parent : Found
    , self : Found
    }


type Element msg
    = El (List (Attr msg)) (Element msg)
    | Row (List (Attr msg)) (List (Element msg))
    | Column (List (Attr msg)) (List (Element msg))
    | TextColumn (List (Attr msg)) (List (Element msg))
    | Paragraph (List (Attr msg)) (List (Element msg))
    | Empty


type Attr msg
    = Attr (Element.Attribute msg)
    | AttrTest (Surroundings -> Test)
    | Batch (List (Attr msg))



{- Retrieve Ids -}


getIds : Element msg -> List String
getIds el =
    "se-0" :: getElementId [ 0, 0 ] el


getElementId : List Int -> Element msg -> List String
getElementId level el =
    let
        id =
            level
                |> List.map toString
                |> String.join "-"
                |> (\x -> "se-" ++ x)
    in
    case el of
        El _ child ->
            id :: getElementId (0 :: level) child

        Row _ children ->
            id :: (List.concat <| List.indexedMap (\i -> getElementId (i :: level)) children)

        Column _ children ->
            id :: (List.concat <| List.indexedMap (\i -> getElementId (i :: level)) children)

        TextColumn _ children ->
            id :: (List.concat <| List.indexedMap (\i -> getElementId (i :: level)) children)

        Paragraph _ children ->
            id :: (List.concat <| List.indexedMap (\i -> getElementId (i :: level)) children)

        Empty ->
            []



{- Render as Html -}


render : Element msg -> Html msg
render el =
    Element.layout [ idAttr "0" ] <|
        renderElement [ 0, 0 ] el


idAttr : String -> Element.Attribute msg
idAttr id =
    Element.htmlAttribute (Html.Attributes.id ("se-" ++ id))


renderElement : List Int -> Element msg -> Element.Element msg
renderElement level el =
    let
        id =
            level
                |> List.map toString
                |> String.join "-"
                |> idAttr
    in
    case el of
        El attrs child ->
            Element.el
                (id :: List.concatMap renderAttribute attrs)
                (renderElement (0 :: level) child)

        Row attrs children ->
            Element.row
                (id :: List.concatMap renderAttribute attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Column attrs children ->
            Element.column
                (id :: List.concatMap renderAttribute attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        TextColumn attrs children ->
            Element.textColumn
                (id :: List.concatMap renderAttribute attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Paragraph attrs children ->
            Element.paragraph
                (id :: List.concatMap renderAttribute attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Empty ->
            Element.empty


renderAttribute : Attr msg -> List (Element.Attribute msg)
renderAttribute attr =
    case attr of
        Attr attribute ->
            [ attribute ]

        AttrTest _ ->
            []

        Batch batch ->
            List.concatMap renderAttribute batch



{- Convert to Test -}


toTest : String -> Dict String Found -> Element msg -> Test
toTest label harvested el =
    let
        maybeFound =
            Dict.get "se-0" harvested
    in
    case maybeFound of
        Nothing ->
            Test.describe label
                [ Test.test "Find Root" <|
                    \_ -> Expect.fail "unable to find root"
                ]

        Just root ->
            Test.describe label
                (createTest [] root harvested [ 0, 0 ] el)


levelToString level =
    level
        |> List.map toString
        |> String.join "-"
        |> (\x -> "se-" ++ x)


createTest : List Found -> Found -> Dict String Found -> List Int -> Element msg -> List Test
createTest otherChildren parent cache level el =
    let
        id =
            levelToString level

        maybeFound =
            Dict.get id cache

        testChildren found children =
            let
                childrenFound =
                    -- Should check taht this lookup doesn't fail.
                    -- Thoug if it does, it'll fail when the element itself is tested
                    List.filterMap
                        (\x ->
                            Dict.get (levelToString (x :: level)) cache
                        )
                        (List.range 0 (List.length children))
            in
            List.foldl (applyChildTest found)
                { index = 0
                , upcoming = childrenFound
                , previous = []
                , tests = []
                }
                children
                |> .tests

        applyChildTest found child { index, upcoming, previous, tests } =
            let
                surroundingChildren =
                    case upcoming of
                        [] ->
                            previous

                        x :: remaining ->
                            remaining ++ previous

                childrenTests =
                    createTest surroundingChildren found cache (index :: level) child
            in
            { index = index + 1
            , tests = tests ++ childrenTests
            , previous =
                case upcoming of
                    [] ->
                        previous

                    x :: _ ->
                        x :: previous
            , upcoming =
                case upcoming of
                    [] ->
                        []

                    _ :: rest ->
                        rest
            }

        tests self attributes children =
            let
                attributeTests =
                    List.concatMap
                        (createAttributeTest
                            { otherChildren = otherChildren
                            , parent = parent
                            , self = self
                            }
                        )
                        attributes
            in
            attributeTests
                ++ testChildren self children

        -- childrenTests surroundings attributes children =
        --     let
        --         attributeTests =
        --             List.concatMap (createAttributeTest surroundings) attributes
        --     in
        --     attributeTests
        --         ++ (List.concat <|
        --                 List.indexedMap (\i -> createTest otherChildren surroundings.self cache (i :: level)) children
        --            )
    in
    case maybeFound of
        Nothing ->
            case el of
                Empty ->
                    []

                _ ->
                    [ Test.test ("Unable to find " ++ id) (always <| Expect.fail "failed id lookup") ]

        Just self ->
            case el of
                El attrs child ->
                    tests self attrs [ child ]

                Row attrs children ->
                    tests self attrs children

                Column attrs children ->
                    tests self attrs children

                TextColumn attrs children ->
                    tests self attrs children

                Paragraph attrs children ->
                    tests self attrs children

                Empty ->
                    []


createAttributeTest : Surroundings -> Attr msg -> List Test
createAttributeTest surroundings attr =
    case attr of
        Attr _ ->
            []

        AttrTest test ->
            [ test surroundings
            ]

        Batch batch ->
            List.concatMap (createAttributeTest surroundings) batch


runTests :
    Random.Pcg.Seed
    -> Test
    ->
        List
            ( String
            , Maybe
                { given : Maybe String
                , description : String
                , reason : Test.Runner.Failure.Reason
                }
            )
runTests seed tests =
    let
        results =
            case Test.Runner.fromTest 100 seed tests of
                Test.Runner.Plain rnrs ->
                    List.map run rnrs

                Test.Runner.Only rnrs ->
                    List.map run rnrs

                Test.Runner.Skipping rnrs ->
                    List.map run rnrs

                Test.Runner.Invalid invalid ->
                    []

        run runner =
            let
                ran =
                    List.map Test.Runner.getFailureReason (runner.run ())
            in
            List.map2 (,) runner.labels ran
    in
    List.concat results
