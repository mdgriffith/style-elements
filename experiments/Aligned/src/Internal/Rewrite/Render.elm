module Internal.Render exposing (Attribute(..), Element, Tag, element, toHtml)

{-| -}

import Internal.Style.Model as Style
import Json.Encode as Json
import VirtualDom


type Element msg
    = Unstyled (LayoutContext -> VirtualDom.Node msg)
    | Styled
        { styles : List Style.Rule
        , html : Maybe String -> LayoutContext -> VirtualDom.Node msg
        }
    | Text String
    | Empty


type LayoutContext
    = AsRow
    | AsColumn
    | AsEl
    | AsGrid
    | AsParagraph
    | AsTextColumn


type Attribute decorative msg
    = Unguarded (VirtualDom.Property msg)
    | Guarded String (Attribute decorative msg)
    | GuardedMany String (List (Attribute decorative msg))
    | StyleRule Style.Rule
    | Save Tag


type Tag
    = TagHeightContent
    | TagWidthContent
    | TagTransform (Maybe Style.PseudoClass) Transformation
    | TagBoxShadow String
    | TagTextShadow String


type Transformation
    = Move (Maybe Float) (Maybe Float) (Maybe Float)
    | Rotate Float Float Float Float
    | Scale Float Float Float


type NodeName
    = Generic
    | NodeName String
    | Embedded String String


type alias Intermediate msg =
    { node : NodeName
    , layout : LayoutContext
    , attributes : List (VirtualDom.Property msg)
    , styles : List Style.Rule
    , tags : List Tag
    , children : List (VirtualDom.Node msg)
    , guards : List String
    }


type Children x
    = Unkeyed (List x)
    | Keyed (List ( String, x ))


element : List (Attribute decorative msg) -> Intermediate msg -> Children (Element msg) -> Element msg
element actions intermediate children =
    let
        rendered =
            List.foldr renderAttribute intermediate actions
                |> resolveTags

        widthHeightContent =
            List.foldr isWidthHeightContent ( False, False ) rendered.tags
                |> (\( w, h ) -> w && h)

        isWidthHeightContent tag ( w, h ) =
            case tag of
                TagHeightContent ->
                    ( w, True )

                TagWidthContent ->
                    ( True, h )

                _ ->
                    ( w, h )

        ( htmlChildren, styleChildren ) =
            case children of
                Keyed keyedChildren ->
                    List.foldr (gatherKeyed widthHeightContent rendered.layout) ( [], rendered.styles ) keyedChildren
                        |> Tuple.mapFirst Keyed

                Unkeyed unkeyedChildren ->
                    List.foldr (gather widthHeightContent rendered.layout) ( [], rendered.styles ) unkeyedChildren
                        |> Tuple.mapFirst Unkeyed
    in
    { rendered
        | styles = rendered.styles ++ styleChildren
    }
        |> renderNode


renderNode : Intermediate msg -> Element msg
renderNode el =
    Empty


gather widthHeightContent context child ( htmls, existingStyles ) =
    case child of
        Unstyled html ->
            ( html context :: htmls
            , existingStyles
            )

        Styled styled ->
            ( styled.html Nothing context :: htmls
            , styled.styles ++ existingStyles
            )

        Text str ->
            -- TEXT OPTIMIZATION
            -- You can have raw text if the element is an el, and has `width-content` and `height-content`
            -- Same if it's a column or row with one child and width-content, height-content
            if widthHeightContent then
                ( VirtualDom.text str
                    :: htmls
                , existingStyles
                )
            else if context == asEl then
                ( textElementFill str
                    :: htmls
                , existingStyles
                )
            else
                ( textElement str
                    :: htmls
                , existingStyles
                )

        Empty ->
            ( htmls, existingStyles )


gatherKeyed widthHeightContent context ( key, child ) ( htmls, existingStyles ) =
    case child of
        Unstyled html ->
            ( ( key, html context ) :: htmls
            , existingStyles
            )

        Styled styled ->
            ( ( key, styled.html Nothing context ) :: htmls
            , styled.styles ++ existingStyles
            )

        Text str ->
            -- TEXT OPTIMIZATION
            -- You can have raw text if the element is an el, and has `width-content` and `height-content`
            -- Same if it's a column or row with one child and width-content, height-content
            if widthHeightContent then
                ( ( key, VirtualDom.text str )
                    :: htmls
                , existingStyles
                )
            else
                ( ( key, textElement str )
                    :: htmls
                , existingStyles
                )

        Empty ->
            ( htmls, existingStyles )


textElement : String -> VirtualDom.Node msg
textElement str =
    VirtualDom.node "div"
        [ VirtualDom.property "className"
            (Json.string "se text width-content height-content")
        ]
        [ VirtualDom.text str ]


textElementFill : String -> VirtualDom.Node msg
textElementFill str =
    VirtualDom.node "div"
        [ VirtualDom.property "className"
            (Json.string "se text width-fill height-fill")
        ]
        [ VirtualDom.text str ]


renderAttribute : Attribute decorative msg -> Intermediate msg -> Intermediate msg
renderAttribute action el =
    case action of
        Unguarded attr ->
            { el | attributes = attr :: el.attributes }

        Guarded guard guarded ->
            if List.any ((==) guard) el.guards then
                el
            else
                renderAttribute guarded el

        GuardedMany guard guardedActions ->
            if List.any ((==) guard) el.guards then
                el
            else
                List.foldr renderAttribute el guardedActions

        StyleRule style ->
            { el | styles = style :: el.styles }

        Save tag ->
            { el | tags = tag :: el.tags }


resolveTags : Intermediate msg -> Intermediate msg
resolveTags el =
    el


toHtml : Element msg -> VirtualDom.Node msg
toHtml el =
    VirtualDom.text ""



{- Constants -}


asGrid : LayoutContext
asGrid =
    AsGrid


asRow : LayoutContext
asRow =
    AsRow


asColumn : LayoutContext
asColumn =
    AsColumn


asEl : LayoutContext
asEl =
    AsEl


asParagraph : LayoutContext
asParagraph =
    AsParagraph


asTextColumn : LayoutContext
asTextColumn =
    AsTextColumn


contextClasses : LayoutContext -> Attribute aligned msg
contextClasses context =
    case context of
        AsRow ->
            htmlClass "se row"

        AsColumn ->
            htmlClass "se column"

        AsEl ->
            htmlClass "se el"

        AsGrid ->
            htmlClass "se grid"

        AsParagraph ->
            htmlClass "se paragraph"

        AsTextColumn ->
            htmlClass "se page"


htmlClass : String -> Attribute aligned msg
htmlClass cls =
    Unguarded <| VirtualDom.property "className" (Json.string cls)



{- Mapping -}


map : (msg -> msg1) -> Element msg -> Element msg1
map fn el =
    case el of
        Styled styled ->
            Styled
                { styles = styled.styles
                , html = \add context -> VirtualDom.map fn <| styled.html add context
                }

        Unstyled html ->
            Unstyled (VirtualDom.map fn << html)

        Text str ->
            Text str

        Empty ->
            Empty
