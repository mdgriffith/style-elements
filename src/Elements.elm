module Elements exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Style.Internal.Model as Internal
import Style.Internal.Set as StyleSet
import Style.Internal.Render as Render
import Style.Internal.Selector as Selector
import Style.Internal.Intermediate as Intermediate exposing (Rendered(..))
import Style.Sheet


type Element elem variation
    = Empty
      -- | Layout LayoutSettings (List (Element elem variation))
      -- | Overlay elem (Element elem variation)
    | Element elem (Element elem variation)
      -- | Variation elem (List ( variation, Bool )) (Element elem variation)
    | Text String


type alias HtmlFn msg =
    List (Html.Attribute msg) -> List (Html msg) -> Html msg


type Styled elem variation animation msg
    = El (HtmlFn msg) (List (Attributes elem variation animation msg))


type Attributes elem variation animation msg
    = Attr (Html.Attribute msg)
    | Style (Internal.Property elem variation animation)


element : List (Attributes elem variation animation msg) -> Styled elem variation animation msg
element =
    El Html.div


elementAs : HtmlFn msg -> List (Attributes elem variation animation msg) -> Styled elem variation animation msg
elementAs =
    El


{-| In Heirarchy

-}
empty : Element elem variation
empty =
    Empty


text : String -> Element elem variation
text =
    Text


el : elem -> Element elem variation -> Element elem variation
el =
    Element



--- Rendering


render : (elem -> Styled elem variation animation msg) -> Element elem variation -> Html msg
render findNode elm =
    let
        ( html, styleset ) =
            renderElement findNode elm

        stylesheet =
            styleset
                |> StyleSet.toList
                |> List.map (\elem -> renderStyle elem <| findNode elem)
                |> Render.unbatchedStylesheet False
                |> (\(Rendered { css }) -> Html.node "style" [] [ Html.text css ])
    in
        Html.div []
            [ stylesheet
            , html
            ]


renderElement : (elem -> Styled elem variation animation msg) -> Element elem variation -> ( Html msg, StyleSet.Set elem )
renderElement findNode elm =
    case elm of
        Empty ->
            ( Html.text "", StyleSet.empty )

        Element element child ->
            let
                ( childHtml, styleset ) =
                    renderElement findNode child

                elemHtml =
                    renderNode element (findNode element) [ childHtml ]
            in
                ( elemHtml, StyleSet.insert element styleset )

        Text str ->
            ( Html.text str, StyleSet.empty )


renderNode : elem -> Styled elem variation animation msg -> List (Html msg) -> Html msg
renderNode elem (El node attrs) children =
    let
        normalAttrs attr =
            case attr of
                Attr a ->
                    Just a

                _ ->
                    Nothing

        attributes =
            List.filterMap normalAttrs attrs

        styleName =
            Html.Attributes.class (Selector.formatName elem)
    in
        node (styleName :: attributes) children


renderStyle : elem -> Styled elem variation animation msg -> Internal.Style elem variation animation
renderStyle elem (El node attrs) =
    let
        styleProps attr =
            case attr of
                Style a ->
                    Just a

                _ ->
                    Nothing
    in
        Internal.Style elem (List.filterMap styleProps attrs)
