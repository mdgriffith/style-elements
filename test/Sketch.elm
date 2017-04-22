module Main exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes


main =
    Html.text "yup"


type Element elem variation
    = Empty
    | Layout LayoutSettings (List (Element elem variation))
    | Overlay elem (Element elem variation)
    | Element elem (Element elem variation)
    | Variation elem (List ( variation, Bool )) (Element elem variation)
    | Text String


type LayoutSettings
    = LayoutSettings


type Styled elem variation msg
    = El (List (Attributes elem variation msg))
    | ElAs String (List (Attributes elem variation msg))


nevermind : a -> a
nevermind =
    identity


empty : Element elem variation
empty =
    Empty


element : List (Attributes elem variation msg) -> Styled elem variation msg
element =
    El


elementAs : String -> List (Attributes elem variation msg) -> Styled elem variation msg
elementAs =
    ElAs


type Attributes elem variation msg
    = Attr (Html.Attribute msg)
    | Style (Property elem variation)


type Property
    = Prop


type Defaults
    = Defaults


render : Defaults -> (elem -> Styled elem variation msg) -> Element elem variation -> Html msg
render defaults findNode elm =
    case elm of
        Empty ->
            Html.text ""

        Layout settings children ->
            Html.div [] (List.map (render defaults findNode) children)

        Overlay bg child ->
            renderNode (findNode bg) [ render defaults findNode child ]

        Element element child ->
            renderNode (findNode element) [ render defaults findNode child ]

        Variation elem variations child ->
            Html.text ""

        Text str ->
            Html.text str


renderNode : Styled elem variation msg -> List (Html msg) -> Html msg
renderNode node children =
    let
        renderAttrs attr =
            case attr of
                Attr a ->
                    Just a

                Style props ->
                    Nothing
    in
        case node of
            El attrs ->
                Html.div (List.filterMap renderAttrs attrs) children

            ElAs nodeName attrs ->
                Html.node nodeName (List.filterMap renderAttrs attrs) children



-- type alias ElementSheet elem msg =
--     { find : elem -> List (Attributes msg)
--     }
-- type Defaults
--     = Defaults
--
-- renderNode : Node elem variation msg -> Html msg
-- renderNode (Elem node =
--     let
--         getAttrs attr =
--             case attr of
--                 Attr attrs ->
--                     Just attrs
--                 _ ->
--                     Nothing
--         getStyle attr =
--             case attr of
--                 Style ->
--                     Just <| Html.Attributes.class "style"
--                 _ ->
--                     Nothing
--         node =
--             Html.div
--         content =
--             List.filterMap getContent attributes
--                 |> List.concat
--                 |> List.map (render trace defaults renderer)
--         attrs =
--             List.filterMap getAttrs attributes
--         style =
--             List.filterMap getStyle attributes
--     in
--         node (style ++ attrs) content
