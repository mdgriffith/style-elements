module Element.Internal.Model exposing (..)

{-| -}

import Style.Internal.Model as Internal
import Html exposing (Html)


type Element elem variation
    = Empty
    | Layout Internal.LayoutModel elem (List (Attribute variation)) (List (Element elem variation))
    | Element elem (List (Attribute variation)) (Element elem variation)
    | Text String


type Attribute variation
    = Variations (List ( Bool, variation ))
    | Height Internal.Length
    | Width Internal.Length
    | Position Int Int
    | PositionFrame Frame
      -- | Anchor AnchorPoint
    | Spacing Float Float Float Float
    | Hidden
    | Transparency Int


type Frame
    = Below
    | Above
    | OnLeft
    | OnRight



-- type AnchorPoint
--     = TopLeft
--     | TopRight
--     | BottomLeft
--     | BottomRight


type alias HtmlFn msg =
    List (Html.Attribute msg) -> List (Html msg) -> Html msg


type Styled elem variation animation msg
    = El (HtmlFn msg) (List (StyleAttribute elem variation animation msg))


type StyleAttribute elem variation animation msg
    = Attr (List (Html.Attribute msg))
    | Style (List (Internal.Property elem variation animation))
