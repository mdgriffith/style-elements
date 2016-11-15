module Style.Elements.Keyed exposing (keyed, keyedAs)

{-| Build keyed elements.

Based off of Html.Keyed

@docs keyed, keyedAs

-}

import Html.Keyed
import Html exposing (Html)
import Style exposing (Model, Element)
import Style.Model
import List
import Svg.Attributes
import Style.Render


{-| Build a keyed element.

-}
keyed : Model -> List (Html.Attribute a) -> List ( String, Element a ) -> Element a
keyed =
    keyedAs "div"


unzipKeys : List ( String, Element msg ) -> ( List (List Style.Model.StyleDefinition), List ( String, Html msg ) )
unzipKeys pairs =
    let
        step ( key, el ) ( styles, keyedEls ) =
            ( Tuple.first el :: styles
            , ( key, Tuple.second el ) :: keyedEls
            )
    in
        List.foldr step ( [], [] ) pairs


{-|
-}
keyedAs : String -> Model -> List (Html.Attribute msg) -> List ( String, Element msg ) -> Element msg
keyedAs node styleModel attrs elements =
    let
        ( className, styleDef ) =
            Style.Render.render styleModel

        ( childrenStyles, children ) =
            unzipKeys elements

        allStyles =
            styleDef :: List.concat childrenStyles
    in
        ( allStyles
        , Html.Keyed.node node (Svg.Attributes.class className :: attrs) children
        )
