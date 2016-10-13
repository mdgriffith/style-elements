module Style
    exposing
        ( Model
        , Variation
        , Element
        , Colors
        , Position
        , Shadow
        , Transition
        , Visibility
        , TextDecoration
        , Alignment
        , VerticalAlignment
        , BackgroundImage
        , Transform
        , Filter
        , Floating
        , Border
        , BorderStyle
        , Flow
        , Layout
        , Text
        , Whitespace
        , Anchor
        , RelativeTo
        , Repeat
        , Animation
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
        , on
        , scale
        , translate
        , rotate
        , repeat
        , repeatX
        , repeatY
        , space
        , round
        , noRepeat
        , underline
        , overline
        , strike
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
        , bold
        , light
        , bolder
        , animation
        , shadow
        , insetShadow
        , textShadow
        , empty
        , variation
        )

{-| A different take on styling.

@docs Model, empty

@docs Variation, variation



# Layouts

Layouts affect how children are arranged.  It is one of the principles of the library that layout is mostly controlled by the parent element.



@docs Layout, textLayout, tableLayout

@docs Flow, flowUp, flowDown, flowRight, flowLeft



@docs Alignment, alignLeft, alignRight, justify, justifyAll, alignCenter

@docs VerticalAlignment, verticalCenter, verticalStretch, alignTop, alignBottom



# Colors

@docs Colors



# Float & Inline

@docs Floating, floatLeft, floatRight, floatTopLeft, floatTopRight



# Visibility

@docs Visibility, hidden, opacity, transparency, visible



# Units

Most values in this library have one set of units chosen and built in to the library.  The exception is for `width` and `height` values which sometimes require different units.  Here's how to create them.

@docs percent, px, auto


# Positioning

@docs Position

@docs parent, currentPosition, screen, RelativeTo

@docs topLeft, topRight, bottomLeft, bottomRight, Anchor

# A Note on Padding and Margins

`padding` and `margin` are interesting when you have a parent and a child element.  You now have two ways of specifying the spacing of the child element within the parent.  Either the `margin` on the child or the `padding` on the parent.  This causes anxiety in the developer.

In the effort of having only one good way to accomplish something, we only allow the `padding` property to be set.

We introduce the `spacing` attribute, which sets the spacing between all child elements.

`inline` elements are not affected by spacing.

Floating elements will only respect spacing values set for the bottom, and whichever happens to be the inner side.


# Padding, Spacing, and Borders

Padding, spacing, and border widths are all specified by a tuple of four floats that represent (top, right, bottom, left).  These are all rendered as `px` values.

The following are convenience functions for setting these values.

@docs all, top, bottom, left, right, topBottom, leftRight, leftRightAndTopBottom, allButTop, allButLeft, allButRight, allButBottom

## Borderstyles

@docs Border, BorderStyle, solid, dotted, dashed




# Text/Font

@docs Text, TextDecoration, underline, overline, strike.

@docs bold, bolder, light

@docs Whitespace, normal, pre, preLine, preWrap, noWrap


# Background Images

@docs BackgroundImage, Repeat, repeat, repeatX, repeatY, noRepeat, round, space


# Shadows

@docs Shadow, shadow, insetShadow, textShadow, dropShadow



# Transforms
@docs Transform, translate, rotate, scale

# Filters
@docs Filter, filterUrl, blur, brightness, contrast, grayscale, hueRotate, invert, opacityFilter, saturate, sepia

# Transitions
@docs Transition, on

# Animations
@docs Animation, animation, rotating, reverseRotating

# Element
@docs Element

-}

import Html
import Time exposing (Time)
import Color exposing (Color)
import Style.Model


{-| The full model for a style.

Some properties are mandatory makes our styles predictable.

Generally you will only define a full style once, and the rest of your styles will be based off that single foundation style.
-}
type alias Model =
    { addClass : Maybe String
    , layout : Layout
    , visibility : Visibility
    , position : Position
    , cursor : String
    , width : Length
    , height : Length
    , colors : Colors
    , spacing : ( Float, Float, Float, Float )
    , padding : ( Float, Float, Float, Float )
    , text : Text
    , border : Border
    , backgroundImage : Maybe BackgroundImage
    , float : Maybe Floating
    , inline : Bool
    , shadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , additional : List ( String, String )
    , transitions : List Transition
    , animation : Maybe Animation
    }


{-| -}
empty : Model
empty =
    { addClass = Nothing
    , layout = textLayout
    , visibility = visible
    , position =
        { relativeTo = currentPosition
        , anchor = topLeft
        , position = ( 0, 0 )
        }
    , colors =
        { background = Color.rgba 255 255 255 0
        , text = Color.black
        , border = Color.grey
        }
    , text =
        { font = "georgia"
        , size = 16
        , characterOffset = Nothing
        , lineHeight = 1.7
        , italic = False
        , boldness = Nothing
        , align = alignLeft
        , decoration = Nothing
        , whitespace = normal
        }
    , border =
        { style = solid
        , width = all 0
        , corners = all 0
        }
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
    , transitions = []
    , animation = Nothing
    , additional = []
    }


{-| A `Variation` is a style where all the properties are optional.

This is used to construct animations and transitions.

Only properties that make sense in that context are present.


-}
type alias Variation =
    { visibility : Maybe Visibility
    , position : Maybe ( Float, Float )
    , cursor : Maybe String
    , width : Maybe Length
    , height : Maybe Length
    , colors : Maybe Colors
    , padding : Maybe ( Float, Float, Float, Float )
    , spacing : Maybe ( Float, Float, Float, Float )
    , text : Maybe Text
    , border : Maybe Border
    , backgroundImagePosition : Maybe ( Float, Float )
    , shadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , additional : List ( String, String )
    }


{-| An empty `Variation`
-}
variation : Variation
variation =
    { visibility = Nothing
    , position = Nothing
    , colors = Nothing
    , text = Nothing
    , border = Nothing
    , cursor = Nothing
    , width = Nothing
    , height = Nothing
    , padding = Nothing
    , spacing = Nothing
    , backgroundImagePosition = Nothing
    , shadows = []
    , transforms = []
    , filters = []
    , additional = []
    }


{-|
-}
type alias Element msg =
    ( List Style.Model.StyleDefinition, Html.Html msg )


{-| -}
type alias Transition =
    Style.Model.Transition Variation


{-| -}
type alias Animation =
    Style.Model.Animated Variation


{-| Colors are bound together in a record.  This is useful for creating palettes of colors.

-}
type alias Colors =
    { background : Color
    , text : Color
    , border : Color
    }


{-| Position coordinates are always rendered in pixels.
They are provided as x and y coordinates where right and down are the positive directions, same as the standard coordinate system for svg.

-}
type alias Position =
    { relativeTo : RelativeTo
    , anchor : Anchor
    , position : ( Float, Float )
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


{-|
-}
type alias TextDecoration =
    Style.Model.TextDecoration


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


{-| Border width and corners are always given as floats and rendered as 'px'.

Corners is the same as `border-radius`
-}
type alias Border =
    { style : BorderStyle
    , width : ( Float, Float, Float, Float )
    , corners : ( Float, Float, Float, Float )
    }


{-| All values are given in 'px' units except for lineHeight which is given in proportion to the fontsize.

So, a fontsize of 16 and a lineHeight of 1 means that the lineheight is going to be 16px.
-}
type alias Text =
    { font : String
    , size : Float
    , lineHeight : Float
    , characterOffset : Maybe Float
    , italic : Bool
    , boldness : Maybe Float
    , align : Alignment
    , decoration : Maybe TextDecoration
    , whitespace : Whitespace
    }


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


{-| Create a transition by specifying a pseudo class and the target style as a Variation.  For example to make a transition on hover, you'd do the following:

```on ":hover" { variation | colors = linkHover }```

-}
on : String -> Variation -> Transition
on name model =
    Style.Model.Transition name model


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


{-| Same as floatLeft, except it will ignore any top spacing that it's parent has set for it.  This is useful for floating things at the beginning of text.

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


{-| Besides that all children are arranged as `display:block` elements.

This is the only layout that allows for child elements to use `float` or `inline`.

If you try to assign a float or make an element inline that is not the child of a textLayout, the float or inline will be ignored and the element will be highlighted in red with a large warning.

-}
textLayout : Layout
textLayout =
    Style.Model.TextLayout


{-| This is the same as setting an element to `display:table`, also known as the "anti-hero of CSS".

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
leftRightAndTopBottom : Float -> Float -> ( Float, Float, Float, Float )
leftRightAndTopBottom x y =
    ( y, x, y, x )


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


{-|

Easing is given as a string name from any of the values accepted by the animation-timing-function css property.

https://developer.mozilla.org/en-US/docs/Web/CSS/animation-timing-function
-}
animation :
    { duration : Time
    , easing : String
    , repeat : Float
    , steps : List ( Float, Variation )
    }
    -> Animation
animation anim =
    Style.Model.Animation anim
