module Style.Internal.Model exposing (..)

{-| -}


type alias Time =
    Float


type Box item
    = Box item item item item


type Color
    = RGBA Float Float Float Float


{-| The stylesheet contains the rendered css as a string, and two functions to lookup
-}
type alias StyleSheet class variation =
    { style : class -> String
    , variations : class -> List ( variation, Bool ) -> List ( String, Bool )
    , css : String
    }


type Style class variation
    = Style class (List (Property class variation))
    | RawStyle String (List ( String, String ))
    | Import String
    | Reset String -- Completely Bare String to write out


mapClassAndVar : (class -> classB) -> (var -> varB) -> Style class var -> Style classB varB
mapClassAndVar fn fnVariation style =
    case style of
        Style class props ->
            Style (fn class) (List.map (mapPropClassAndVar fn fnVariation) props)

        Import str ->
            Import str

        RawStyle str props ->
            RawStyle str props

        Reset r ->
            Reset r


mapPropClassAndVar : (class -> classB) -> (var -> varB) -> Property class var -> Property classB varB
mapPropClassAndVar fn fnVar prop =
    case prop of
        Child class props ->
            Child (fn class) (List.map (mapPropClassAndVar fn fnVar) props)

        Variation var props ->
            Variation (fnVar var) (List.map (mapPropClass fn) props)

        Exact name val ->
            Exact name val

        Position props ->
            Position props

        Font name val ->
            Font name val

        Layout props ->
            Layout props

        Background props ->
            Background props

        MediaQuery name props ->
            MediaQuery name (List.map (mapPropClassAndVar fn fnVar) props)

        PseudoElement name props ->
            PseudoElement name (List.map (mapPropClassAndVar fn fnVar) props)

        Shadows shadows ->
            Shadows shadows

        Transform transforms ->
            Transform transforms

        Filters filters ->
            Filters filters

        Visibility v ->
            Visibility v

        TextColor color ->
            TextColor color

        Transitions t ->
            Transitions t

        SelectionColor clr ->
            SelectionColor clr

        FontFamily fam ->
            FontFamily fam


mapPropClass : (class -> classB) -> Property class var -> Property classB var
mapPropClass fn prop =
    case prop of
        Child class props ->
            Child (fn class) (List.map (mapPropClass fn) props)

        Variation var props ->
            Variation var (List.map (mapPropClassAndVar fn identity) props)

        Exact name val ->
            Exact name val

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

        TextColor color ->
            TextColor color

        Transitions t ->
            Transitions t

        SelectionColor clr ->
            SelectionColor clr

        FontFamily fam ->
            FontFamily fam


type Property class variation
    = Exact String String
    | Variation variation (List (Property class Never))
    | Child class (List (Property class variation))
    | MediaQuery String (List (Property class variation))
    | PseudoElement String (List (Property class variation))
    | Position (List PositionElement)
    | Font String String
    | FontFamily (List Font)
    | Layout LayoutModel
    | Background BackgroundElement
    | Shadows (List ShadowModel)
    | Transform (List Transformation)
    | Filters (List Filter)
    | Visibility Visible
    | SelectionColor Color
    | TextColor Color
    | Transitions (List Transition)


type Font
    = Serif
    | SansSerif
    | Cursive
    | Fantasy
    | Monospace
    | FontName String
    | ImportFont String String


type BackgroundSize
    = Contain
    | Cover
    | BackgroundWidth Length
    | BackgroundHeight Length
    | BackgroundSize
        { width : Length
        , height : Length
        }


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
    = TextLayout Bool
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
        , size : BackgroundSize
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
