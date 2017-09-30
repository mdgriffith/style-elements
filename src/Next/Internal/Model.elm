module Next.Internal.Model exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Lazy
import Color


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
        Property "grid-area"
            (String.join " / "
                [ toString rowStart
                , toString colStart
                , toString rowEnd
                , toString colEnd
                ]
            )


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
        [ Property "grid-template-rows"
            (String.join " " (List.map renderLen rows))
        , Property "grid-template-columns"
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
    Grid "div" (StyleProps (gridTemplate template) :: attrs) (List.map (\(OnGrid cell) -> cell) template.cells)


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
        OnGrid <| addAttrs [ StyleProps [ coords ] ] box.content


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
    = StyleProps (List Property)
    | Height Length
    | Width Length
    | HAlign HorizontalAlignment
    | VAlign VerticalAlignment
    | Move (Maybe Float) (Maybe Float) (Maybe Float)
    | Rotate Float Float Float Float
    | Scale (Maybe Float) (Maybe Float) (Maybe Float)
    | Opacity Float
    | Spacing Float
    | SpacingXY Float Float
    | Padding
        { top : Maybe Float
        , left : Maybe Float
        , bottom : Maybe Float
        , right : Maybe Float
        }
    | Event (Html.Attribute msg)
    | InputEvent (Html.Attribute msg)
    | Attr (Html.Attribute msg)
    | Overflow Axis


type Length
    = Px Float
    | Content
    | Expand
    | Fill Float


type HorizontalAlignment
    = AlignLeft
    | AlignRight
    | Center
    | Spread


type VerticalAlignment
    = AlignTop
    | AlignBottom
    | VerticalCenter
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
    | Within



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



-- | Unstyled thing


type Style
    = Style String (List Property)


type Property
    = Property String String


toStyleSheet : List Style -> String
toStyleSheet styles =
    let
        renderProps (Property key val) existing =
            existing ++ "\n" ++ key ++ ": " ++ val ++ ";"

        combine (Style str props) rendered =
            rendered ++ "\n" ++ str ++ "{" ++ (List.foldl renderProps "" props) ++ "}"
    in
        List.foldl combine "" styles



-- renderStyle : Strategy -> Style -> Html.Attribute msg
-- renderStyle
-- inline styles -> add as Html.Attributes.style
-- viaVirtualCss -> Generate Class via index, pass up css structure
--


todo =
    Styled [] (Html.text "")


unstyled =
    Styled []


static =
    """
.style-elements {
    width: 100%;
    height: 100%;
}

.el {
    position: relative;
    display: block;
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    border-width: 0;
}

.paragraph > .el {
    display: inline;
}

.paragraph > .el > .text {
    display: inline;
}

.paragraph > .row {
    display: inline-flex;
}
.paragraph > .column {
    display: inline-flex;
}
.paragraph > .grid {
    display: inline-grid;
}

.row {
    display: flex;
    flex-direction: row;
}

.row > .align-top {
    align-self: flex-start;
}
.row > .align-bottom {
    align-self: flex-end;
}
.row > .vertical-center {
    align-self: center;
}

.row.align-left {
    justify-content: flex-start;
}
.row.align-right {
    justify-content: flex-end;
}
.row.center {
    justify-content: center;
}
.row.spread {
    justify-content: space-between;
}
.row.align-top {
    align-items: flex-start;
}
.row.align-bottom {
    align-items: flex-end;
}
.row.vertical-center {
    align-items: center;
}


.column {
    display: flex;
    flex-direction: column;
}
.column > .align-left {
    align-self: flex-start;
}
.column > .align-right {
    align-self: flex-end;
}
.column > .center {
    align-self: center;
}
.column.align-left {
    align-items: flex-start;
}
.column.align-right {
    align-items: flex-end;
}
.column.center {
    align-items: center;
}
.column.spread {
    justify-content: space-between;
}
.column.align-top {
    justify-content: flex-start;
}
.column.align-bottom {
    justify-content: flex-end;
}
.column.vertical-center {
    justify-content: center;
}

.el.below {
    position: absolute;
    bottom: 0;
    height: 0;
}
.el.above {
    position: absolute;
    top: 0;
    height: 0;
}
.el.on-right {
    position: absolute;
    left: 100%;
    width: 0;
}
.el.on-left {
    position: absolute;
    right: 100%;
    width: 0;
}
.el.overlay {
    position: absolute;
    left:0;
    top:0;
}



"""


viewportStylesheet =
    """html, body {
        height: 100%;
        width: 100%;
}

"""


staticSheet : Html msg
staticSheet =
    Html.node "style" [] [ Html.text static ]


viewportSheet =
    Html.node "style" [] [ Html.text (viewportStylesheet ++ static) ]


layout : Element msg -> Html msg
layout el =
    let
        (Styled styles html) =
            render FirstAndLast [ 0 ] [] el
    in
        Html.div [ Html.Attributes.class "style-elements" ]
            [ staticSheet
            , Html.node "style" [] [ Html.text <| toStyleSheet styles ]
            , html
            ]


viewport : Element msg -> Html msg
viewport el =
    let
        (Styled styles html) =
            render FirstAndLast [ 0 ] [] el
    in
        Html.div [ Html.Attributes.class "style-elements" ]
            [ viewportSheet
            , Html.node "style" [] [ Html.text <| toStyleSheet styles ]
            , html
            ]


{-| Classes Needed

.el ->
On every element. When is it needed?
paragraph -> sets children as .inline

.expanded-width/expanded-height ->
class added instead of rendering

.styled-01 ->
This is the actual styling class that is generated.

.alignLeft, .alignRight, .center, .spread, .verticalCenter, .alignTop, .alignBottom ->
These definitions change depending on what type of parent is present.

  - Row, Column -> flexbox
  - TextLayout, Paragraph -> Float
  - container, el -> flexbox
  - grid -> unaffected?

.first, .middle, .firstAndLast, .last ->

  - Used to set Spacing Margins
  - Could it be replaced by nth-child? (<https://developer.mozilla.org/en-US/docs/Web/CSS/:nth-child>)

-- Elements Positioned Nearby

  - Spacing doesn't directly apply to them (meaning nth-child selectors might not work)
  - Parent Row/Column alignment should naturally not apply because nearby elements use `position:absolute`

-}
render : Position -> List Int -> List (Element msg) -> Element msg -> Styled (Html msg)
render position index addedChildren el =
    let
        positionClass =
            case position of
                FirstAndLast ->
                    "el first-and-last"

                Last ->
                    "el last"

                First ->
                    "el first"

                Middle ->
                    "el middle"
    in
        case el of
            Empty ->
                Styled [] (Html.text "")

            Text decoration content ->
                case decoration of
                    NoDecoration ->
                        unstyled <| Html.div [ Html.Attributes.class (positionClass ++ " text") ] [ Html.text content ]

                    RawText ->
                        unstyled <| Html.text content

                    Bold ->
                        unstyled <| Html.strong [ Html.Attributes.class (positionClass ++ " text") ] [ Html.text content ]

                    Italic ->
                        unstyled <| Html.em [ Html.Attributes.class (positionClass ++ " text") ] [ Html.text content ]

                    Underline ->
                        unstyled <| Html.u [ Html.Attributes.class (positionClass ++ " text") ] [ Html.text content ]

                    Strike ->
                        unstyled <| Html.u [ Html.Attributes.class (positionClass ++ " text") ] [ Html.text content ]

                    Super ->
                        unstyled <| Html.sup [ Html.Attributes.class (positionClass ++ " text") ] [ Html.text content ]

                    Sub ->
                        unstyled <| Html.sub [ Html.Attributes.class (positionClass ++ " text") ] [ Html.text content ]

            Spacer pixels ->
                let
                    self =
                        "styled-" ++ String.join "" (List.map toString index)

                    spacings =
                        [ renderDependent ("#" ++ self) <|
                            FollowingSibling ".el" [ Property "margin-left" "0", Property "margin-top" "0" ]
                        , Style (".row > ." ++ self)
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
                            [ Html.Attributes.class (self) ]
                            []
                        )

            El name attributes child ->
                renderStyled name index attributes positionClass SingleLayout [ child ] addedChildren ""

            Row name attributes children ->
                renderStyled name index attributes positionClass RowLayout children addedChildren "row"

            Column name attributes children ->
                renderStyled name index attributes positionClass ColumnLayout children addedChildren "column"

            Grid name attributes children ->
                renderStyled name index attributes positionClass GridLayout children addedChildren "grid"

            Page attributes children ->
                renderStyled "div" index attributes positionClass ColumnLayout children addedChildren "text"

            Paragraph attributes children ->
                renderStyled "p" index attributes positionClass RowLayout children addedChildren "paragraph"

            Nearby { anchor, nearby } ->
                render position index (List.map positionNearby nearby) anchor

            Raw html ->
                Styled [] html


positionNearby : ( Location, Element msg ) -> Element msg
positionNearby ( location, element ) =
    case location of
        Above ->
            El "div" [ Attr <| Html.Attributes.class "above" ] element

        Below ->
            El "div" [ Attr <| Html.Attributes.class "below" ] element

        OnRight ->
            El "div" [ Attr <| Html.Attributes.class "on-right" ] element

        OnLeft ->
            El "div" [ Attr <| Html.Attributes.class "on-left" ] element

        Within ->
            El "div" [ Attr <| Html.Attributes.class "overlay" ] element


renderStyled : String -> List Int -> List (Attribute msg) -> String -> LayoutHint -> List (Element msg) -> List (Element msg) -> String -> Styled (Html msg)
renderStyled name index attributes positionClass hint children otherChildren additionalClass =
    let
        ( childrenStyles, renderedChildren ) =
            renderChildren index children

        ( otherChildrenStyles, renderedOtherChildren ) =
            renderOtherChildren (List.length children) index otherChildren

        -- { attributes, styleProperties, otherStyles }
        rendered =
            renderAttributes hint attributes

        self =
            "styled-" ++ String.join "" (List.map toString index)

        myStyle =
            Style ("#" ++ self)
                (rendered.styleProperties)

        others =
            List.map (renderDependent ("#" ++ self)) rendered.otherStyles
    in
        Styled (myStyle :: others ++ childrenStyles ++ otherChildrenStyles)
            (Html.node name
                (Html.Attributes.id self :: Html.Attributes.class (additionalClass ++ " " ++ positionClass) :: rendered.attributes)
                (renderedChildren ++ renderedOtherChildren)
            )


renderChildren : List Int -> List (Element msg) -> ( List Style, List (Html msg) )
renderChildren index children =
    let
        place =
            getReversePosition (List.length children)

        ( _, childrenStyles, renderedChildren ) =
            List.foldr renderStyleList ( 0, [], [] ) children

        renderStyleList child ( i, renderedStyles, renderedEls ) =
            let
                (Styled styles el) =
                    render (place i) (i :: index) [] child
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
                    render FirstAndLast (i + offset :: index) [] child
            in
                ( i + 1
                , styles ++ renderedStyles
                , el :: renderedEls
                )
    in
        ( childrenStyles, renderedChildren )


type alias Gathered msg =
    { attributes : List (Html.Attribute msg)
    , styleProperties : List Property
    , otherStyles : List DependentStyle
    , rotation : Maybe String
    , translation : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , scale : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    }


{-| This is a style definition that is relative to the current element.

    DependentStyle selector props ->
        ".current-element"

-}
type DependentStyle
    = Child String (List Property)
    | Pseudo String (List Property)
    | FollowingSibling String (List Property)


renderDependent : String -> DependentStyle -> Style
renderDependent selector dep =
    case dep of
        Child name props ->
            Style (selector ++ " > " ++ name) props

        Pseudo name props ->
            Style (selector ++ ":" ++ name) props

        FollowingSibling name props ->
            Style (selector ++ " + " ++ name) props


renderAttributes : LayoutHint -> List (Attribute msg) -> Gathered msg
renderAttributes hint attrs =
    let
        init =
            { attributes = []
            , styleProperties = []
            , otherStyles = []
            , rotation = Nothing
            , translation = Nothing
            , scale = Nothing
            }
    in
        List.foldr (gatherAttributes hint) init attrs
            |> formatTransformations


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
    in
        if transform == "" then
            gathered
        else
            { gathered
                | styleProperties = Property "transform" transform :: gathered.styleProperties
            }


type LayoutHint
    = RowLayout
    | ColumnLayout
    | GridLayout
    | SingleLayout


gatherAttributes : LayoutHint -> Attribute msg -> Gathered msg -> Gathered msg
gatherAttributes hint attr gathered =
    case attr of
        StyleProps props ->
            { gathered | styleProperties = props ++ gathered.styleProperties }

        Height len ->
            case len of
                Px px ->
                    -- add width: Xpx to current style
                    { gathered | styleProperties = Property "height" (toString px ++ "px") :: gathered.styleProperties }

                Content ->
                    -- need to default to alignLeft
                    { gathered | styleProperties = Property "height" "auto" :: gathered.styleProperties }

                Expand ->
                    -- add class "expand-height"
                    { gathered | attributes = Html.Attributes.class "expand-height" :: gathered.attributes }

                Fill portion ->
                    -- renders as flex-grow: portion
                    { gathered | styleProperties = Property "height" "100%" :: gathered.styleProperties }

        Width len ->
            case len of
                Px px ->
                    -- add width: Xpx to current style
                    { gathered | styleProperties = Property "width" (toString px ++ "px") :: gathered.styleProperties }

                Content ->
                    -- need to default to alignLeft
                    { gathered | styleProperties = Property "width" "auto" :: gathered.styleProperties }

                Expand ->
                    -- add class "expand-width"
                    { gathered | attributes = Html.Attributes.class "expand-width" :: gathered.attributes }

                Fill portion ->
                    -- renders as flex-grow: portion
                    { gathered | styleProperties = Property "width" "100%" :: gathered.styleProperties }

        HAlign alignment ->
            case alignment of
                AlignLeft ->
                    { gathered | attributes = Html.Attributes.class "align-left" :: gathered.attributes }

                AlignRight ->
                    { gathered | attributes = Html.Attributes.class "align-right" :: gathered.attributes }

                Center ->
                    { gathered | attributes = Html.Attributes.class "center" :: gathered.attributes }

                Spread ->
                    { gathered | attributes = Html.Attributes.class "spread" :: gathered.attributes }

        VAlign alignment ->
            case alignment of
                AlignTop ->
                    { gathered | attributes = Html.Attributes.class "align-top" :: gathered.attributes }

                AlignBottom ->
                    { gathered | attributes = Html.Attributes.class "align-bottom" :: gathered.attributes }

                VerticalCenter ->
                    { gathered | attributes = Html.Attributes.class "vertical-center" :: gathered.attributes }

                VerticalJustify ->
                    { gathered | attributes = Html.Attributes.class "vertical-justify" :: gathered.attributes }

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
            -- Add a new style > .children
            case hint of
                RowLayout ->
                    { gathered
                        | otherStyles =
                            Child ".middle" [ Property "margin-left" (toString spacing ++ "px") ]
                                :: Child ".last" [ Property "margin-left" (toString spacing ++ "px") ]
                                :: gathered.otherStyles
                    }

                ColumnLayout ->
                    { gathered
                        | otherStyles =
                            Child ".middle" [ Property "margin-top" (toString spacing ++ "px") ]
                                :: Child ".last" [ Property "margin-top" (toString spacing ++ "px") ]
                                :: gathered.otherStyles
                    }

                GridLayout ->
                    { gathered
                        | styleProperties =
                            Property "grid-column-gap" (toString spacing ++ "px")
                                :: Property "grid-row-gap" (toString spacing ++ "px")
                                :: gathered.styleProperties
                    }

                SingleLayout ->
                    gathered

        SpacingXY x y ->
            case hint of
                RowLayout ->
                    { gathered
                        | otherStyles =
                            Child ".middle" [ Property "margin-left" (toString x ++ "px") ]
                                :: Child ".last" [ Property "margin-left" (toString x ++ "px") ]
                                :: gathered.otherStyles
                    }

                ColumnLayout ->
                    { gathered
                        | otherStyles =
                            Child ".middle" [ Property "margin-top" (toString y ++ "px") ]
                                :: Child ".last" [ Property "margin-top" (toString y ++ "px") ]
                                :: gathered.otherStyles
                    }

                GridLayout ->
                    { gathered
                        | styleProperties =
                            Property "grid-column-gap" (toString x ++ "px")
                                :: Property "grid-row-gap" (toString y ++ "px")
                                :: gathered.styleProperties
                    }

                SingleLayout ->
                    gathered

        Padding { top, right, bottom, left } ->
            -- render to current style
            { gathered
                | styleProperties =
                    gathered.styleProperties
                        |> addMaybe (Maybe.map (\x -> Property "padding-top" (toString x ++ "px")) top)
                        |> addMaybe (Maybe.map (\x -> Property "padding-bottom" (toString x ++ "px")) bottom)
                        |> addMaybe (Maybe.map (\x -> Property "padding-left" (toString x ++ "px")) left)
                        |> addMaybe (Maybe.map (\x -> Property "padding-right" (toString x ++ "px")) right)
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

        Event attr ->
            -- add to current attributes
            { gathered | attributes = attr :: gathered.attributes }

        InputEvent attr ->
            -- add to current attributes
            { gathered | attributes = attr :: gathered.attributes }

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


type Position
    = First
    | Middle
    | Last
    | FirstAndLast


getPosition : Int -> Int -> Position
getPosition total i =
    if total <= 1 then
        FirstAndLast
    else if i == 0 then
        First
    else if i == total - 1 then
        Last
    else
        Middle


getReversePosition : Int -> Int -> Position
getReversePosition total i =
    if total <= 1 then
        FirstAndLast
    else if i == 0 then
        Last
    else if i == total - 1 then
        First
    else
        Middle


positionMap : (Position -> Int -> a -> b) -> List a -> List b
positionMap fn list =
    case list of
        [] ->
            []

        a :: [] ->
            [ fn FirstAndLast 0 a ]

        full ->
            let
                len =
                    List.length list - 1

                applyFn a ( index, existing ) =
                    if index == 0 then
                        ( index + 1, fn Last (len - index) a :: existing )
                    else if index == len then
                        ( index + 1, fn First (len - index) a :: existing )
                    else
                        ( index + 1, fn Middle (len - index) a :: existing )
            in
                list
                    |> List.foldr applyFn ( 0, [] )
                    |> Tuple.second



-- {-| -}
-- lazy : (a -> Element msg) -> a -> Element msg
-- lazy fn a =
--     Styled
--         (VirtualCss.lazy (renderStyles << fn) a)
--         (Html.lazy (renderHtml << fn) a)
{- API Interface -}


empty =
    Empty


text : String -> Element msg
text =
    Text NoDecoration


paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph =
    Paragraph


page : List (Attribute msg) -> List (Element msg) -> Element msg
page =
    Page


container : List (Attribute msg) -> Element msg -> Element msg
container attrs el =
    Row "div" (Width (Fill 1) :: Height (Fill 1) :: attrs) [ el ]


node : String -> List (Attribute msg) -> Element msg -> Element msg
node =
    El


el : List (Attribute msg) -> Element msg -> Element msg
el =
    El "div"


row : List (Attribute msg) -> List (Element msg) -> Element msg
row =
    Row "div"


column : List (Attribute msg) -> List (Element msg) -> Element msg
column =
    Column "div"


below : Element msg -> Element msg -> Element msg
below =
    nearby Below


above : Element msg -> Element msg -> Element msg
above =
    nearby Above


onRight : Element msg -> Element msg -> Element msg
onRight =
    nearby OnRight


onLeft : Element msg -> Element msg -> Element msg
onLeft =
    nearby OnLeft


overlay : Element msg -> Element msg -> Element msg
overlay =
    nearby Within


spacer : Float -> Element msg
spacer =
    Spacer


style : List Property -> Attribute msg
style =
    StyleProps


prop : String -> String -> Property
prop =
    Property


{-| -}
center : Attribute msg
center =
    HAlign Center


{-| -}
verticalCenter : Attribute msg
verticalCenter =
    VAlign VerticalCenter


{-| -}
verticalSpread : Attribute msg
verticalSpread =
    VAlign VerticalJustify


{-| -}
spread : Attribute msg
spread =
    HAlign Spread


{-| -}
alignTop : Attribute msg
alignTop =
    VAlign AlignTop


{-| -}
alignBottom : Attribute msg
alignBottom =
    VAlign AlignBottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    HAlign AlignLeft


{-| -}
alignRight : Attribute msg
alignRight =
    HAlign AlignRight


{-| -}
width : Length -> Attribute msg
width =
    Width


{-| -}
height : Length -> Attribute msg
height =
    Height


{-| -}
px : Float -> Length
px =
    Px


{-| -}
content : Length
content =
    Content


{-| -}
fill : Length
fill =
    Fill 1


spacing : Float -> Attribute msg
spacing =
    Spacing


spacingXY : Float -> Float -> Attribute msg
spacingXY =
    SpacingXY


{-| -}
moveUp : Float -> Attribute msg
moveUp y =
    Move Nothing (Just (negate y)) Nothing


{-| -}
moveDown : Float -> Attribute msg
moveDown y =
    Move Nothing (Just y) Nothing


{-| -}
moveRight : Float -> Attribute msg
moveRight x =
    Move (Just x) Nothing Nothing


{-| -}
moveLeft : Float -> Attribute msg
moveLeft x =
    Move (Just (negate x)) Nothing Nothing
