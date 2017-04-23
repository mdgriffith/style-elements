module Element.Internal.Model exposing (..)

{-| -}

import Element.Style.Internal.Model as Internal
import Html exposing (Html)
import Color exposing (Color)


type ElementSheet elem variation animation msg
    = ElementSheet Defaults (elem -> Styled elem variation animation msg)


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
    | Element (Maybe elem) (List (Attribute variation msg)) (Element elem variation msg) (Maybe (List (Element elem variation msg)))
    | Layout Internal.LayoutModel SpacingRestriction (Maybe elem) (List (Attribute variation msg)) (List (Element elem variation msg))


type SpacingRestriction
    = SpacingAllowed
    | NoSpacing


type Attribute variation msg
    = Variations (List ( Bool, variation ))
    | Height Internal.Length
    | Width Internal.Length
    | Anchor AnchorPoint
    | Position Int Int
    | PositionFrame Frame
    | Hidden
    | Transparency Int
    | Spacing ( Float, Float, Float, Float )
    | Padding ( Float, Float, Float, Float )
    | Event (Html.Attribute msg)


type Decoration
    = NoDecoration
    | Bold
    | Italic
    | Underline
    | Strike


type Frame
    = Below
    | Above
    | OnLeft
    | OnRight
    | Screen


type AnchorPoint
    = Left
    | Right
    | Top
    | Bottom


type alias HtmlFn msg =
    List (Html.Attribute msg) -> List (Html msg) -> Html msg


type Styled elem variation animation msg
    = El (HtmlFn msg) (List (StyleAttribute elem variation animation msg))


type StyleAttribute elem variation animation msg
    = Attr (Html.Attribute msg)
    | Style (Internal.Property elem variation animation)
