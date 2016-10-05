module Style.Elements.Basic exposing (..)

import Html
import Html.Attributes
import Style exposing (..)
import Style.Elements
import Style.Default


base : Style.Model
base =
    Style.Default.style


textLayout : Style.Model
textLayout =
    base


flowRight : Style.Model
flowRight =
    { base
        | layout =
            Style.FlexLayout
                { go = Right
                , wrap = True
                , spacing = all 10
                , align = ( HLeft, VCenter )
                }
    }


flowLeft : Style.Model
flowLeft =
    { base
        | layout =
            Style.FlexLayout
                { go = Left
                , wrap = True
                , spacing = all 10
                , align = ( HRight, VCenter )
                }
    }


flowDown : Style.Model
flowDown =
    { base
        | layout =
            Style.FlexLayout
                { go = Down
                , wrap = True
                , spacing = all 10
                , align = ( HRight, VCenter )
                }
    }


flowUp : Style.Model
flowUp =
    { base
        | layout =
            Style.FlexLayout
                { go = Up
                , wrap = True
                , spacing = all 10
                , align = ( HRight, VCenter )
                }
    }


center : Style.Model
center =
    { base
        | layout =
            Style.FlexLayout
                { go = Right
                , wrap = True
                , spacing = all 10
                , align = ( HCenter, VCenter )
                }
    }


h1 : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
h1 =
    Style.Elements.elementAs Html.h1
        { base
            | text =
                let
                    default =
                        Style.Default.text
                in
                    { default | size = 32 }
        }


h2 : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
h2 =
    Style.Elements.elementAs Html.h2
        { base
            | text =
                let
                    default =
                        Style.Default.text
                in
                    { default | size = 24 }
        }


h3 : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
h3 =
    Style.Elements.elementAs Html.h3
        { base
            | text =
                let
                    default =
                        Style.Default.text
                in
                    { default | size = 18 }
        }


indent : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
indent =
    Style.Elements.element
        { base | padding = left 30 }


link : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
link =
    Style.Elements.elementAs Html.a
        { base
            | cursor = "pointer"
        }


break : Style.Element msg
break =
    Style.Elements.elementAs Html.br
        base
        []
        []


rule : Style.Element msg
rule =
    Style.Elements.elementAs Html.hr
        base
        []
        []


text : String -> Style.Element msg
text str =
    Style.Elements.elementAs (\_ _ -> Html.text str)
        base
        []
        []


image : String -> List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
image src attrs children =
    Style.Elements.elementAs Html.img
        base
        (Html.Attributes.src src :: attrs)
        children


icon : String -> List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
icon str attrs children =
    Style.Elements.element
        base
        attrs
        (text str :: children)


i : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
i =
    Style.Elements.elementAs Html.i
        { base
            | text =
                let
                    default =
                        Style.Default.text
                in
                    { default | italic = True }
        }


b : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
b =
    Style.Elements.elementAs Html.i
        { base
            | text =
                let
                    default =
                        Style.Default.text
                in
                    { default | boldness = Just 700 }
        }



-------------------
-- Table Creation
-------------------


table : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
table =
    Style.Elements.elementAs Html.table
        { base | layout = Style.TableLayout { spacing = all 0 } }


tableHeader : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
tableHeader =
    Style.Elements.elementAs Html.th base


row : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
row =
    Style.Elements.elementAs Html.tr base


column : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
column =
    Style.Elements.elementAs Html.td base



--------------------
-- Input Elements
--------------------


button : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
button =
    Style.Elements.elementAs Html.button base


checkbox : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
checkbox attrs children =
    Style.Elements.elementAs Html.input
        base
        (Html.Attributes.type' "checkbox" :: attrs)
        children


input : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
input =
    Style.Elements.elementAs Html.input base


textarea : List (Html.Attribute msg) -> List (Style.Element msg) -> Style.Element msg
textarea =
    Style.Elements.elementAs Html.textarea base



-- Integration with existing html


html : Html.Html msg -> Style.Element msg
html =
    Style.Elements.html
