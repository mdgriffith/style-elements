module Style.Internal.Intermediate exposing (..)

{-| -}

import Murmur3
import Style.Internal.Find as Findable
import Style.Internal.Render.Css as Css
import Style.Internal.Selector as Selector exposing (Selector)


type Class class variation
    = Class
        { selector : Selector class variation
        , props : List (Prop class variation)
        }
    | Media
        { query : String
        , selector : Selector class variation
        , props : List (Prop class variation)
        }
    | Free String


type Prop class variation
    = Props (List ( String, String ))
    | SubClass (Class class variation)
    | PropsAndSub (List ( String, String )) (Class class variation)
    | Animation


type Renderable
    = RenderableClass String (List ( String, String ))
    | RenderableMedia String String (List ( String, String ))
    | RenderableFree String


props : List ( String, String ) -> Prop class variation
props =
    Props


type Rendered class variation
    = Rendered
        { css : String
        , findable : List (Findable.Element class variation)
        }


raw : Class class variation -> ( String, String )
raw cls =
    let
        topName =
            case cls of
                Class { selector } ->
                    Selector.topName selector

                Media { selector } ->
                    Selector.topName selector

                Free _ ->
                    ""
    in
    ( topName
    , cls
        |> makeRenderable
        |> List.map render
        |> String.join "\n"
    )


finalize : List (Class class variation) -> Rendered class variation
finalize intermediates =
    let
        finalizeCss cls =
            makeRenderable cls
                |> List.map render
                |> String.join "\n"
    in
    Rendered
        { css =
            intermediates
                |> List.map finalizeCss
                |> String.join "\n"
        , findable =
            List.concatMap asFindable intermediates
        }


guard : Class class variation -> Class class variation
guard class =
    applyGuard (hash <| calculateGuard class) class


calculateGuard : Class class variation -> String
calculateGuard class =
    let
        propToString ( x, y ) =
            x ++ y

        asString prop =
            case prop of
                Props ps ->
                    String.concat <| List.map propToString ps

                SubClass embedded ->
                    calculateGuard embedded

                PropsAndSub ps embedded ->
                    (String.concat <| List.map propToString ps) ++ calculateGuard embedded

                Animation ->
                    ""
    in
    case class of
        Class { props } ->
            List.map asString props
                |> String.concat

        Media { props } ->
            List.map asString props
                |> String.concat

        _ ->
            ""


applyGuard : String -> Class class variation -> Class class variation
applyGuard guard class =
    let
        guardProp prop =
            case prop of
                SubClass sc ->
                    SubClass <| applyGuard guard sc

                x ->
                    x
    in
    case class of
        Class cls ->
            Class
                { selector = Selector.guard guard cls.selector
                , props = List.map guardProp cls.props
                }

        Media media ->
            Media
                { query = media.query
                , selector = Selector.guard guard media.selector
                , props = List.map guardProp media.props
                }

        x ->
            x


asMediaQuery : String -> Prop class variation -> Prop class variation
asMediaQuery query prop =
    let
        classAsMediaQuery cls =
            case cls of
                Class { selector, props } ->
                    Media
                        { query = query
                        , selector = selector
                        , props = props
                        }

                x ->
                    x
    in
    case prop of
        SubClass cls ->
            SubClass (classAsMediaQuery cls)

        PropsAndSub x cls ->
            PropsAndSub x (classAsMediaQuery cls)

        x ->
            x


{-| -}
hash : String -> String
hash value =
    Murmur3.hashString 8675309 value
        |> toString


{-| -}
render : Renderable -> String
render renderable =
    case renderable of
        RenderableClass selector props ->
            selector ++ Css.brace 0 (String.join "\n" <| List.map (Css.prop 2) props) ++ "\n"

        RenderableMedia query selector props ->
            query ++ Css.brace 0 ("  " ++ selector ++ Css.brace 2 (String.join "\n" <| List.map (Css.prop 4) props))

        RenderableFree str ->
            str


makeRenderable : Class class variation -> List Renderable
makeRenderable cls =
    let
        renderableProps prop ( rendered, subEls ) =
            case prop of
                Props ps ->
                    ( rendered ++ ps
                    , subEls
                    )

                SubClass embedded ->
                    ( rendered
                    , subEls ++ makeRenderable embedded
                    )

                PropsAndSub ps embedded ->
                    ( rendered ++ ps
                    , subEls ++ makeRenderable embedded
                    )

                Animation ->
                    ( rendered, subEls )
    in
    case cls of
        Class { selector, props } ->
            let
                ( rendered, subelements ) =
                    List.foldl renderableProps ( [], [] ) props
            in
            RenderableClass (Selector.render Nothing selector) rendered :: subelements

        Media { query, selector, props } ->
            let
                ( rendered, subelements ) =
                    List.foldl renderableProps ( [], [] ) props
            in
            RenderableMedia query (Selector.render Nothing selector) rendered :: subelements

        Free str ->
            [ RenderableFree str ]


{-| -}
asFindable : Class class variation -> List (Findable.Element class variation)
asFindable intermediate =
    let
        findableProp prop =
            case prop of
                SubClass cls ->
                    asFindable cls

                PropsAndSub _ cls ->
                    asFindable cls

                _ ->
                    []
    in
    case intermediate of
        Class { selector, props } ->
            Selector.getFindable selector ++ List.concatMap findableProp props

        _ ->
            []
