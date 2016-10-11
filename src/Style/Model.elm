module Style.Model exposing (..)

{-| -}

import Html
import Color exposing (Color)
import Time exposing (Time)


type alias Element msg =
    ( List StyleDefinition, Html.Html msg )


type StyleDefinition
    = StyleDef
        { name : String
        , tags : List String
        , style : List ( String, String )
        , modes :
            List StyleDefinition
        , keyframes :
            Maybe (List ( Float, List ( String, String ) ))
        }


{-| -}
type alias Model =
    { addClass : Maybe String
    , layout : Layout
    , visibility : Visibility
    , position : Position
    , cursor : String
    , width : Length
    , height : Length
    , colors : Colors
    , spacing : ( Float, Float, Float, Float )
    , padding : ( Float, Float, Float, Float )
    , text : Text
    , border : Border
    , backgroundImage : Maybe BackgroundImage
    , float : Maybe Floating
    , inline : Bool
    , shadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , additional : List ( String, String )
    , transitions : List Transition
    , animation : Maybe Animation
    }


{-| A `Variation` is a style where all the properties are optional.

This is used to construct the target style for animations and transitions.


-}
type alias Variation =
    { visibility : Maybe Visibility
    , position : Maybe ( Float, Float )
    , cursor : Maybe String
    , width : Maybe Length
    , height : Maybe Length
    , colors : Maybe Colors
    , padding : Maybe ( Float, Float, Float, Float )
    , spacing : Maybe ( Float, Float, Float, Float )
    , text : Maybe Text
    , border : Maybe Border
    , backgroundImagePosition : Maybe ( Float, Float )
    , shadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , additional : List ( String, String )
    }


{-| -}
type Animation
    = Animation
        { duration : Time
        , easing : String
        , repeat : Float
        , steps : List ( Float, Variation )
        }


{-| -}
type Transition
    = Transition String Variation


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
    | TextLayout
    | TableLayout


{-| -}
type alias Flexible =
    { go : Direction
    , wrap : Bool
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
type Shadow
    = Shadow
        { kind : String
        , offset : ( Float, Float )
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
