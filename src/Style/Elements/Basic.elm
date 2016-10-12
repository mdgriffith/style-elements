module Style.Elements.Basic exposing (..)

{-|

@docs centered, split, floatLeft, floatRight, floatTopLeft, floatTopRight

# Common Text Elements


@docs text, i, b, break, line, dottedList, numberedList

-}

import Html
import Html.Attributes
import Style exposing (..)
import Style.Elements exposing (..)


{-| Flow child elements horizontally to the right and center them.
-}
centered : List (Html.Attribute msg) -> List (Element msg) -> Element msg
centered =
    element
        { empty
            | layout =
                flowRight
                    { wrap = True
                    , horizontal = alignCenter
                    , vertical = alignTop
                    }
        }


{-| Flow child elements horizontally, but have them keep to the edges.
-}
split : List (Html.Attribute msg) -> List (Element msg) -> Element msg
split =
    element
        { empty
            | layout =
                flowRight
                    { wrap = True
                    , horizontal = justify
                    , vertical = verticalCenter
                    }
        }


{-| Float a single element to the left
-}
floatLeft : Element a -> Element a
floatLeft floater =
    element
        { empty
            | float = Just Style.floatLeft
        }
        []
        [ floater ]


{-|
-}
floatRight : Element a -> Element a
floatRight floater =
    element
        { empty
            | float = Just Style.floatRight
        }
        []
        [ floater ]


{-| Float a single element to the left.  "topLeft" means it will ignore top spacing that the parent specifies and use 0px insteas.
-}
floatTopLeft : Element a -> Element a
floatTopLeft floater =
    element
        { empty
            | float = Just Style.floatTopLeft
        }
        []
        [ floater ]


{-|
-}
floatTopRight : Element a -> Element a
floatTopRight floater =
    element
        { empty
            | float = Just Style.floatTopRight
        }
        []
        [ floater ]



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
        [ Html.Attributes.style
            [ ( "font-style", "italic" )
            ]
        , Html.Attributes.class "inline"
        ]
        [ text str ]


{-| -}
b : String -> Element msg
b str =
    html
        Html.b
        [ Html.Attributes.style
            [ ( "font-weight", "bold" )
            ]
        , Html.Attributes.class "inline"
        ]
        [ text str ]


{-| -}
break : Element msg
break =
    html Html.br [ Html.Attributes.class "inline" ] []


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
        , Html.Attributes.class "inline"
        ]
        []


{-| An unordered list that sets all children as `li` elements.
-}
dottedList : List (Html.Attribute msg) -> List (Element msg) -> Element msg
dottedList attrs children =
    html
        Html.ul
        attrs
        (List.map (\child -> html Html.li [ Html.Attributes.class "inline" ] [ child ]) children)


{-| An ordered list that sets all children as `li` elements.
-}
numberedList : List (Html.Attribute msg) -> List (Element msg) -> Element msg
numberedList attrs children =
    html
        Html.ol
        attrs
        (List.map
            (\child ->
                html Html.li [ Html.Attributes.class "inline" ] [ child ]
            )
            children
        )
