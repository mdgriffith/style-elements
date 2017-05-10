module Style.Internal.Model exposing (..)

{-| -}

import Color exposing (Color)
import Time exposing (Time)
import Html


{-| The stylesheet contains the rendered css as a string, and two functions to lookup
-}
type alias StyleSheet class variation animation msg =
    { style : class -> Html.Attribute msg
    , variations : class -> List ( variation, Bool ) -> Html.Attribute msg
    , animations : List animation --(Internal.Animation animation msg)
    , css : String
    }


type Style class variation animation
    = Style class (List (Property class variation animation))
    | RawStyle String (List ( String, String ))
    | Import String


mapClass : (class -> classB) -> Style class variation animation -> Style classB variation animation
mapClass fn style =
    case style of
        Style class props ->
            Style (fn class) (List.map (mapPropClass fn) props)

        Import str ->
            Import str

        RawStyle str props ->
            RawStyle str props


mapPropClass : (class -> classB) -> Property class variation animation -> Property classB variation animation
mapPropClass fn prop =
    case prop of
        Child class props ->
            Child (fn class) (List.map (mapPropClass fn) props)

        Variation var props ->
            Variation var (List.map (mapPropClass fn) props)

        Exact name val ->
            Exact name val

        Box props ->
            Box props

        Position props ->
            Position props

        Font name val ->
            Font name val

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

        TextColor color ->
            TextColor color

        DecorationPalette p ->
            DecorationPalette p

        Transitions t ->
            Transitions t


type Property class variation animation
    = Exact String String
    | Variation variation (List (Property class Never animation))
    | Child class (List (Property class variation animation))
    | MediaQuery String (List (Property class variation animation))
    | PseudoElement String (List (Property class variation animation))
    | Box (List BoxElement)
    | Position (List PositionElement)
    | Font String String
    | Layout LayoutModel
    | Background BackgroundElement
    | Shadows (List ShadowModel)
    | Transform (List Transformation)
    | Filters (List Filter)
    | Visibility Visible
    | TextColor Color
    | DecorationPalette
        { cursor : Maybe Color
        , selection : Maybe Color
        , decoration : Maybe Color
        }
    | Palette
        { text : Color
        , background : Color
        , border : Color
        }
    | Transitions (List Transition)


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


type BoxElement
    = BoxProp String String


type LayoutModel
    = TextLayout
    | FlexLayout Direction (List FlexBoxElement)
    | Grid GridTemplate (List GridAlignment)


type FlexBoxElement
    = Wrap Bool
    | Horz (Centerable Horizontal)
    | Vert (Centerable Vertical)


type GridAlignment
    = GridH (Centerable Horizontal)
    | GridV (Centerable Vertical)
    | GridGap Float Float


type GridTemplate
    = GridTemplate
        { rows : List Length
        , columns : List Length
        }
    | NamedGridTemplate
        { rows : List ( Length, List NamedGridPosition )
        , columns : List Length
        }


type GridPosition
    = GridPosition
        { start : ( Int, Int )
        , width : Int
        , height : Int
        }


type NamedGridPosition
    = Named SpanLength (Maybe String)


type SpanLength
    = SpanAll
    | SpanJust Int


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
    | Fill Float
    | Calc Float Float
