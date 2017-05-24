module Element.Internal.Model exposing (..)

{-| -}

import Style.Internal.Model as Style
import Html exposing (Html)


type Element style variation msg
    = Empty
    | Spacer Float
    | Text Decoration String
    | Element String (Maybe style) (List (Attribute variation msg)) (Element style variation msg) (Maybe (List (Element style variation msg)))
    | Layout String Style.LayoutModel (Maybe style) (List (Attribute variation msg)) (Children (Element style variation msg))


type Children child
    = Normal (List child)
    | Keyed (List ( String, child ))


mapChildren fn children =
    case children of
        Normal c ->
            Normal (List.map fn c)

        Keyed keyed ->
            Keyed (List.map (Tuple.mapSecond fn) keyed)


{-| -}
type OnGrid thing
    = OnGrid thing


{-| -}
type NamedOnGrid thing
    = NamedOnGrid thing


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
    | Opacity Float
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
    | Relative
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
