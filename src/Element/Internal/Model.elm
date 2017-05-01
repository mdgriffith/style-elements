module Element.Internal.Model exposing (..)

{-| -}

import Style.Internal.Model as Internal
import Html exposing (Html)
import Color exposing (Color)


type ElementSheet elem variation animation msg
    = ElementSheet
        { defaults : Defaults
        , stylesheet : Internal.StyleSheet elem variation animation msg
        }


type alias Defaults =
    { typeface : List String
    , fontSize : Float
    , lineHeight : Float
    , textColor : Color
    }


type Element elem variation msg
    = Empty
    | Spacer Float
    | Text Decoration String
    | Element (HtmlFn msg) (Maybe elem) (List (Attribute variation msg)) (Element elem variation msg) (Maybe (List (Element elem variation msg)))
    | Layout (HtmlFn msg) Internal.LayoutModel (Maybe elem) (List (Attribute variation msg)) (List (Element elem variation msg))


type alias HtmlFn msg =
    List (Html.Attribute msg) -> List (Html msg) -> Html msg


type Attribute variation msg
    = Vary variation Bool
    | Height Internal.Length
    | Width Internal.Length
    | Inline
    | Align Alignment
    | Position Int Int
    | PositionFrame Frame
    | Hidden
    | Transparency Int
    | Spacing Float Float
    | Expand
    | Padding ( Float, Float, Float, Float )
    | Event (Html.Attribute msg)
    | Attr (Html.Attribute msg)
    | GridArea String
    | GridCoords Internal.GridPosition


type Decoration
    = NoDecoration
    | Bold
    | Italic
    | Underline
    | Strike
    | Super
    | Sub


type Frame
    = Screen
    | Positioned
    | Nearby Close


type Close
    = Below
    | Above
    | OnLeft
    | OnRight


type Anchor
    = TopRight
    | TopLeft
    | BottomRight
    | BottomLeft


type Nearby element
    = IsNearby element


type Anchored element
    = Anchored Anchor element


type Alignment
    = Left
    | Right
    | Top
    | Bottom
    | Center
    | VerticalCenter
    | Justify
