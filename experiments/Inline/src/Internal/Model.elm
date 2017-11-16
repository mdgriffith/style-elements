module Internal.Model exposing (..)

import Color exposing (Color)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes
import Html.Lazy
import Internal.Style
import Regex
import Set


type Styled msg
    = Styled (List Style) (Html msg)


type Style
    = Style String (List Property)
    | Keyed String (List ( String, List Property ))


type Property
    = Property String String


type Element msg
    = Empty
    | Spacer Float
    | Text Decoration String
    | El String (List (Attribute msg)) (Element msg)
    | Row String (List (Attribute msg)) (List (Element msg))
    | Column String (List (Attribute msg)) (List (Element msg))
    | Grid String (List (Attribute msg)) (List (Element msg))
    | Page (List (Attribute msg)) (List (Element msg))
    | Paragraph (List (Attribute msg)) (List (Element msg))
    | Raw (Html msg)
    | Nearby
        { anchor : Element msg
        , nearby : List ( Location, Element msg )
        }


type Decoration
    = NoDecoration -- renders as <span>
    | RawText --renders as raw text


type Attribute msg
    = SingletonStyle String String String
    | Opacity Float
    | Height Length
    | Width Length
    | ContentXAlign HorizontalAlign
    | ContentYAlign VerticalAlign
    | SelfXAlign HorizontalAlign
    | SelfYAlign VerticalAlign
    | Move (Maybe Float) (Maybe Float) (Maybe Float)
    | Rotate Float Float Float Float
    | Scale (Maybe Float) (Maybe Float) (Maybe Float)
    | Spacing Float
    | SpacingXY Float Float
    | Padding
        { top : Float
        , left : Float
        , bottom : Float
        , right : Float
        }
    | Attr (Html.Attribute msg)
    | Overflow Axis
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


class =
    Attr << Html.Attributes.class


mapAttr fn attr =
    case attr of
        SingletonStyle x y z ->
            SingletonStyle x y z

        Opacity o ->
            Opacity o

        Height len ->
            Height len

        Width len ->
            Width len

        ContentXAlign align ->
            ContentXAlign align

        ContentYAlign align ->
            ContentYAlign align

        SelfXAlign align ->
            SelfXAlign align

        SelfYAlign align ->
            SelfYAlign align

        Move x y z ->
            Move x y z

        Rotate x y z a ->
            Rotate x y z a

        Scale x y z ->
            Scale x y z

        Spacing space ->
            Spacing space

        SpacingXY x y ->
            SpacingXY x y

        Padding pad ->
            Padding pad

        Attr htmlAttr ->
            Attr (Html.Attributes.map fn htmlAttr)

        Overflow axis ->
            Overflow axis

        TextShadow shadow ->
            TextShadow shadow

        BoxShadow shadow ->
            BoxShadow shadow

        Filter filter ->
            Filter filter


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


type Font
    = Serif
    | SansSerif
    | Monospace
    | Typeface String
    | ImportFont String String


type Length
    = Px Float
    | Content
    | Expand
    | Fill Float


type HorizontalAlign
    = AlignLeft
    | AlignRight
    | XCenter
    | Spread


type VerticalAlign
    = AlignTop
    | AlignBottom
    | YCenter
    | VerticalJustify


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


addAttrs : List (Attribute msg) -> Element msg -> Element msg
addAttrs additional element =
    case element of
        Empty ->
            El "div" additional Empty

        Spacer pixels ->
            element

        Text dec str ->
            El "div" additional element

        El node attrs child ->
            El node (additional ++ attrs) child

        Row node attrs children ->
            Row node (additional ++ attrs) children

        Column node attrs children ->
            Column node (additional ++ attrs) children

        Grid name attrs children ->
            Grid name (additional ++ attrs) children

        Page attrs children ->
            Page (additional ++ attrs) children

        Paragraph attrs children ->
            Paragraph (additional ++ attrs) children

        Raw html ->
            El "div" additional element

        Nearby close ->
            Nearby { close | anchor = addAttrs additional close.anchor }


{-| -}
type alias GridPosition msg =
    { start : ( Int, Int )
    , width : Int
    , height : Int
    , content : Element msg
    }


type OnGrid el
    = OnGrid el


type NamedOnGrid el
    = NamedOnGrid el



-- gridPosition { start, width, height } =
--     let
--         ( x, y ) =
--             start
--         ( rowStart, rowEnd ) =
--             ( y + 1, y + 1 + height )
--         ( colStart, colEnd ) =
--             ( x + 1, x + 1 + width )
--     in
--     StyleProperty "grid-area"
--         (String.join " / "
--             [ toString rowStart
--             , toString colStart
--             , toString rowEnd
--             , toString colEnd
--             ]
--         )
-- gridTemplate : { a | columns : List Length, rows : List Length } -> List (Attribute msg)
-- gridTemplate { rows, columns } =
--     let
--         renderLen len =
--             case len of
--                 Px x ->
--                     toString x ++ "px"
--                 Expand ->
--                     "100%"
--                 Content ->
--                     "auto"
--                 Fill i ->
--                     toString i ++ "fr"
--     in
--     [ StyleProperty "grid-template-rows"
--         (String.join " " (List.map renderLen rows))
--     , StyleProperty "grid-template-columns"
--         (String.join " " (List.map renderLen columns))
--     ]


{-| -}
type alias GridTemplate msg =
    { rows : List Length
    , columns : List Length
    , cells : List (OnGrid (Element msg))
    }



-- {-| -}
-- grid : List (Attribute msg) -> GridTemplate msg -> Element msg
-- grid attrs template =
--     Grid "div" (gridTemplate template ++ attrs) (List.map (\(OnGrid cell) -> cell) template.cells)
-- cell : GridPosition msg -> OnGrid (Element msg)
-- cell box =
--     let
--         coords =
--             gridPosition
--                 { start = box.start
--                 , width = box.width
--                 , height = box.height
--                 }
--     in
--     OnGrid <| addAttrs [ coords ] box.content


nearby : Location -> Element msg -> Element msg -> Element msg
nearby position placed anchoringElement =
    case anchoringElement of
        Nearby { anchor, nearby } ->
            Nearby
                { anchor = anchor
                , nearby = ( position, placed ) :: nearby
                }

        _ ->
            Nearby
                { anchor = anchoringElement
                , nearby = [ ( position, placed ) ]
                }


toStyleSheet : List Style -> String
toStyleSheet styles =
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

                Keyed key styles ->
                    if Set.member key cache then
                        ( rendered, cache )
                    else
                        let
                            merge ( selector, props ) existing =
                                existing ++ "\n" ++ renderStyle selector props
                        in
                        ( List.foldl merge rendered styles, Set.insert key cache )
    in
    List.foldl combine ( "", Set.empty ) styles
        |> Tuple.first


viewportStylesheet =
    """html, body {
        height: 100%;
        width: 100%;
}

"""


staticSheet : Html msg
staticSheet =
    Html.node "style" [] [ Html.text Internal.Style.rules ]


viewportSheet =
    Html.node "style" [] [ Html.text (viewportStylesheet ++ Internal.Style.rules) ]


{-| -}
render : List (Element msg) -> Element msg -> Styled msg
render addedChildren el =
    case el of
        Empty ->
            Styled [] (Html.text "")

        Text decoration content ->
            let
                ( otherChildrenStyles, renderedOtherChildren ) =
                    renderChildren addedChildren
            in
            case decoration of
                RawText ->
                    -- This isn't exposed in a public API, but is only used internally when raw text is needed
                    -- (mostly for Element.Input output)
                    Styled [] (Html.text content)

                NoDecoration ->
                    Styled otherChildrenStyles <|
                        Html.div [ Html.Attributes.class "se text width-fill" ]
                            (Html.text content :: renderedOtherChildren)

        Spacer pixels ->
            let
                spacings =
                    [ Style (".row > .spacer-" ++ toString pixels)
                        [ Property "width" (toString pixels ++ "px")
                        , Property "height" "0px"
                        ]
                    , Style (".column > .spacer-" ++ toString pixels)
                        [ Property "height" (toString pixels ++ "px")
                        , Property "width" "0px"
                        ]
                    ]
            in
            Styled spacings
                (Html.node "span"
                    [ Html.Attributes.class ("spacer-" ++ toString pixels) ]
                    []
                )

        El name attributes child ->
            renderStyled name attributes [ child ] addedChildren "se el"

        Row name attributes children ->
            renderStyled name attributes children addedChildren "se row"

        Column name attributes children ->
            renderStyled name attributes children addedChildren "se column"

        Grid name attributes children ->
            renderStyled name attributes children addedChildren "se grid"

        Page attributes children ->
            renderStyled "div" attributes children addedChildren "se page"

        Paragraph attributes children ->
            renderStyled "p" attributes children addedChildren "se paragraph"

        Nearby { anchor, nearby } ->
            render (List.map positionNearby nearby) anchor

        Raw html ->
            Styled [] html


positionNearby : ( Location, Element msg ) -> Element msg
positionNearby ( location, element ) =
    case location of
        Above ->
            El "div" [ Attr (Html.Attributes.class "above") ] element

        Below ->
            El "div" [ Attr (Html.Attributes.class "below") ] element

        OnRight ->
            El "div" [ Attr (Html.Attributes.class "on-right") ] element

        OnLeft ->
            El "div" [ Attr (Html.Attributes.class "on-left") ] element

        Overlay ->
            El "div" [ Attr (Html.Attributes.class "overlay") ] element


type alias Gathered msg =
    { attributes : List (Html.Attribute msg)
    , styleProperties : List Property
    , rules : List Style
    , filters : Maybe String
    , boxShadows : Maybe String
    , textShadows : Maybe String
    , rotation : Maybe String
    , translation : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , scale : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , hasWidth : Bool
    , hasHeight : Bool
    , hasPadding : Bool
    , hasXContentAlign : Bool
    , hasYContentAlign : Bool
    , hasXSelfAlign : Bool
    , hasYSelfAlign : Bool
    , hasSpacing : Bool
    }


pair =
    (,)


initGathered =
    { attributes = []
    , styleProperties = []
    , rules = []
    , hasPadding = False
    , rotation = Nothing
    , translation = Nothing
    , scale = Nothing
    , filters = Nothing
    , boxShadows = Nothing
    , textShadows = Nothing
    , hasWidth = False
    , hasHeight = False
    , hasXContentAlign = False
    , hasYContentAlign = False
    , hasXSelfAlign = False
    , hasYSelfAlign = False
    , hasSpacing = False
    }



-- renderStyledSlim : String -> List (Attribute msg) -> List (Element msg) -> Styled msg
-- renderStyledSlim name attributes children =
--     let
--         ( childrenStyles, renderedChildren ) =
--             renderChildren children
--         rendered =
--             attributes
--                 |> List.foldr gatherAttributes initGathered
--                 |> formatTransformations
--     in
--     Styled (rendered.rules ++ childrenStyles ++ otherChildrenStyles)
--         (Html.node name
--             (Html.Attributes.class additionalClass :: rendered.attributes)
--             (renderedChildren ++ renderedOtherChildren)
--         )


renderStyled : String -> List (Attribute msg) -> List (Element msg) -> List (Element msg) -> String -> Styled msg
renderStyled name attributes children otherChildren additionalClass =
    let
        ( childrenStyles, renderedChildren ) =
            renderChildren children

        ( otherChildrenStyles, renderedOtherChildren ) =
            renderChildren otherChildren

        rendered =
            attributes
                |> List.foldr gatherAttributes initGathered
                |> formatTransformations
    in
    Styled (rendered.rules ++ childrenStyles ++ otherChildrenStyles)
        (Html.node name
            (Html.Attributes.class additionalClass :: rendered.attributes)
            (renderedChildren ++ renderedOtherChildren)
        )


renderChildren : List (Element msg) -> ( List Style, List (Html msg) )
renderChildren children =
    let
        ( childrenStyles, renderedChildren ) =
            List.foldr renderStyleList ( [], [] ) children

        renderStyleList child ( renderedStyles, renderedEls ) =
            let
                (Styled styles el) =
                    render [] child
            in
            ( styles ++ renderedStyles
            , el :: renderedEls
            )
    in
    ( childrenStyles, renderedChildren )


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
                    , Keyed name
                        [ pair ("." ++ name) [ Property "transform" transforms ]
                        ]
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
                    , Keyed name
                        [ pair ("." ++ name) [ Property "filter" filter ]
                        ]
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
                    , Keyed name
                        [ pair ("." ++ name) [ Property "box-shadow" shades ]
                        ]
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
                    , Keyed name
                        [ pair ("." ++ name) [ Property "text-shadow" shades ]
                        ]
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


gatherAttributes : Attribute msg -> Gathered msg -> Gathered msg
gatherAttributes attr gathered =
    case attr of
        SingletonStyle class name val ->
            { gathered
                | attributes = Html.Attributes.class class :: gathered.attributes
                , rules =
                    Keyed class
                        [ pair ("." ++ class) [ Property name val ]
                        ]
                        :: gathered.rules
            }

        Height len ->
            if gathered.hasHeight then
                gathered
            else
                case len of
                    Px px ->
                        let
                            class =
                                "height-px-" ++ floatClass px
                        in
                        { gathered
                            | attributes = Html.Attributes.class class :: gathered.attributes
                            , hasHeight = True
                            , rules =
                                Keyed class
                                    [ pair ("." ++ class) [ Property "height" (toString px ++ "px") ]
                                    ]
                                    :: gathered.rules
                        }

                    Content ->
                        { gathered
                            | styleProperties = Property "height" "auto" :: gathered.styleProperties
                            , hasHeight = True
                        }

                    Expand ->
                        { gathered
                            | attributes = Html.Attributes.class "expand-height" :: gathered.attributes
                            , hasHeight = True
                        }

                    Fill portion ->
                        { gathered
                            | attributes = Html.Attributes.class "height-fill" :: gathered.attributes
                            , hasHeight = True
                        }

        Width len ->
            if gathered.hasWidth then
                gathered
            else
                case len of
                    Px px ->
                        -- add width: Xpx to current style
                        let
                            class =
                                "width-px-" ++ floatClass px
                        in
                        { gathered
                            | attributes = Html.Attributes.class class :: gathered.attributes
                            , hasWidth = True
                            , rules =
                                Keyed class
                                    [ pair ("." ++ class) [ Property "width" (toString px ++ "px") ]
                                    ]
                                    :: gathered.rules
                        }

                    Content ->
                        { gathered
                            | attributes = Html.Attributes.class "width-content" :: gathered.attributes
                            , hasWidth = True
                        }

                    Expand ->
                        { gathered
                            | attributes = Html.Attributes.class "expand-width" :: gathered.attributes
                            , hasWidth = True
                        }

                    Fill portion ->
                        { gathered
                            | attributes = Html.Attributes.class "width-fill" :: gathered.attributes
                            , hasWidth = True
                        }

        ContentXAlign alignment ->
            if gathered.hasXContentAlign then
                gathered
            else
                case alignment of
                    AlignLeft ->
                        { gathered
                            | attributes = Html.Attributes.class "content-left" :: gathered.attributes
                            , hasXContentAlign = True
                        }

                    AlignRight ->
                        { gathered
                            | attributes =
                                Html.Attributes.class "content-right" :: gathered.attributes
                            , hasXContentAlign = True
                        }

                    XCenter ->
                        { gathered
                            | attributes = Html.Attributes.class "content-center-x" :: gathered.attributes
                            , hasXContentAlign = True
                        }

                    Spread ->
                        { gathered
                            | attributes = Html.Attributes.class "spread" :: gathered.attributes
                            , hasXContentAlign = True
                        }

        ContentYAlign alignment ->
            if gathered.hasYContentAlign then
                gathered
            else
                case alignment of
                    AlignTop ->
                        { gathered
                            | attributes = Html.Attributes.class "content-top" :: gathered.attributes
                            , hasYContentAlign = True
                        }

                    AlignBottom ->
                        { gathered
                            | attributes = Html.Attributes.class "content-bottom" :: gathered.attributes
                            , hasYContentAlign = True
                        }

                    YCenter ->
                        { gathered
                            | attributes = Html.Attributes.class "content-center-y" :: gathered.attributes
                            , hasYContentAlign = True
                        }

                    VerticalJustify ->
                        { gathered
                            | attributes = Html.Attributes.class "vertical-justify" :: gathered.attributes
                            , hasYContentAlign = True
                        }

        SelfXAlign alignment ->
            if gathered.hasXSelfAlign then
                gathered
            else
                case alignment of
                    AlignLeft ->
                        { gathered
                            | attributes = Html.Attributes.class "self-left" :: gathered.attributes
                            , hasXSelfAlign = True
                        }

                    AlignRight ->
                        { gathered
                            | attributes = Html.Attributes.class "self-right" :: gathered.attributes
                            , hasXSelfAlign = True
                        }

                    XCenter ->
                        { gathered
                            | attributes = Html.Attributes.class "self-center-x" :: gathered.attributes
                            , hasXSelfAlign = True
                        }

                    Spread ->
                        { gathered
                            | attributes = Html.Attributes.class "spread" :: gathered.attributes
                            , hasXSelfAlign = True
                        }

        SelfYAlign alignment ->
            if gathered.hasYSelfAlign then
                gathered
            else
                case alignment of
                    AlignTop ->
                        { gathered
                            | attributes = Html.Attributes.class "self-top" :: gathered.attributes
                            , hasYSelfAlign = True
                        }

                    AlignBottom ->
                        { gathered
                            | attributes = Html.Attributes.class "self-bottom" :: gathered.attributes
                            , hasYSelfAlign = True
                        }

                    YCenter ->
                        { gathered
                            | attributes = Html.Attributes.class "self-center-y" :: gathered.attributes
                            , hasYSelfAlign = True
                        }

                    VerticalJustify ->
                        { gathered
                            | attributes = Html.Attributes.class "vertical-justify" :: gathered.attributes
                            , hasYSelfAlign = True
                        }

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

        Opacity o ->
            -- add opacity to style
            { gathered
                | styleProperties = Property "opacity" (toString o) :: gathered.styleProperties
            }

        Spacing spacing ->
            if gathered.hasSpacing then
                gathered
            else
                -- Add a new style > .children
                let
                    name =
                        "spacing-" ++ toString spacing

                    spaceCls =
                        "." ++ name
                in
                { gathered
                    | rules =
                        Keyed name
                            [ pair (spaceCls ++ ".row > .se") [ Property "margin-left" (toString spacing ++ "px") ]
                            , pair (spaceCls ++ ".row > .se:first-child") [ Property "margin-left" "0" ]
                            , pair (spaceCls ++ ".column > .se") [ Property "margin-top" (toString spacing ++ "px") ]
                            , pair (spaceCls ++ ".column > .se:first-child") [ Property "margin-top" "0" ]
                            , pair (spaceCls ++ ".page > .se") [ Property "margin-top" (toString spacing ++ "px") ]
                            , pair (spaceCls ++ ".page > .se:first-child") [ Property "margin-top" "0" ]
                            , pair (spaceCls ++ ".page > .self-left") [ Property "margin-right" (toString spacing ++ "px") ]
                            , pair (spaceCls ++ ".page > .self-right") [ Property "margin-left" (toString spacing ++ "px") ]
                            , pair (spaceCls ++ ".grid")
                                [ Property "grid-column-gap" (toString spacing ++ "px")
                                , Property "grid-row-gap" (toString spacing ++ "px")
                                ]
                            ]
                            :: gathered.rules
                    , attributes = Html.Attributes.class name :: gathered.attributes
                    , hasSpacing = True
                }

        SpacingXY x y ->
            if gathered.hasSpacing then
                gathered
            else
                let
                    name =
                        "spacing-xy-" ++ toString x ++ "-" ++ toString y

                    spaceCls =
                        "." ++ name
                in
                { gathered
                    | rules =
                        Keyed name
                            [ pair (spaceCls ++ ".row > .se") [ Property "margin-left" (toString x ++ "px") ]
                            , pair (spaceCls ++ ".row > .se:first-child") [ Property "margin-left" "0" ]
                            , pair (spaceCls ++ ".column > .se") [ Property "margin-top" (toString y ++ "px") ]
                            , pair (spaceCls ++ ".column > .se:first-child") [ Property "margin-top" "0" ]
                            , pair (spaceCls ++ ".page > .se") [ Property "margin-top" (toString y ++ "px") ]
                            , pair (spaceCls ++ ".page > .se:first-child") [ Property "margin-top" "0" ]
                            , pair (spaceCls ++ ".page > .self-left") [ Property "margin-right" (toString x ++ "px") ]
                            , pair (spaceCls ++ ".page > .self-right") [ Property "margin-left" (toString x ++ "px") ]
                            , pair (spaceCls ++ ".grid")
                                [ Property "grid-column-gap" (toString x ++ "px")
                                , Property "grid-row-gap" (toString y ++ "px")
                                ]
                            ]
                            :: gathered.rules
                    , attributes = Html.Attributes.class name :: gathered.attributes
                    , hasSpacing = True
                }

        Padding padding ->
            let
                padCls =
                    "pad-"
                        ++ toString padding.top
                        ++ "-"
                        ++ toString padding.right
                        ++ "-"
                        ++ toString padding.bottom
                        ++ "-"
                        ++ toString padding.left

                name =
                    "." ++ padCls

                expanded =
                    Keyed
                        name
                        [ pair name
                            [ Property "padding"
                                (toString padding.top
                                    ++ "px "
                                    ++ toString padding.right
                                    ++ "px "
                                    ++ toString padding.bottom
                                    ++ "px "
                                    ++ toString padding.left
                                    ++ "px"
                                )
                            ]
                        , pair (name ++ ".el > .se.expand-width")
                            [ Property "width" ("calc(100% + " ++ toString (padding.left + padding.right) ++ "px)")
                            , Property "margin-left" (toString (negate padding.left) ++ "px")
                            ]
                        , pair (name ++ ".column > .se.expand-width")
                            [ Property "width" ("calc(100% + " ++ toString (padding.left + padding.right) ++ "px)")
                            , Property "margin-left" (toString (negate padding.left) ++ "px")
                            ]
                        , pair (name ++ ".row > .se.expand-width:first-child")
                            [ Property "width" ("calc(100% + " ++ toString padding.left ++ "px)")
                            , Property "margin-left" (toString (negate padding.left) ++ "px")
                            ]
                        , pair (name ++ ".row > .se.expand-width:last-child")
                            [ Property "width" ("calc(100% + " ++ toString padding.right ++ "px)")
                            , Property "margin-right" (toString (negate padding.right) ++ "px")
                            ]
                        , pair (name ++ ".row.has-nearby > .se.expand-width::nth-last-child(2)")
                            [ Property "width" ("calc(100% + " ++ toString padding.right ++ "px)")
                            , Property "margin-right" (toString (negate padding.right) ++ "px")
                            ]
                        , pair (name ++ ".page > .se.expand-width:first-child")
                            [ Property "width" ("calc(100% + " ++ toString (padding.left + padding.right) ++ "px)")
                            , Property "margin-left" (toString (negate padding.left) ++ "px")
                            ]
                        , pair (name ++ ".el > .se.expand-height")
                            [ Property "height" ("calc(100% + " ++ toString (padding.top + padding.bottom) ++ "px)")
                            , Property "margin-top" (toString (negate padding.top) ++ "px")
                            ]
                        , pair (name ++ ".row > .se.expand-height")
                            [ Property "height" ("calc(100% + " ++ toString (padding.top + padding.bottom) ++ "px)")
                            , Property "margin-top" (toString (negate padding.top) ++ "px")
                            ]
                        , pair (name ++ ".column > .se.expand-height:first-child")
                            [ Property "height" ("calc(100% + " ++ toString padding.top ++ "px)")
                            , Property "margin-top" (toString (negate padding.top) ++ "px")
                            ]
                        , pair (name ++ ".column > .se.expand-height:last-child")
                            [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
                            , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
                            ]
                        , pair (name ++ ".column.has-nearby > .se.expand-height::nth-last-child(2)")
                            [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
                            , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
                            ]
                        , pair (name ++ ".page > .se.expand-height:first-child")
                            [ Property "height" ("calc(100% + " ++ toString padding.top ++ "px)")
                            , Property "margin-top" (toString (negate padding.top) ++ "px")
                            ]
                        , pair (name ++ ".page > .se.expand-height:last-child")
                            [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
                            , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
                            ]
                        , pair (name ++ ".page > .se.expand-height::nth-last-child(2)")
                            [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
                            , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
                            ]
                        ]
            in
            { gathered
                | attributes = Html.Attributes.class padCls :: gathered.attributes
                , hasPadding = True
                , rules = expanded :: gathered.rules
            }

        Overflow overflow ->
            case overflow of
                XAxis ->
                    { gathered
                        | styleProperties = Property "overflow-x" "auto" :: gathered.styleProperties
                    }

                YAxis ->
                    { gathered
                        | styleProperties = Property "overflow-y" "auto" :: gathered.styleProperties
                    }

                AllAxis ->
                    { gathered
                        | styleProperties = Property "overflow" "auto" :: gathered.styleProperties
                    }

        Attr attr ->
            -- add to current attributes
            { gathered | attributes = attr :: gathered.attributes }


addMaybe : Maybe thing -> List thing -> List thing
addMaybe maybeThing list =
    case maybeThing of
        Nothing ->
            list

        Just x ->
            x :: list


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


floatClass : Float -> String
floatClass x =
    toString <| round (x * 100)


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
