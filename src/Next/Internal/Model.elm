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
    = Height Length
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
    = Left
    | Right
    | Center
    | Justify


type VerticalAlignment
    = Top
    | Bottom
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
            key ++ ": " ++ val ++ ";"

        combine (Style str props) rendered =
            str ++ "{" ++ (List.foldl renderProps "" props) ++ "}\n"
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


layout : Element msg -> Html msg
layout el =
    let
        (Styled styles html) =
            render [ 0 ] el
    in
        Html.div []
            [ Html.node "style" [] [ Html.text <| toStyleSheet styles ]
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
render : List Int -> Element msg -> Styled (Html msg)
render index el =
    case el of
        Empty ->
            Styled [] (Html.text "")

        Text decoration content ->
            case decoration of
                NoDecoration ->
                    unstyled <| Html.div [] [ Html.text content ]

                RawText ->
                    unstyled <| Html.text content

                Bold ->
                    unstyled <| Html.strong [] [ Html.text content ]

                Italic ->
                    unstyled <| Html.em [] [ Html.text content ]

                Underline ->
                    unstyled <| Html.u [] [ Html.text content ]

                Strike ->
                    unstyled <| Html.u [] [ Html.text content ]

                Super ->
                    unstyled <| Html.sup [] [ Html.text content ]

                Sub ->
                    unstyled <| Html.sub [] [ Html.text content ]

        Spacer pixels ->
            todo

        El name attributes child ->
            let
                (Styled styles renderedChild) =
                    render (0 :: index) child

                self =
                    "styled-" ++ String.join "" (List.map toString index)

                myStyle =
                    Style ("." ++ self)
                        [ Property "color" "blue"
                        ]
            in
                Styled (myStyle :: styles)
                    (Html.node name [ Html.Attributes.class self ] [ renderedChild ])

        Container name attributes child ->
            todo

        Row name attributes children ->
            todo

        Column name attributes children ->
            todo

        Grid attributes children ->
            todo

        TextLayout attributes children ->
            todo

        Paragraph attributes children ->
            todo

        Raw html ->
            todo

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


renderAttributes : Attribute msg -> Html.Attribute msg
renderAttributes attr =
    case attr of
        Height len ->
            Html.Attributes.class ""

        Width len ->
            case len of
                Px px ->
                    -- add width: Xpx to current style
                    Html.Attributes.class ""

                Content ->
                    -- need to default to alignLeft
                    Html.Attributes.class ""

                Expand ->
                    -- add class "expand-width"
                    Html.Attributes.class ""

                Fill portion ->
                    -- renders as flex-grow: portion
                    Html.Attributes.class ""

        HAlign alignment ->
            Html.Attributes.class ""

        VAlign alignment ->
            Html.Attributes.class ""

        Position mx my mz ->
            -- add translate to the transform stack
            Html.Attributes.class ""

        Opacity o ->
            -- add opacity to style
            Html.Attributes.class ""

        Spacing spacing ->
            -- Add a new style > .children
            Html.Attributes.class ""

        SpacingXY x y ->
            Html.Attributes.class ""

        Padding (Maybe Float) (Maybe Float) (Maybe Float) (Maybe Float) ->
            -- render to current style
            Html.Attributes.class ""

        Event attr ->
            -- add to current attributes
            attr

        InputEvent attr ->
            -- add to current attributes
            attr

        Attr attr ->
            -- add to current attributes
            attr

        Overflow overflow ->
            -- render to current style
            Html.Attributes.class ""


type Position
    = First
    | Middle
    | Last
    | FirstAndLast


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
