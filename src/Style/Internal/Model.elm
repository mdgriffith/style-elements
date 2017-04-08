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

        Box props ->
            Box props

        Position props ->
            Position props

        Font props ->
            Font props

        Layout props ->
            Layout props

        Background props ->
            Background props

        MediaQuery name props ->
            MediaQuery name (List.map (mapPropClass fn) props)

        Shadows shadows ->
            Shadows shadows

        Transform transforms ->
            Transform transforms

        Filters filters ->
            Filters filters


type Property class variation animation
    = Exact String String
    | Variation variation (List (Property class Never animation))
    | Child class (List (Property class variation animation))
    | MediaQuery String (List (Property class variation animation))
    | Border (List BorderElement)
    | Box (List BoxElement)
    | Position (List PositionElement)
    | Font (List FontElement)
    | Layout LayoutModel
    | Background (List BackgroundElement)
    | Shadows (List ShadowModel)
    | Transform (List Transformation)
    | Filters (List Filter)


type PositionElement
    = RelativeTo PositionParent
    | PosLeft Float
    | PosRight Float
    | PosTop Float
    | PosBottom Float
    | ZIndex Int
    | Inline
    | Float Floating


type PositionParent
    = Screen
    | Current
    | Parent


type Floating
    = FloatLeft
    | FloatRight
    | FloatTopLeft
    | FloatTopRight


type BorderElement
    = BorderElement String String


type BoxElement
    = BoxProp String String


type FontElement
    = FontElement String String


type LayoutModel
    = TextLayout { spacing : Maybe ( Float, Float, Float, Float ) }
    | FlexLayout Direction (List FlexBoxElement)


type FlexBoxElement
    = Wrap Bool
    | Horz (Centerable Horizontal)
    | Vert (Centerable Vertical)
    | Spacing ( Float, Float, Float, Float )


type BackgroundElement
    = BackgroundImage
        { src : String
        , position : ( Float, Float )
        , repeat : Repeat
        }
    | BackgroundElement String String


type ShadowModel
    = ShadowModel
        { kind : String
        , offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }


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
    | DropShadow
        { offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }


type Transformation
    = Translate Float Float Float
    | Rotate Float Float Float
    | Scale Float Float Float
    | Origin Float Float Float


type Repeat
    = RepeatX
    | RepeatY
    | Repeat
    | Space
    | Round
    | NoRepeat


type Direction
    = Up
    | GoRight
    | Down
    | GoLeft


type Centerable thing
    = Center
    | Justify
    | JustifyAll
    | Other thing


type Vertical
    = Top
    | Bottom


type Horizontal
    = Left
    | Right


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
