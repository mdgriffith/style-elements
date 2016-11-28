module Style.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)


type Model class
    = Model
        { selector : Selector class
        , properties :
            List Property
        }


type Selector class
    = Exactly String
    | Class class
    | AutoClass


type Property
    = Property String String
    | Mix (List Property)
    | Box String ( Float, Float, Float, Float )
    | Spacing ( Float, Float, Float, Float )
    | LayoutProp Layout
    | Len String Length
    | Filters (List Filter)
    | Transforms (List Transform)
    | TransitionProperty Transition
    | Shadows (List Shadow)
    | BackgroundImageProp BackgroundImage
    | AnimationProp Animation
    | VisibilityProp Visibility
    | FloatProp Floating
    | RelProp PositionParent
    | PositionProp Anchor Float Float
    | ColorProp String Color
    | MediaQuery String (List Property)
    | SubElement String (List Property)


propertyName : Property -> String
propertyName prop =
    case prop of
        Property name _ ->
            name

        Mix props ->
            String.join "" <| List.map propertyName props

        Box name _ ->
            name

        Spacing _ ->
            "spacing"

        LayoutProp _ ->
            "layout"

        Len name _ ->
            name

        Filters _ ->
            "filters"

        Transforms _ ->
            "transforms"

        TransitionProperty _ ->
            "trans"

        Shadows _ ->
            "shadows"

        BackgroundImageProp _ ->
            "bg-image"

        AnimationProp _ ->
            "anim"

        VisibilityProp _ ->
            "vis"

        FloatProp _ ->
            "float"

        RelProp _ ->
            "rel"

        PositionProp _ _ _ ->
            "pos"

        ColorProp name _ ->
            name

        MediaQuery name _ ->
            name

        SubElement name _ ->
            name


type alias Transition =
    { property : String
    , duration : Time
    , easing : String
    , delay : Time
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
type Animation
    = Animation
        { duration : Time
        , easing : String
        , repeat : Float
        , steps : List ( Float, List Property )
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
type PositionParent
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
    | InlineLayout


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
