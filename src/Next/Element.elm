module Next.Element
    exposing
        ( above
        , below
        , column
        , content
        , el
        , empty
        , expand
        , fill
        , height
        , layout
        , onLeft
        , onRight
        , overlay
        , page
        , paragraph
        , px
        , row
        , space
        , text
        , viewport
        , when
        , whenJust
        , width
        )

{-| -}

import Html exposing (Html)
import Html.Attributes
import Next.Internal.Model exposing (..)


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


{-| -}
expand : Length
expand =
    Expand


layout : List (Attribute msg) -> Element msg -> Html msg
layout attrs child =
    let
        (Styled styles html) =
            render FirstAndLast [ 0 ] [] (el attrs child)
    in
    Html.div [ Html.Attributes.class "style-elements" ]
        [ staticSheet
        , Html.node "style" [] [ Html.text <| toStyleSheet styles ]
        , html
        ]


viewport : List (Attribute msg) -> Element msg -> Html msg
viewport attrs child =
    let
        (Styled styles html) =
            render FirstAndLast [ 0 ] [] (el attrs child)
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
paragraph attrs children =
    Paragraph (Width (Fill 1) :: Height (Fill 1) :: attrs) children


page : List (Attribute msg) -> List (Element msg) -> Element msg
page attrs children =
    Page (Width (Px 650) :: attrs) children


el : List (Attribute msg) -> Element msg -> Element msg
el attrs child =
    El "div" (Width (Fill 1) :: Height (Fill 1) :: attrs) child


row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    Row "div" (Width (Fill 1) :: Height (Fill 1) :: attrs) children


column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Column "div" (Width (Fill 1) :: Height (Fill 1) :: attrs) children


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
    nearby Overlay


space : Float -> Element msg
space =
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
