module ViewSnippets exposing (..)

{-| -}

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events
import Html exposing (Html)
import StyleSheet exposing (..)


box : Element Styles variation msg
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


singleElementPercentWidthText : Html msg
singleElementPercentWidthText =
    Element.layout (StyleSheet.stylesheet) (Element.el None [ width (percent 60) ] (text "My first Element!"))


centeredSingleElementPercentWidthText : Html msg
centeredSingleElementPercentWidthText =
    Element.layout (StyleSheet.stylesheet) (Element.el None [ center, width (percent 60) ] (text "My first Element!"))


centeredSingleElementText : Html msg
centeredSingleElementText =
    Element.layout (StyleSheet.stylesheet) (Element.el None [ center ] (text "My first Element!"))


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
