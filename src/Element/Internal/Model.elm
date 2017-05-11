module Element.Internal.Model exposing (..)

{-| -}

import Style.Internal.Model as Style
import Html exposing (Html)
import Color exposing (Color)


type ElementSheet elem variation animation msg
    = ElementSheet
        { defaults : Defaults
        , stylesheet : Style.StyleSheet elem variation animation msg
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
    | Layout (HtmlFn msg) Style.LayoutModel (Maybe elem) (List (Attribute variation msg)) (List (Element elem variation msg))


type alias HtmlFn msg =
    List (Html.Attribute msg) -> List (Html msg) -> Html msg


type Attribute variation msg
    = Vary variation Bool
    | Height Style.Length
    | Width Style.Length
    | Inline
    | HAlign HorizontalAlignment
    | VAlign VerticalAlignment
    | Position (Maybe Float) (Maybe Float) (Maybe Float)
    | PositionFrame Frame
    | Hidden
    | Transparency Int
    | Spacing Float Float
    | Margin ( Float, Float, Float, Float )
    | Expand
    | Padding ( Float, Float, Float, Float )
    | PhantomPadding ( Float, Float, Float, Float ) -- Isn't rendered as padding, but is communicated for purposes as inheritance.
    | Event (Html.Attribute msg)
    | InputEvent (Html.Attribute msg)
    | Attr (Html.Attribute msg)
    | GridArea String
    | GridCoords Style.GridPosition
    | PointerEvents Bool


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


type HorizontalAlignment
    = Left
    | Right
    | Center
    | Justify


type VerticalAlignment
    = Top
    | Bottom
    | VerticalCenter
