module Next.Internal.Model exposing (..)

import Color exposing (Color)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes
import Html.Lazy
import Next.Internal.Style
import Set


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
    | Bold
    | Italic
    | Underline
    | Strike
    | Super
    | Sub


type Attribute msg
    = StyleProperty String String
    | FontFamily (List Font)
    | Opacity Float
    | Hidden
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
        { top : Maybe Float
        , left : Maybe Float
        , bottom : Maybe Float
        , right : Maybe Float
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


mapAttr fn attr =
    case attr of
        StyleProperty name val ->
            StyleProperty name val

        FontFamily typefaces ->
            FontFamily typefaces

        Opacity o ->
            Opacity o

        Hidden ->
            Hidden

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


gridPosition { start, width, height } =
    let
        ( x, y ) =
            start

        ( rowStart, rowEnd ) =
            ( y + 1, y + 1 + height )

        ( colStart, colEnd ) =
            ( x + 1, x + 1 + width )
    in
    StyleProperty "grid-area"
        (String.join " / "
            [ toString rowStart
            , toString colStart
            , toString rowEnd
            , toString colEnd
            ]
        )


gridTemplate : { a | columns : List Length, rows : List Length } -> List (Attribute msg)
gridTemplate { rows, columns } =
    let
        renderLen len =
            case len of
                Px x ->
                    toString x ++ "px"

                Expand ->
                    "100%"

                Content ->
                    "auto"

                Fill i ->
                    toString i ++ "fr"
    in
    [ StyleProperty "grid-template-rows"
        (String.join " " (List.map renderLen rows))
    , StyleProperty "grid-template-columns"
        (String.join " " (List.map renderLen columns))
    ]


{-| -}
type alias GridTemplate msg =
    { rows : List Length
    , columns : List Length
    , cells : List (OnGrid (Element msg))
    }


{-| -}
grid : List (Attribute msg) -> GridTemplate msg -> Element msg
grid attrs template =
    Grid "div" (gridTemplate template ++ attrs) (List.map (\(OnGrid cell) -> cell) template.cells)


cell : GridPosition msg -> OnGrid (Element msg)
cell box =
    let
        coords =
            gridPosition
                { start = box.start
                , width = box.width
                , height = box.height
                }
    in
    OnGrid <| addAttrs [ coords ] box.content


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



{- Attributes that need parent -> child communication

      Row/Column spacing ->
          .parent > .child-first
          .parent > .child-first-last
          .parent > .child-middle
          .parent > .child-last


      Element w/padding ->
          .parent > .expanded-width ++ row-first, row-last
          .parent > .expanded-height ++ column-first, column-last


   -- Alignment
   Row/Column -> .alignLeft, .alignRight (overrides for individual elements)

   TextLayout -> .alignLeft, .alignRight (corresponds to floats)


   Border.between 1
   Parent -> .child-first, .child-middle (border-bottom)


   Respace -> .el ~ .spaced


   -- Paragraph
   -> .children.row
    display: inline-flex

   -> .children.el
    display: inline


   -- TextLayout
    .children.el -> block
    .children.row -> -- Don't override anything (already a block element)


-}


type Styled thing
    = Styled (List Style) thing


type Style
    = Style String (List Property)
    | Keyed String (List ( String, List Property ))


type Property
    = Property String String


toStyleSheet : List Style -> String
toStyleSheet styles =
    let
        renderProps (Property key val) existing =
            existing ++ "\n" ++ key ++ ": " ++ val ++ ";"

        renderStyle selector props =
            selector ++ "{" ++ List.foldl renderProps "" props ++ "}"

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
    Html.node "style" [] [ Html.text Next.Internal.Style.rules ]


viewportSheet =
    Html.node "style" [] [ Html.text (viewportStylesheet ++ Next.Internal.Style.rules) ]


{-| Classes Needed
-}
render : List Int -> List (Element msg) -> Element msg -> Styled (Html msg)
render index addedChildren el =
    case el of
        Empty ->
            Styled [] (Html.text "")

        Text decoration content ->
            let
                ( otherChildrenStyles, renderedOtherChildren ) =
                    renderOtherChildren 1 index addedChildren

                renderText node =
                    Styled otherChildrenStyles <|
                        node [ Html.Attributes.class "se text width-fill" ]
                            (Html.text content :: renderedOtherChildren)
            in
            case decoration of
                RawText ->
                    -- This isn't exposed in a public API, but is only used internally when raw text is needed
                    -- (mostly for Element.Input output)
                    Styled [] (Html.text content)

                NoDecoration ->
                    renderText Html.div

                Bold ->
                    renderText Html.strong

                Italic ->
                    renderText Html.em

                Underline ->
                    renderText Html.u

                Strike ->
                    renderText Html.u

                Super ->
                    renderText Html.sup

                Sub ->
                    renderText Html.sub

        Spacer pixels ->
            let
                self =
                    "styled-" ++ String.join "" (List.map toString index)

                spacings =
                    [ Style (".row > ." ++ self)
                        [ Property "width" (toString pixels ++ "px")
                        , Property "height" "0px"
                        ]
                    , Style (".column > ." ++ self)
                        [ Property "height" (toString pixels ++ "px")
                        , Property "width" "0px"
                        ]
                    ]
            in
            Styled spacings
                (Html.node "span"
                    [ Html.Attributes.class (self ++ " spacer") ]
                    []
                )

        El name attributes child ->
            renderStyled name index attributes [ child ] addedChildren "se el"

        Row name attributes children ->
            renderStyled name index attributes children addedChildren "se row"

        Column name attributes children ->
            renderStyled name index attributes children addedChildren "se column"

        Grid name attributes children ->
            renderStyled name index attributes children addedChildren "se grid"

        Page attributes children ->
            renderStyled "div" index attributes children addedChildren "se page"

        Paragraph attributes children ->
            renderStyled "p" index attributes children addedChildren "se paragraph"

        Nearby { anchor, nearby } ->
            render index (List.map positionNearby nearby) anchor

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
    , padding :
        Maybe
            { top : Maybe Float
            , left : Maybe Float
            , bottom : Maybe Float
            , right : Maybe Float
            }
    , rotation : Maybe String
    , translation : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , scale : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , hasWidth : Bool
    , hasHeight : Bool
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
    , padding = Nothing
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


renderStyled : String -> List Int -> List (Attribute msg) -> List (Element msg) -> List (Element msg) -> String -> Styled (Html msg)
renderStyled name index attributes children otherChildren additionalClass =
    let
        ( childrenStyles, renderedChildren ) =
            renderChildren index children

        ( otherChildrenStyles, renderedOtherChildren ) =
            renderOtherChildren (List.length children) index otherChildren

        rendered =
            attributes
                |> List.foldr gatherAttributes initGathered
                |> formatTransformations

        self =
            "styled-" ++ String.join "-" (List.map toString index)

        myStyle =
            Style ("#" ++ self)
                rendered.styleProperties
    in
    Styled (myStyle :: rendered.rules ++ childrenStyles ++ otherChildrenStyles)
        (Html.node name
            (Html.Attributes.id self :: Html.Attributes.class additionalClass :: rendered.attributes)
            (renderedChildren ++ renderedOtherChildren)
        )


renderChildren : List Int -> List (Element msg) -> ( List Style, List (Html msg) )
renderChildren index children =
    let
        ( _, childrenStyles, renderedChildren ) =
            List.foldr renderStyleList ( 0, [], [] ) children

        renderStyleList child ( i, renderedStyles, renderedEls ) =
            let
                (Styled styles el) =
                    render (i :: index) [] child
            in
            ( i + 1
            , styles ++ renderedStyles
            , el :: renderedEls
            )
    in
    ( childrenStyles, renderedChildren )


renderOtherChildren : Int -> List Int -> List (Element msg) -> ( List Style, List (Html msg) )
renderOtherChildren offset index children =
    let
        ( _, childrenStyles, renderedChildren ) =
            List.foldr renderStyleList ( 0, [], [] ) children

        renderStyleList child ( i, renderedStyles, renderedEls ) =
            let
                (Styled styles el) =
                    render (i + offset :: index) [] child
            in
            ( i + 1
            , styles ++ renderedStyles
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

        transform =
            [ scale, translate, gathered.rotation ]
                |> List.filterMap identity
                |> String.join " "

        paddingName padding =
            "pad-"
                ++ (toString <| Maybe.withDefault 0 padding.top)
                ++ "-"
                ++ (toString <| Maybe.withDefault 0 padding.right)
                ++ "-"
                ++ (toString <| Maybe.withDefault 0 padding.bottom)
                ++ "-"
                ++ (toString <| Maybe.withDefault 0 padding.left)

        expanded name padding =
            Keyed
                name
                [ pair name
                    [ Property "padding-top" ((toString <| Maybe.withDefault 0 padding.top) ++ "px")
                    , Property "padding-bottom" ((toString <| Maybe.withDefault 0 padding.bottom) ++ "px")
                    , Property "padding-left" ((toString <| Maybe.withDefault 0 padding.left) ++ "px")
                    , Property "padding-right" ((toString <| Maybe.withDefault 0 padding.right) ++ "px")
                    ]
                , pair (name ++ ".el > .se.expand-width")
                    [ Property "width" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.left + Maybe.withDefault 0 padding.right) ++ "px)")
                    , Property "margin-left" (toString (negate <| Maybe.withDefault 0 padding.left) ++ "px")
                    ]
                , pair (name ++ ".column > .se.expand-width")
                    [ Property "width" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.left + Maybe.withDefault 0 padding.right) ++ "px)")
                    , Property "margin-left" (toString (negate <| Maybe.withDefault 0 padding.left) ++ "px")
                    ]
                , pair (name ++ ".row > .se.expand-width:first-child")
                    [ Property "width" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.left) ++ "px)")
                    , Property "margin-left" (toString (negate <| Maybe.withDefault 0 padding.left) ++ "px")
                    ]
                , pair (name ++ ".row > .se.expand-width:last-child")
                    [ Property "width" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.right) ++ "px)")
                    , Property "margin-right" (toString (negate <| Maybe.withDefault 0 padding.right) ++ "px")
                    ]
                , pair (name ++ ".row.has-nearby > .se.expand-width::nth-last-child(2)")
                    [ Property "width" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.right) ++ "px)")
                    , Property "margin-right" (toString (negate <| Maybe.withDefault 0 padding.right) ++ "px")
                    ]
                , pair (name ++ ".page > .se.expand-width:first-child")
                    [ Property "width" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.left + Maybe.withDefault 0 padding.right) ++ "px)")
                    , Property "margin-left" (toString (negate <| Maybe.withDefault 0 padding.left) ++ "px")
                    ]
                , pair (name ++ ".el > .se.expand-height")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.top + Maybe.withDefault 0 padding.bottom) ++ "px)")
                    , Property "margin-top" (toString (negate <| Maybe.withDefault 0 padding.top) ++ "px")
                    ]
                , pair (name ++ ".row > .se.expand-height")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.top + Maybe.withDefault 0 padding.bottom) ++ "px)")
                    , Property "margin-top" (toString (negate <| Maybe.withDefault 0 padding.top) ++ "px")
                    ]
                , pair (name ++ ".column > .se.expand-height:first-child")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.top) ++ "px)")
                    , Property "margin-top" (toString (negate <| Maybe.withDefault 0 padding.top) ++ "px")
                    ]
                , pair (name ++ ".column > .se.expand-height:last-child")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.bottom) ++ "px)")
                    , Property "margin-bottom" (toString (negate <| Maybe.withDefault 0 padding.bottom) ++ "px")
                    ]
                , pair (name ++ ".column.has-nearby > .se.expand-height::nth-last-child(2)")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.bottom) ++ "px)")
                    , Property "margin-bottom" (toString (negate <| Maybe.withDefault 0 padding.bottom) ++ "px")
                    ]
                , pair (name ++ ".page > .se.expand-height:first-child")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.top) ++ "px)")
                    , Property "margin-top" (toString (negate <| Maybe.withDefault 0 padding.top) ++ "px")
                    ]
                , pair (name ++ ".page > .se.expand-height:last-child")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.bottom) ++ "px)")
                    , Property "margin-bottom" (toString (negate <| Maybe.withDefault 0 padding.bottom) ++ "px")
                    ]
                , pair (name ++ ".page > .se.expand-height::nth-last-child(2)")
                    [ Property "height" ("calc(100% + " ++ toString (Maybe.withDefault 0 padding.bottom) ++ "px)")
                    , Property "margin-bottom" (toString (negate <| Maybe.withDefault 0 padding.bottom) ++ "px")
                    ]
                ]

        addFilters filters props =
            case filters of
                Nothing ->
                    props

                Just filts ->
                    Property "filters" filts :: props

        addBoxShadows shadows props =
            case shadows of
                Nothing ->
                    props

                Just shades ->
                    Property "box-shadow" shades :: props

        addTextShadows shadows props =
            case shadows of
                Nothing ->
                    props

                Just shades ->
                    Property "text-shadow" shades :: props
    in
    case gathered.padding of
        Nothing ->
            let
                style =
                    gathered.styleProperties
                        |> addFilters gathered.filters
                        |> addBoxShadows gathered.boxShadows
                        |> addTextShadows gathered.textShadows
            in
            { gathered
                | styleProperties =
                    if transform == "" then
                        style
                    else
                        Property "transform" transform :: style
            }

        Just pad ->
            let
                style =
                    gathered.styleProperties
                        |> addFilters gathered.filters
                        |> addBoxShadows gathered.boxShadows
                        |> addTextShadows gathered.textShadows

                padCls =
                    paddingName pad
            in
            { gathered
                | styleProperties =
                    if transform == "" then
                        style
                    else
                        Property "transform" transform :: style
                , attributes = Html.Attributes.class padCls :: gathered.attributes
                , rules =
                    expanded ("." ++ padCls) pad :: gathered.rules
            }


gatherAttributes : Attribute msg -> Gathered msg -> Gathered msg
gatherAttributes attr gathered =
    case attr of
        StyleProperty name val ->
            { gathered | styleProperties = Property name val :: gathered.styleProperties }

        FontFamily family ->
            let
                renderedFonts : Property
                renderedFonts =
                    let
                        renderFont font =
                            case font of
                                Serif ->
                                    "serif"

                                SansSerif ->
                                    "sans-serif"

                                Monospace ->
                                    "monospace"

                                Typeface name ->
                                    "\"" ++ name ++ "\""

                                ImportFont name url ->
                                    "\"" ++ name ++ "\""
                    in
                    family
                        |> List.map renderFont
                        |> String.join ", "
                        |> Property "font-family"
            in
            { gathered | styleProperties = renderedFonts :: gathered.styleProperties }

        Hidden ->
            { gathered | attributes = Html.Attributes.class "hidden" :: gathered.attributes }

        Height len ->
            if gathered.hasHeight then
                gathered
            else
                case len of
                    Px px ->
                        -- add width: Xpx to current style
                        { gathered
                            | styleProperties = Property "height" (toString px ++ "px") :: gathered.styleProperties
                            , hasHeight = True
                        }

                    Content ->
                        -- need to default to alignLeft
                        { gathered
                            | styleProperties = Property "height" "auto" :: gathered.styleProperties
                            , hasHeight = True
                        }

                    Expand ->
                        -- add class "expand-height"
                        { gathered
                            | attributes = Html.Attributes.class "expand-height" :: gathered.attributes
                            , hasHeight = True
                        }

                    Fill portion ->
                        -- renders as flex-grow: portion
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
                        { gathered | styleProperties = Property "width" (toString px ++ "px") :: gathered.styleProperties, hasWidth = True }

                    Content ->
                        -- need to default to alignLeft
                        { gathered
                            | styleProperties = Property "width" "auto" :: gathered.styleProperties
                            , hasWidth = True
                        }

                    Expand ->
                        -- add class "expand-width"
                        { gathered
                            | attributes = Html.Attributes.class "expand-width" :: gathered.attributes
                            , hasWidth = True
                        }

                    Fill portion ->
                        -- renders as flex-grow: portion
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
                                Html.Attributes.class "content-right"
                                    :: gathered.attributes
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
                        ("rotate3d("
                            ++ toString x
                            ++ ","
                            ++ toString y
                            ++ ","
                            ++ toString z
                            ++ ","
                            ++ toString angle
                            ++ "rad)"
                        )
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

        Padding pad ->
            let
                ifMissing x y =
                    case x of
                        Nothing ->
                            y

                        _ ->
                            x

                mergePadding exist pad =
                    case exist of
                        Nothing ->
                            pad

                        Just existing ->
                            { top = ifMissing existing.top pad.top
                            , bottom = ifMissing existing.bottom pad.bottom
                            , left = ifMissing existing.left pad.left
                            , right = ifMissing existing.right pad.right
                            }
            in
            { gathered
                | padding =
                    Just (mergePadding gathered.padding pad)
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
