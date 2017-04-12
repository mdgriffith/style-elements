module Style.Internal.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)


type Style class variation animation
    = Style class (List (Property class variation animation))
    | Import String


mapClass : (class -> classB) -> Style class variation animation -> Style classB variation animation
mapClass fn style =
    case style of
        Style class props ->
            Style (fn class) (List.map (mapPropClass fn) props)

        Import str ->
            Import str


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

        PseudoElement name props ->
            PseudoElement name (List.map (mapPropClass fn) props)

        Shadows shadows ->
            Shadows shadows

        Transform transforms ->
            Transform transforms

        Filters filters ->
            Filters filters

        Visibility v ->
            Visibility v

        Palette p ->
            Palette p

        Transitions t ->
            Transitions t


type Property class variation animation
    = Exact String String
    | Variation variation (List (Property class Never animation))
    | Child class (List (Property class variation animation))
    | MediaQuery String (List (Property class variation animation))
    | PseudoElement String (List (Property class variation animation))
    | Border (List BorderElement)
    | Box (List BoxElement)
    | Position (List PositionElement)
    | Font (List FontElement)
    | Layout LayoutModel
    | Background (List BackgroundElement)
    | Shadows (List ShadowModel)
    | Transform (List Transformation)
    | Filters (List Filter)
    | Visibility Visible
    | Palette (List ColorElement)
    | Transitions (List Transition)


type ColorElement
    = ColorElement String Color


type Transition
    = Transition
        { delay : Time
        , duration : Time
        , easing : String
        , props : List String
        }


type Visible
    = Hidden
    | Invisible
    | Opacity Float


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
    | BackgroundLinearGradient GradientDirection (List GradientStep)


type GradientDirection
    = ToUp
    | ToDown
    | ToRight
    | ToTopRight
    | ToBottomRight
    | ToLeft
    | ToTopLeft
    | ToBottomLeft
    | ToAngle Float


type GradientStep
    = ColorStep Color
    | PercentStep Color Float
    | PxStep Color Float


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
    | OpacityFilter Float
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
    | Rotate Float
    | RotateAround Float Float Float Float
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
