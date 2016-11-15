module Style.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)


type Model
    = Model
        { visibility : Visibility
        , layout : Layout
        , inline : Bool
        , float : Maybe Floating
        , relativeTo : RelativeTo
        , anchor : Anchor
        , position : ( Float, Float )
        , cursor : String
        , width : Length
        , height : Length
        , colors : ColorPalette
        , font : Font
        , italic : Bool
        , bold : Maybe Int
        , strike : Bool
        , underline : Bool
        , spacing : ( Float, Float, Float, Float )
        , padding : ( Float, Float, Float, Float )
        , borderStyle : BorderStyle
        , borderWidth : ( Float, Float, Float, Float )
        , borderRadius : ( Float, Float, Float, Float )
        , backgroundImage : Maybe BackgroundImage
        , shadows : Maybe (List Shadow)
        , transforms : Maybe (List Transform)
        , filters : Maybe (List Filter)
        , animation : Maybe Animation
        , media : List (MediaQuery Model)
        , zIndex : Maybe Int
        , minWidth : Maybe Length
        , maxWidth : Maybe Length
        , minHeight : Maybe Length
        , maxHeight : Maybe Length
        , properties : Maybe (List ( String, String ))
        , transition : Maybe Transition
        , subelements : Maybe SubElements
        }


type alias SubElements =
    { hover : Maybe Model
    , focus : Maybe Model
    , checked : Maybe Model
    , after : Maybe Model
    , before : Maybe Model
    , selection : Maybe Model
    }


emptySubElements : SubElements
emptySubElements =
    { hover = Nothing
    , focus = Nothing
    , checked = Nothing
    , after = Nothing
    , before = Nothing
    , selection = Nothing
    }


type alias Transition =
    { property : String
    , duration : Time
    , easing : String
    , delay : Time
    }


type alias Font =
    { font : String
    , size : Float
    , lineHeight : Float
    , letterOffset : Maybe Float
    , align : Alignment
    , whitespace : Whitespace
    }


{-|
-}
type alias ColorPalette =
    { background : Color
    , text : Color
    , border : Color
    }


{-| -}
type alias BackgroundImage =
    { src : String
    , position : ( Float, Float )
    , repeat : Repeat
    }


{-| -}
type StyleDefinition
    = StyleDef
        { name : String
        , tags : List String
        , style : List ( String, String )
        , children : List StyleDefinition
        , animation : Maybe ( Style, Maybe ( String, Keyframes ) )
        , media : List ( String, StyleDefinition )
        }


type alias Animation =
    Animated Model


type alias Style =
    List ( String, String )


type alias Keyframes =
    List ( Float, List ( String, String ) )


{-| -}
type Animated style
    = Animation
        { duration : Time
        , easing : String
        , repeat : Float
        , steps : List ( Float, style )
        }


type MediaQuery style
    = MediaQuery String style


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
    | DropShadow Shadow


{-| Floats only work if the parent has its layout set to `TextLayout`.

Otherwise a warning will be logged and the float property won't be applied.

-}
type Floating
    = FloatLeft
    | FloatRight
    | FloatTopRight
    | FloatTopLeft


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
type Flexible
    = Flexible
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


{-| -}
type Visibility
    = Transparent Float
    | Hidden


{-| -}
type Transform
    = Translate Float Float Float
    | Rotate Float Float Float
    | Scale Float Float Float


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
