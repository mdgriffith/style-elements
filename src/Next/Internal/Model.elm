module Next.Internal.Model exposing (..)

import Html exposing (Html)
import Html.Attributes


type Element msg
    = Empty
    | Spacer Float
    | Text Decoration String
    | El String (List (Attribute msg)) (Element msg)
    | Container String (List (Attribute msg)) (Element msg)
    | Row String (List (Attribute msg)) (List (Element msg))
    | Column String (List (Attribute msg)) (List (Element msg))
    | Grid (List (Attribute msg)) (List (Element msg))
    | TextLayout (List (Attribute msg)) (List (Element msg))
    | Paragraph (List (Attribute msg)) (List (Element msg))
    | Raw (Html msg)
    | Nearby Location (Element msg)
    | Screen (Element msg)


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
    | Position (Maybe Float) (Maybe Float) (Maybe Float)
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

.paragraph > .el {
    display: inline;
}

.paragraph > .row {
    display: inline-flex;
}
.paragraph > .column {
    display: inline-flex;
}
.paragraph >

.row {
    display: flex;
    flex-direction: row;
}

.row > .el {
    flex-basis: 0;
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

.column > .el {
    flex-basis: 0;
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
    align-items: space-between;
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



"""


layout : Element msg -> Html msg
layout el =
    let
        (Styled styles html) =
            render FirstAndLast [ 0 ] el
    in
        Html.div []
            [ Html.node "style" [] [ Html.text <| static ++ toStyleSheet styles ]
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
render : Position -> List Int -> Element msg -> Styled (Html msg)
render position index el =
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
                        unstyled <| Html.div [ Html.Attributes.class positionClass ] [ Html.text content ]

                    RawText ->
                        unstyled <| Html.text content

                    Bold ->
                        unstyled <| Html.strong [ Html.Attributes.class positionClass ] [ Html.text content ]

                    Italic ->
                        unstyled <| Html.em [ Html.Attributes.class positionClass ] [ Html.text content ]

                    Underline ->
                        unstyled <| Html.u [ Html.Attributes.class positionClass ] [ Html.text content ]

                    Strike ->
                        unstyled <| Html.u [ Html.Attributes.class positionClass ] [ Html.text content ]

                    Super ->
                        unstyled <| Html.sup [ Html.Attributes.class positionClass ] [ Html.text content ]

                    Sub ->
                        unstyled <| Html.sub [ Html.Attributes.class positionClass ] [ Html.text content ]

            Spacer pixels ->
                let
                    self =
                        "styled-" ++ String.join "" (List.map toString index)

                    spacings =
                        [ renderDependent ("." ++ self) <|
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
                let
                    (Styled styles renderedChild) =
                        render FirstAndLast (0 :: index) child

                    -- { attributes, styleProperties, otherStyles }
                    rendered =
                        renderAttributes SingleLayout attributes

                    self =
                        "styled-" ++ String.join "" (List.map toString index)

                    myStyle =
                        Style ("." ++ self) rendered.styleProperties

                    others =
                        List.map (renderDependent ("." ++ self)) rendered.otherStyles
                in
                    Styled (myStyle :: others ++ styles)
                        (Html.node name
                            (Html.Attributes.class (self ++ " el " ++ positionClass) :: rendered.attributes)
                            [ renderedChild ]
                        )

            Container name attributes child ->
                todo

            Row name attributes children ->
                let
                    ( childrenStyles, renderedChildren ) =
                        renderChildren index children

                    -- { attributes, styleProperties, otherStyles }
                    rendered =
                        renderAttributes RowLayout attributes

                    self =
                        "styled-" ++ String.join "" (List.map toString index)

                    additionalProperties =
                        [ Property "display" "flex"
                        , Property "flex-direction" "row"
                        ]

                    myStyle =
                        Style ("." ++ self)
                            (additionalProperties ++ rendered.styleProperties)

                    others =
                        List.map (renderDependent ("." ++ self)) rendered.otherStyles
                in
                    Styled (myStyle :: others ++ childrenStyles)
                        (Html.node name (Html.Attributes.class (self ++ " el row " ++ positionClass) :: rendered.attributes) renderedChildren)

            Column name attributes children ->
                let
                    ( childrenStyles, renderedChildren ) =
                        renderChildren index children

                    -- { attributes, styleProperties, otherStyles }
                    rendered =
                        renderAttributes ColumnLayout attributes

                    self =
                        "styled-" ++ String.join "" (List.map toString index)

                    myStyle =
                        Style ("." ++ self)
                            rendered.styleProperties

                    others =
                        List.map (renderDependent ("." ++ self)) rendered.otherStyles
                in
                    Styled (myStyle :: others ++ childrenStyles)
                        (Html.node name (Html.Attributes.class (self ++ " el column " ++ positionClass) :: rendered.attributes) renderedChildren)

            Grid attributes children ->
                todo

            TextLayout attributes children ->
                let
                    ( childrenStyles, renderedChildren ) =
                        renderChildren index children

                    -- { attributes, styleProperties, otherStyles }
                    rendered =
                        renderAttributes ColumnLayout attributes

                    self =
                        "styled-" ++ String.join "" (List.map toString index)

                    myStyle =
                        Style ("." ++ self)
                            (rendered.styleProperties)

                    others =
                        List.map (renderDependent ("." ++ self)) rendered.otherStyles
                in
                    Styled (myStyle :: others ++ childrenStyles)
                        (Html.node "div" (Html.Attributes.class (self ++ " el text " ++ positionClass) :: rendered.attributes) renderedChildren)

            Paragraph attributes children ->
                let
                    ( childrenStyles, renderedChildren ) =
                        renderChildren index children

                    -- { attributes, styleProperties, otherStyles }
                    rendered =
                        renderAttributes RowLayout attributes

                    self =
                        "styled-" ++ String.join "" (List.map toString index)

                    myStyle =
                        Style ("." ++ self)
                            (rendered.styleProperties)

                    others =
                        List.map (renderDependent ("." ++ self)) rendered.otherStyles
                in
                    Styled (myStyle :: others ++ childrenStyles)
                        (Html.node "p" (Html.Attributes.class (self ++ " el paragraph " ++ positionClass) :: rendered.attributes) renderedChildren)

            Raw html ->
                Styled [] html

            Nearby location child ->
                case location of
                    Above ->
                        todo

                    Below ->
                        todo

                    OnRight ->
                        todo

                    OnLeft ->
                        todo

                    Within ->
                        todo

            Screen child ->
                todo


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
                    render (place i) (i :: index) child
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
            }
    in
        List.foldr (gatherAttributes hint) init attrs


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

        Position mx my mz ->
            -- add translate to the transform stack
            gathered

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


text : String -> Element msg
text =
    Text NoDecoration


paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph =
    Paragraph


textLayout : List (Attribute msg) -> List (Element msg) -> Element msg
textLayout =
    TextLayout


el : List (Attribute msg) -> Element msg -> Element msg
el =
    El "div"


row : List (Attribute msg) -> List (Element msg) -> Element msg
row =
    Row "div"


column : List (Attribute msg) -> List (Element msg) -> Element msg
column =
    Column "div"


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


spacer =
    Spacer
