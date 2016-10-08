module Style.Model exposing (..)

{-| -}

import Html
import Color exposing (Color)
import Time exposing (Time)


type alias HtmlNode msg =
    List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg


type Element msg
    = Element
        { style : Model
        , node : HtmlNode msg
        , attributes : List (Html.Attribute msg)
        , children : List (Element msg)
        }
    | WeakElement
        { style : List ( String, String )
        , node : HtmlNode msg
        , attributes : List (Html.Attribute msg)
        , children : List (Element msg)
        }
    | Html (Html.Html msg)


{-| -}
type alias Model =
    { layout : Layout
    , visibility : Visibility
    , position : Position
    , cursor : String
    , width : Length
    , height : Length
    , colors : Colors
    , padding : ( Float, Float, Float, Float )
    , text : Text
    , border : Border
    , backgroundImage : Maybe BackgroundImage
    , float : Maybe Floating
    , inline : Bool
    , shadows : List Shadow
    , textShadows : List Shadow
    , insetShadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , transitions : List Transition
    , animation : Maybe Animation
    }


{-| -}
type alias Weak =
    { layout : Maybe Layout
    , visibility : Maybe Visibility
    , position : Maybe Position
    , cursor : Maybe String
    , width : Maybe Length
    , height : Maybe Length
    , colors : Maybe Colors
    , padding : Maybe ( Float, Float, Float, Float )
    , text : Maybe Text
    , border : Maybe Border
    , backgroundImage : Maybe BackgroundImage
    , float : Maybe Floating
    , inline : Bool
    , shadows : List Shadow
    , textShadows : List Shadow
    , insetShadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , transitions : List Transition
    , animation : Maybe Animation
    }


{-| -}
type Animation
    = Animation
        { duration : Time
        , easing : String
        , repeat : Float
        , steps : List ( Float, Weak )
        }


{-| -}
type Transition
    = Transition String Model


{-| -}
type alias BackgroundImage =
    { src : String
    , position : ( Float, Float )
    , repeat : Repeat
    }


{-| -}
type Repeat
    = RepeatX
    | RepeatY
    | Repeat
    | Space
    | Round
    | NoRepeat


{-| -}
type Filter
    = FilterUrl String
    | Blur Float
    | Brightness Float
    | Contrast Float
    | Grayscale Float
    | HueRotate Float
    | Invert Float
    | Opacity Float
    | Saturate Float
    | Sepia Float


{-| Floats only work if the parent has its layout set to `TextLayout`.

Otherwise a warning will be logged and the float property won't be applied.

-}
type Floating
    = FloatLeft
    | FloatRight


{-| -}
type alias Anchor =
    ( AnchorVertical, AnchorHorizontal )


{-|
-}
type RelativeTo
    = Screen
    | CurrentPosition
    | Parent


{-| -}
type AnchorVertical
    = AnchorTop
    | AnchorBottom


{-| -}
type AnchorHorizontal
    = AnchorLeft
    | AnchorRight


{-| -}
type alias Colors =
    { background : Color
    , text : Color
    , border : Color
    }


{-| -}
type alias Position =
    { relativeTo : RelativeTo
    , anchor : ( AnchorVertical, AnchorHorizontal )
    , position : ( Float, Float )
    }


{-| -}
type Length
    = Px Float
    | Percent Float
    | Auto


{-| -}
type Layout
    = FlexLayout Flexible
    | TextLayout Textual
    | TableLayout Table


{-| -}
type alias Table =
    { spacing : ( Float, Float, Float, Float )
    }


{-| -}
type alias Textual =
    { spacing : ( Float, Float, Float, Float )
    }


{-| -}
type alias Flexible =
    { go : Direction
    , wrap : Bool
    , spacing : ( Float, Float, Float, Float )
    , horizontal : Alignment
    , vertical : VerticalAlignment
    }


{-| -}
type Direction
    = Up
    | Right
    | Down
    | Left


{-| -}
type VerticalAlignment
    = AlignTop
    | AlignBottom
    | VCenter
    | VStretch


{-| -}
type Alignment
    = AlignLeft
    | AlignRight
    | AlignCenter
    | Justify
    | JustifyAll


{-| -}
type TextDecoration
    = Underline
    | Overline
    | Strike


{-| -}
type BorderStyle
    = Solid
    | Dashed
    | Dotted


type Visibility
    = Transparent Float
    | Hidden


{-| -}
type Transform
    = Translate Float Float Float
    | Rotate Float Float Float
    | Scale Float Float Float


{-| All values are given in 'px' units
-}
type alias Text =
    { font : String
    , size : Float
    , lineHeight : Float
    , characterOffset : Maybe Float
    , italic : Bool
    , boldness : Maybe Float
    , align : Alignment
    , decoration : Maybe TextDecoration
    , whitespace : Whitespace
    }


type Whitespace
    = Normal
    | Pre
    | PreWrap
    | PreLine
    | NoWrap


{-| -}
type alias Shadow =
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }


{-| Border width and corners are always given in px
-}
type alias Border =
    { style : BorderStyle
    , width : ( Float, Float, Float, Float )
    , corners : ( Float, Float, Float, Float )
    }
