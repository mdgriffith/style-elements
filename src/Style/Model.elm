module Style.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)


type Model class layoutClass positionClass variation
    = StyleModel
        { selector : Selector class
        , properties : List (Property variation)
        }
    | LayoutModel
        { selector : Selector layoutClass
        , properties : List LayoutProperty
        }
    | PositionModel
        { selector : Selector positionClass
        , properties : List PositionProperty
        }


type Selector class
    = Exactly String
    | Class class
    | AutoClass


type Property variation
    = Property String String
    | Mix (List (Property variation))
    | Box String ( Float, Float, Float, Float )
    | Len String Length
    | Filters (List Filter)
    | Transforms (List Transform)
    | TransitionProperty Transition
    | Shadows (List Shadow)
    | BackgroundImageProp BackgroundImage
    | AnimationProp (Animation (Property variation))
    | VisibilityProp Visibility
    | ColorProp String Color
    | MediaQuery String (List (Property variation))
    | SubElement String (List (Property variation))
    | Variation variation (List (Property variation))


type PositionProperty
    = PositionProp Anchor Float Float
    | RelProp PositionParent
    | FloatProp Floating


{-| -}
type LayoutProperty
    = Spacing ( Float, Float, Float, Float )
    | LayoutProp Layout



--| LayoutVariation variation


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


layoutPropertyName : LayoutProperty -> String
layoutPropertyName layoutProp =
    case layoutProp of
        Spacing _ ->
            "spacing"

        LayoutProp _ ->
            "layout"


propertyName : Property variation -> String
propertyName prop =
    case prop of
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


positionPropertyName : PositionProperty -> String
positionPropertyName prop =
    case prop of
        FloatProp _ ->
            "float"

        RelProp _ ->
            "rel"

        PositionProp _ _ _ ->
            "pos"


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
