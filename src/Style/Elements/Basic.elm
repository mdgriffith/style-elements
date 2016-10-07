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
    elementAs Html.h1
        { base
            | text =
                { defaultText | size = 32 }
        }


h2 : List (Html.Attribute msg) -> List (Element msg) -> Element msg
h2 =
    elementAs Html.h2
        { base
            | text =
                { defaultText | size = 24 }
        }


h3 : List (Html.Attribute msg) -> List (Element msg) -> Element msg
h3 =
    elementAs Html.h3
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
    elementAs Html.a
        { base
            | cursor = "pointer"
        }


break : Element msg
break =
    elementAs Html.br
        base
        []
        []


rule : Element msg
rule =
    elementAs Html.hr
        base
        []
        []


text : String -> Element msg
text str =
    elementAs (\_ _ -> Html.text str)
        base
        []
        []


image : String -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
image src attrs children =
    elementAs Html.img
        base
        (Html.Attributes.src src :: attrs)
        children


icon : String -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
icon str attrs children =
    element
        base
        attrs
        (text str :: children)


i : List (Html.Attribute msg) -> List (Element msg) -> Element msg
i =
    elementAs Html.i
        { base
            | text =
                { defaultText | italic = True }
        }


b : List (Html.Attribute msg) -> List (Element msg) -> Element msg
b =
    elementAs Html.i
        { base
            | text =
                { defaultText | boldness = bold }
        }



-------------------
-- Table Creation
-------------------


table : List (Html.Attribute msg) -> List (Element msg) -> Element msg
table =
    elementAs Html.table
        { base
            | layout = Style.tableLayout { spacing = all 0 }
        }


tableHeader : List (Html.Attribute msg) -> List (Element msg) -> Element msg
tableHeader =
    elementAs Html.th base


row : List (Html.Attribute msg) -> List (Element msg) -> Element msg
row =
    elementAs Html.tr base


column : List (Html.Attribute msg) -> List (Element msg) -> Element msg
column =
    elementAs Html.td base



--------------------
-- Input Elements
--------------------


button : List (Html.Attribute msg) -> List (Element msg) -> Element msg
button =
    elementAs Html.button base


checkbox : List (Html.Attribute msg) -> List (Element msg) -> Element msg
checkbox attrs children =
    elementAs Html.input
        base
        (Html.Attributes.type' "checkbox" :: attrs)
        children


input : List (Html.Attribute msg) -> List (Element msg) -> Element msg
input =
    elementAs Html.input base


textarea : List (Html.Attribute msg) -> List (Element msg) -> Element msg
textarea =
    elementAs Html.textarea base
