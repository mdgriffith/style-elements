module Elements exposing (..)

import Style exposing (default, defaultText)
import Html
import Animation


text str attr =
    Html.text str



--div : Style.Element msg


div =
    Style.element
        Html.div
        Style.default



--nav : Style.Element msg


nav =
    Style.element
        Html.nav
        { default
            | layout = Style.horizontal
        }



--a : Style.Element msg


a =
    Style.element
        Html.a
        Style.default



--header : Style.Element msg


header =
    Style.element
        Html.header
        Style.default



--h2 : Style.Element msg


h2 =
    Style.element Html.h2
        { default
            | text = { defaultText | size = 25 }
        }



--h3 : Style.Element msg


h3 =
    Style.element Html.h3
        { default
            | text = { defaultText | size = 20 }
        }



--h4 : Style.Element msg


h4 =
    Style.element Html.h4
        { default
            | text = { defaultText | size = 22 }
        }


type ButtonStyle
    = NormalButton
    | RedButton



--button : ButtonStyle -> Style.Element msg


button =
    Style.options
        Html.button
        buttonVariations



--buttonVariations : ButtonStyle -> Style.Model


buttonVariations style =
    case style of
        NormalButton ->
            Style.default

        RedButton ->
            Style.default



--animatedButton : Animation.State -> Style.Element msg


animatedButton =
    Style.animated
        Html.button



--p : Style.Element msg


p =
    Style.element
        Html.p
        Style.default
