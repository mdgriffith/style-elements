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


type Analyzed element
    = Analyzed element Found


type alias Found =
    { boundingBox : BoundingBox
    , style : Style
    , parentBoundingBox : BoundingBox
    }


type alias Style =
    List ( String, String )


type alias BoundingBox =
    { width : Int
    , height : Int
    , left : Int
    , top : Int
    , right : Int
    , bottom : Int
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
    | AttrTest (Found -> Test)
    | Batch (List (Attr msg))



{- Retrieve Ids -}


getIds : Element msg -> List String
getIds el =
    getElementId [ 0 ] el


getElementId : List Int -> Element msg -> List String
getElementId level el =
    let
        id =
            level
                |> List.map toString
                |> String.join "-"
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
    Element.layout [] <|
        renderElement [ 0 ] el


idAttr : String -> Element.Attribute msg
idAttr id =
    Element.htmlAttribute (Html.Attributes.id id)


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


toTest : Dict String Found -> Element msg -> Test
toTest harvested el =
    Test.describe "Style Elements Layout Test"
        []


createTest : Dict String Found -> List Int -> Element msg -> List Test
createTest cache level el =
    let
        id =
            level
                |> List.map toString
                |> String.join "-"

        maybeFound =
            Dict.get id cache
    in
    case maybeFound of
        Nothing ->
            [ Test.test ("Unable to find " ++ id) (always <| Expect.equal 0 1) ]

        Just found ->
            case el of
                El attrs child ->
                    let
                        attributeTests =
                            List.concatMap (createAttributeTest found) attrs
                    in
                    attributeTests ++ createTest cache (0 :: level) child

                Row attrs children ->
                    let
                        attributeTests =
                            List.concatMap (createAttributeTest found) attrs
                    in
                    attributeTests
                        ++ (List.concat <|
                                List.indexedMap (\i -> createTest cache (i :: level)) children
                           )

                Column attrs children ->
                    let
                        attributeTests =
                            List.concatMap (createAttributeTest found) attrs
                    in
                    attributeTests
                        ++ (List.concat <|
                                List.indexedMap (\i -> createTest cache (i :: level)) children
                           )

                TextColumn attrs children ->
                    let
                        attributeTests =
                            List.concatMap (createAttributeTest found) attrs
                    in
                    attributeTests
                        ++ (List.concat <|
                                List.indexedMap (\i -> createTest cache (i :: level)) children
                           )

                Paragraph attrs children ->
                    let
                        attributeTests =
                            List.concatMap (createAttributeTest found) attrs
                    in
                    attributeTests
                        ++ (List.concat <|
                                List.indexedMap (\i -> createTest cache (i :: level)) children
                           )

                Empty ->
                    []


createAttributeTest : Found -> Attr msg -> List Test
createAttributeTest found attr =
    case attr of
        Attr _ ->
            []

        AttrTest test ->
            [ test found ]

        Batch batch ->
            List.concatMap (createAttributeTest found) batch


runTests : Random.Pcg.Seed -> Test -> List ( String, Maybe { given : Maybe String, message : String } )
runTests seed tests =
    let
        runners =
            Test.Runner.fromTest 100 seed tests

        results =
            case runners of
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
                    List.map Test.Runner.getFailure (runner.run ())
            in
            List.map2 (,) runner.labels ran
    in
    List.concat results
