module Style.Elements.Basic exposing (..)

import Html
import Html.Attributes
import Style exposing (..)
import Style.Elements exposing (..)
import Style.Default


base : Style.Model
base =
    Style.Default.style


defaultText : Style.Text
defaultText =
    Style.Default.text


h1 : List (Html.Attribute msg) -> List (Element msg) -> Element msg
h1 =
    elementAs "h1"
        { base
            | text =
                { defaultText | size = 32 }
        }


h2 : List (Html.Attribute msg) -> List (Element msg) -> Element msg
h2 =
    elementAs "h2"
        { base
            | text =
                { defaultText | size = 24 }
        }


h3 : List (Html.Attribute msg) -> List (Element msg) -> Element msg
h3 =
    elementAs "h3"
        { base
            | text =
                { defaultText | size = 18 }
        }


indent : List (Html.Attribute msg) -> List (Element msg) -> Element msg
indent =
    element
        { base | padding = left 30 }


link : List (Html.Attribute msg) -> List (Element msg) -> Element msg
link =
    elementAs "a"
        { base
            | cursor = "pointer"
        }


break : Element msg
break =
    html (Html.br [] [])


rule : Element msg
rule =
    html (Html.hr [] [])


text : String -> Element msg
text str =
    html (Html.text str)


image : String -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
image src attrs children =
    elementAs "img"
        base
        (Html.Attributes.src src :: attrs)
        children


icon : String -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
icon str attrs children =
    element base attrs (text str :: children)


i : List (Html.Attribute msg) -> List (Element msg) -> Element msg
i attrs children =
    html <|
        Html.i
            (Html.Attributes.style [ ( "font-style", "italic" ) ] :: attrs)
            (List.map Style.Elements.build children)


b : List (Html.Attribute msg) -> List (Element msg) -> Element msg
b attrs children =
    html <|
        Html.b
            (Html.Attributes.style [ ( "font-weight", "bold" ) ] :: attrs)
            (List.map Style.Elements.build children)


code : List (Html.Attribute msg) -> List (Element msg) -> Element msg
code =
    elementAs "code"
        { base
            | text =
                { defaultText | whitespace = pre }
        }



-------------------
-- Table Creation
-------------------


table : List (Html.Attribute msg) -> List (Element msg) -> Element msg
table =
    elementAs "table"
        { base
            | layout = Style.tableLayout { spacing = all 0 }
        }


tableHeader : List (Html.Attribute msg) -> List (Element msg) -> Element msg
tableHeader =
    elementAs "th" base


row : List (Html.Attribute msg) -> List (Element msg) -> Element msg
row =
    elementAs "tr" base


column : List (Html.Attribute msg) -> List (Element msg) -> Element msg
column =
    elementAs "td" base



--------------------
-- Input Elements
--------------------


button : List (Html.Attribute msg) -> List (Element msg) -> Element msg
button =
    elementAs "button" base


checkbox : List (Html.Attribute msg) -> List (Element msg) -> Element msg
checkbox attrs children =
    elementAs "input"
        base
        (Html.Attributes.type' "checkbox" :: attrs)
        children


input : List (Html.Attribute msg) -> List (Element msg) -> Element msg
input =
    elementAs "input" base


textarea : List (Html.Attribute msg) -> List (Element msg) -> Element msg
textarea =
    elementAs "textarea" base
