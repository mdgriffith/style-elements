module Main exposing (..)

{-
   How performant is it to dynamically render a stylesheet?

   Is it comparable to inline styles?

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy
import AnimationFrame
import Time exposing (Time)
import Murmur3
import Dict
import VirtualCss
import Next.Internal.Model as Next


type alias Model =
    { nodes : Int
    , skipped : Float
    , time : Float
    , total : Float
    , renderer : RenderConfig
    , frameTime : Float
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


type alias RenderConfig =
    { technique : Technique
    , color : Bool
    , translate : Bool
    , rotate : Bool
    , reducer : Reducer
    , names : Naming
    , lazy : Bool
    }


type Naming
    = Hashed
    | Indexed


model : Model
model =
    { nodes = 200
    , time = 0
    , total = 0
    , skipped = 0
    , renderer =
        { technique = InlineStyles
        , color = True
        , translate = True
        , rotate = True
        , reducer = NoReducer
        , names = Indexed
        , lazy = False
        }
    , frameTime = 16.66
    }


prime model =
    let
        primeStyle i =
            VirtualCss.insert ".test { color: blue; }" 0

        primed =
            List.map primeStyle (List.range 0 (model.nodes - 1))
    in
        model


reprime model newNodes =
    let
        delete i =
            VirtualCss.delete 0

        primeStyle i =
            VirtualCss.insert ".test { color: blue; }" 0

        del =
            List.map delete (List.range 0 (model.nodes - 1))

        primed =
            List.map primeStyle (List.range 0 (newNodes - 1))
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


update msg model =
    case msg of
        Set n ->
            let
                _ =
                    reprime model n
            in
                ( { model | nodes = n }, Cmd.none )

        ChangeRenderer n ->
            ( { model | renderer = n }, Cmd.none )

        Name naming ->
            let
                renderer =
                    model.renderer
            in
                ( { model
                    | renderer = { renderer | names = naming }
                  }
                , Cmd.none
                )

        SetReducer reducer ->
            let
                renderer =
                    model.renderer
            in
                ( { model
                    | renderer = { renderer | reducer = reducer }
                  }
                , Cmd.none
                )

        MakeLazy on ->
            let
                renderer =
                    model.renderer
            in
                ( { model
                    | renderer = { renderer | lazy = on }
                  }
                , Cmd.none
                )

        SetColor on ->
            let
                renderer =
                    model.renderer
            in
                ( { model
                    | renderer = { renderer | color = on }
                  }
                , Cmd.none
                )

        SetTranslate on ->
            let
                renderer =
                    model.renderer
            in
                ( { model
                    | renderer = { renderer | translate = on }
                  }
                , Cmd.none
                )

        SetRotate on ->
            let
                renderer =
                    model.renderer
            in
                ( { model
                    | renderer = { renderer | rotate = on }
                  }
                , Cmd.none
                )

        Tick time ->
            let
                filterStrength =
                    20

                newSkipped =
                    if model.time /= 0 && time - model.time > Time.millisecond * 18 then
                        (time - model.time)
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
                    /*will-chage: auto;*/

                }
                .style-no-bg {
                    width:10px;
                    height:10px;
                    margin-right: 10px;
                    margin-bottom: 10px;
                    /*contain: strict;*/
                    /*will-chage: auto;*/

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
        , case model.renderer.technique of
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
                      , (List.member model.renderer.technique
                            [ InlineStyles, CssAnimation ]
                        )
                      )
                    ]
                ]
                [ text "naming", text ": ", text (toString model.renderer.names) ]
            , div
                [ classList
                    [ ( "disabled"
                      , (List.member model.renderer.technique
                            [ InlineStyles, CssAnimation, UsingVirtualCss ]
                        )
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
                                ({ renderer
                                    | technique = ConcreteStyleSheet
                                 }
                                )
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
                                ({ renderer
                                    | technique = CssAnimation
                                 }
                                )
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
                                ({ renderer
                                    | technique = UsingVirtualCss
                                 }
                                )
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
                                ({ renderer
                                    | technique = VirtualCssTransformViaAnimation
                                 }
                                )
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
                                ({ renderer
                                    | technique = StyleElements
                                 }
                                )
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
            ]
        , div [ style [ ( "padding-top", "20px" ) ] ]
            [ label []
                [ input [ type_ "checkbox", checked model.renderer.lazy, onCheck MakeLazy ] []
                , text " lazy"
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
                        [ Next.width (Next.px 10)
                        , Next.height (Next.px 10)
                        , Next.style props
                        ]
                        Next.empty
            in
                Next.row
                    [ Next.width (Next.px 600)
                    , Next.style [ Next.prop "flex-wrap" "wrap", Next.prop "margin-top" "100px" ]
                    ]
                    (List.map el (List.range 0 (x - 1)))

        ( r, g, b ) =
            animateColor time

        pos =
            animatePosSin time

        props =
            List.filterMap identity
                [ Just <| Next.prop "margin-right" "10px"
                , Just <| Next.prop "margin-bottom" "10px"
                , if renderer.color then
                    Just <| Next.prop "background-color" ("rgb(" ++ toString r ++ ", " ++ toString g ++ ", " ++ toString b ++ ")")
                  else
                    Nothing
                , if renderer.translate || renderer.rotate then
                    Just <|
                        Next.prop "transform" <|
                            (String.join " " <|
                                [ if renderer.translate then
                                    ("translate(" ++ toString pos ++ "px, 0px)")
                                  else
                                    ""
                                , if renderer.rotate then
                                    ("rotate(" ++ toString pos ++ "deg)")
                                  else
                                    ""
                                ]
                            )
                  else
                    Nothing
                ]
    in
        -- if renderer.lazy then
        --     Html.Lazy.lazy fixed nodes
        -- else
        Next.layout <| fixed nodes


virtualCss time nodes renderer =
    let
        fixed x =
            let
                cls i =
                    case renderer.names of
                        Hashed ->
                            props
                                |> toString
                                |> Murmur3.hashString 8675309
                                |> toString
                                |> (\x -> "style-" ++ x)

                        Indexed ->
                            "virtual-css-" ++ toString i

                el i =
                    if renderer.color then
                        div [ class ("style-no-bg test " ++ cls i) ] []
                    else
                        div [ class ("style test " ++ cls i) ] []
            in
                div [ class "renderer" ]
                    (List.map el (List.range 0 (x - 1)))

        props =
            []
                |> addColor renderer time
                |> addTransform renderer time

        newStyle i =
            let
                cls =
                    case renderer.names of
                        Hashed ->
                            props
                                |> toString
                                |> Murmur3.hashString 8675309
                                |> toString
                                |> (\x -> "style-" ++ x)

                        Indexed ->
                            "virtual-css-" ++ toString i

                _ =
                    VirtualCss.delete i

                rendered =
                    renderStyle <| Style ("." ++ cls) props
            in
                VirtualCss.insert rendered i

        renderedCss =
            List.map newStyle (List.range 0 (nodes - 1))
    in
        if renderer.lazy then
            Html.Lazy.lazy fixed nodes
        else
            fixed nodes


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
                |> addColor renderer time

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
                [ class ("style test")
                , style
                    ([]
                        |> addColor renderer time
                        |> addTransform renderer time
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
        viewStyled renderer time i =
            let
                myStyleProps =
                    []
                        |> addColor renderer time
                        |> addTransform renderer time

                cls =
                    case renderer.names of
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
                        (List.range 0 (nodes - 1))
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
                        (List.range 0 (nodes - 1))
                            |> List.foldr combine ( Dict.empty, [] )
                            |> Tuple.mapFirst ((List.map (renderStyle << asStyle)) << Dict.toList)

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
        cls ++ "{" ++ (String.join "\n" (List.map renderProp props)) ++ "}"


type Style
    = Style String (List ( String, String ))


wrap : Int -> Int -> Int
wrap bound i =
    if i > bound then
        rem i bound
    else
        i


animateColor time =
    ( wrap 255 <| round <| ((sin (Time.inSeconds time) + 1) / 2) * 255
    , 151
    , 167
    )


animatePos time =
    (round <| Time.inSeconds time)
        |> toFloat
        |> (*) 300.0
        |> (+) 500.0
        |> (toFloat << wrap 800 << round)


animatePosSin time =
    Time.inSeconds time
        |> sin
        |> (*) 100.0
        |> (+) 200.0


addColor renderer time styleAttrs =
    let
        ( r, g, b ) =
            animateColor time
    in
        if renderer.color then
            ( "background-color", "rgb(" ++ toString r ++ ", " ++ toString g ++ ", " ++ toString b ++ ")" ) :: styleAttrs
        else
            styleAttrs


addTransform renderer time styleAttrs =
    let
        pos =
            animatePosSin time

        transforms =
            List.filterMap identity
                [ if renderer.translate then
                    Just ("translate(" ++ toString pos ++ "px, 0px)")
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
