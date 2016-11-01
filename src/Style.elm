module Style
    exposing
        ( Model
        , Element
        , ColorPalette
        , Shadow
        , Visibility
        , Alignment
        , VerticalAlignment
        , BackgroundImage
        , Transform
        , Filter
        , Floating
        , BorderStyle
        , Flow
        , Layout
        , Font
        , Whitespace
        , Anchor
        , RelativeTo
        , Repeat
        , Animation
        , Trigger
        , MediaQuery
        , flowUp
        , flowDown
        , flowRight
        , flowLeft
        , textLayout
        , tableLayout
        , top
        , bottom
        , left
        , right
        , all
        , topBottom
        , leftRight
        , leftRightAndTopBottom
        , leftRightTopBottom
        , allButTop
        , allButLeft
        , allButRight
        , allButBottom
        , normal
        , pre
        , preWrap
        , preLine
        , noWrap
        , alignLeft
        , alignRight
        , justify
        , justifyAll
        , alignCenter
        , verticalCenter
        , verticalStretch
        , alignTop
        , alignBottom
        , topLeft
        , bottomRight
        , topRight
        , bottomLeft
        , currentPosition
        , parent
        , screen
        , hidden
        , visible
        , opacity
        , transparency
        , auto
        , px
        , percent
        , solid
        , dotted
        , dashed
        , floatLeft
        , floatRight
        , floatTopLeft
        , floatTopRight
        , scale
        , translate
        , rotate
        , repeat
        , repeatX
        , repeatY
        , space
        , round
        , noRepeat
        , filterUrl
        , blur
        , brightness
        , contrast
        , grayscale
        , hueRotate
        , invert
        , opacityFilter
        , saturate
        , sepia
        , shadow
        , insetShadow
        , textShadow
        , dropShadow
        , on
        , onWith
        , animate
        , animateOn
        , hover
        , focus
        , checked
        , selection
        , after
        , before
        , empty
        , variation
        , mediaQuery
        , layout
        , visibility
        , relativeTo
        , anchor
        , position
        , colors
        , font
        , italicize
        , bold
        , light
        , strike
        , underline
        , borderStyle
        , borderWidth
        , cornerRadius
        , cursor
        , width
        , height
        , padding
        , spacing
        , float
        , inline
        , backgroundImage
        , shadows
        , transforms
        , filters
        , animations
        , media
        , properties
        )

{-|

This module is focused around composing a style.

@docs Model, empty, variation

@docs anchor, position, relativeTo



# Layouts

Layouts affect how children are arranged.  In this library, layout is controlled by the parent element.

@docs layout, Layout, textLayout, tableLayout

@docs Flow, flowUp, flowDown, flowRight, flowLeft

@docs Alignment, alignLeft, alignRight, justify, justifyAll, alignCenter

@docs VerticalAlignment, verticalCenter, verticalStretch, alignTop, alignBottom


# Colors

@docs colors, ColorPalette


# Inline

@docs inline


# Float

@docs float, Floating, floatLeft, floatRight, floatTopLeft, floatTopRight



# Visibility

@docs visibility, Visibility, hidden, opacity, transparency, visible


# Units

@docs height, width

Most values in this library have one set of units chosen and built in to the library.

However, `width` and `height` values can be pixels, percent, or auto.

@docs percent, px, auto


# Positioning

The coordinates for the `position` value in the style model are x and y coordinates where right and down are the positive directions, same as the standard coordinate system for svg.

These coordinates are always rendered in pixels.

@docs position

@docs relativeTo, RelativeTo, parent, currentPosition, screen

@docs anchor, Anchor, topLeft, topRight, bottomLeft, bottomRight


# A Note on Padding and Margins

In CSS `padding` and `margin` are interesting when you have a parent and a child element.  You now have two ways of specifying the spacing of the child element within the parent.  Either the `margin` on the child or the `padding` on the parent.  This causes anxiety in the developer.

In the effort of having only one good way to accomplish something, we only allow the `padding` property to be set.

We introduce the `spacing` attribute, which sets the spacing between all _child_ elements (using the margin property).

> __Some exceptions__
>
> `inline` elements are not affected by spacing.
>
> Floating elements will only respect certain spacing values.

@docs padding, spacing


# Padding, Spacing, and Borders

Padding, spacing, and border widths are all specified by a tuple of four floats that represent (top, right, bottom, left).  These are all rendered as `px` values.

The following are convenience functions for setting these values.

@docs all, top, bottom, left, right, topBottom, leftRight, leftRightAndTopBottom, leftRightTopBottom, allButTop, allButLeft, allButRight, allButBottom

## Borderstyles


@docs borderStyle, borderWidth, BorderStyle, solid, dotted, dashed, cornerRadius


# Text/Font

@docs font, Font, Whitespace, normal, pre, preLine, preWrap, noWrap, italicize, bold, light, strike, underline, cursor


# Background Images

@docs backgroundImage, BackgroundImage, Repeat, repeat, repeatX, repeatY, noRepeat, round, space


@docs properties

# Shadows

@docs shadows, Shadow, shadow, insetShadow, textShadow, dropShadow


# Transforms

@docs transforms, Transform, translate, rotate, scale

# Filters

@docs filters, Filter, filterUrl, blur, brightness, contrast, grayscale, hueRotate, invert, opacityFilter, saturate, sepia



# Animations

@docs animations, Animation, on, onWith, animate, animateOn

## Animation triggers.

@docs Trigger, selection, after, before, hover, focus, checked




# Media Queries

@docs media, MediaQuery, mediaQuery

# Element
@docs Element


-}

import Html
import Time exposing (Time)
import Color exposing (Color)
import Style.Model exposing (Model(..))


{-| The full model for a style.

Some properties are mandatory in order to make predictable styles.

-}
type alias Model =
    Style.Model.Model


{-| -}
empty : Model
empty =
    Model
        { layout = textLayout
        , visibility = visible
        , relativeTo = currentPosition
        , anchor = topLeft
        , position = ( 0, 0 )
        , colors =
            { background = Color.rgba 255 255 255 0
            , text = Color.darkCharcoal
            , border = Color.grey
            }
        , font =
            { font = "georgia"
            , size = 16
            , characterOffset = Nothing
            , lineHeight = 1.7
            , align = alignLeft
            , whitespace = normal
            }
        , italic = False
        , bold = Nothing
        , strike = False
        , underline = False
        , borderStyle = solid
        , borderWidth = all 0
        , cornerRadius = all 0
        , cursor = "auto"
        , width = auto
        , height = auto
        , padding = all 0
        , spacing = all 0
        , float = Nothing
        , inline = False
        , backgroundImage = Nothing
        , shadows = []
        , transforms = []
        , filters = []
        , animations = []
        , media = []
        , properties = []
        }


{-| A `variation` is a style where all the properties are optional.

If you were to render it without setting anything the class wouldn't have any properties in it.

Use this sparingly.  Your default should be to use `Style.empty` as your starting point.

`Style.variation` should be used for animations and inline elements.

-}
variation : Model
variation =
    Variation
        { layout = Nothing
        , visibility = Nothing
        , relativeTo = Nothing
        , anchor = Nothing
        , position = Nothing
        , colors = Nothing
        , font = Nothing
        , italic = False
        , bold = Nothing
        , strike = False
        , underline = False
        , borderStyle = Nothing
        , borderWidth = Nothing
        , cornerRadius = Nothing
        , cursor = Nothing
        , width = Nothing
        , height = Nothing
        , padding = Nothing
        , spacing = Nothing
        , float = Nothing
        , inline = False
        , backgroundImage = Nothing
        , shadows = []
        , transforms = []
        , filters = []
        , animations = []
        , media = []
        , properties = []
        }


{-|
-}
type alias Element msg =
    ( List Style.Model.StyleDefinition, Html.Html msg )


{-| -}
type alias Animation =
    Style.Model.Animated Model


{-| -}
type alias Trigger =
    Style.Model.Trigger


{-| -}
type alias MediaQuery =
    Style.Model.MediaQuery Model


{-|
-}
type alias ColorPalette =
    { background : Color
    , text : Color
    , border : Color
    }


{-| -}
type alias BackgroundImage =
    { src : String
    , position : ( Float, Float )
    , repeat : Repeat
    }


{-|
-}
type alias Shadow =
    Style.Model.Shadow


{-|
-}
type alias Visibility =
    Style.Model.Visibility


{-| Used for specifying text alignment and the horizontal alignment of in flex layouts
-}
type alias Alignment =
    Style.Model.Alignment


{-|
-}
type alias VerticalAlignment =
    Style.Model.VerticalAlignment


{-|
-}
type alias Transform =
    Style.Model.Transform


{-|
-}
type alias BorderStyle =
    Style.Model.BorderStyle


{-|
-}
type alias Flexible =
    Style.Model.Flexible


{-|
-}
type alias Layout =
    Style.Model.Layout


{-|
-}
type alias Length =
    Style.Model.Length


{-| Only rendered if the parent is a textLayout.
-}
type alias Floating =
    Style.Model.Floating


{-|
-}
type alias Anchor =
    Style.Model.Anchor


{-|
-}
type alias RelativeTo =
    Style.Model.RelativeTo


{-|
-}
type alias Repeat =
    Style.Model.Repeat


{-| All values are given in 'px' units except for lineHeight which is given in proportion to the fontsize.

So, a fontsize of 16 and a lineHeight of 1 means that the lineheight is going to be 16px.
-}
type alias Font =
    Style.Model.Font


{-| -}
type alias Whitespace =
    Style.Model.Whitespace


{-|
-}
type alias Filter =
    Style.Model.Filter


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


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


{-| Float something to the left.  Only valid in textLayouts.

Will ignore any left spacing that it's parent has set for it.

-}
floatLeft : Floating
floatLeft =
    Style.Model.FloatLeft


{-|

-}
floatRight : Floating
floatRight =
    Style.Model.FloatRight


{-| Same as floatLeft, except it will ignore any top spacing that it's parent has set for it.

This is useful for floating things at the beginning of text.

-}
floatTopLeft : Floating
floatTopLeft =
    Style.Model.FloatLeftTop


{-|

-}
floatTopRight : Floating
floatTopRight =
    Style.Model.FloatRightTop


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
layout : Layout -> Model -> Model
layout myLayout model =
    case model of
        Model state ->
            Model { state | layout = myLayout }

        Variation state ->
            Variation { state | layout = Just myLayout }


{-| -}
visibility : Visibility -> Model -> Model
visibility vis model =
    case model of
        Model state ->
            Model { state | visibility = vis }

        Variation state ->
            Variation { state | visibility = Just vis }


{-| -}
anchor : Anchor -> Model -> Model
anchor anc model =
    case model of
        Model state ->
            Model { state | anchor = anc }

        Variation state ->
            Variation { state | anchor = Just anc }


{-| -}
relativeTo : RelativeTo -> Model -> Model
relativeTo rel model =
    case model of
        Model state ->
            Model { state | relativeTo = rel }

        Variation state ->
            Variation { state | relativeTo = Just rel }


{-| -}
position : ( Float, Float ) -> Model -> Model
position pos model =
    case model of
        Model state ->
            Model { state | position = pos }

        Variation state ->
            Variation { state | position = Just pos }


{-| -}
cursor : String -> Model -> Model
cursor curs model =
    case model of
        Model state ->
            Model { state | cursor = curs }

        Variation state ->
            Variation { state | cursor = Just curs }


{-| -}
width : Length -> Model -> Model
width w model =
    case model of
        Model state ->
            Model { state | width = w }

        Variation state ->
            Variation { state | width = Just w }


{-| -}
height : Length -> Model -> Model
height h model =
    case model of
        Model state ->
            Model { state | height = h }

        Variation state ->
            Variation { state | height = Just h }


{-| -}
colors : ColorPalette -> Model -> Model
colors palette model =
    case model of
        Model state ->
            Model { state | colors = palette }

        Variation state ->
            Variation { state | colors = Just palette }


{-| -}
spacing : ( Float, Float, Float, Float ) -> Model -> Model
spacing s model =
    case model of
        Model state ->
            Model { state | spacing = s }

        Variation state ->
            Variation { state | spacing = Just s }


{-| -}
padding : ( Float, Float, Float, Float ) -> Model -> Model
padding s model =
    case model of
        Model state ->
            Model { state | padding = s }

        Variation state ->
            Variation { state | padding = Just s }


{-| -}
borderWidth : ( Float, Float, Float, Float ) -> Model -> Model
borderWidth s model =
    case model of
        Model state ->
            Model { state | borderWidth = s }

        Variation state ->
            Variation { state | borderWidth = Just s }


{-| -}
cornerRadius : ( Float, Float, Float, Float ) -> Model -> Model
cornerRadius s model =
    case model of
        Model state ->
            Model { state | cornerRadius = s }

        Variation state ->
            Variation { state | cornerRadius = Just s }


{-| -}
font : Font -> Model -> Model
font text model =
    case model of
        Model state ->
            Model { state | font = text }

        Variation state ->
            Variation { state | font = Just text }


{-| -}
underline : Model -> Model
underline model =
    case model of
        Model state ->
            Model { state | underline = True }

        Variation state ->
            Variation { state | underline = True }


{-| -}
strike : Model -> Model
strike model =
    case model of
        Model state ->
            Model { state | strike = True }

        Variation state ->
            Variation { state | strike = True }


{-| -}
inline : Model -> Model
inline model =
    case model of
        Model state ->
            Model { state | inline = True }

        Variation state ->
            Variation { state | inline = True }


{-| -}
italicize : Model -> Model
italicize model =
    case model of
        Model state ->
            Model { state | italic = True }

        Variation state ->
            Variation { state | italic = True }


{-| -}
bold : Model -> Model
bold model =
    case model of
        Model state ->
            Model { state | bold = Just 700 }

        Variation state ->
            Variation { state | bold = Just 700 }


{-| -}
light : Model -> Model
light model =
    case model of
        Model state ->
            Model { state | bold = Just 300 }

        Variation state ->
            Variation { state | bold = Just 300 }


{-| -}
borderStyle : BorderStyle -> Model -> Model
borderStyle style model =
    case model of
        Model state ->
            Model { state | borderStyle = style }

        Variation state ->
            Variation { state | borderStyle = Just style }


{-| -}
float : Floating -> Model -> Model
float floating model =
    case model of
        Model state ->
            Model { state | float = Just floating }

        Variation state ->
            Variation { state | float = Just floating }


{-| -}
backgroundImage : BackgroundImage -> Model -> Model
backgroundImage style model =
    case model of
        Model state ->
            Model { state | backgroundImage = Just style }

        Variation state ->
            Variation { state | backgroundImage = Just style }


{-| -}
shadows : List Shadow -> Model -> Model
shadows shades model =
    case model of
        Model state ->
            Model { state | shadows = shades }

        Variation state ->
            Variation { state | shadows = shades }


{-| -}
transforms : List Transform -> Model -> Model
transforms trans model =
    case model of
        Model state ->
            Model { state | transforms = trans }

        Variation state ->
            Variation { state | transforms = trans }


{-| -}
filters : List Filter -> Model -> Model
filters filts model =
    case model of
        Model state ->
            Model { state | filters = filts }

        Variation state ->
            Variation { state | filters = filts }


{-| -}
animations : List Animation -> Model -> Model
animations filts model =
    case model of
        Model state ->
            Model { state | animations = filts }

        Variation state ->
            Variation { state | animations = filts }


{-| -}
media : List MediaQuery -> Model -> Model
media queries model =
    case model of
        Model state ->
            Model { state | media = queries }

        Variation state ->
            Variation { state | media = queries }


{-| -}
properties : List ( String, String ) -> Model -> Model
properties props model =
    case model of
        Model state ->
            Model { state | properties = props }

        Variation state ->
            Variation { state | properties = props }


{-| This is the only layout that allows for child elements to use `float` or `inline`.

If you try to assign a float or make an element inline that is not the child of a textLayout, the float or inline will be ignored and the element will be highlighted in red with a large warning.

Besides this, all immediate children are arranged as if they were `display: block`.

-}
textLayout : Layout
textLayout =
    Style.Model.TextLayout


{-| This is the same as setting an element to `display:table`.

-}
tableLayout : Layout
tableLayout =
    Style.Model.TableLayout


{-|

-}
type alias Flow =
    { wrap : Bool
    , horizontal : Alignment
    , vertical : VerticalAlignment
    }


{-| This is a flexbox based layout
-}
flowUp : Flow -> Layout
flowUp { wrap, horizontal, vertical } =
    Style.Model.FlexLayout <|
        Style.Model.Flexible
            { go = Style.Model.Up
            , wrap = wrap
            , horizontal = horizontal
            , vertical = vertical
            }


{-|

-}
flowDown : Flow -> Layout
flowDown { wrap, horizontal, vertical } =
    Style.Model.FlexLayout <|
        Style.Model.Flexible
            { go = Style.Model.Down
            , wrap = wrap
            , horizontal = horizontal
            , vertical = vertical
            }


{-| -}
flowRight : Flow -> Layout
flowRight { wrap, horizontal, vertical } =
    Style.Model.FlexLayout <|
        Style.Model.Flexible
            { go = Style.Model.Right
            , wrap = wrap
            , horizontal = horizontal
            , vertical = vertical
            }


{-| -}
flowLeft : Flow -> Layout
flowLeft { wrap, horizontal, vertical } =
    Style.Model.FlexLayout <|
        Style.Model.Flexible
            { go = Style.Model.Left
            , wrap = wrap
            , horizontal = horizontal
            , vertical = vertical
            }


{-| -}
normal : Whitespace
normal =
    Style.Model.Normal


{-| -}
pre : Whitespace
pre =
    Style.Model.Pre


{-| -}
preWrap : Whitespace
preWrap =
    Style.Model.PreWrap


{-| -}
preLine : Whitespace
preLine =
    Style.Model.PreLine


{-| -}
noWrap : Whitespace
noWrap =
    Style.Model.NoWrap


{-| -}
alignTop : VerticalAlignment
alignTop =
    Style.Model.AlignTop


{-| -}
alignBottom : VerticalAlignment
alignBottom =
    Style.Model.AlignBottom


{-| -}
verticalStretch : VerticalAlignment
verticalStretch =
    Style.Model.VStretch


{-| -}
verticalCenter : VerticalAlignment
verticalCenter =
    Style.Model.VCenter


{-| -}
justify : Alignment
justify =
    Style.Model.Justify


{-| -}
justifyAll : Alignment
justifyAll =
    Style.Model.JustifyAll


{-| -}
alignLeft : Alignment
alignLeft =
    Style.Model.AlignLeft


{-| -}
alignRight : Alignment
alignRight =
    Style.Model.AlignRight


{-| -}
alignCenter : Alignment
alignCenter =
    Style.Model.AlignCenter


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
leftRightAndTopBottom : Float -> Float -> ( Float, Float, Float, Float )
leftRightAndTopBottom x y =
    ( y, x, y, x )


{-| -}
leftRightTopBottom : Float -> Float -> Float -> Float -> ( Float, Float, Float, Float )
leftRightTopBottom l r t b =
    ( t, r, b, l )


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


{-|
-}
visible : Visibility
visible =
    Style.Model.Transparent 0


{-| A value between 0 and 1
-}
transparency : Float -> Visibility
transparency x =
    Style.Model.Transparent x


{-| A value between 0 and 1
-}
opacity : Float -> Visibility
opacity x =
    Style.Model.Transparent (1.0 - x)


{-| -}
shadow :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color.Color
    }
    -> Shadow
shadow { offset, size, blur, color } =
    Style.Model.Shadow
        { kind = "box"
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }


{-| -}
insetShadow :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color.Color
    }
    -> Shadow
insetShadow { offset, blur, color, size } =
    Style.Model.Shadow
        { kind = "inset"
        , offset = offset
        , size = size
        , blur = blur
        , color = color
        }


{-| -}
textShadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color.Color
    }
    -> Shadow
textShadow { offset, blur, color } =
    Style.Model.Shadow
        { kind = "text"
        , offset = offset
        , size = 0
        , blur = blur
        , color = color
        }


{-|
-}
dropShadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color.Color
    }
    -> Shadow
dropShadow { offset, blur, color } =
    Style.Model.Shadow
        { kind = "drop"
        , offset = offset
        , size = 0
        , blur = blur
        , color = color
        }


{-| Units always rendered as `radians`.

Use `x * deg` or `x * turn` from the standard library if you want to use a different set of units.
-}
rotate : Float -> Float -> Float -> Transform
rotate x y z =
    Style.Model.Rotate x y z


{-| Units are always as pixels
-}
translate : Float -> Float -> Float -> Transform
translate x y z =
    Style.Model.Translate x y z


{-| -}
scale : Float -> Float -> Float -> Transform
scale x y z =
    Style.Model.Scale x y z


{-| -}
filterUrl : String -> Filter
filterUrl s =
    Style.Model.FilterUrl s


{-| -}
blur : Float -> Filter
blur x =
    Style.Model.Blur x


{-| -}
brightness : Float -> Filter
brightness x =
    Style.Model.Brightness x


{-| -}
contrast : Float -> Filter
contrast x =
    Style.Model.Contrast x


{-| -}
grayscale : Float -> Filter
grayscale x =
    Style.Model.Grayscale x


{-| -}
hueRotate : Float -> Filter
hueRotate x =
    Style.Model.HueRotate x


{-| -}
invert : Float -> Filter
invert x =
    Style.Model.Invert x


{-| -}
opacityFilter : Float -> Filter
opacityFilter x =
    Style.Model.Opacity x


{-| -}
saturate : Float -> Filter
saturate x =
    Style.Model.Saturate x


{-| -}
sepia : Float -> Filter
sepia x =
    Style.Model.Sepia x


{-| -}
mediaQuery : String -> Model -> MediaQuery
mediaQuery name variation =
    Style.Model.MediaQuery name variation


{-| Create a transition by specifying a pseudo class and the target style as a Variation.  For example to make a transition on hover, you'd do the following:

```on hover { variation | colors = linkHover }```

Defaults to duration 300, easing as "ease"

-}
on : Trigger -> Model -> Animation
on trigger model =
    Style.Model.Animation
        { trigger = trigger
        , duration = 300
        , easing = "ease"
        , frames = Style.Model.Transition model
        }


{-| Set a custom duration and easing for the transition.

Easings are given as strings as they would be in css:

https://developer.mozilla.org/en-US/docs/Web/CSS/animation-timing-function

-}
onWith : Trigger -> { duration : Time, easing : String } -> Model -> Animation
onWith trigger { duration, easing } model =
    Style.Model.Animation
        { trigger = trigger
        , duration = duration
        , easing = easing
        , frames = Style.Model.Transition model
        }


{-| Begin an animation as soon as the elment is mounted.
-}
animate :
    { duration : Time
    , easing : String
    , repeat : Float
    , steps : List ( Float, Model )
    }
    -> Animation
animate { duration, easing, repeat, steps } =
    Style.Model.Animation
        { trigger = Style.Model.Mount
        , duration = duration
        , easing = easing
        , frames =
            Style.Model.Keyframes
                { repeat = repeat
                , steps = steps
                }
        }


{-| Begin an animation on a trigger.

-}
animateOn :
    Trigger
    -> { duration : Time
       , easing : String
       , repeat : Float
       , steps : List ( Float, Model )
       }
    -> Animation
animateOn trigger { duration, easing, repeat, steps } =
    Style.Model.Animation
        { trigger = trigger
        , duration = duration
        , easing = easing
        , frames =
            Style.Model.Keyframes
                { repeat = repeat
                , steps = steps
                }
        }


{-| -}
hover : Trigger
hover =
    Style.Model.PseudoClass ":hover"


{-| -}
focus : Trigger
focus =
    Style.Model.PseudoClass ":focus"


{-| -}
checked : Trigger
checked =
    Style.Model.PseudoClass ":checked"


{-| -}
selection : Trigger
selection =
    Style.Model.PseudoClass "::selection"


{-| -}
after : Trigger
after =
    Style.Model.PseudoClass "::after"


{-| -}
before : Trigger
before =
    Style.Model.PseudoClass "::before"
