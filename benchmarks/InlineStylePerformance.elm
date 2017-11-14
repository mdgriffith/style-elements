module Main exposing (..)

{-
   How performant is it to dynamically render a stylesheet?

   Is it comparable to inline styles?

-}

import AnimationFrame
import Color
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy
import Murmur3
import Next.Inline.Element as Next
import Next.Inline.Element.Content as Content
import Next.Inline.Element.Position as Position
import Next.Inline.Style.Color as Color
import Set
import Time exposing (Time)
import VirtualCss


type alias Model =
    { nodes : Int
    , skipped : Float
    , time : Float
    , total : Float
    , renderer : RenderConfig
    , frameTime : Float
    , refreshFrame : Refresh
    }


type Technique
    = InlineStyles
    | ConcreteStyleSheet
    | CssAnimation
    | UsingVirtualCss
    | VirtualCssTransformViaAnimation
    | StyleElements


type Reducer
    = NoReducer
    | DictReducer
    | CheatReducer


type alias RenderConfig =
    { technique : Technique
    , color : Bool
    , translate : Bool
    , rotate : Bool
    , reducer : Reducer
    , names : Naming
    , lazy : Bool
    , independent : Bool
    }


type Refresh
    = RefreshNow
    | RefreshTime Time
    | Continue


type Naming
    = Hashed
    | Indexed
    | Encoded



-- | Encoded


model : Model
model =
    { nodes = 500
    , time = 0
    , total = 0
    , skipped = 0
    , refreshFrame = Continue
    , renderer =
        { technique = InlineStyles
        , color = True
        , translate = True
        , rotate = True
        , reducer = NoReducer
        , names = Indexed
        , lazy = False
        , independent = True
        }

    -- { technique = UsingVirtualCss
    -- , color = True
    -- , translate = True
    -- , rotate = True
    -- , reducer = NoReducer
    -- , names = Indexed
    -- , lazy = False
    -- , independent = False
    -- }
    -- { technique = UsingVirtualCss
    -- , color = True
    -- , translate = True
    -- , rotate = True
    -- , reducer = DictReducer
    -- , names = Encoded
    -- , lazy = False
    -- , independent = True
    -- }
    -- { technique = UsingVirtualCss
    -- , color = True
    -- , translate = True
    -- , rotate = True
    -- , reducer = DictReducer
    -- , names = Encoded
    -- , lazy = False
    -- , independent = False
    -- }
    , frameTime = 16.66
    }


prime model =
    let
        primeStyle i =
            VirtualCss.insert ".test { color: blue; }" 0

        primed =
            List.map primeStyle (List.range 0 (model.nodes * 2))
    in
    model


reprime model newNodes =
    let
        delete i =
            VirtualCss.delete 0

        primeStyle i =
            VirtualCss.insert ".test { color: blue; }" 0

        del =
            List.map delete (List.range 0 (model.nodes * 2))

        primed =
            List.map primeStyle (List.range 0 (newNodes * 2))
    in
    model


primeOne model =
    let
        primeStyle =
            VirtualCss.insert ".test { color: blue; }" 0
    in
    model


main : Program Never Model Msg
main =
    Html.program
        { init =
            ( prime model, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> AnimationFrame.times Tick
        }


type Msg
    = Tick Time
    | Set Int
    | ChangeRenderer RenderConfig
    | SetColor Bool
    | SetRotate Bool
    | SetTranslate Bool
    | Name Naming
    | MakeLazy Bool
    | SetReducer Reducer
    | MakeIndependent Bool


update msg model =
    let
        refreshed =
            { model | refreshFrame = RefreshNow }
    in
    case msg of
        Tick time ->
            let
                filterStrength =
                    20

                newSkipped =
                    if model.time /= 0 && time - model.time > Time.millisecond * 18 then
                        time - model.time
                    else
                        0

                newTotal =
                    if model.time == 0 then
                        0
                    else
                        model.total + (time - model.time)

                currentFrameTime =
                    if model.time == 0 then
                        16.66
                    else
                        time - model.time
            in
            ( { model
                | time = time
                , total = newTotal
                , skipped = model.skipped + newSkipped
                , frameTime = model.frameTime + ((currentFrameTime - model.frameTime) / filterStrength)
                , refreshFrame =
                    case model.refreshFrame of
                        RefreshNow ->
                            RefreshTime (time + Time.inSeconds 0.5)

                        Continue ->
                            Continue

                        RefreshTime revert ->
                            if time > revert then
                                Continue
                            else
                                model.refreshFrame
              }
            , Cmd.none
            )

        Set n ->
            let
                _ =
                    reprime model n
            in
            ( { refreshed | nodes = n }, Cmd.none )

        ChangeRenderer n ->
            ( { refreshed | renderer = n }, Cmd.none )

        Name naming ->
            let
                renderer =
                    model.renderer
            in
            ( { refreshed
                | renderer = { renderer | names = naming }
              }
            , Cmd.none
            )

        SetReducer reducer ->
            let
                renderer =
                    model.renderer
            in
            ( { refreshed
                | renderer = { renderer | reducer = reducer }
              }
            , Cmd.none
            )

        MakeLazy on ->
            let
                renderer =
                    model.renderer
            in
            ( { refreshed
                | renderer = { renderer | lazy = on }
              }
            , Cmd.none
            )

        MakeIndependent on ->
            let
                renderer =
                    model.renderer
            in
            ( { refreshed
                | renderer = { renderer | independent = on }
              }
            , Cmd.none
            )

        SetColor on ->
            let
                renderer =
                    model.renderer
            in
            ( { refreshed
                | renderer = { renderer | color = on }
              }
            , Cmd.none
            )

        SetTranslate on ->
            let
                renderer =
                    model.renderer
            in
            ( { refreshed
                | renderer = { renderer | translate = on }
              }
            , Cmd.none
            )

        SetRotate on ->
            let
                renderer =
                    model.renderer
            in
            ( { refreshed
                | renderer = { renderer | rotate = on }
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ Html.node "style"
            []
            [ text """
                .column {
                    display: flex;
                    flex: 1;
                    flex-direction: column;
                }
                .disabled {
                    color:red;
                    text-decoration: line-through;
                }
                .renderer {
                    display: flex;
                    flex: 1 row;
                    flex-wrap: wrap;
                    width: 600px;
                    margin-top: 100px;
                }
                .style {
                    background-color:rgb(0,151,167);
                    width:10px;
                    height:10px;
                    margin-right: 10px;
                    margin-bottom: 10px;
                    /*contain: strict;*/
                    /* will-change: transform, opacity, background-color; */
                    /*will-chage: auto;*/

                }
                .style-no-bg {
                    width:10px;
                    height:10px;
                    margin-right: 10px;
                    margin-bottom: 10px;
                    /*contain: strict;*/
                    /*will-chage: auto;*/
                    /* will-change: transform, opacity, background-color; */

                }
                .blue {
                    background-color: blue;
                }
                .stats{
                    width:400px;
                    position:absolute;
                    right:200px;
                    top:20px;
                }
                .move-it {
                    animation: 4s linear 0s infinite alternate move;
                }
                .move-it-color {
                    animation: 4s linear 0s infinite alternate move-and-color;
                }
                @keyframes move {
                    0% {
                        transform: translateX(100px) rotate(0deg);
                    }
                    100% {
                        transform: translateX(300px) rotate(270deg);
                    }
                }
                @keyframes move-and-color {
                    0% {
                        background-color: rgb(0,151,167);
                        transform: translateX(100px) rotate(0deg);
                    }
                    100% {
                        background-color: #FF4136;
                        transform: translateX(300px) rotate(270deg);
                    }
                }
                """ ]
        , viewStats model
        , if model.refreshFrame /= Continue then
            Html.div [ Html.Attributes.style [ ( "background-color", "red" ), ( "width", "100%" ), ( "height", "100%" ) ] ] [ Html.text "REFRESH" ]
          else
            case model.renderer.technique of
                InlineStyles ->
                    inlineRenderer model.time model.nodes model.renderer

                ConcreteStyleSheet ->
                    concreteStylesheet model.time model.nodes model.renderer

                CssAnimation ->
                    cssAnimationRenderer model.nodes model.renderer

                UsingVirtualCss ->
                    virtualCss model.time model.nodes model.renderer

                VirtualCssTransformViaAnimation ->
                    virtualCssTransformViaAnimation model.time model.nodes model.renderer

                StyleElements ->
                    styleElements model.time model.nodes model.renderer
        ]


viewStats : Model -> Html Msg
viewStats model =
    div [ class "stats" ]
        [ div [] [ text "avg fps" ]
        , div [] [ text <| toString <| round (1000 / model.frameTime) ]
        , div [ style [ ( "padding-top", "20px" ) ] ]
            [ text ("Number of nodes: " ++ toString model.nodes) ]
        , div []
            [ button [ onClick (Set 10) ] [ text "10 Nodes" ]
            , button [ onClick (Set 50) ] [ text "50 Nodes" ]
            , button [ onClick (Set 100) ] [ text "100 Nodes" ]
            , button [ onClick (Set 200) ] [ text "200 Nodes" ]
            , button [ onClick (Set 300) ] [ text "250 Nodes" ]
            , button [ onClick (Set 300) ] [ text "300 Nodes" ]
            , button [ onClick (Set 400) ] [ text "400 Nodes" ]
            , button [ onClick (Set 500) ] [ text "500 Nodes" ]
            , button [ onClick (Set 1000) ] [ text "1000 Nodes" ]
            , button [ onClick (Set 1500) ] [ text "1500 Nodes" ]
            ]
        , div [ style [ ( "padding-top", "20px" ) ] ]
            [ div [] [ text "technique", text ": ", text (toString model.renderer.technique) ]
            , div [] [ text "colors", text ": ", text (toString model.renderer.color) ]
            , div [] [ text "translate", text ": ", text (toString model.renderer.translate) ]
            , div [] [ text "rotate", text ": ", text (toString model.renderer.rotate) ]
            , div
                [ classList
                    [ ( "disabled"
                      , List.member model.renderer.technique
                            [ InlineStyles, CssAnimation ]
                      )
                    ]
                ]
                [ text "naming", text ": ", text (toString model.renderer.names) ]
            , div
                [ classList
                    [ ( "disabled"
                      , List.member model.renderer.technique
                            [ InlineStyles, CssAnimation, UsingVirtualCss ]
                      )
                    ]
                ]
                [ text "reducer", text ": ", text (toString model.renderer.reducer) ]
            ]
        , let
            renderer =
                model.renderer
          in
          div [ class "column", style [ ( "padding-top", "20px" ) ] ]
            [ label []
                [ input
                    [ type_ "radio"
                    , name "renderer"
                    , checked (model.renderer.technique == InlineStyles)
                    , onClick
                        (ChangeRenderer
                            { renderer
                                | technique = InlineStyles
                            }
                        )
                    ]
                    []
                , text "Inline"
                ]
            , label []
                [ input
                    [ type_ "radio"
                    , name "renderer"
                    , checked (model.renderer.technique == ConcreteStyleSheet)
                    , onClick
                        (ChangeRenderer
                            { renderer
                                | technique = ConcreteStyleSheet
                            }
                        )
                    ]
                    []
                , text "Concrete Stylesheet"
                ]
            , label []
                [ input
                    [ type_ "radio"
                    , name "renderer"
                    , checked (model.renderer.technique == CssAnimation)
                    , onClick
                        (ChangeRenderer
                            { renderer
                                | technique = CssAnimation
                            }
                        )
                    ]
                    []
                , text "CssAnimation"
                ]
            , label []
                [ input
                    [ type_ "radio"
                    , name "renderer"
                    , checked (model.renderer.technique == UsingVirtualCss)
                    , onClick
                        (ChangeRenderer
                            { renderer
                                | technique = UsingVirtualCss
                            }
                        )
                    ]
                    []
                , text "VirtualCSS"
                ]
            , label []
                [ input
                    [ type_ "radio"
                    , name "renderer"
                    , checked (model.renderer.technique == VirtualCssTransformViaAnimation)
                    , onClick
                        (ChangeRenderer
                            { renderer
                                | technique = VirtualCssTransformViaAnimation
                            }
                        )
                    ]
                    []
                , text "VirtualCSS - Color(VCSS), Translate(Animation)"
                ]
            , label []
                [ input
                    [ type_ "radio"
                    , name "renderer"
                    , checked (model.renderer.technique == StyleElements)
                    , onClick
                        (ChangeRenderer
                            { renderer
                                | technique = StyleElements
                            }
                        )
                    ]
                    []
                , text "Style Elements (v5)"
                ]
            ]
        , div [ style [ ( "padding-top", "20px" ) ] ]
            [ label []
                [ input [ type_ "checkbox", checked model.renderer.color, onCheck SetColor ] []
                , text " color"
                ]
            , label []
                [ input [ type_ "checkbox", checked model.renderer.translate, onCheck SetTranslate ] []
                , text " translate"
                ]
            , label []
                [ input [ type_ "checkbox", checked model.renderer.rotate, onCheck SetRotate ] []
                , text " rotate"
                ]
            ]
        , div [ class "column", style [ ( "padding-top", "20px" ) ] ]
            [ label []
                [ input [ type_ "radio", name "naming strategy", checked (model.renderer.names == Indexed), onClick (Name Indexed) ] []
                , text " indexed"
                ]
            , label []
                [ input [ type_ "radio", name "naming strategy", checked (model.renderer.names == Hashed), onClick (Name Hashed) ] []
                , text " hashed"
                ]
            , label []
                [ input [ type_ "radio", name "naming strategy", checked (model.renderer.names == Encoded), onClick (Name Encoded) ] []
                , text " encoded"
                ]
            ]
        , div [ class "column", style [ ( "padding-top", "20px" ) ] ]
            [ label []
                [ input [ type_ "radio", name "reducing-strategy", checked (model.renderer.reducer == NoReducer), onClick (SetReducer NoReducer) ] []
                , text " no reducer"
                ]
            , label []
                [ input [ type_ "radio", name "reducing-strategy", checked (model.renderer.reducer == DictReducer), onClick (SetReducer DictReducer) ] []
                , text " dict reducer"
                ]
            , label []
                [ input [ type_ "radio", name "reducing-strategy", checked (model.renderer.reducer == CheatReducer), onClick (SetReducer CheatReducer) ] []
                , text " cheat reducer"
                ]
            ]
        , div [ style [ ( "padding-top", "20px" ) ] ]
            [ label []
                [ input [ type_ "checkbox", checked model.renderer.lazy, onCheck MakeLazy ] []
                , text " lazy"
                ]
            ]
        , div [ style [ ( "padding-top", "20px" ) ] ]
            [ label []
                [ input [ type_ "checkbox", checked model.renderer.independent, onCheck MakeIndependent ] []
                , text " indepedent"
                ]
            ]
        ]



{- Rendering Strategies -}


styleElements time nodes renderer =
    let
        fixed x =
            let
                el i =
                    Next.el
                        ([ Next.width (Next.px 10)
                         , Next.height (Next.px 10)
                         ]
                            ++ props
                        )
                        Next.empty
            in
            Next.row
                [ Next.width (Next.px 600)
                , Content.paddingAll 100
                , Content.spacing 10
                ]
                (List.map el (List.range 0 (x - 1)))

        ( r, g, b ) =
            animateColor time 0

        pos =
            animatePosSin time 0

        props =
            List.filterMap identity
                [ if renderer.color then
                    Just <| Color.background (Color.rgb r g b)
                  else
                    Nothing
                , if renderer.translate then
                    Just <| Position.moveRight pos
                  else
                    Nothing
                , if renderer.rotate then
                    Just <| Position.rotate pos
                  else
                    Nothing
                ]
    in
    -- if renderer.lazy then
    --     Html.Lazy.lazy fixed nodes
    -- else
    Next.layout []
        (fixed nodes)


virtualCss : Float -> Int -> { a | lazy : Bool, color : Bool, independent : Bool, names : Naming, reducer : Reducer, rotate : Bool, translate : Bool } -> Html msg
virtualCss time nodes renderer =
    let
        refresh i cls props =
            let
                _ =
                    VirtualCss.delete i
            in
            VirtualCss.insert (renderStyle <| Style ("." ++ cls) props) i

        reduceAndInsertStyles ( html, styles ) =
            case renderer.reducer of
                DictReducer ->
                    let
                        combine ( cls, props ) ( styleI, cache ) =
                            if Set.member cls cache then
                                ( styleI, cache )
                            else
                                let
                                    _ =
                                        refresh styleI cls props
                                in
                                ( styleI + 1, Set.insert cls cache )
                    in
                    List.foldr combine ( 0, Set.empty ) styles
                        |> (Debug.log "total styles" << Tuple.first)
                        |> always html

                CheatReducer ->
                    let
                        _ =
                            List.indexedMap (\i ( cls, props ) -> refresh i cls props) styles
                    in
                    html

                NoReducer ->
                    let
                        _ =
                            List.indexedMap (\i ( cls, props ) -> refresh i cls props) styles
                    in
                    html
    in
    if renderer.lazy && renderer.names == Indexed then
        -- Html.Lazy.lazy2 createNodesLazy renderer nodes
        createStyledNodes renderer nodes time
            |> reduceAndInsertStyles
    else
        createStyledNodes renderer nodes time
            |> reduceAndInsertStyles


createStyledNodes : { a | color : Bool, names : Naming, reducer : Reducer, independent : Bool, rotate : Bool, translate : Bool } -> Int -> Float -> ( Html msg, List ( String, List ( String, String ) ) )
createStyledNodes renderer count time =
    let
        buildStyle i =
            case renderer.names of
                Encoded ->
                    encodedProps renderer time (toFloat i)

                Hashed ->
                    let
                        class =
                            []
                                |> addColor renderer time (toFloat i)
                                |> addTransform renderer time (toFloat i)
                                |> toString
                                |> Murmur3.hashString 8675309
                                |> toString
                                |> (\x -> "style-" ++ x)
                    in
                    ( class
                    , [ ( class
                        , []
                            |> addColor renderer time (toFloat i)
                            |> addTransform renderer time (toFloat i)
                        )
                      ]
                    )

                Indexed ->
                    let
                        name =
                            "virtual-css-" ++ toString i
                    in
                    ( name
                    , [ ( name
                        , []
                            |> addColor renderer time (toFloat i)
                            |> addTransform renderer time (toFloat i)
                        )
                      ]
                    )

        el myClass =
            if renderer.color then
                div [ class ("style-no-bg test " ++ myClass) ] []
            else
                div [ class ("style test " ++ myClass) ] []

        addElement i ( html, styles ) =
            let
                ( class, newStyles ) =
                    buildStyle i
            in
            ( el class :: html
            , newStyles ++ styles
            )

        ( htmls, styles ) =
            List.foldr addElement ( [], [] ) (List.range 0 (count - 1))
    in
    ( div [ class "renderer" ]
        htmls
    , styles
    )


virtualCssTransformViaAnimation time nodes renderer =
    let
        fixed x =
            let
                el i =
                    if renderer.color then
                        div [ class ("style-no-bg test move-it virtual-css-" ++ toString i) ] []
                    else
                        div [ class ("style test move-it virtual-css-" ++ toString i) ] []
            in
            div [ class "renderer" ]
                (List.map el (List.range 0 (x - 1)))

        props =
            []
                |> addColor renderer time 0

        newStyle i =
            let
                _ =
                    VirtualCss.delete i

                rendered =
                    renderStyle <| Style (".virtual-css-" ++ toString i) props
            in
            VirtualCss.insert rendered i

        renderedCss =
            List.map newStyle (List.range 0 (nodes - 1))
    in
    if renderer.lazy then
        Html.Lazy.lazy fixed nodes
    else
        fixed nodes


inlineRenderer time nodes renderer =
    let
        viewInline time i =
            div
                [ class "style test"
                , style
                    ([]
                        |> addColor renderer time i
                        |> addTransform renderer time i
                    )
                ]
                []
    in
    div [ class "renderer" ]
        (List.map (viewInline time << toFloat) (List.range 0 (nodes - 1)))


cssAnimationRenderer nodes renderer =
    let
        el =
            let
                styleCls =
                    if renderer.color then
                        "style blue test move-it-color"
                    else
                        "style blue test move-it"
            in
            div [ class styleCls ] []
    in
    if renderer.lazy then
        Html.Lazy.lazy
            (\n ->
                div [ class "renderer" ]
                    (List.repeat n el)
            )
            nodes
    else
        div [ class "renderer" ]
            (List.repeat nodes el)


concreteStylesheet time nodes renderer =
    let
        myStyleProps =
            []
                |> addColor renderer time 0
                |> addTransform renderer time 0

        viewStyled renderer time i =
            let
                cls =
                    case renderer.names of
                        Encoded ->
                            myStyleProps
                                |> toString
                                |> Murmur3.hashString 8675309
                                |> toString
                                |> (\x -> "style-" ++ x)

                        Hashed ->
                            myStyleProps
                                |> toString
                                |> Murmur3.hashString 8675309
                                |> toString
                                |> (\x -> "style-" ++ x)

                        Indexed ->
                            "concrete-style-" ++ toString i
            in
            ( Style ("." ++ cls)
                myStyleProps
            , div [ class ("style test " ++ cls) ] []
            )

        ( allStyles, renderedNodes ) =
            case renderer.reducer of
                CheatReducer ->
                    let
                        combine i ( stylesheet, ns ) =
                            let
                                ( style, node ) =
                                    viewStyled renderer time i
                            in
                            ( renderStyle style :: stylesheet
                            , node :: ns
                            )
                    in
                    List.range 0 (nodes - 1)
                        |> List.foldr combine ( [], [] )

                NoReducer ->
                    let
                        combine i ( stylesheet, ns ) =
                            let
                                ( style, node ) =
                                    viewStyled renderer time i
                            in
                            ( renderStyle style :: stylesheet
                            , node :: ns
                            )
                    in
                    List.range 0 (nodes - 1)
                        |> List.foldr combine ( [], [] )

                DictReducer ->
                    let
                        combine i ( stylesheet, ns ) =
                            let
                                ( Style cls props, node ) =
                                    viewStyled renderer time i
                            in
                            ( Dict.insert cls props stylesheet
                            , node :: ns
                            )
                    in
                    List.range 0 (nodes - 1)
                        |> List.foldr combine ( Dict.empty, [] )
                        |> Tuple.mapFirst (List.map (renderStyle << asStyle) << Dict.toList)

        stylesheet =
            node "style"
                []
                [ text (String.join "\n" allStyles) ]
    in
    div [ class "renderer" ]
        (stylesheet :: renderedNodes)


asStyle ( cls, props ) =
    Style cls props


renderStyle (Style cls props) =
    let
        renderProp ( name, val ) =
            "  " ++ name ++ ": " ++ val ++ ";"
    in
    cls ++ "{" ++ String.join "\n" (List.map renderProp props) ++ "}"


type Style
    = Style String (List ( String, String ))


wrap : Int -> Int -> Int
wrap bound i =
    if i > bound then
        rem i bound
    else
        i


animateColor time i =
    ( wrap 255 <| round <| ((sin (Time.inSeconds (time + i)) + 1) / 2) * 255
    , 151
    , 167
    )


animatePos time i =
    (round <| Time.inSeconds time)
        |> toFloat
        |> (*) 300.0
        |> (+) 500.0
        |> (toFloat << wrap 800 << round)


animatePosSin time i =
    Time.inSeconds (time + i)
        |> sin
        |> (*) 100.0
        |> (+) 200.0


encodedPropsSingle : { a | color : Bool, independent : Bool, translate : Bool, rotate : Bool } -> Float -> Float -> ( String, List ( String, List ( String, String ) ) )
encodedPropsSingle renderer time i =
    let
        ( r, g, b ) =
            animateColor time
                (if renderer.independent then
                    i
                 else
                    0
                )

        pos =
            animatePosSin time
                (if renderer.independent then
                    i
                 else
                    0
                )

        encoding =
            (String.join "-" << List.filterMap identity)
                [ if renderer.color then
                    Just <| String.join "-" [ "bc", toString r, toString g, toString b ]
                  else
                    Nothing
                , if renderer.translate || renderer.rotate then
                    Just <|
                        (String.join "-" <|
                            [ if renderer.translate then
                                "tr-" ++ toString (round (pos * 100)) ++ "px-0px"
                              else
                                ""
                            , if renderer.rotate then
                                "rt" ++ toString (round (pos * 100)) ++ "d"
                              else
                                ""
                            ]
                        )
                  else
                    Nothing
                ]

        props =
            List.filterMap identity
                [ if renderer.color then
                    Just <| ( "background-color", "rgb(" ++ toString r ++ ", " ++ toString g ++ ", " ++ toString b ++ ")" )
                  else
                    Nothing
                , if renderer.translate || renderer.rotate then
                    Just <|
                        ( "transform"
                        , String.join " " <|
                            [ if renderer.translate then
                                "translate(" ++ toString pos ++ "px, 0px)"
                              else
                                ""
                            , if renderer.rotate then
                                "rotate(" ++ toString pos ++ "deg)"
                              else
                                ""
                            ]
                        )
                  else
                    Nothing
                ]
    in
    ( encoding
    , [ ( encoding, props ) ]
    )


encodedProps : { a | color : Bool, independent : Bool, translate : Bool, rotate : Bool } -> Float -> Float -> ( String, List ( String, List ( String, String ) ) )
encodedProps renderer time i =
    let
        ( colorCls, colors ) =
            if renderer.color then
                let
                    ( r, g, b ) =
                        animateColor time
                            (if renderer.independent then
                                i
                             else
                                0
                            )

                    clsName =
                        String.join "-" [ "bc", toString r, toString g, toString b ]
                in
                ( clsName
                , Just <|
                    ( clsName
                    , [ ( "background-color", "rgb(" ++ toString r ++ ", " ++ toString g ++ ", " ++ toString b ++ ")" ) ]
                    )
                )
            else
                ( "", Nothing )

        ( transformCls, transforms ) =
            if renderer.translate || renderer.rotate then
                let
                    pos =
                        animatePosSin time
                            (if renderer.independent then
                                i
                             else
                                0
                            )

                    name =
                        String.join "-" <|
                            [ if renderer.translate then
                                "tr-" ++ toString (round (pos * 100)) ++ "px-0px"
                              else
                                ""
                            , if renderer.rotate then
                                "rt-" ++ toString (round (pos * 100)) ++ "d"
                              else
                                ""
                            ]
                in
                ( name
                , Just <|
                    ( name
                    , [ ( "transform"
                        , String.join " " <|
                            [ if renderer.translate then
                                "translate(" ++ toString pos ++ "px, 0px)"
                              else
                                ""
                            , if renderer.rotate then
                                "rotate(" ++ toString pos ++ "deg)"
                              else
                                ""
                            ]
                        )
                      ]
                    )
                )
            else
                ( "", Nothing )
    in
    ( colorCls ++ " " ++ transformCls
    , List.filterMap identity [ colors, transforms ]
    )


addColor renderer time i styleAttrs =
    let
        ( r, g, b ) =
            animateColor time
                (if renderer.independent then
                    i
                 else
                    0
                )
    in
    if renderer.color then
        ( "background-color", "rgb(" ++ toString r ++ ", " ++ toString g ++ ", " ++ toString b ++ ")" ) :: styleAttrs
    else
        styleAttrs


addTransform renderer time i styleAttrs =
    let
        pos =
            animatePosSin time
                (if renderer.independent then
                    i
                 else
                    0
                )

        transforms =
            List.filterMap identity
                [ if renderer.translate then
                    Just ("translate3d(" ++ toString pos ++ "px, 0px, 0px)")
                  else
                    Nothing
                , if renderer.rotate then
                    Just ("rotate(" ++ toString pos ++ "deg)")
                  else
                    Nothing
                ]
    in
    if List.isEmpty transforms then
        styleAttrs
    else
        ( "transform"
        , String.join " " transforms
        )
            :: styleAttrs
