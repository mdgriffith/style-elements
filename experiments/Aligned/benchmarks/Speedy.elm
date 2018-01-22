module SpeedyStyle exposing (..)

{-| Style Elements allows you to specify styles inline when creating your view.
This has a bunch of development productivity benefits, but introduces a challenge for performance.
Inline styles are slow, so all these styles need to be gathered and rendered into a single stylesheet at the top
(or eventually insert dynamically into the CSSOM using `insertRule`).

Some style properties are handled by constants, so don't need to be gathered but properties like colors and paddings still need to be collected.

So, this challenge is how to do this as efficiently as possible!

Here are the requirements:

  - Every style needs to be rendered as a css class on the element it's attached to: so a color might be `bg-color-100-100-20-1`
  - Styles need to be gathered and rendered as a stylesheet at the root.
    Duplicates need to be eliminated and order largely doesn't matter
    (properties that care about order are rendered as constants so don't factor in this exercise).
  - order matters for element children
  - order may not matter for html attributes (?)

-}

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Color exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Set exposing (Set)


main : BenchmarkProgram
main =
    program suite


suite : Benchmark
suite =
    describe "Simplified Rendering Pipeline"
        [ benchmark2 "Existing Style Elements Implementation (v5)" testElements 2 10
        ]



{- Current Implementation in Style Elements -}


testElements : Int -> Int -> Html msg
testElements levelDesired numberOfChildren =
    let
        createElements level numChildren =
            if level == 0 then
                Empty
            else
                element [ Colored Color.black, Colored Color.blue, Padding level ]
                    (List.repeat numChildren (createElements (level - 1) numChildren))
    in
    renderRoot
        (createElements levelDesired numberOfChildren)


type Style
    = Colored Color
    | Padding Int


type Element msg
    = Element (List Style) (Html msg)
    | Empty


element : List Style -> List (Element msg) -> Element msg
element styles children =
    let
        -- render attributes
        htmlAttributes =
            List.foldr gatherAttributes [] styles

        gatherAttributes attr existing =
            case attr of
                Colored color ->
                    Html.Attributes.class ("bg-" ++ formatColorClass color) :: existing

                Padding i ->
                    Html.Attributes.class ("pad-" ++ toString i) :: existing

        ( styleChildren, htmlChildren ) =
            List.foldr gatherChildren ( [], [] ) children

        gatherChildren child ( collectedStyles, collectedHtml ) =
            case child of
                Empty ->
                    ( collectedStyles, collectedHtml )

                Element elStyle elHtml ->
                    ( elStyle ++ collectedStyles
                    , elHtml :: collectedHtml
                    )
    in
    Element (styles ++ styleChildren) (Html.div htmlAttributes htmlChildren)


renderRoot : Element msg -> Html msg
renderRoot el =
    case el of
        Empty ->
            Html.text ""

        Element styles children ->
            let
                stylesheet =
                    styles
                        |> List.foldr reduceStyles ( Set.empty, [] )
                        |> Tuple.second
                        |> List.map renderStyle
                        |> String.join "\n"
                        |> (\str -> Html.node "style" [] [ Html.text str ])

                renderStyle style =
                    case style of
                        Colored color ->
                            ".bg-" ++ formatColorClass color ++ "{ background-color:" ++ formatColor color ++ "}"

                        Padding i ->
                            ".pad-" ++ toString i ++ "{ padding:" ++ toString i ++ "}"
            in
            Html.div []
                [ stylesheet, children ]


reduceStyles : Style -> ( Set String, List Style ) -> ( Set String, List Style )
reduceStyles style ( cache, existing ) =
    let
        styleName =
            case style of
                Colored color ->
                    "bg-" ++ formatColorClass color

                Padding i ->
                    "pad-" ++ toString i
    in
    if Set.member styleName cache then
        ( cache, existing )
    else
        ( Set.insert styleName cache
        , style :: existing
        )


formatColorClass : Color -> String
formatColorClass color =
    let
        -- We're skipping rendering the alpha value at the moment.
        -- Don't worry about it for now :)
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    toString red
        ++ "-"
        ++ toString green
        ++ "-"
        ++ toString blue


formatColor : Color -> String
formatColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    ("rgba(" ++ toString red)
        ++ ("," ++ toString green)
        ++ ("," ++ toString blue)
        ++ ("," ++ toString alpha ++ ")")
