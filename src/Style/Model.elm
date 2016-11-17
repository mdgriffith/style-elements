module Style.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)


type Model class
    = Model
        { class : Maybe class
        , classOverride : Maybe String
        , visibility : Visibility
        , layout : Layout
        , inline : Bool
        , float : Maybe Floating
        , relativeTo : RelativeTo
        , anchor : Anchor
        , position : ( Float, Float )
        , colors : ColorPalette
        , font : Font
        , italic : Bool
        , bold : Maybe Int
        , strike : Bool
        , underline : Bool
        , spacing : ( Float, Float, Float, Float )
        , borderStyle :
            BorderStyle
            --, backgroundImage : Maybe BackgroundImage
            --, shadows : Maybe (List Shadow)
            --, transforms : Maybe (List Transform)
            --, filters : Maybe (List Filter)
        , animation : Maybe (Animation class)
        , media : List (MediaQuery class)
        , zIndex : Maybe Int
        , properties :
            List (Property class)
            --, transition :
            --    Maybe Transition
        , subelements : Maybe (SubElements class)
        }


type Property class
    = Property String String
    | Box String ( Float, Float, Float, Float )
    | Len String Length
    | Filters (List Filter)
    | Transforms (List Transform)
    | TransitionProperty Transition
    | Shadows (List Shadow)
    | BackgroundImageProp BackgroundImage



--| SubElement String (Model a)


type alias SubElements a =
    { hover : Maybe (Model a)
    , focus : Maybe (Model a)
    , checked : Maybe (Model a)
    , after : Maybe (Model a)
    , before : Maybe (Model a)
    , selection : Maybe (Model a)
    }


emptySubElements : SubElements a
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


type alias Keyframes =
    List ( Float, List ( String, String ) )


{-| -}
type Animation a
    = Animation
        { duration : Time
        , easing : String
        , repeat : Float
        , steps : List ( Float, Model a )
        }


type MediaQuery a
    = MediaQuery String (Model a)


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
