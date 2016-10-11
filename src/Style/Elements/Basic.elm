module Style.Elements.Basic exposing (..)

import Html
import Html.Attributes
import Style exposing (..)
import Style.Elements exposing (..)


{-| Flow child elements horizontally and center them.
-}
centered : Style.Model
centered =
    { empty
        | layout =
            flowRight
                { wrap = True
                , spacing = all 10
                , horizontal = alignCenter
                , vertical = verticalCenter
                }
    }


{-| Flow child elements horizontally, but have them keep to the edges.
Good for nav bars with options on both sides
-}
split : List (Html.Attribute msg) -> List (Element msg) -> Element msg
split =
    elementAs "split"
        { empty
            | layout =
                flowRight
                    { wrap = True
                    , spacing = all 10
                    , horizontal = alignCenter
                    , vertical = verticalCenter
                    }
        }


{-| Standard font sizes so you don't have to look them up.
-}
fontSizes : { standard : Float, h1 : Float, h2 : Float, h3 : Float }
fontSizes =
    { standard = 16
    , h3 = 18
    , h2 = 24
    , h1 = 32
    }



-----------------
-- Text Elements
-- Most of these take either no arguments or a single piece of text.
-- This limits what you can do with them but cleans up text areas of the UI code.
-----------------


{-| -}
text : String -> Element msg
text str =
    html (\_ _ -> Html.text str) [] []


{-| -}
i : String -> Element msg
i str =
    html
        Html.i
        [ Html.Attributes.style [ ( "font-style", "italic" ) ] ]
        [ text str ]


{-| -}
b : String -> Element msg
b str =
    html
        Html.b
        [ Html.Attributes.style [ ( "font-weight", "bold" ) ] ]
        [ text str ]


{-| -}
break : Element msg
break =
    html Html.br [] []


{-| -}
line : Element msg
line =
    html
        Html.hr
        [ Html.Attributes.style
            [ ( "height", "1px" )
            , ( "border", "none" )
            , ( "background-color", "#ddd" )
            ]
        ]
        []


{-| -}
dottedList : List (Html.Attribute msg) -> List (Element msg) -> Element msg
dottedList attrs children =
    html
        Html.ul
        attrs
        (List.map (\child -> html Html.li [] [ child ]) children)


{-| -}
numberedList : List (Html.Attribute msg) -> List (Element msg) -> Element msg
numberedList attrs children =
    html
        Html.ol
        attrs
        (List.map
            (\child ->
                html Html.li [] [ child ]
            )
            children
        )
