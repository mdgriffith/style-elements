module Layout.Fuzz exposing (..)

{-| -}

import Element exposing (Element)
import Element.Attributes
import Fuzz exposing (Fuzzer)


type Styles
    = None


horizontalAlignment : Fuzzer (Maybe (Element.Attribute variation msg))
horizontalAlignment =
    Fuzz.oneOf
        [ Fuzz.constant (Just Element.Attributes.alignLeft)
        , Fuzz.constant (Just Element.Attributes.alignRight)
        , Fuzz.constant (Just Element.Attributes.center)
        , Fuzz.constant (Just Element.Attributes.spread)
        , Fuzz.constant Nothing
        ]


verticalAlignment : Fuzzer (Maybe (Element.Attribute variation msg))
verticalAlignment =
    Fuzz.oneOf
        [ Fuzz.constant (Just Element.Attributes.alignTop)
        , Fuzz.constant (Just Element.Attributes.alignBottom)
        , Fuzz.constant (Just Element.Attributes.verticalCenter)
        , Fuzz.constant (Just Element.Attributes.verticalSpread)
        , Fuzz.constant Nothing
        ]


spacing : Fuzzer (Maybe (Element.Attribute variation msg))
spacing =
    Fuzz.oneOf
        [ Fuzz.constant (Just <| Element.Attributes.spacing 5)
        , Fuzz.constant (Just <| Element.Attributes.spacingXY 10 20)
        , Fuzz.constant Nothing
        ]


clip : Fuzzer (Maybe (Element.Attribute variation msg))
clip =
    Fuzz.oneOf
        [ Fuzz.constant (Just <| Element.Attributes.clip)
        , Fuzz.constant (Just <| Element.Attributes.clipY)
        , Fuzz.constant (Just <| Element.Attributes.clipX)
        , Fuzz.constant Nothing
        ]


move : Fuzzer (Maybe (Element.Attribute variation msg))
move =
    Fuzz.oneOf
        [ Fuzz.constant (Just <| Element.Attributes.moveLeft 5)
        , Fuzz.constant (Just <| Element.Attributes.moveRight 5)
        , Fuzz.constant (Just <| Element.Attributes.moveUp 5)
        , Fuzz.constant (Just <| Element.Attributes.moveDown 5)
        , Fuzz.constant Nothing
        ]


width : Fuzzer (Maybe (Element.Attribute variation msg))
width =
    Fuzz.oneOf
        [ Fuzz.constant (Just <| Element.Attributes.width Element.Attributes.fill)
        , Fuzz.constant (Just <| Element.Attributes.width (Element.Attributes.fillPortion 2))
        , Fuzz.constant (Just <| Element.Attributes.width (Element.Attributes.px 200))
        , Fuzz.constant (Just <| Element.Attributes.width (Element.Attributes.percent 50))
        , Fuzz.constant (Just <| Element.Attributes.width (Element.Attributes.percent 100))
        , Fuzz.constant (Just <| Element.Attributes.width Element.Attributes.content)
        , Fuzz.constant Nothing
        ]


height : Fuzzer (Maybe (Element.Attribute variation msg))
height =
    Fuzz.oneOf
        [ Fuzz.constant (Just <| Element.Attributes.height Element.Attributes.fill)
        , Fuzz.constant (Just <| Element.Attributes.height (Element.Attributes.fillPortion 2))
        , Fuzz.constant (Just <| Element.Attributes.height (Element.Attributes.px 200))
        , Fuzz.constant (Just <| Element.Attributes.height (Element.Attributes.percent 50))
        , Fuzz.constant (Just <| Element.Attributes.height (Element.Attributes.percent 100))
        , Fuzz.constant (Just <| Element.Attributes.height Element.Attributes.content)
        , Fuzz.constant Nothing
        ]


attributes : Fuzzer (List (Element.Attribute variation msg))
attributes =
    let
        prepend attr existing =
            case attr of
                Nothing ->
                    existing

                Just a ->
                    a :: existing
    in
    Fuzz.constant []
        |> Fuzz.map2 prepend horizontalAlignment
        |> Fuzz.map2 prepend verticalAlignment
        |> Fuzz.map2 prepend width
        |> Fuzz.map2 prepend height
        |> Fuzz.map2 prepend move
        |> Fuzz.map2 prepend spacing
        |> Fuzz.map2 prepend clip


element : Int -> Fuzzer (Element Styles variation msg)
element levelLimit =
    if levelLimit <= 0 then
        Fuzz.oneOf
            [ Fuzz.constant (Element.text "Hello")
            , Fuzz.constant Element.empty
            ]
    else
        Fuzz.oneOf
            [ Fuzz.constant (Element.text "Hello")
            , Fuzz.constant Element.empty
            , Fuzz.map2 (Element.el None) attributes (element (levelLimit - 1))
            , Fuzz.map2 (Element.row None)
                attributes
                (children
                    { levelLimit = levelLimit - 1
                    , min = 0
                    , max = 3
                    }
                )
            , Fuzz.map2 (Element.column None)
                attributes
                (children
                    { levelLimit = levelLimit - 1
                    , min = 0
                    , max = 3
                    }
                )
            ]


type alias Children =
    { levelLimit : Int
    , min : Int
    , max : Int
    }


children : Children -> Fuzzer (List (Element Styles variation msg))
children { levelLimit, min, max } =
    Fuzz.map2
        (\count el ->
            List.repeat count el
        )
        (Fuzz.intRange min max)
        (element levelLimit)
