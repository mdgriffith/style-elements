module Style exposing (..)

{-|



-}

import Html
import Html.Attributes
import Animation
import Style.Model


type alias Model =
    Style.Model.Model


type alias Element msg =
    Style.Model.Element msg


type alias Colors =
    Style.Model.Colors


type alias Shadow =
    Style.Model.Shadow


type alias Position =
    Style.Model.Position


type alias Transition =
    Style.Model.Transition


type alias Visibility =
    Style.Model.Visibility


type alias TextDecoration =
    Style.Model.TextDecoration


type alias TextAlignment =
    Style.Model.TextAlignment


type alias VerticalJustification =
    Style.Model.VerticalJustification


type alias HorizontalJustification =
    Style.Model.HorizontalJustification


type alias Transform =
    Style.Model.Transform


type alias BorderStyle =
    Style.Model.BorderStyle


type alias Table =
    Style.Model.Table


type alias Flexible =
    Style.Model.Flexible


type alias Layout =
    Style.Model.Layout


type alias Textual =
    Style.Model.Textual


type alias Length =
    Style.Model.Length


type alias Anchor =
    Style.Model.Anchor


type alias RelativeTo =
    Style.Model.RelativeTo


type alias Floating =
    Style.Model.Floating


type alias Repeat =
    Style.Model.Repeat


type alias Border =
    Style.Model.Border


type alias Text =
    Style.Model.Text


(=>) =
    (,)


type alias HtmlNode msg =
    List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg


{-| -}
repeatX : Repeat
repeatX =
    Style.Model.RepeatX


{-| -}
repeatY : Repeat
repeatY =
    Style.Model.RepeatY


{-| -}
repeat : Repeat
repeat =
    Style.Model.Repeat


{-| -}
space : Repeat
space =
    Style.Model.Space


{-| -}
round : Repeat
round =
    Style.Model.Round


{-| -}
noRepeat : Repeat
noRepeat =
    Style.Model.NoRepeat


{-| -}
transitionTo : Model -> Maybe Transition
transitionTo model =
    Just (Style.Model.Transition model)


{-|

-}
floatLeft : Floating
floatLeft =
    Style.Model.FloatLeft


{-|

-}
floatRight : Floating
floatRight =
    Style.Model.FloatRight


{-| -}
screen : RelativeTo
screen =
    Style.Model.Screen


{-| -}
parent : RelativeTo
parent =
    Style.Model.Parent


{-| -}
currentPosition : RelativeTo
currentPosition =
    Style.Model.CurrentPosition


{-| -}
topLeft : Anchor
topLeft =
    Style.Model.AnchorTop => Style.Model.AnchorLeft


{-| -}
topRight : Anchor
topRight =
    Style.Model.AnchorTop => Style.Model.AnchorRight


{-| -}
bottomLeft : Anchor
bottomLeft =
    Style.Model.AnchorBottom => Style.Model.AnchorLeft


{-| -}
bottomRight : Anchor
bottomRight =
    Style.Model.AnchorBottom => Style.Model.AnchorRight


{-| -}
px : Float -> Length
px x =
    Style.Model.Px x


{-| -}
percent : Float -> Length
percent x =
    Style.Model.Percent x


{-| -}
auto : Length
auto =
    Style.Model.Auto


{-| -}
textLayout : Textual -> Layout
textLayout t =
    Style.Model.TextLayout t


{-| -}
tableLayout : Table -> Layout
tableLayout t =
    Style.Model.TableLayout t


type alias Flow =
    { wrap : Bool
    , spacing : ( Float, Float, Float, Float )
    , align : ( HorizontalJustification, VerticalJustification )
    }


{-| -}
flowDown : Flow -> Layout
flowDown { wrap, spacing, align } =
    Style.Model.FlexLayout
        { go = Style.Model.Down
        , wrap = wrap
        , spacing = spacing
        , align = align
        }


{-| -}
flowUp : Flow -> Layout
flowUp { wrap, spacing, align } =
    Style.Model.FlexLayout
        { go = Style.Model.Up
        , wrap = wrap
        , spacing = spacing
        , align = align
        }


{-| -}
flowRight : Flow -> Layout
flowRight { wrap, spacing, align } =
    Style.Model.FlexLayout
        { go = Style.Model.Right
        , wrap = wrap
        , spacing = spacing
        , align = align
        }


{-| -}
flowLeft : Flow -> Layout
flowLeft { wrap, spacing, align } =
    Style.Model.FlexLayout
        { go = Style.Model.Left
        , wrap = wrap
        , spacing = spacing
        , align = align
        }


{-| -}
center : ( HorizontalJustification, VerticalJustification )
center =
    ( Style.Model.HCenter
    , Style.Model.VCenter
    )


{-| -}
toLeft : HorizontalJustification
toLeft =
    Style.Model.HLeft


{-| -}
toRight : HorizontalJustification
toRight =
    Style.Model.HRight


{-| -}
horizontalCenter : HorizontalJustification
horizontalCenter =
    Style.Model.HCenter


{-| -}
horizontalStretch : HorizontalJustification
horizontalStretch =
    Style.Model.HStretch


{-| -}
verticalCenter : VerticalJustification
verticalCenter =
    Style.Model.VCenter


{-| -}
toTop : VerticalJustification
toTop =
    Style.Model.VTop


{-| -}
toBottom : VerticalJustification
toBottom =
    Style.Model.VBottom


{-| -}
verticalStretch : VerticalJustification
verticalStretch =
    Style.Model.VStretch


{-| -}
justify : TextAlignment
justify =
    Style.Model.Justify


{-| -}
justifyAll : TextAlignment
justifyAll =
    Style.Model.JustifyAll


{-| -}
alignLeft : TextAlignment
alignLeft =
    Style.Model.AlignLeft


{-| -}
alignRight : TextAlignment
alignRight =
    Style.Model.AlignRight


{-| -}
alignCenter : TextAlignment
alignCenter =
    Style.Model.AlignCenter


{-| -}
underline : TextDecoration
underline =
    Style.Model.Underline


{-| -}
overline : TextDecoration
overline =
    Style.Model.Overline


{-| -}
strike : TextDecoration
strike =
    Style.Model.Strike


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


{-| -}
solid : BorderStyle
solid =
    Style.Model.Solid


{-| -}
dashed : BorderStyle
dashed =
    Style.Model.Dashed


{-| -}
dotted : BorderStyle
dotted =
    Style.Model.Dotted


{-|
-}
hidden : Visibility
hidden =
    Style.Model.Hidden


{-| A Value between 0 and 1
-}
transparency : Float -> Visibility
transparency x =
    Style.Model.Transparent x


{-| A Value between 0 and 1
-}
opacity : Float -> Visibility
opacity x =
    Style.Model.Transparent (1.0 - x)


{-| Units always given as radians.

Use `x * deg` if you want to use a different set of units.
-}
rotate : Float -> Float -> Float -> Transform
rotate x y z =
    Style.Model.Rotate x y z


{-| Units always always as pixels
-}
translate : Float -> Float -> Float -> Transform
translate x y z =
    Style.Model.Translate x y z


{-| -}
scale : Float -> Float -> Float -> Transform
scale x y z =
    Style.Model.Scale x y z
