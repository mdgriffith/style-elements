module Testable exposing (..)

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
    | Nearby
        { location : Location
        , element : Element msg
        , test : Surroundings -> () -> Expect.Expectation
        , label : String
        }
    | Label String
    | LabeledTest
        { test : Surroundings -> () -> Expect.Expectation
        , label : String
        , attr : Element.Attribute msg
        }


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | InFront
    | Behind


type alias Surroundings =
    { siblings : List Found
    , parent : Found
    , children : List Found
    , self : Found
    }


type alias Found =
    { bbox : BoundingBox
    , style : Style
    }


{-| -}
type alias Style =
    List ( String, String )


type alias BoundingBox =
    { width : Float
    , height : Float
    , left : Float
    , top : Float
    , right : Float
    , bottom : Float
    , padding :
        { left : Float
        , right : Float
        , top : Float
        , bottom : Float
        }
    }



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

        makeAttributes attrs =
            attrs
                |> List.indexedMap (renderAttribute level)
                |> List.concat
    in
    case el of
        El attrs child ->
            Element.el
                (id :: makeAttributes attrs)
                (renderElement (0 :: level) child)

        Row attrs children ->
            Element.row
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Column attrs children ->
            Element.column
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        TextColumn attrs children ->
            Element.textColumn
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Paragraph attrs children ->
            Element.paragraph
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Empty ->
            Element.empty


renderAttribute : List Int -> Int -> Attr msg -> List (Element.Attribute msg)
renderAttribute level attrIndex attr =
    case attr of
        Attr attribute ->
            [ attribute ]

        AttrTest _ ->
            []

        Label _ ->
            []

        Nearby { location, element } ->
            case location of
                Above ->
                    [ Element.above (renderElement (attrIndex :: -1 :: level) element) ]

                Below ->
                    [ Element.below (renderElement (attrIndex :: -1 :: level) element) ]

                OnRight ->
                    [ Element.onRight (renderElement (attrIndex :: -1 :: level) element) ]

                OnLeft ->
                    [ Element.onLeft (renderElement (attrIndex :: -1 :: level) element) ]

                InFront ->
                    [ Element.inFront (renderElement (attrIndex :: -1 :: level) element) ]

                Behind ->
                    [ Element.behind (renderElement (attrIndex :: -1 :: level) element) ]

        Batch batch ->
            List.indexedMap (renderAttribute (attrIndex :: level)) batch
                |> List.concat

        LabeledTest { attr } ->
            [ attr ]



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


levelToString : List a -> String
levelToString level =
    level
        |> List.map toString
        |> String.join "-"
        |> (\x -> "se-" ++ x)


createTest : List Found -> Found -> Dict String Found -> List Int -> Element msg -> List Test
createTest siblings parent cache level el =
    let
        id =
            levelToString level

        maybeFound =
            Dict.get id cache

        testChildren : Found -> List (Element msg) -> List Test
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

        applyChildTest :
            Found
            -> Element msg
            ->
                { a
                    | index : Int
                    , previous : List Found
                    , tests : List Test
                    , upcoming : List Found
                }
            ->
                { index : Int
                , previous : List Found
                , tests : List Test
                , upcoming : List Found
                }
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

        tests : Found -> List (Attr msg) -> List (Element msg) -> List Test
        tests self attributes children =
            let
                findBBox elem ( i, gathered ) =
                    case Dict.get (levelToString (i :: level)) cache of
                        Nothing ->
                            Debug.log "Failed to find child"
                                ( i + 1
                                , gathered
                                )

                        Just found ->
                            ( i + 1
                            , found :: gathered
                            )

                childrenFoundData =
                    List.foldl findBBox ( 0, [] ) children
                        |> Tuple.second

                attributeTests =
                    attributes
                        |> applyLabels
                        |> List.indexedMap
                            -- Found -> Dict String Found -> List Int -> Int -> Surroundings -> Attr msg -> List Test
                            (\i attr ->
                                createAttributeTest parent
                                    cache
                                    level
                                    i
                                    { siblings = siblings
                                    , parent = parent
                                    , self = self
                                    , children = childrenFoundData
                                    }
                                    attr
                            )
                        |> List.concat
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
        --                 List.indexedMap (\i -> createTest siblings surroundings.self cache (i :: level)) children
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


applyLabels : List (Attr msg) -> List (Attr msg)
applyLabels attrs =
    let
        toLabel attr =
            case attr of
                Label label ->
                    Just label

                _ ->
                    Nothing

        newLabels =
            attrs
                |> List.filterMap toLabel
                |> String.join ", "

        applyLabel newLabel attr =
            case attr of
                LabeledTest labeled ->
                    LabeledTest
                        { labeled
                            | label =
                                if newLabel == "" then
                                    labeled.label
                                else
                                    newLabel ++ ", " ++ labeled.label
                        }

                x ->
                    x
    in
    List.map (applyLabel newLabels) attrs


createAttributeTest : Found -> Dict String Found -> List Int -> Int -> Surroundings -> Attr msg -> List Test
createAttributeTest parent cache level attrIndex surroundings attr =
    case attr of
        Attr _ ->
            []

        Label _ ->
            []

        AttrTest test ->
            [ test surroundings
            ]

        Nearby nearby ->
            --createTest : List Found -> Found -> Dict String Found -> List Int -> Element msg -> List Test
            createTest
                []
                -- no siblings
                parent
                -- need parent
                cache
                -- need cache
                (attrIndex :: -1 :: level)
                -- need index
                (addAttribute (AttrTest (\context -> Test.test nearby.label (nearby.test context))) nearby.element)

        Batch batch ->
            batch
                |> List.indexedMap (\i attr -> createAttributeTest parent cache (attrIndex :: level) i surroundings attr)
                |> List.concat

        LabeledTest { label, test } ->
            [ Test.test label (test surroundings) ]


addAttribute : Attr msg -> Element msg -> Element msg
addAttribute attr el =
    case el of
        El attrs child ->
            El (attr :: attrs) child

        Row attrs children ->
            Row (attr :: attrs) children

        Column attrs children ->
            Column (attr :: attrs) children

        TextColumn attrs children ->
            TextColumn (attr :: attrs) children

        Paragraph attrs children ->
            Paragraph (attr :: attrs) children

        Empty ->
            Empty


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
