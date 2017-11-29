module Internal.Model exposing (..)

{-| Implement style elements using as few calls as possible
-}

import Color exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Internal.Style
import Json.Encode as Json
import Regex
import Set exposing (Set)
import VirtualCss
import VirtualDom


type Element msg
    = Unstyled (Html msg)
    | Unresolved (List Style) NodeName (List (Html.Attribute msg)) (List (Html msg))


type NodeName
    = Generic
    | NodeName String
    | Embedded String String



-- In order to gain laziness, only constant position values can be passed to Html
-- | Almost (Position -> Html msg)


type alias Position =
    { alignment : SameAxisAlignment
    }


type SameAxisAlignment
    = NoAlignment
    | OnColumn HAlign
    | OnRow VAlign


type HAlign
    = AlignLeft
    | AlignRight
    | CenterX


type VAlign
    = AlignTop
    | AlignBottom
    | CenterY


type Style
    = Style String (List Property)
      --       class  prop   val
    | Single String String String
    | Colored String String Color
    | SpacingStyle Int Int
    | PaddingStyle Int Int Int Int


type Property
    = Property String String


type Attribute msg
    = Attr (Html.Attribute msg)
      -- invalidation key and literal class
    | Class String String
      -- invalidation key "border-color" as opposed to "border-color-10-10-10" that will be the key for the class
    | StyleClass Style
      -- Descriptions will add aria attributes and if the element is not a link, may set the node type.
    | Describe Description
    | Nearby Location (Element msg)
    | Move (Maybe Float) (Maybe Float) (Maybe Float)
    | Rotate Float Float Float Float
    | Scale (Maybe Float) (Maybe Float) (Maybe Float)
    | TextShadow
        { offset : ( Float, Float )
        , blur : Float
        , color : Color
        }
    | BoxShadow
        { inset : Bool
        , offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }
    | Filter FilterType
    | NoAttribute


type Description
    = Main
    | Navigation
      -- | Search
    | ContentInfo
    | Complementary
    | Heading Int
    | Label String
    | LivePolite
    | LiveAssertive


type FilterType
    = FilterUrl String
    | Blur Float
    | Brightness Float
    | Contrast Float
    | Grayscale Float
    | HueRotate Float
    | Invert Float
    | OpacityFilter Float
    | Saturate Float
    | Sepia Float
    | DropShadow
        { offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }


type Length
    = Px Float
    | Content
    | Expand
    | Fill Float


type Axis
    = XAxis
    | YAxis
    | AllAxis


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | Overlay


map : (msg -> msg1) -> Element msg -> Element msg1
map fn el =
    case el of
        Unresolved styles node attrs children ->
            Unresolved styles node (List.map (Html.Attributes.map fn) attrs) (List.map (Html.map fn) children)

        Unstyled html ->
            Unstyled (Html.map fn html)


mapAttr : (msg -> msg1) -> Attribute msg -> Attribute msg1
mapAttr fn attr =
    case attr of
        NoAttribute ->
            NoAttribute

        Describe description ->
            Describe description

        -- invalidation key "border-color" as opposed to "border-color-10-10-10" that will be the key for the class
        Class x y ->
            Class x y

        StyleClass style ->
            StyleClass style

        Nearby location element ->
            Nearby location (map fn element)

        Move x y z ->
            Move x y z

        Rotate x y z a ->
            Rotate x y z a

        Scale x y z ->
            Scale x y z

        Attr htmlAttr ->
            Attr (Html.Attributes.map fn htmlAttr)

        TextShadow shadow ->
            TextShadow shadow

        BoxShadow shadow ->
            BoxShadow shadow

        Filter filter ->
            Filter filter


class : String -> Attribute msg
class x =
    Class x x


{-| -}
embed : (a -> Element msg) -> a -> Html msg
embed fn a =
    case fn a of
        Unstyled html ->
            html

        Unresolved styles node attrs children ->
            renderNode node
                attrs
                (children ++ [ toStyleSheet styles ])


{-| -}
embed2 : (a -> b -> Element msg) -> a -> b -> Html msg
embed2 fn a b =
    case fn a b of
        Unstyled html ->
            html

        Unresolved styles node attrs children ->
            renderNode node
                attrs
                (children ++ [ toStyleSheet styles ])


styleKey : Style -> String
styleKey style =
    case style of
        Style class _ ->
            class

        Single _ prop _ ->
            prop

        Colored _ prop _ ->
            prop

        SpacingStyle _ _ ->
            "spacing"

        PaddingStyle _ _ _ _ ->
            "padding"


styleName : Style -> String
styleName style =
    case style of
        Style class _ ->
            class

        Single class _ _ ->
            class

        Colored class _ _ ->
            class

        SpacingStyle x y ->
            "spacing-" ++ toString x ++ "-" ++ toString y

        PaddingStyle top right bottom left ->
            "pad-"
                ++ toString top
                ++ "-"
                ++ toString right
                ++ "-"
                ++ toString bottom
                ++ "-"
                ++ toString left


addDot : Style -> Style
addDot style =
    case style of
        Style class props ->
            Style ("." ++ class) props

        Single class name val ->
            Single ("." ++ class) name val

        Colored class name val ->
            Colored ("." ++ class) name val

        SpacingStyle x y ->
            SpacingStyle x y

        PaddingStyle top right bottom left ->
            PaddingStyle top right bottom left


locationClass : Location -> String
locationClass location =
    case location of
        Above ->
            "se el above"

        Below ->
            "se el below"

        OnRight ->
            "se el on-right"

        OnLeft ->
            "se el on-left"

        Overlay ->
            "se el overlay"


renderNode node attrs children =
    case node of
        Generic ->
            VirtualDom.node "div" attrs children

        NodeName nodeName ->
            VirtualDom.node nodeName attrs children

        Embedded nodeName internal ->
            VirtualDom.node nodeName
                attrs
                [ VirtualDom.node internal [ Html.Attributes.class "se el" ] children ]


skip newValue old =
    case old of
        Nothing ->
            Just newValue

        x ->
            x


gatherAttributes : Attribute msg -> Gathered msg -> Gathered msg
gatherAttributes attr gathered =
    case attr of
        NoAttribute ->
            gathered

        Describe description ->
            case description of
                Main ->
                    { gathered | node = skip "main" gathered.node }

                Navigation ->
                    { gathered | node = skip "nav" gathered.node }

                -- Search ->
                --     { gathered | node = skip "main" gathered.node }
                ContentInfo ->
                    { gathered | node = skip "footer" gathered.node }

                Complementary ->
                    { gathered | node = skip "aside" gathered.node }

                Heading i ->
                    if i < 1 then
                        { gathered | node = skip "h1" gathered.node }
                    else if i < 7 then
                        { gathered | node = skip ("h" ++ toString i) gathered.node }
                    else
                        { gathered | node = skip "h6" gathered.node }

                Label label ->
                    { gathered | attributes = Html.Attributes.attribute "aria-label" label :: gathered.attributes }

                LivePolite ->
                    { gathered | attributes = Html.Attributes.attribute "aria-live" "polite" :: gathered.attributes }

                LiveAssertive ->
                    { gathered | attributes = Html.Attributes.attribute "aria-live" "assertive" :: gathered.attributes }

        Nearby location elem ->
            case elem of
                Unstyled html ->
                    { gathered
                        | nearbys =
                            VirtualDom.node "div" [ Html.Attributes.class (locationClass location) ] [ html ]
                                :: gathered.nearbys
                    }

                Unresolved styles node attrs children ->
                    { gathered
                        | rules = gathered.rules ++ styles
                        , nearbys =
                            VirtualDom.node "div"
                                [ Html.Attributes.class (locationClass location) ]
                                [ renderNode node attrs children
                                ]
                                :: gathered.nearbys
                    }

        StyleClass style ->
            { gathered
                | attributes = VirtualDom.property "className" (Json.string (styleName style)) :: gathered.attributes
                , rules = addDot style :: gathered.rules
                , has = Set.insert (styleKey style) gathered.has
            }

        Class key class ->
            if Set.member key gathered.has then
                gathered
            else
                { gathered
                    | attributes = VirtualDom.property "className" (Json.string class) :: gathered.attributes
                    , has = Set.insert key gathered.has
                }

        Attr attr ->
            { gathered | attributes = attr :: gathered.attributes }

        Move mx my mz ->
            -- add translate to the transform stack
            let
                addIfNothing val existing =
                    case existing of
                        Nothing ->
                            val

                        x ->
                            x

                translate =
                    case gathered.translation of
                        Nothing ->
                            Just
                                ( mx, my, mz )

                        Just ( existingX, existingY, existingZ ) ->
                            Just
                                ( addIfNothing mx existingX
                                , addIfNothing my existingY
                                , addIfNothing mz existingZ
                                )
            in
            { gathered | translation = translate }

        Filter filter ->
            case gathered.filters of
                Nothing ->
                    { gathered | filters = Just (filterName filter) }

                Just existing ->
                    { gathered | filters = Just (filterName filter ++ " " ++ existing) }

        BoxShadow shadow ->
            case gathered.boxShadows of
                Nothing ->
                    { gathered | boxShadows = Just (formatBoxShadow shadow) }

                Just existing ->
                    { gathered | boxShadows = Just (formatBoxShadow shadow ++ ", " ++ existing) }

        TextShadow shadow ->
            case gathered.textShadows of
                Nothing ->
                    { gathered | textShadows = Just (formatTextShadow shadow) }

                Just existing ->
                    { gathered | textShadows = Just (formatTextShadow shadow ++ ", " ++ existing) }

        Rotate x y z angle ->
            { gathered
                | rotation =
                    Just
                        ("rotate3d(" ++ toString x ++ "," ++ toString y ++ "," ++ toString z ++ "," ++ toString angle ++ "rad)")
            }

        Scale mx my mz ->
            -- add scale to the transform stack
            let
                addIfNothing val existing =
                    case existing of
                        Nothing ->
                            val

                        x ->
                            x

                scale =
                    case gathered.scale of
                        Nothing ->
                            Just
                                ( mx
                                , my
                                , mz
                                )

                        Just ( existingX, existingY, existingZ ) ->
                            Just
                                ( addIfNothing mx existingX
                                , addIfNothing my existingY
                                , addIfNothing mz existingZ
                                )
            in
            { gathered | scale = scale }


type alias Gathered msg =
    { attributes : List (Html.Attribute msg)
    , rules : List Style
    , nearbys : List (Html msg)
    , node : Maybe String
    , filters : Maybe String
    , boxShadows : Maybe String
    , textShadows : Maybe String
    , rotation : Maybe String
    , translation : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , scale : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , has : Set String
    }


pair =
    (,)


initGathered : Gathered msg
initGathered =
    { attributes = []
    , rules = []
    , node = Nothing
    , nearbys = []
    , rotation = Nothing
    , translation = Nothing
    , scale = Nothing
    , filters = Nothing
    , boxShadows = Nothing
    , textShadows = Nothing
    , has = Set.empty
    }


{-| -}
uncapitalize : String -> String
uncapitalize str =
    let
        head =
            String.left 1 str
                |> String.toLower

        tail =
            String.dropLeft 1 str
    in
    head ++ tail


{-| -}
className : String -> String
className x =
    x
        |> uncapitalize
        |> Regex.replace Regex.All (Regex.regex "[^a-zA-Z0-9_-]") (\_ -> "")
        |> Regex.replace Regex.All (Regex.regex "[A-Z0-9]+") (\{ match } -> " " ++ String.toLower match)
        |> Regex.replace Regex.All (Regex.regex "[\\s+]") (\_ -> "")


formatTransformations : Gathered msg -> Gathered msg
formatTransformations gathered =
    let
        translate =
            case gathered.translation of
                Nothing ->
                    Nothing

                Just ( x, y, z ) ->
                    Just
                        ("translate3d("
                            ++ toString (Maybe.withDefault 0 x)
                            ++ "px, "
                            ++ toString (Maybe.withDefault 0 y)
                            ++ "px, "
                            ++ toString (Maybe.withDefault 0 z)
                            ++ "px)"
                        )

        scale =
            case gathered.scale of
                Nothing ->
                    Nothing

                Just ( x, y, z ) ->
                    Just
                        ("scale3d("
                            ++ toString (Maybe.withDefault 0 x)
                            ++ "px, "
                            ++ toString (Maybe.withDefault 0 y)
                            ++ "px, "
                            ++ toString (Maybe.withDefault 0 z)
                            ++ "px)"
                        )

        transformations =
            [ scale, translate, gathered.rotation ]
                |> List.filterMap identity

        addTransform ( classes, styles ) =
            case transformations of
                [] ->
                    ( classes, styles )

                trans ->
                    let
                        transforms =
                            String.join " " trans

                        name =
                            "transform-" ++ className transforms
                    in
                    ( name :: classes
                    , Single ("." ++ name) "transform" transforms
                        :: styles
                    )

        addFilters ( classes, styles ) =
            case gathered.filters of
                Nothing ->
                    ( classes, styles )

                Just filter ->
                    let
                        name =
                            "filter-" ++ className filter
                    in
                    ( name :: classes
                    , Single ("." ++ name) "filter" filter
                        :: styles
                    )

        addBoxShadows ( classes, styles ) =
            case gathered.boxShadows of
                Nothing ->
                    ( classes, styles )

                Just shades ->
                    let
                        name =
                            "box-shadow-" ++ className shades
                    in
                    ( name :: classes
                    , Single ("." ++ name) "box-shadow" shades
                        :: styles
                    )

        addTextShadows ( classes, styles ) =
            case gathered.textShadows of
                Nothing ->
                    ( classes, styles )

                Just shades ->
                    let
                        name =
                            "text-shadow-" ++ className shades
                    in
                    ( name :: classes
                    , Single ("." ++ name) "text-shadow" shades
                        :: styles
                    )
    in
    let
        ( classes, styles ) =
            ( [], gathered.rules )
                |> addFilters
                |> addBoxShadows
                |> addTextShadows
                |> addTransform
    in
    { gathered
        | attributes = Html.Attributes.class (String.join " " classes) :: gathered.attributes
        , rules =
            styles
    }


toStyleSheetNoReduction : List Style -> VirtualDom.Node msg
toStyleSheetNoReduction styles =
    let
        renderProps (Property key val) existing =
            existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

        renderStyle selector props =
            selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"

        combine style rendered =
            case style of
                Style selector props ->
                    rendered ++ "\n" ++ renderStyle selector props

                Single class prop val ->
                    rendered ++ class ++ "{" ++ prop ++ ":" ++ val ++ "}\n"

                Colored class prop color ->
                    rendered ++ class ++ "{" ++ prop ++ ":" ++ formatColor color ++ "}\n"

                SpacingStyle x y ->
                    ""

                PaddingStyle top right bottom left ->
                    ""
    in
    List.foldl combine "" styles
        |> (\rendered -> VirtualDom.node "style" [] [ Html.text rendered ])


toStyleSheetVirtualCss : List Style -> ()
toStyleSheetVirtualCss stylesheet =
    case stylesheet of
        [] ->
            ()

        styles ->
            let
                renderProps (Property key val) existing =
                    existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

                renderStyle selector props =
                    selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"

                _ =
                    VirtualCss.clear ()

                combine style cache =
                    case style of
                        Style selector props ->
                            let
                                _ =
                                    VirtualCss.insert (renderStyle selector props) 0
                            in
                            cache

                        Single class prop val ->
                            if Set.member class cache then
                                cache
                            else
                                let
                                    _ =
                                        VirtualCss.insert (class ++ "{" ++ prop ++ ":" ++ val ++ "}") 0
                                in
                                Set.insert class cache

                        Colored class prop color ->
                            if Set.member class cache then
                                cache
                            else
                                let
                                    _ =
                                        VirtualCss.insert (class ++ "{" ++ prop ++ ":" ++ formatColor color ++ "}") 0
                                in
                                Set.insert class cache

                        SpacingStyle x y ->
                            let
                                class =
                                    ".spacing-" ++ toString x ++ "-" ++ toString y
                            in
                            if Set.member class cache then
                                cache
                            else
                                -- TODO!
                                cache

                        -- ( rendered ++ spacingClasses class x y
                        -- , Set.insert class cache
                        -- )
                        PaddingStyle top right bottom left ->
                            let
                                class =
                                    ".pad-"
                                        ++ toString top
                                        ++ "-"
                                        ++ toString right
                                        ++ "-"
                                        ++ toString bottom
                                        ++ "-"
                                        ++ toString left
                            in
                            if Set.member class cache then
                                cache
                            else
                                -- TODO!
                                cache

                -- ( rendered ++ paddingClasses class top right bottom left
                -- , Set.insert class cache
                -- )
            in
            List.foldl combine Set.empty styles
                |> always ()


toStyleSheet : List Style -> VirtualDom.Node msg
toStyleSheet stylesheet =
    case stylesheet of
        [] ->
            Html.text ""

        styles ->
            let
                renderProps (Property key val) existing =
                    existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

                renderStyle selector props =
                    selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"

                combine style ( rendered, cache ) =
                    case style of
                        Style selector props ->
                            ( rendered ++ "\n" ++ renderStyle selector props
                            , cache
                            )

                        Single class prop val ->
                            if Set.member class cache then
                                ( rendered, cache )
                            else
                                ( rendered ++ class ++ "{" ++ prop ++ ":" ++ val ++ "}\n"
                                , Set.insert class cache
                                )

                        Colored class prop color ->
                            if Set.member class cache then
                                ( rendered, cache )
                            else
                                ( rendered ++ class ++ "{" ++ prop ++ ":" ++ formatColor color ++ "}\n"
                                , Set.insert class cache
                                )

                        SpacingStyle x y ->
                            let
                                class =
                                    ".spacing-" ++ toString x ++ "-" ++ toString y
                            in
                            if Set.member class cache then
                                ( rendered, cache )
                            else
                                ( rendered ++ spacingClasses class x y
                                , Set.insert class cache
                                )

                        PaddingStyle top right bottom left ->
                            let
                                class =
                                    ".pad-"
                                        ++ toString top
                                        ++ "-"
                                        ++ toString right
                                        ++ "-"
                                        ++ toString bottom
                                        ++ "-"
                                        ++ toString left
                            in
                            if Set.member class cache then
                                ( rendered, cache )
                            else
                                ( rendered ++ paddingClasses class top right bottom left
                                , Set.insert class cache
                                )
            in
            List.foldl combine ( "", Set.empty ) styles
                |> Tuple.first
                |> (\rendered -> VirtualDom.node "style" [] [ Html.text rendered ])


spacingClasses class x y =
    let
        renderProps (Property key val) existing =
            existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

        renderStyle selector props =
            selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"

        merge ( selector, props ) existing =
            existing ++ "\n" ++ renderStyle selector props
    in
    List.foldl merge
        ""
        [ pair (class ++ ".row > .se") [ Property "margin-left" (toString x ++ "px") ]
        , pair (class ++ ".row > .se:first-child") [ Property "margin-left" "0" ]
        , pair (class ++ ".column > .se") [ Property "margin-top" (toString y ++ "px") ]
        , pair (class ++ ".column > .se:first-child") [ Property "margin-top" "0" ]
        , pair (class ++ ".page > .se") [ Property "margin-top" (toString y ++ "px") ]
        , pair (class ++ ".page > .se:first-child") [ Property "margin-top" "0" ]
        , pair (class ++ ".page > .self-left") [ Property "margin-right" (toString x ++ "px") ]
        , pair (class ++ ".page > .self-right") [ Property "margin-left" (toString x ++ "px") ]
        , pair (class ++ ".grid")
            [ Property "grid-column-gap" (toString x ++ "px")
            , Property "grid-row-gap" (toString y ++ "px")
            ]
        ]


paddingClasses class top right bottom left =
    let
        renderProps (Property key val) existing =
            existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

        renderStyle selector props =
            selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"

        merge ( selector, props ) existing =
            existing ++ "\n" ++ renderStyle selector props
    in
    List.foldl merge
        ""
        [ pair class
            [ Property "padding"
                (toString top
                    ++ "px "
                    ++ toString right
                    ++ "px "
                    ++ toString bottom
                    ++ "px "
                    ++ toString left
                    ++ "px"
                )
            ]
        , pair (class ++ ".el > .se.width-expand")
            [ Property "width" ("calc(100% + " ++ toString (left + right) ++ "px)")
            , Property "margin-left" (toString (negate left) ++ "px")
            ]
        , pair (class ++ ".column > .se.width-expand")
            [ Property "width" ("calc(100% + " ++ toString (left + right) ++ "px)")
            , Property "margin-left" (toString (negate left) ++ "px")
            ]
        , pair (class ++ ".row > .se.width-expand:first-child")
            [ Property "width" ("calc(100% + " ++ toString left ++ "px)")
            , Property "margin-left" (toString (negate left) ++ "px")
            ]
        , pair (class ++ ".row > .se.width-expand:last-child")
            [ Property "width" ("calc(100% + " ++ toString right ++ "px)")
            , Property "margin-right" (toString (negate right) ++ "px")
            ]
        , pair (class ++ ".row.has-nearby > .se.width-expand::nth-last-child(2)")
            [ Property "width" ("calc(100% + " ++ toString right ++ "px)")
            , Property "margin-right" (toString (negate right) ++ "px")
            ]
        , pair (class ++ ".page > .se.width-expand:first-child")
            [ Property "width" ("calc(100% + " ++ toString (left + right) ++ "px)")
            , Property "margin-left" (toString (negate left) ++ "px")
            ]
        , pair (class ++ ".el > .se.height-expand")
            [ Property "height" ("calc(100% + " ++ toString (top + bottom) ++ "px)")
            , Property "margin-top" (toString (negate top) ++ "px")
            ]
        , pair (class ++ ".row > .se.height-expand")
            [ Property "height" ("calc(100% + " ++ toString (top + bottom) ++ "px)")
            , Property "margin-top" (toString (negate top) ++ "px")
            ]
        , pair (class ++ ".column > .se.height-expand:first-child")
            [ Property "height" ("calc(100% + " ++ toString top ++ "px)")
            , Property "margin-top" (toString (negate top) ++ "px")
            ]
        , pair (class ++ ".column > .se.height-expand:last-child")
            [ Property "height" ("calc(100% + " ++ toString bottom ++ "px)")
            , Property "margin-bottom" (toString (negate bottom) ++ "px")
            ]
        , pair (class ++ ".column.has-nearby > .se.height-expand::nth-last-child(2)")
            [ Property "height" ("calc(100% + " ++ toString bottom ++ "px)")
            , Property "margin-bottom" (toString (negate bottom) ++ "px")
            ]
        , pair (class ++ ".page > .se.height-expand:first-child")
            [ Property "height" ("calc(100% + " ++ toString top ++ "px)")
            , Property "margin-top" (toString (negate top) ++ "px")
            ]
        , pair (class ++ ".page > .se.height-expand:last-child")
            [ Property "height" ("calc(100% + " ++ toString bottom ++ "px)")
            , Property "margin-bottom" (toString (negate bottom) ++ "px")
            ]
        , pair (class ++ ".page > .se.height-expand::nth-last-child(2)")
            [ Property "height" ("calc(100% + " ++ toString bottom ++ "px)")
            , Property "margin-bottom" (toString (negate bottom) ++ "px")
            ]
        ]


formatDropShadow : { d | blur : a, color : Color, offset : ( b, c ) } -> String
formatDropShadow shadow =
    String.join " "
        [ toString (Tuple.first shadow.offset) ++ "px"
        , toString (Tuple.second shadow.offset) ++ "px"
        , toString shadow.blur ++ "px"
        , formatColor shadow.color
        ]


formatTextShadow : { d | blur : a, color : Color, offset : ( b, c ) } -> String
formatTextShadow shadow =
    String.join " "
        [ toString (Tuple.first shadow.offset) ++ "px"
        , toString (Tuple.second shadow.offset) ++ "px"
        , toString shadow.blur ++ "px"
        , formatColor shadow.color
        ]


formatBoxShadow : { e | blur : a, color : Color, inset : Bool, offset : ( b, c ), size : d } -> String
formatBoxShadow shadow =
    String.join " " <|
        List.filterMap identity
            [ if shadow.inset then
                Just "inset"
              else
                Nothing
            , Just <| toString (Tuple.first shadow.offset) ++ "px"
            , Just <| toString (Tuple.second shadow.offset) ++ "px"
            , Just <| toString shadow.blur ++ "px"
            , Just <| toString shadow.size ++ "px"
            , Just <| formatColor shadow.color
            ]


filterName filtr =
    case filtr of
        FilterUrl url ->
            "url(" ++ url ++ ")"

        Blur x ->
            "blur(" ++ toString x ++ "px)"

        Brightness x ->
            "brightness(" ++ toString x ++ "%)"

        Contrast x ->
            "contrast(" ++ toString x ++ "%)"

        Grayscale x ->
            "grayscale(" ++ toString x ++ "%)"

        HueRotate x ->
            "hueRotate(" ++ toString x ++ "deg)"

        Invert x ->
            "invert(" ++ toString x ++ "%)"

        OpacityFilter x ->
            "opacity(" ++ toString x ++ "%)"

        Saturate x ->
            "saturate(" ++ toString x ++ "%)"

        Sepia x ->
            "sepia(" ++ toString x ++ "%)"

        DropShadow shadow ->
            let
                shadowModel =
                    { offset = shadow.offset
                    , size = shadow.size
                    , blur = shadow.blur
                    , color = shadow.color
                    }
            in
            "drop-shadow(" ++ formatDropShadow shadowModel ++ ")"


floatClass : Float -> String
floatClass x =
    toString <| round (x * 100)


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


formatColorClass : Color -> String
formatColorClass color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    toString red
        ++ "-"
        ++ toString green
        ++ "-"
        ++ toString blue
        ++ "-"
        ++ floatClass alpha


renderAttributes : List (Attribute msg) -> List Style -> ( Maybe String, List (Html.Attribute msg), List Style, Maybe (List (Html msg)) )
renderAttributes attributes styleChildren =
    case attributes of
        [] ->
            ( Nothing
            , []
            , styleChildren
            , Nothing
            )

        attrs ->
            List.foldr gatherAttributes { initGathered | rules = styleChildren } attrs
                |> formatTransformations
                |> (\{ rules, attributes, nearbys, node } ->
                        case nearbys of
                            [] ->
                                ( node
                                , attributes
                                , rules
                                , Nothing
                                )

                            additionalChildren ->
                                ( node
                                , attributes
                                , rules
                                , Just additionalChildren
                                )
                   )


render : Maybe String -> List (Attribute msg) -> List (Element msg) -> Element msg
render nodeName attributes children =
    let
        ( htmlChildren, styleChildren ) =
            List.foldr gather ( [], [] ) children

        gather child ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    ( html :: htmls, existingStyles )

                Unresolved styles node attrs children ->
                    ( renderNode node attrs children :: htmls
                    , styles ++ existingStyles
                    )

        ( nodeNameOverride, renderedAttributes, renderedRules, additionalChildren ) =
            renderAttributes attributes styleChildren
    in
    case renderedRules of
        [] ->
            Unstyled <|
                renderNode
                    (case nodeName of
                        Nothing ->
                            case nodeNameOverride of
                                Nothing ->
                                    Generic

                                Just override ->
                                    NodeName override

                        Just node ->
                            case nodeNameOverride of
                                Nothing ->
                                    NodeName node

                                Just override ->
                                    Embedded node override
                    )
                    renderedAttributes
                    (case additionalChildren of
                        Nothing ->
                            htmlChildren

                        Just additional ->
                            htmlChildren
                                ++ [ VirtualDom.node "div" [ VirtualDom.property "className" (Json.string "se el nearby") ] additional ]
                    )

        _ ->
            Unresolved renderedRules
                (case nodeName of
                    Nothing ->
                        case nodeNameOverride of
                            Nothing ->
                                Generic

                            Just override ->
                                NodeName override

                    Just node ->
                        case nodeNameOverride of
                            Nothing ->
                                NodeName node

                            Just override ->
                                Embedded node override
                )
                renderedAttributes
                (case additionalChildren of
                    Nothing ->
                        htmlChildren

                    Just additional ->
                        htmlChildren
                            ++ [ VirtualDom.node "div" [ VirtualDom.property "className" (Json.string "se el nearby") ] additional ]
                )


type RenderMode
    = Viewport
    | Layout
    | NoStaticStyleSheet
    | WithVirtualCss
    | Unreduced


{-| -}
renderHtml : RenderMode -> List (Attribute msg) -> List (Element msg) -> Html msg
renderHtml mode attributes children =
    let
        ( htmlChildren, styleChildren ) =
            List.foldr gather ( [], [] ) children

        gather child ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    ( html :: htmls, existingStyles )

                Unresolved styles node attrs children ->
                    ( renderNode node attrs children :: htmls
                    , styles ++ existingStyles
                    )

        ( nodeName, renderedAttributes, renderedRules, additionalChildren ) =
            renderAttributes attributes styleChildren

        styleSheets children =
            case mode of
                NoStaticStyleSheet ->
                    toStyleSheet renderedRules :: children

                Layout ->
                    Internal.Style.rulesElement
                        :: toStyleSheet renderedRules
                        :: children

                Viewport ->
                    Internal.Style.viewportRulesElement
                        :: toStyleSheet renderedRules
                        :: children

                Unreduced ->
                    Internal.Style.rulesElement
                        :: toStyleSheetNoReduction renderedRules
                        :: children

                WithVirtualCss ->
                    let
                        _ =
                            toStyleSheetVirtualCss renderedRules
                    in
                    Internal.Style.rulesElement
                        :: children
    in
    VirtualDom.node (Maybe.withDefault "div" nodeName) renderedAttributes <|
        case additionalChildren of
            Nothing ->
                styleSheets htmlChildren

            Just additional ->
                styleSheets <|
                    htmlChildren
                        ++ [ VirtualDom.node "div"
                                [ VirtualDom.property "className" (Json.string "se el nearby") ]
                                additional
                           ]


htmlClass : String -> Attribute msg
htmlClass cls =
    Attr <| VirtualDom.property "className" (Json.string cls)
