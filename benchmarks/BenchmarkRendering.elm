module Main exposing (..)

{-| Benchmarks

  - Render 1000 Html Nodes
  - Render 1000 basic Elements
  - 1000 basic elements with a 6 property style

-}

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Color
import Element
import Element.Attributes
import Element.Internal.Adjustments as Adjustments
import Element.Internal.Render
import Html
import Html.Attributes
import Next.Element
import Next.Element.Position
import Next.Internal.Slim as Slim
import Next.Internal.Style
import Style
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Internal.Render


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
        [ describe "Basic"
            [ benchmark1 "html" html ()
            , benchmark1 "html with reset" htmlWithReset ()
            , benchmark1 "elem" elem ()
            , benchmark1 "next" nextElem ()
            , benchmark1 "slim" slim ()
            ]
        , describe "Center one Element"
            [ benchmark1 "html" html ()
            , benchmark1 "elem" centered ()
            , benchmark1 "next elem" centeredNext ()
            ]
        , describe "500 element test"
            [ benchmark1 "html" manyHtml 500
            , benchmark1 "elem" manyElem 500
            , benchmark1 "next" manyNextElem 500
            , benchmark1 "slim" manySlim 500
            ]
        , describe "500 styled element test"
            [ benchmark1 "html" manyStyledHtml 500
            , benchmark1 "elem" manyElem 500
            , benchmark1 "slim - styled" manySlimStyled 500
            ]
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


manyHtml i =
    Html.div []
        (List.repeat i (Html.div [] [ Html.text "hello" ]))


manyStyledHtml i =
    Html.div []
        (List.repeat i
            (Html.div
                [ Html.Attributes.style
                    [ ( "background-color", "red" )
                    , ( "color", "blue" )
                    , ( "font-size", "16px" )
                    , ( "border-width", "1px" )
                    , ( "border-color", "yellow" )
                    ]
                ]
                [ Html.text "hello" ]
            )
        )


{-| -}
html _ =
    Html.div []
        []


{-| -}
htmlWithReset _ =
    Html.div []
        [ Html.node "style" [] [ Html.text Next.Internal.Style.rules ]
        , Html.text ""
        ]


elem _ =
    Element.layout styleSheet <|
        Element.el Test [] Element.empty


slim _ =
    Slim.layout [] <|
        Slim.el [] Slim.empty


manySlim i =
    Slim.layout [] <|
        Slim.row
            []
            (List.repeat i (Slim.el [] (Slim.text "hello")))


manyElem i =
    Element.layout styleSheet <|
        Element.row None
            []
            (List.repeat i (Element.el Test [] (Element.text "hello")))


nextElem _ =
    Next.Element.layout [] <|
        Next.Element.el [] Next.Element.empty


manyNextElem i =
    Next.Element.layout [] <|
        Next.Element.row
            []
            (List.repeat i (Next.Element.el [] (Next.Element.text "hello")))


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
            , Border.all 1
            , Color.border Color.yellow
            ]
        ]


centered i =
    Element.layout styleSheet <|
        Element.el
            Test
            [ Element.Attributes.center
            ]
            Element.empty


centeredNext _ =
    Next.Element.layout [] <|
        Next.Element.el
            [ Next.Element.Position.center
            ]
            Next.Element.empty


manySlimStyled i =
    Slim.layout [] <|
        Slim.row
            []
            (List.repeat i
                (Slim.el
                    [ Slim.backgroundColor Color.red
                    , Slim.textColor Color.blue
                    , Slim.fontSize 16
                    , Slim.border 1
                    , Slim.borderColor Color.yellow
                    ]
                    (Slim.text "hello")
                )
            )
