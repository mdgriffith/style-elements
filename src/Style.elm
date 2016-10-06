module Style exposing (..)

import Html
import Html.Attributes
import Animation
import Color exposing (Color)


(=>) =
    (,)


type alias HtmlNode msg =
    List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg


type Element msg
    = Element
        { style : Model
        , node : HtmlNode msg
        , attributes : List (Html.Attribute msg)
        , children : List (Element msg)
        }
    | Html (Html.Html msg)


type alias Model =
    { layout : Layout
    , visibility : Visibility
    , position : Position
    , cursor : String
    , width : Length
    , height : Length
    , colors : Colors
    , padding : ( Float, Float, Float, Float )
    , text : Text
    , border : Border
    , float : Maybe Floating
    , inline : Bool
    , shadows : List Shadow
    , textShadows : List Shadow
    , insetShadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , onHover : Maybe Transition
    , onFocus : Maybe Transition
    }


type Transition
    = Transition Model


transitionTo : Model -> Maybe Transition
transitionTo model =
    Just (Transition model)


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


{-| Floats only work if the parent has its layout set to `TextLayout`.

Otherwise a warning will be logged and the float property won't be applied.

-}
type Floating
    = FloatLeft
    | FloatRight


{-|

-}
floatLeft : Floating
floatLeft =
    FloatLeft


{-|

-}
floatRight : Floating
floatRight =
    FloatRight


type alias Colors =
    { background : Color
    , text : Color
    , border : Color
    }


type alias Position =
    { relativeTo : RelativeTo
    , anchor : ( AnchorVertical, AnchorHorizontal )
    , position : ( Float, Float )
    }


{-|
-}
type RelativeTo
    = Screen
    | CurrentPosition
    | Parent


screen : RelativeTo
screen =
    Screen


parent : RelativeTo
parent =
    Parent


currentPosition : RelativeTo
currentPosition =
    CurrentPosition


type alias Anchor =
    ( AnchorVertical, AnchorHorizontal )


type AnchorVertical
    = AnchorTop
    | AnchorBottom


type AnchorHorizontal
    = AnchorLeft
    | AnchorRight


{-| -}
topLeft : Anchor
topLeft =
    AnchorTop => AnchorLeft


{-| -}
topRight : Anchor
topRight =
    AnchorTop => AnchorRight


{-| -}
bottomLeft : Anchor
bottomLeft =
    AnchorBottom => AnchorLeft


{-| -}
bottomRight : Anchor
bottomRight =
    AnchorBottom => AnchorRight


type Length
    = Px Float
    | Percent Float
    | Auto


{-| -}
px : Float -> Length
px x =
    Px x


{-| -}
percent : Float -> Length
percent x =
    Percent x


{-| -}
auto : Length
auto =
    Auto


type Layout
    = FlexLayout Flexible
    | TextLayout Textual
    | TableLayout Table


textLayout : Textual -> Layout
textLayout t =
    TextLayout t


tableLayout : Table -> Layout
tableLayout t =
    TableLayout t


flexLayout : Flexible -> Layout
flexLayout t =
    FlexLayout t


type alias Table =
    { spacing : ( Float, Float, Float, Float )
    }


type alias Textual =
    { spacing : ( Float, Float, Float, Float )
    }


type alias Flexible =
    { go : Direction
    , wrap : Bool
    , spacing : ( Float, Float, Float, Float )
    , align : ( HorizontalJustification, VerticalJustification )
    }


type Direction
    = Up
    | Right
    | Down
    | Left


{-| -}
center : ( HorizontalJustification, VerticalJustification )
center =
    ( HCenter, VCenter )


type HorizontalJustification
    = HLeft
    | HRight
    | HCenter
    | HStretch


toLeft : HorizontalJustification
toLeft =
    HLeft


toRight : HorizontalJustification
toRight =
    HRight


horizontalCenter : HorizontalJustification
horizontalCenter =
    HCenter


horizontalStretch : HorizontalJustification
horizontalStretch =
    HStretch


type VerticalJustification
    = VTop
    | VBottom
    | VCenter
    | VStretch


verticalCenter : VerticalJustification
verticalCenter =
    VCenter


toTop : VerticalJustification
toTop =
    VTop


toBottom : VerticalJustification
toBottom =
    VBottom


verticalStretch : VerticalJustification
verticalStretch =
    VStretch


type TextAlignment
    = AlignLeft
    | AlignRight
    | AlignCenter
    | Justify
    | JustifyAll


{-| -}
justify : TextAlignment
justify =
    Justify


{-| -}
justifyAll : TextAlignment
justifyAll =
    JustifyAll


{-| -}
alignLeft : TextAlignment
alignLeft =
    AlignLeft


{-| -}
alignRight : TextAlignment
alignRight =
    AlignRight


{-| -}
alignCenter : TextAlignment
alignCenter =
    AlignCenter


{-| All values are given in 'px' units
-}
type alias Text =
    { font : String
    , size : Float
    , lineHeight : Float
    , characterOffset : Maybe Float
    , italic : Bool
    , boldness : Maybe Float
    , align : TextAlignment
    , decoration : Maybe TextDecoration
    }


type TextDecoration
    = Underline
    | Overline
    | Strike


{-| -}
underline : TextDecoration
underline =
    Underline


{-| -}
overline : TextDecoration
overline =
    Overline


{-| -}
strike : TextDecoration
strike =
    Strike


{-| -}
bold : Maybe Float
bold =
    Just 700


{-| -}
light : Maybe Float
light =
    Just 300


{-| -}
bolder : Maybe Float
bolder =
    Just 900


{-| -}
all : a -> ( a, a, a, a )
all x =
    ( x, x, x, x )


{-| -}
left : Float -> ( Float, Float, Float, Float )
left x =
    ( 0, 0, 0, x )


{-| -}
right : Float -> ( Float, Float, Float, Float )
right x =
    ( 0, x, 0, 0 )


{-| -}
top : Float -> ( Float, Float, Float, Float )
top x =
    ( x, 0, 0, 0 )


{-| -}
bottom : Float -> ( Float, Float, Float, Float )
bottom x =
    ( 0, 0, x, 0 )


{-| -}
topBottom : Float -> ( Float, Float, Float, Float )
topBottom x =
    ( x, 0, x, 0 )


{-| -}
leftRight : Float -> ( Float, Float, Float, Float )
leftRight x =
    ( 0, x, 0, x )


{-| -}
allButRight : Float -> ( Float, Float, Float, Float )
allButRight x =
    ( x, 0, x, x )


{-| -}
allButLeft : Float -> ( Float, Float, Float, Float )
allButLeft x =
    ( x, x, x, 0 )


{-| -}
allButTop : Float -> ( Float, Float, Float, Float )
allButTop x =
    ( 0, x, x, x )


{-| -}
allButBottom : Float -> ( Float, Float, Float, Float )
allButBottom x =
    ( x, x, 0, x )


{-| Border width and corners are always given in px
-}
type alias Border =
    { style : BorderStyle
    , width : ( Float, Float, Float, Float )
    , corners : ( Float, Float, Float, Float )
    }


{-| -}
type BorderStyle
    = Solid
    | Dashed
    | Dotted


{-| -}
solid : BorderStyle
solid =
    Solid


{-| -}
dashed : BorderStyle
dashed =
    Dashed


{-| -}
dotted : BorderStyle
dotted =
    Dotted


type Visibility
    = Transparent Float
    | Hidden


{-|
-}
hidden : Visibility
hidden =
    Hidden


{-| A Value between 0 and 1
-}
transparency : Float -> Visibility
transparency x =
    Transparent x


{-| A Value between 0 and 1
-}
opacity : Float -> Visibility
opacity x =
    Transparent (1.0 - x)


type alias Shadow =
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }


type Transform
    = Translate Float Float Float
    | Rotate Float Float Float
    | Scale Float Float Float


{-| Units always given as radians.

Use `x * deg` if you want to use a different set of units.
-}
rotate : Float -> Float -> Float -> Transform
rotate x y z =
    Rotate x y z


{-| Units always always as pixels
-}
translate : Float -> Float -> Float -> Transform
translate x y z =
    Translate x y z


{-| -}
scale : Float -> Float -> Float -> Transform
scale x y z =
    Scale x y z
