module Main exposing (..)

{-| Let's see how fast browser CSS parsing speed is.

Specifically we want to compare browser CSS parsing speed with a strategy that reduces the number of rules that needs to be parsed.

Is the overhead of reducing the number of rules faster than th CSS parsing speed?

In order to check this we want to render a page with 10k buttons:

  - First with a static style sheet where there are 10k button style rules
  - Second where the rules are reduced to a minimal number needed and then rendered

We want to check this for the situation where all buttons have the same style, and for where all buttons have different styles.

This isn't about html rendering speed, so the html should be generated before the test

-}

import AnimationFrame
import Color
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy
import Murmur3
import Set
import Time exposing (Time)


main =
    Html.program
        { init =
            ( init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


init =
    NoStyles


type RenderWith
    = NoStyles
    | StaticBlueButtons
    | ReducedBlueButtons
    | LazyReducedBlueButtons
    | StaticAllColorButtons
    | IndexedAllColorButtons
    | ReducedAllColorButtons
    | LazyReducedAllColorButtons
    | ReducedAllColorAllProps
    | JITReducedAllProps


type Msg
    = Render RenderWith


update msg model =
    case msg of
        Render with ->
            ( with, Cmd.none )


view model =
    div []
        [ Html.node "style"
            []
            [ case model of
                NoStyles ->
                    Html.text ""

                StaticBlueButtons ->
                    Html.text (allBlueButtons ())

                ReducedBlueButtons ->
                    Html.text (reducedBlueButtons ())

                LazyReducedBlueButtons ->
                    Html.text (lazyReducedBlueButtons ())

                StaticAllColorButtons ->
                    Html.text (allColorButtons ())

                ReducedAllColorButtons ->
                    Html.text (reducedallColorButtons ())

                LazyReducedAllColorButtons ->
                    Html.text (reducedLazyAllColorButtons ())

                ReducedAllColorAllProps ->
                    Html.text (reducedallColorButtonsAllProps ())

                IndexedAllColorButtons ->
                    Html.text (allColorButtonsIndexed ())

                JITReducedAllProps ->
                    Html.text (jitReductionAllProps ())
            ]
        , Html.div []
            [ Html.button [ Html.Events.onClick (Render StaticBlueButtons) ] [ Html.text "Static, All Blue Styles" ]
            , Html.button [ Html.Events.onClick (Render ReducedBlueButtons) ] [ Html.text "Reduced, All Blue Styles" ]
            , Html.button [ Html.Events.onClick (Render ReducedBlueButtons) ] [ Html.text "Lazy, Reduced, All Blue Styles" ]
            , Html.button [ Html.Events.onClick (Render StaticAllColorButtons) ] [ Html.text "Static, All Color Styles" ]
            , Html.button [ Html.Events.onClick (Render ReducedAllColorButtons) ] [ Html.text "Reduced, All Color Styles" ]
            , Html.button [ Html.Events.onClick (Render LazyReducedAllColorButtons) ] [ Html.text "Lazy Reduced, All Color Styles" ]
            , Html.button [ Html.Events.onClick (Render ReducedAllColorAllProps) ] [ Html.text "Reduced, All Color, All Props" ]
            , Html.button [ Html.Events.onClick (Render IndexedAllColorButtons) ] [ Html.text "Indexed, All Color" ]
            , Html.button [ Html.Events.onClick (Render JITReducedAllProps) ] [ Html.text "JIT all props" ]
            ]
        , buttons
        ]


buttonCount =
    10000


buttons =
    let
        viewButton i =
            Html.button
                [ Html.Attributes.classList
                    [ ( "btn", True )
                    , ( "btn-i-" ++ toString i, True )
                    , ( "btn-" ++ toString (i % 255), True )
                    , ( "btn-rad-5", True )
                    , ( "btn-white", True )
                    , ( "btn-pad-5-10", True )
                    ]
                ]
                [ Html.text "I'm a button!" ]
    in
    Html.div [ Html.Attributes.class "button-container" ]
        (List.map viewButton (List.range 1 buttonCount))


type Style
    = Style String (List ( String, String ))


toStyleSheet styles =
    let
        renderProps ( name, val ) rendered =
            rendered ++ name ++ ":" ++ val ++ ";"

        toRuleString (Style selector props) =
            selector ++ " {" ++ List.foldl renderProps "" props ++ "}"
    in
    styles
        |> List.map toRuleString
        |> String.join "\n"


renderStyle (Style selector props) =
    let
        renderProps ( name, val ) rendered =
            rendered ++ name ++ ":" ++ val ++ ";"
    in
    selector ++ " {" ++ List.foldl renderProps "" props ++ "}"


allBlueButtons _ =
    let
        blue _ =
            Style ".btn"
                [ ( "background-color", "blue" )
                , ( "color", "white" )
                , ( "border-radius", "5px" )
                , ( "padding", "5px 10px" )
                ]
    in
    List.map blue (List.range 1 buttonCount)
        |> toStyleSheet


{-| For every iteration of the fold, we want to generate a single style and insert it into a dict structure.

This is to establish a baseline of what reducing looks like. If this doesn't work, other more realistic strategies wont'

-}
reducedBlueButtons : a -> String
reducedBlueButtons _ =
    let
        blue i accum =
            Dict.insert "button"
                (Style ".btn"
                    [ ( "background-color", "blue" )
                    , ( "color", "white" )
                    , ( "border-radius", "5px" )
                    , ( "padding", "5px 10px" )
                    ]
                )
                accum
    in
    List.foldr blue Dict.empty (List.range 1 buttonCount)
        |> Dict.values
        |> toStyleSheet


allColorButtons : a -> String
allColorButtons _ =
    let
        blue i =
            let
                blueShade =
                    toString (i % 255)
            in
            Style (".btn-" ++ blueShade)
                [ ( "background-color", "rgb(0,0," ++ blueShade ++ ")" )
                , ( "color", "white" )
                , ( "border-radius", "5px" )
                , ( "padding", "5px 10px" )
                ]
    in
    List.map blue (List.range 1 buttonCount)
        |> toStyleSheet


allColorButtonsIndexed : a -> String
allColorButtonsIndexed _ =
    let
        blue i =
            let
                blueShade =
                    toString (i % 255)
            in
            Style (".btn-i-" ++ toString i)
                [ ( "background-color", "rgb(0,0," ++ blueShade ++ ")" )
                , ( "color", "white" )
                , ( "border-radius", "5px" )
                , ( "padding", "5px 10px" )
                ]
    in
    List.map blue (List.range 1 buttonCount)
        |> toStyleSheet


{-| Now buttons have varying blue shades from blue 0 to blue 255.

We also do multiple insertions for each button. One that is similar to before and one that captures the blue color

-}
reducedallColorButtons : a -> String
reducedallColorButtons _ =
    let
        blue i accum =
            let
                blueShade =
                    toString (i % 255)
            in
            accum
                |> Dict.insert blueShade
                    (Style (".btn-" ++ blueShade)
                        [ ( "background-color", "rgb(0,0," ++ blueShade ++ ")" )
                        ]
                    )
                |> Dict.insert "button"
                    (Style ".btn"
                        [ ( "color", "white" )
                        , ( "border-radius", "5px" )
                        , ( "padding", "5px 10px" )
                        ]
                    )
    in
    List.foldr blue Dict.empty (List.range 1 buttonCount)
        |> Dict.values
        |> toStyleSheet


{-| Now buttons have varying blue shades from blue 0 to blue 255.

We also do multiple insertions for each button. One that is similar to before and one that captures the blue color

-}
reducedallColorButtonsAllProps : a -> String
reducedallColorButtonsAllProps _ =
    let
        styleDicts =
            createStyleStretch 1 buttonCount
    in
    styleDicts
        |> Dict.values
        |> toStyleSheet


{-| Now buttons have varying blue shades from blue 0 to blue 255.

We also do multiple insertions for each button. One that is similar to before and one that captures the blue color

-}
jitReductionAllProps : a -> String
jitReductionAllProps _ =
    let
        styles =
            List.foldr createStyle [] (List.range 0 buttonCount)
    in
    reduceAndRenderList styles
        |> Tuple.first


reduceAndRenderList ls =
    let
        renderProp ( name, val ) =
            name ++ ":" ++ val

        render ( key, vals ) =
            List.map renderProp vals
                |> String.join ";"

        reduceNRender ( key, style ) ( rendered, cache ) =
            if Set.member key cache then
                ( rendered, cache )
            else
                ( renderStyle style
                    ++ "\n"
                    ++ rendered
                , Set.insert key cache
                )
    in
    List.foldr reduceNRender ( "", Set.empty ) ls


createStyle i accum =
    let
        blueShade =
            toString (i % 255)

        borderCount =
            toString (i % 3000)
    in
    ( blueShade
    , Style (".btn-" ++ blueShade)
        [ ( "background-color", "rgb(0,0," ++ blueShade ++ ")" )
        ]
    )
        :: ( "border" ++ toString borderCount
           , Style (".btn-i-" ++ toString borderCount)
                [ ( "border", "1px solid rgb(0,0," ++ blueShade ++ ")" )
                ]
           )
        :: ( "rad-5"
           , Style ".btn-rad-5"
                [ ( "border-radius", "5px" )
                ]
           )
        :: ( "pad-5-10"
           , Style ".btn-pad-5-10"
                [ ( "padding", "5px 10px" )
                ]
           )
        :: ( "clr-white"
           , Style (".btn-txt-" ++ blueShade)
                [ ( "color", "rgb(" ++ blueShade ++ "," ++ blueShade ++ "," ++ blueShade ++ ")" )
                ]
           )
        :: accum


createStyleStretch s e =
    let
        blue i accum =
            let
                blueShade =
                    toString (i % 255)

                borderCount =
                    toString (i % 3000)
            in
            accum
                |> Dict.insert blueShade
                    (Style (".btn-" ++ blueShade)
                        [ ( "background-color", "rgb(0,0," ++ blueShade ++ ")" )
                        ]
                    )
                |> Dict.insert ("border" ++ toString borderCount)
                    (Style (".btn-i-" ++ toString borderCount)
                        [ ( "border", "1px solid rgb(0,0," ++ blueShade ++ ")" )
                        ]
                    )
                |> Dict.insert "rad-5"
                    (Style ".btn-rad-5"
                        [ ( "border-radius", "5px" )
                        ]
                    )
                |> Dict.insert "pad-5-10"
                    (Style ".btn-pad-5-10"
                        [ ( "padding", "5px 10px" )
                        ]
                    )
                |> Dict.insert "clr-white"
                    (Style (".btn-txt-" ++ blueShade)
                        [ ( "color", "rgb(" ++ blueShade ++ "," ++ blueShade ++ "," ++ blueShade ++ ")" )
                        ]
                    )
    in
    List.foldr blue Dict.empty (List.range s e)


{-| Now buttons have varying blue shades from blue 0 to blue 255.

We also do multiple insertions for each button. One that is similar to before and one that captures the blue color

-}
reducedLazyAllColorButtons : a -> String
reducedLazyAllColorButtons _ =
    let
        blue i accum =
            let
                blueShade =
                    toString (i % 255)
            in
            accum
                |> Dict.insert blueShade
                    (\_ ->
                        Style (".btn-" ++ blueShade)
                            [ ( "background-color", "rgb(0,0," ++ blueShade ++ ")" )
                            ]
                    )
                |> Dict.insert "button"
                    (\_ ->
                        Style ".btn"
                            [ ( "color", "white" )
                            , ( "border-radius", "5px" )
                            , ( "padding", "5px 10px" )
                            ]
                    )
    in
    List.foldr blue Dict.empty (List.range 1 buttonCount)
        |> Dict.values
        |> toLazyStyleSheet


toLazyStyleSheet styles =
    let
        renderProps ( name, val ) rendered =
            rendered ++ name ++ ":" ++ val ++ ";"

        toRuleString (Style selector props) =
            selector ++ " {" ++ List.foldl renderProps "" props ++ "}"
    in
    styles
        |> List.map (\x -> toRuleString <| x ())
        |> String.join "\n"


lazyReducedBlueButtons _ =
    let
        blue i accum =
            Dict.insert "button"
                (\_ ->
                    Style ".btn"
                        [ ( "background-color", "blue" )
                        , ( "color", "white" )
                        , ( "border-radius", "5px" )
                        , ( "padding", "5px 10px" )
                        ]
                )
                accum
    in
    List.foldr blue Dict.empty (List.range 1 buttonCount)
        |> Dict.values
        |> toLazyStyleSheet
