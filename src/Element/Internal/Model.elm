module Element.Internal.Model exposing (..)

{-| -}

import Element.Style.Internal.Model as Internal
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
    , spacing : ( Float, Float, Float, Float )
    , textColor : Color
    }


type Element elem variation msg
    = Empty
    | Text Decoration String
    | Element (HtmlFn msg) (Maybe elem) (List (Attribute variation msg)) (Element elem variation msg) (Maybe (List (Element elem variation msg)))
    | Layout (HtmlFn msg) Internal.LayoutModel (Maybe elem) (List (Attribute variation msg)) (List (Element elem variation msg))


type alias HtmlFn msg =
    List (Html.Attribute msg) -> List (Html msg) -> Html msg


type Attribute variation msg
    = Vary variation Bool
    | LayoutAttr Internal.LayoutModel
    | Height Internal.Length
    | Width Internal.Length
    | Align Alignment
    | Position Int Int
    | PositionFrame Frame
    | Hidden
    | Transparency Int
    | Spacing ( Float, Float, Float, Float )
    | Padding ( Float, Float, Float, Float )
    | Event (Html.Attribute msg)
    | Attr (Html.Attribute msg)


type Decoration
    = NoDecoration
    | Bold
    | Italic
    | Underline
    | Strike
    | Super
    | Sub


type Frame
    = Screen Anchor
    | Nearby Close
    | Within Anchor


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
