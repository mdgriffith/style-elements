module Main exposing (..)

{-| Benchmarks

  - Render 1000 Html Nodes
  - Render 1000 basic Elements
  - 1000 basic elements with a 6 property style

-}

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Style.Font as Font
import Style.Border as Border
import Style.Color as Color
import Element
import Element.Attributes
import Html
import Color
import Style
import Style.Internal.Render
import Element.Internal.Adjustments as Adjustments
import Element.Internal.Render


main : BenchmarkProgram
main =
    program
        (describe "Style Elements Benchamrks"
            [ --basicFns
              --   elementRendering
              fullRendering

            -- deepRendering
            ]
        )


fullRendering : Benchmark
fullRendering =
    describe "Rendering"
        [ Benchmark.compare "Basic Element"
            (benchmark1 "html" html ())
            (benchmark1 "elem" elem ())

        -- , Benchmark.compare "Styled Elements"
        --     (benchmark1 "html" html ())
        --     (benchmark1 "elem" styled ())
        -- , Benchmark.compare "Precompiled Styled Elements"
        --     (benchmark1 "html" html ())
        --     (benchmark1 "elem" precompiledStyle ())
        , Benchmark.compare "Centered Styled Elements"
            (benchmark1 "html" html ())
            (benchmark1 "elem" centered ())

        -- , (benchmark1 "1000 Styles" styles ())
        ]



-- elementRendering : Benchmark
-- elementRendering =
--     describe "Element Rendering Pipeline"
--         [ benchmark1 "Rendering Basic Elem" elem ()
--         , benchmark1 "Make Adjustments" adjust ()
--         , benchmark1 "Render" render ()
--         , benchmark1 "Render Attributes" renderAttributes ()
--         , benchmark1 "Skip Attributes" skipRenderAttributes ()
--         -- , benchmark1 "Convert" convert ()
--         ]


basicFns =
    describe "Basic Techniques for Functions"
        [ benchmark1 "Simple" simple ()
        , benchmark1 "Fn Composition" fn ()
        , benchmark1 "Fn Composed" composed ()
        , benchmark1 "Fn Application" fn2 ()
        , benchmark1 "Builder" builder ()
        , benchmark1 "filterMap" concatMapBuilder ()
        ]


builder _ =
    let
        x xs =
            1 :: xs
    in
        (x << x << x << x << x << x << x << x) []


concatMapBuilder _ =
    let
        x =
            Just 1

        y =
            Nothing
    in
        List.filterMap identity [ x, y, x, y, x, y, x, y ]


composed =
    (identity << identity << identity << identity << identity << identity << identity << identity << identity)


fnPrecomposed x =
    composed x


simple x =
    identity x


fn x =
    (identity << identity << identity << identity << identity << identity << identity << identity << identity) x


fn2 y =
    identity <| identity <| identity <| identity <| identity <| identity <| identity <| identity <| identity y


deepRendering : Benchmark
deepRendering =
    describe "Rendering"
        [ Benchmark.compare "Deep Basic Element"
            (benchmark1 "html" htmlDepth 500)
            (benchmark1 "elem" elemDepth 500)

        -- , Benchmark.compare "Styled Elements"
        --     (benchmark1 "html" html ())
        --     (benchmark1 "elem" styled ())
        ]


html _ =
    Html.div [] []


elem _ =
    Element.layout styleSheet <|
        Element.el Test [] Element.empty


htmlDepth i =
    if i <= 0 then
        Html.text ""
    else
        Html.div [] [ htmlDepth (i - 1) ]


elemDepth i =
    Element.layout styleSheet <|
        elemDepthHelper i


elemDepthHelper i =
    if i <= 0 then
        Element.empty
    else
        Element.el Test [] (elemDepthHelper (i - 1))



-- adjust _ =
--     Element.el [] Element.empty
--         |> Adjustments.apply
-- adjusted =
--     adjust ()
-- render _ =
--     adjusted
--         |> Tuple.first
--         |> Element.Internal.Render.renderElementAndStyle Nothing Element.Internal.Render.FirstAndLast
-- renderAttributes _ =
--     Element.Internal.Render.renderAttributesAndStyle
--         Element.Internal.Render.Single
--         Element.Internal.Render.FirstAndLast
--         Nothing
--         (Element.Internal.Render.gather [])


skipRenderAttributes _ =
    if [] == [] then
        True
    else
        False



-- Element.Internal.Render.renderAttributesAndStyle
--     Element.Internal.Render.Single
--     Element.Internal.Render.FirstAndLast
--     Nothing
--     (Element.Internal.Render.gather [])
-- convert _ =
--     Element.el [] Element.empty
--         |> Element.Internal.Render.convert
-- styled i =
--     Element.layout <|
--         Element.el
--             [ Element.Attributes.style
--                 [ Color.background Color.red
--                 , Color.text Color.blue
--                 , Font.size 16
--                 , Font.pre
--                 , Border.all 1
--                 , Color.border Color.yellow
--                 ]
--             ]
--             Element.empty
-- myStyle =
--     Element.Attributes.style
--         [ Color.background Color.red
--         , Color.text Color.blue
--         , Font.size 16
--         , Font.pre
--         , Border.all 1
--         , Color.border Color.yellow
--         ]
-- styles _ =
--     Element.Attributes.style
--         [ Color.background Color.red
--         , Color.text Color.blue
--         , Font.size 16
--         , Font.pre
--         , Border.all 1
--         , Color.border Color.yellow
--         ]


type Styles
    = None
    | Test


styleSheet =
    Style.styleSheet
        [ Style.style None []
        , Style.style Test
            [ Color.background Color.red
            , Color.text Color.blue
            , Font.size 16
            , Font.pre
            , Border.all 1
            , Color.border Color.yellow
            ]
        ]



-- precompiledStyle _ =
--     Element.layout <|
--         Element.el
--             [ myStyle
--             ]
--             Element.empty


centered i =
    Element.layout styleSheet <|
        Element.el
            Test
            [ Element.Attributes.center
            ]
            Element.empty
