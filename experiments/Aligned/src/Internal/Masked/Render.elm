module Internal.Masked.Render exposing (..)

{-| -}

import Color exposing (Color)
import Internal.Masked.Flag as Flag exposing (Flag)
import Internal.Masked.Style as Style
import Json.Encode as Json
import VirtualDom


type Element msg
    = Unstyled (LayoutContext -> VirtualDom.Node msg)
    | Styled (List Style.Rule) (Maybe String -> LayoutContext -> VirtualDom.Node msg)
    | Text String
    | Empty


type LayoutContext
    = AsRow
    | AsColumn
    | AsEl
    | AsGrid
    | AsParagraph
    | AsTextColumn


fontColor clr =
    let
        name =
            formatColor clr
    in
    StyleRule (Flag.col 1) (Style.Prop "color" name) (VirtualDom.property "className" (Json.string name))


backgroundColor clr =
    let
        name =
            formatColor clr
    in
    StyleRule (Flag.col 1) (Style.Prop "color" name) (VirtualDom.property "className" (Json.string name))


padding p =
    let
        name =
            toString p ++ "px"
    in
    StyleRule (Flag.col 3) (Style.Prop "padding" name) (VirtualDom.property "className" (Json.string ("p" ++ name)))


fontCenter =
    Guarded (Flag.col 2) (VirtualDom.property "className" (Json.string "font-center"))


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


type Attribute decorative msg
    = Unguarded (VirtualDom.Property msg)
    | Guarded Flag (VirtualDom.Property msg)
    | StyleRule Flag Style.Rule (VirtualDom.Property msg)



-- | Save Tag
-- type Tag
--     = TagTransform (Maybe Style.PseudoClass) Transformation
--     | TagBoxShadow String
--     | TagTextShadow String


type Transformation
    = Move (Maybe Float) (Maybe Float) (Maybe Float)
    | Rotate Float Float Float Float
    | Scale Float Float Float


type NodeName
    = Generic
    | NodeName String
    | Embedded String String


type Children x
    = Unkeyed (List x)
    | Keyed (List ( String, x ))


type Rendered msg
    = Nada
    | Flagged Flag (List (VirtualDom.Property msg))
    | FlaggedAndStyled Flag (List (VirtualDom.Property msg)) (List Style.Rule)


nada : Rendered msg
nada =
    Nada


element : LayoutContext -> List (Attribute decorative msg) -> List (Element msg) -> Element msg
element context attrs children =
    let
        rendered =
            attrs
                |> List.foldr renderAttribute nada

        -- ( htmlChildren, styleChildren ) =
        --     case children of
        --         Keyed keyedChildren ->
        --             List.foldr (gatherKeyed widthHeightContent rendered.layout) ( [], rendered.styles ) keyedChildren
        --                 |> Tuple.mapFirst Keyed
        --         Unkeyed unkeyedChildren ->
        --             List.foldr (gather widthHeightContent rendered.layout) ( [], rendered.styles ) unkeyedChildren
        --                 |> Tuple.mapFirst Unkeyed
    in
    Empty


renderAttribute : Attribute decorative msg -> Rendered msg -> Rendered msg
renderAttribute attr rendered =
    case attr of
        Unguarded prop ->
            case rendered of
                Nada ->
                    Flagged Flag.none [ prop ]

                Flagged flag props ->
                    Flagged flag (prop :: props)

                FlaggedAndStyled flag props styles ->
                    FlaggedAndStyled flag (prop :: props) styles

        Guarded guard prop ->
            case rendered of
                Nada ->
                    Flagged guard [ prop ]

                Flagged flag props ->
                    if not (Flag.present guard flag) then
                        Flagged (Flag.add guard flag) (prop :: props)
                    else
                        rendered

                FlaggedAndStyled flag props styles ->
                    if not (Flag.present guard flag) then
                        FlaggedAndStyled (Flag.add guard flag) (prop :: props) styles
                    else
                        rendered

        StyleRule guard rule prop ->
            case rendered of
                Nada ->
                    FlaggedAndStyled guard [ prop ] [ rule ]

                Flagged flag props ->
                    if not (Flag.present guard flag) then
                        FlaggedAndStyled (Flag.add guard flag) (prop :: props) [ rule ]
                    else
                        rendered

                FlaggedAndStyled flag props styles ->
                    if not (Flag.present guard flag) then
                        FlaggedAndStyled (Flag.add guard flag) (prop :: props) (rule :: styles)
                    else
                        rendered


asHtml : Element msg -> VirtualDom.Node msg
asHtml el =
    case el of
        Unstyled render ->
            render AsEl

        Styled rules render ->
            render Nothing AsEl

        Text str ->
            VirtualDom.text str

        Empty ->
            VirtualDom.text ""
