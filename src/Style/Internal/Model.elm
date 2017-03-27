module Style.Internal.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)
import Animation.Messenger


type Model class layoutClass positionClass variation animation msg
    = StyleModel
        { selector : Selector class
        , properties : List (Property animation variation msg)
        }
    | LayoutModel
        { selector : Selector layoutClass
        , properties : List (Property animation variation msg)
        }
    | PositionModel
        { selector : Selector positionClass
        , properties : List (Property animation variation msg)
        }


type Selector class
    = Exactly String
    | Class class


type Property animation variation msg
    = Property String String
    | Mix (List (Property animation variation msg))
    | Box String ( Float, Float, Float, Float )
    | Len String Length
    | Filters (List Filter)
    | Transforms (List Transform)
    | TransitionProperty Transition
    | Shadows (List Shadow)
    | BackgroundImageProp BackgroundImage
    | VisibilityProp Visibility
    | ColorProp String Color
    | MediaQuery String (List (Property animation variation msg))
    | SubElement String (List (Property animation variation msg))
    | Variation variation (List (Property animation variation msg))
    | AnimationProp (Animation (Property animation variation msg))
    | DynamicAnimation animation (Animation.Messenger.State msg -> Animation.Messenger.State msg)
    | Spacing ( Float, Float, Float, Float )
    | LayoutProp Layout
    | Position Anchor Float Float
    | RelProp PositionParent
    | FloatProp Floating
    | Inline


type LayoutProperty animation variation msg
    = LayoutProperty (Property animation variation msg)


layoutToProperty : LayoutProperty animation variation msg -> Property animation variation msg
layoutToProperty (LayoutProperty prop) =
    prop


type PositionProperty animation variation msg
    = PositionProp (Property animation variation msg)


positionToProperty : PositionProperty animation variation msg -> Property animation variation msg
positionToProperty (PositionProp prop) =
    prop


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
        , horizontal : Centerable Horizontal
        , vertical : Centerable Vertical
        }


{-| -}
type Direction
    = Up
    | GoRight
    | Down
    | GoLeft


type Centerable thing
    = Center
    | Stretch
    | Other thing


type Vertical
    = Top
    | Bottom


type Horizontal
    = Left
    | Right


propertyName : Property animation variation msg -> String
propertyName prop =
    case prop of
        Spacing _ ->
            "spacing"

        LayoutProp _ ->
            "layout"

        Property name _ ->
            name

        Mix props ->
            String.join "" <| List.map propertyName props

        Box name _ ->
            name

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

        ColorProp name _ ->
            name

        MediaQuery name _ ->
            name

        SubElement name _ ->
            name

        Variation name _ ->
            toString name

        DynamicAnimation name _ ->
            toString name

        FloatProp _ ->
            "float"

        RelProp _ ->
            "rel"

        Position _ _ _ ->
            "pos"

        Inline ->
            "inline"


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
type Animation prop
    = Animation
        { duration : Time
        , easing : String
        , repeat : Float
        , steps : List ( Float, List prop )
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
