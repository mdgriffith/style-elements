module ViewSnippets exposing (..)

{-| -}

import Color
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events
import Element.Keyed
import Html exposing (Html)
import StyleSheet exposing (..)


box =
    el Box [ width (px 20), height (px 20) ] empty



{- views -}


emptyElement : Html msg
emptyElement =
    Element.layout (StyleSheet.stylesheet) Element.empty


textElement : Html msg
textElement =
    Element.layout (StyleSheet.stylesheet) (text "My first Element!")


singleElement : Html msg
singleElement =
    Element.layout (StyleSheet.stylesheet) (Element.el None [] Element.empty)


singleElementText : Html msg
singleElementText =
    Element.layout (StyleSheet.stylesheet) (Element.el None [] (text "My first Element!"))


viewBox : Html msg
viewBox =
    Element.layout (StyleSheet.stylesheet) <|
        box


viewRow : Html msg
viewRow =
    Element.layout (StyleSheet.stylesheet) <|
        Element.row None
            []
            [ box
            , box
            , box
            ]


viewRowWithSpacing : Html msg
viewRowWithSpacing =
    Element.layout (StyleSheet.stylesheet) <|
        Element.row None
            [ spacingXY 20 20 ]
            [ box
            , box
            , box
            ]


viewRowWithSpacingPadding : Html msg
viewRowWithSpacingPadding =
    Element.layout (StyleSheet.stylesheet) <|
        Element.row None
            [ spacingXY 20 20, padding 100 ]
            [ box
            , box
            , box
            ]
