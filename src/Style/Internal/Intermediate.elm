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


getProps : Prop class variation -> List ( String, String )
getProps prop =
    case prop of
        Props rendered ->
            rendered

        SubClass (Class myClass) ->
            List.concatMap getProps myClass.props

        PropsAndSub rendered (Class myClass) ->
            rendered ++ List.concatMap getProps myClass.props

        Animation ->
            []

        _ ->
            []


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



-- propertyHash :


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
        Class classRule ->
            List.map asString classRule.props
                |> String.concat

        Media mediaRule ->
            List.map asString mediaRule.props
                |> String.concat

        _ ->
            ""


applyGuard : String -> Class class variation -> Class class variation
applyGuard guardString class =
    let
        guardProp prop =
            case prop of
                SubClass sc ->
                    SubClass <| applyGuard guardString sc

                x ->
                    x
    in
    case class of
        Class cls ->
            Class
                { selector = Selector.guard guardString cls.selector
                , props = List.map guardProp cls.props
                }

        Media media ->
            Media
                { query = media.query
                , selector = Selector.guard guardString media.selector
                , props = List.map guardProp media.props
                }

        x ->
            x


asMediaQuery : String -> Prop class variation -> Prop class variation
asMediaQuery query prop =
    let
        classAsMediaQuery cls =
            case cls of
                Class classRule ->
                    Media
                        { query = query
                        , selector = classRule.selector
                        , props = classRule.props
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
        |> String.fromInt


{-| -}
render : Renderable -> String
render renderable =
    case renderable of
        RenderableClass selector styleProps ->
            selector ++ Css.brace 0 (String.join "\n" <| List.map (Css.prop 2) styleProps) ++ "\n"

        RenderableMedia query selector styleProps ->
            query ++ Css.brace 0 ("  " ++ selector ++ Css.brace 2 (String.join "\n" <| List.map (Css.prop 4) styleProps))

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
        Class classRule ->
            let
                ( rendered, subelements ) =
                    List.foldl renderableProps ( [], [] ) classRule.props
            in
            RenderableClass (Selector.render Nothing classRule.selector) rendered :: subelements

        Media mediaRule ->
            let
                ( rendered, subelements ) =
                    List.foldl renderableProps ( [], [] ) mediaRule.props
            in
            RenderableMedia mediaRule.query (Selector.render Nothing mediaRule.selector) rendered :: subelements

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
        Class classRule ->
            Selector.getFindable classRule.selector ++ List.concatMap findableProp classRule.props

        _ ->
            []
