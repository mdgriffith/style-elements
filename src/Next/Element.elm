module Next.Element
    exposing
        ( above
        , below
        , column
        , el
        , empty
        , layout
        , onLeft
        , onRight
        , overlay
        , page
        , paragraph
        , row
        , spacer
        , text
        , viewport
        , when
        , whenJust
        )

{-| -}

import Html exposing (Html)
import Html.Attributes
import Next.Internal.Model exposing (..)


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


empty : Element msg
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


el : List (Attribute msg) -> Element msg -> Element msg
el attrs el =
    Row "div" (Width (Fill 1) :: Height (Fill 1) :: attrs) [ el ]


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


{-| A helper function. This:

    when (x == 5) (text "yay, it's 5")

is sugar for

    if (x == 5) then
        text "yay, it's 5"
    else
        empty

-}
when : Bool -> Element msg -> Element msg
when bool elm =
    if bool then
        elm
    else
        empty


{-| Another helper function that defaults to `empty`

    whenJust (Just ("Hi!")) text

is sugar for

    case maybe of
        Nothing ->
            empty
        Just x ->
            text x

-}
whenJust : Maybe a -> (a -> Element msg) -> Element msg
whenJust maybe view =
    case maybe of
        Nothing ->
            empty

        Just thing ->
            view thing
