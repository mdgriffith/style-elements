module Style.Internal.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)


type Style class variation animation
    = Style class (List (Property class variation animation))


{-| -}
type BatchedStyle class variation animation
    = Single (Style class variation animation)
    | Many (List (Style class variation animation))


mapClass : (class -> classB) -> Style class variation animation -> Style classB variation animation
mapClass fn (Style class props) =
    Style (fn class) (List.map (mapPropClass fn) props)


mapPropClass : (class -> classB) -> Property class variation animation -> Property classB variation animation
mapPropClass fn prop =
    case prop of
        Child class props ->
            Child (fn class) (List.map (mapPropClass fn) props)

        Variation var props ->
            Variation var (List.map (mapPropClass fn) props)

        Exact name val ->
            Exact name val

        Border props ->
            Border props


type Property class variation animation
    = Exact String String
    | Variation variation (List (Property class Never animation))
    | Child class (List (Property class variation animation))
    | Border BorderModel


type alias BorderModel =
    { color : Maybe ( String, String )
    , width : Maybe ( String, String )
    , radius : Maybe ( String, String )
    , style : Maybe ( String, String )
    }


emptyBorderModel : BorderModel
emptyBorderModel =
    { color = Nothing
    , width = Nothing
    , radius = Nothing
    , style = Nothing
    }


type Length
    = Px Float
    | Percent Float
    | Auto



--| Box String ( Float, Float, Float, Float )
--| Len String Length
--| Filters (List Filter)
--| Transforms (List Transform)
--| TransitionProperty Transition
--| Shadows (List Shadow)
--| BackgroundImageProp BackgroundImage
--| VisibilityProp Visibility
--| ColorProp String Color
--| MediaQuery String (List (Property variation animation))
--| SubElement String (List (Property variation animation))
--| AnimationProp (Animation (Property variation animation))
--| Spacing ( Float, Float, Float, Float )
--| LayoutProp Layout
--| Position Anchor Float Float
--| RelProp PositionParent
--| FloatProp Floating
--| Inline
--{-| -}
--type Layout
--    = FlexLayout Flexible
--    | TextLayout
--    | TableLayout
--{-| -}
--type Flexible
--    = Flexible
--        { go : Direction
--        , wrap : Bool
--        , horizontal : Centerable Horizontal
--        , vertical : Centerable Vertical
--        }
--{-| -}
--type Direction
--    = Up
--    | GoRight
--    | Down
--    | GoLeft
--type Centerable thing
--    = Center
--    | Stretch
--    | Other thing
--type Vertical
--    = Top
--    | Bottom
--type Horizontal
--    = Left
--    | Right
--propertyName : Property animation variation msg -> String
--propertyName prop =
--    case prop of
--        Spacing _ ->
--            "spacing"
--        LayoutProp _ ->
--            "layout"
--        Property name _ ->
--            name
--        Mix props ->
--            String.join "" <| List.map propertyName props
--        Box name _ ->
--            name
--        Len name _ ->
--            name
--        Filters _ ->
--            "filters"
--        Transforms _ ->
--            "transforms"
--        TransitionProperty _ ->
--            "trans"
--        Shadows _ ->
--            "shadows"
--        BackgroundImageProp _ ->
--            "bg-image"
--        AnimationProp _ ->
--            "anim"
--        VisibilityProp _ ->
--            "vis"
--        ColorProp name _ ->
--            name
--        MediaQuery name _ ->
--            name
--        SubElement name _ ->
--            name
--        Variation name _ ->
--            toString name
--        DynamicAnimation name _ ->
--            toString name
--        FloatProp _ ->
--            "float"
--        RelProp _ ->
--            "rel"
--        Position _ _ _ ->
--            "pos"
--        Inline ->
--            "inline"
--type alias Transition =
--    { property : String
--    , duration : Time
--    , easing : String
--    , delay : Time
--    }
--{-| -}
--type alias BackgroundImage =
--    { src : String
--    , position : ( Float, Float )
--    , repeat : Repeat
--    }
--type alias Keyframes =
--    List ( Float, List ( String, String ) )
--{-| -}
--type Animation prop
--    = Animation
--        { duration : Time
--        , easing : String
--        , repeat : Float
--        , steps : List ( Float, List prop )
--        }
--{-| -}
--type Repeat
--    = RepeatX
--    | RepeatY
--    | Repeat
--    | Space
--    | Round
--    | NoRepeat
--{-| -}
--type Filter
--    = FilterUrl String
--    | Blur Float
--    | Brightness Float
--    | Contrast Float
--    | Grayscale Float
--    | HueRotate Float
--    | Invert Float
--    | Opacity Float
--    | Saturate Float
--    | Sepia Float
--    | DropShadow Shadow
--{-| Floats only work if the parent has its layout set to `TextLayout`.
---}
--type Floating
--    = FloatLeft
--    | FloatRight
--    | FloatTopRight
--    | FloatTopLeft
--{-| -}
--type alias Anchor =
--    ( AnchorVertical, AnchorHorizontal )
--{-|
---}
--type PositionParent
--    = Screen
--    | CurrentPosition
--    | Parent
--{-| -}
--type AnchorVertical
--    = AnchorTop
--    | AnchorBottom
--{-| -}
--type AnchorHorizontal
--    = AnchorLeft
--    | AnchorRight
--{-| -}
--{-| -}
--type TextDecoration
--    = Underline
--    | Overline
--    | Strike
--{-| -}
--type BorderStyle
--    = Solid
--    | Dashed
--    | Dotted
--{-| -}
--type Visibility
--    = Transparent Float
--    | Hidden
--{-| -}
--type Transform
--    = Translate Float Float Float
--    | Rotate Float Float Float
--    | Scale Float Float Float
--type Whitespace
--    = Normal
--    | Pre
--    | PreWrap
--    | PreLine
--    | NoWrap
--{-| -}
--type Shadow
--    = Shadow
--        { kind : String
--        , offset : ( Float, Float )
--        , size : Float
--        , blur : Float
--        , color : Color
--        }
