module Chat exposing (..)

import Color exposing (rgba)
import Element exposing (..)
import Element.Attributes exposing (..)
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Transition as Transition
import Html
import Html.Attributes as Html


type Styles
    = None
    | Container
    | Label
    | Navbar
    | Sidebar
    | Inspector
    | MessageBox
    | Chat
    | Main
    | H3


colors =
    { mauve = rgba 176 161 186 1
    , blue1 = rgba 165 181 191 1
    , blue2 = rgba 171 200 199 1
    , green1 = rgba 184 226 200 1
    , green2 = rgba 191 240 212 1
    }


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.stylesheet
        [ style None []
        , style Container
            [ Color.text Color.black
            , Color.background colors.blue2
            , Color.border Color.lightGrey
            ]
        , style Chat
            [ Color.background colors.blue1
            ]
        , style Navbar
            [ Color.background colors.mauve
            ]
        , style Sidebar
            [ Color.background colors.green1
            ]
        , style Inspector
            [ Color.background colors.green2
            ]
        , style MessageBox
            [ Color.background colors.blue2 ]
        , style Main
            [ Font.typeface [ "helvetica" ] ]
        , style H3
            [ Font.size 20, Font.weight 400 ]
        ]


main =
    Element.viewport stylesheet <|
        column Main
            [ height <| fill 1 ]
            [ navbar
            , row None
                [ height <| fill 1
                , width <| fill 1
                ]
                [ sidebar, body, inspector ]
            ]


navbar =
    el Navbar [ padding 20 ] (text "Navbar")


sidebar =
    column Sidebar
        [ padding 20
        , alignLeft
        , width <| px 300
        ]
        [ el H3 [] (text "Channels") ]


inspector =
    column Inspector
        [ padding 20
        , alignLeft
        , width <| px 200
        , height <| fill 1
        ]
        [ text "Inspector" ]


body =
    column None
        [ alignLeft
        , width <| fill 1
        ]
        [ messages, messageBox ]


messages =
    column
        Chat
        [ width <| fill 1
        , alignLeft
        , yScrollbar
        ]
        (List.map message <| List.range 1 100)


message n =
    el None
        [ padding 10 ]
        (text <| "message" ++ toString n)


messageBox =
    el MessageBox
        [ height <| px 300
        , width <| fill 1
        , verticalCenter
        ]
        (text "Message box")
