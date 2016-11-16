module Style
    exposing
        ( Model
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
        , MediaQuery
        , Transition
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
        , animate
        , transition
        , hover
        , focus
        , checked
        , selection
        , after
        , before
        , empty
        , mediaQuery
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
        , borderRadius
        , cursor
        , zIndex
        , width
        , minWidth
        , maxWidth
        , height
        , minHeight
        , maxHeight
        , padding
        , spacing
        , float
        , inline
        , backgroundImage
        , shadows
        , transforms
        , filters
        , media
        , properties
        )

{-|

This module is focused around composing a style.

@docs Model, empty


# Positioning

The coordinates for the `position` value in the style model are x and y coordinates where right and down are the positive directions, same as the standard coordinate system for svg.

These coordinates are always rendered in pixels.

@docs position

@docs relativeTo, RelativeTo, parent, currentPosition, screen

@docs anchor, Anchor, topLeft, topRight, bottomLeft, bottomRight


# Width/Height

@docs height, minHeight, maxHeight, width, minWidth, maxWidth

# Units

Most values in this library have one set of units to the library that are required to be used.

However, `width` and `height` values can be pixels, percent, or auto.

@docs percent, px, auto


# A Note on Padding and Margins

In CSS `padding` and `margin` are interesting when you have a parent and a child element.  You now have two ways of specifying the spacing of the child element within the parent.  Either the `margin` on the child or the `padding` on the parent.  This causes anxiety in the developer.

In the effort of having only one good way to accomplish something, we only allow the `padding` property to be set.

We introduce the `spacing` attribute, which sets the spacing between all _child_ elements (using the margin property).

> __Some exceptions__
>
> `inline` elements are not affected by spacing.
>
> Floating elements will only respect certain spacing values.

@docs padding, spacing, zIndex


# Padding, Spacing, and Borders

Padding, spacing, and border widths are all specified by a tuple of four floats that represent (top, right, bottom, left).  These are all rendered as `px` values.

The following are convenience functions for setting these values.

@docs all, top, bottom, left, right, topBottom, leftRight, leftRightAndTopBottom, leftRightTopBottom, allButTop, allButLeft, allButRight, allButBottom


## Borderstyles

@docs borderStyle, borderWidth, BorderStyle, solid, dotted, dashed, borderRadius

# Layouts

Layouts affect how children are arranged.  In this library, layout is controlled by the parent element.

@docs Layout, textLayout, tableLayout

@docs Flow, flowUp, flowDown, flowRight, flowLeft


@docs inline

@docs float, Floating, floatLeft, floatRight, floatTopLeft, floatTopRight

# Alignment

@docs Alignment, alignLeft, alignRight, justify, justifyAll, alignCenter

@docs VerticalAlignment, verticalCenter, verticalStretch, alignTop, alignBottom



# Colors

@docs colors, ColorPalette




# Visibility

@docs visibility, Visibility, hidden, opacity, transparency, visible





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


# Animations and Transitions

@docs Animation, animate


@docs Transition, transition

## Pseudo elements and classes

@docs selection, after, before, hover, focus, checked


# Media Queries

@docs media, MediaQuery, mediaQuery



-}

import Html exposing (Html)
import Html.Attributes
import Time exposing (Time)
import Color exposing (Color)
import Set exposing (Set)
import Style.Model exposing (Model(..), emptySubElements)
import Style.Render


{-| The full model for a style.

Some properties are mandatory in order to make predictable styles.

-}
type alias Simple =
    Style.Model.Model String


{-| -}
type alias Model a =
    Style.Model.Model a


{-| -}
empty : Model a
empty =
    Model
        { class = Nothing
        , classOverride = Nothing
        , layout = Style.Model.TextLayout
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
            , letterOffset = Nothing
            , lineHeight = 1.7
            , align = alignLeft
            , whitespace = normal
            }
        , italic = False
        , bold = Nothing
        , strike = False
        , underline = False
        , cursor = "auto"
        , width = auto
        , height = auto
        , borderStyle = solid
        , borderWidth = all 0
        , borderRadius = all 0
        , padding = all 0
        , spacing = all 0
        , float = Nothing
        , inline = False
        , backgroundImage = Nothing
        , shadows = Nothing
        , transforms = Nothing
        , filters = Nothing
        , animation = Nothing
        , media = []
        , properties = Nothing
        , zIndex = Nothing
        , minWidth = Nothing
        , maxWidth = Nothing
        , minHeight = Nothing
        , maxHeight = Nothing
        , transition =
            Just
                { property = "all"
                , duration = 300
                , easing = "ease-out"
                , delay = 0
                }
        , subelements = Nothing
        }


class : Model a -> Html.Attribute msg
class (Model style) =
    Html.Attributes.class (Style.Render.getName (Model style))


embed : List (Model a) -> Html msg
embed styles =
    styles
        |> List.map Style.Render.render
        |> uniqueBy Tuple.first
        |> List.map Tuple.second
        |> String.join "\n"
        |> (\allStyles -> Html.node "style" [] [ Html.text <| allStyles ])


{-| Drop duplicates where what is considered to be a duplicate is the result of first applying the supplied function to the elements of the list.
-}
uniqueBy : (a -> comparable) -> List a -> List a
uniqueBy f list =
    uniqueHelp f Set.empty list


uniqueHelp : (a -> comparable) -> Set comparable -> List a -> List a
uniqueHelp f existing remaining =
    case remaining of
        [] ->
            []

        first :: rest ->
            let
                computedFirst =
                    f first
            in
                if Set.member computedFirst existing then
                    uniqueHelp f existing rest
                else
                    first :: uniqueHelp f (Set.insert computedFirst existing) rest


{-| -}
type alias MediaQuery class =
    ( String, Model class -> Model class )


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
type alias Transition =
    Style.Model.Transition


{-|
-}
type alias Visibility =
    Style.Model.Visibility


{-|
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
floatLeft : Model a -> Model a
floatLeft (Model state) =
    Model { state | float = Just Style.Model.FloatLeft }


{-|

-}
floatRight : Model a -> Model a
floatRight (Model state) =
    Model { state | float = Just Style.Model.FloatRight }


{-| Same as floatLeft, except it will ignore any top spacing that it's parent has set for it.

This is useful for floating things at the beginning of text.

-}
floatTopLeft : Model a -> Model a
floatTopLeft (Model state) =
    Model { state | float = Just Style.Model.FloatTopLeft }


{-|

-}
floatTopRight : Model a -> Model a
floatTopRight (Model state) =
    Model { state | float = Just Style.Model.FloatTopRight }


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
visibility : Visibility -> Model a -> Model a
visibility vis (Model state) =
    Model { state | visibility = vis }


{-| -}
anchor : Anchor -> Model a -> Model a
anchor anc (Model state) =
    Model { state | anchor = anc }


{-| -}
relativeTo : RelativeTo -> Model a -> Model a
relativeTo rel (Model state) =
    Model { state | relativeTo = rel }


{-| -}
position : ( Float, Float ) -> Model a -> Model a
position pos (Model state) =
    Model { state | position = pos }


{-| -}
cursor : String -> Model a -> Model a
cursor curs (Model state) =
    Model { state | cursor = curs }


{-| -}
zIndex : Int -> Model a -> Model a
zIndex i (Model state) =
    Model { state | zIndex = Just i }


{-| -}
width : Length -> Model a -> Model a
width w (Model state) =
    Model { state | width = w }


{-| -}
minWidth : Length -> Model a -> Model a
minWidth w (Model state) =
    Model { state | minWidth = Just w }


{-| -}
maxWidth : Length -> Model a -> Model a
maxWidth w (Model state) =
    Model { state | maxWidth = Just w }


{-| -}
height : Length -> Model a -> Model a
height h (Model state) =
    Model { state | height = h }


{-| -}
minHeight : Length -> Model a -> Model a
minHeight h (Model state) =
    Model { state | minHeight = Just h }


{-| -}
maxHeight : Length -> Model a -> Model a
maxHeight h (Model state) =
    Model { state | maxHeight = Just h }


{-| -}
colors : ColorPalette -> Model a -> Model a
colors palette (Model state) =
    Model { state | colors = palette }


{-| -}
spacing : ( Float, Float, Float, Float ) -> Model a -> Model a
spacing s (Model state) =
    Model { state | spacing = s }


{-| -}
padding : ( Float, Float, Float, Float ) -> Model a -> Model a
padding s (Model state) =
    Model { state | padding = s }


{-| -}
borderWidth : ( Float, Float, Float, Float ) -> Model a -> Model a
borderWidth s (Model state) =
    Model { state | borderWidth = s }


{-| -}
borderRadius : ( Float, Float, Float, Float ) -> Model a -> Model a
borderRadius s (Model state) =
    Model { state | borderRadius = s }


{-| -}
font : Font -> Model a -> Model a
font text (Model state) =
    Model { state | font = text }


{-| -}
underline : Model a -> Model a
underline (Model state) =
    Model { state | underline = True }


{-| -}
strike : Model a -> Model a
strike (Model state) =
    Model { state | strike = True }


{-| -}
inline : Model a -> Model a
inline (Model state) =
    Model { state | inline = True }


{-| -}
italicize : Model a -> Model a
italicize (Model state) =
    Model { state | italic = True }


{-| -}
bold : Model a -> Model a
bold (Model state) =
    Model { state | bold = Just 700 }


{-| -}
light : Model a -> Model a
light (Model state) =
    Model { state | bold = Just 300 }


{-| -}
borderStyle : BorderStyle -> Model a -> Model a
borderStyle style (Model state) =
    Model { state | borderStyle = style }


{-| -}
float : Floating -> Model a -> Model a
float floating (Model state) =
    Model { state | float = Just floating }


{-| -}
backgroundImage : BackgroundImage -> Model a -> Model a
backgroundImage style (Model state) =
    Model { state | backgroundImage = Just style }


{-| -}
shadows : List Shadow -> Model a -> Model a
shadows shades (Model state) =
    Model { state | shadows = Just shades }


{-| -}
transforms : List Transform -> Model a -> Model a
transforms trans (Model state) =
    Model { state | transforms = Just trans }


{-| -}
filters : List Filter -> Model a -> Model a
filters filts (Model state) =
    Model { state | filters = Just filts }


{-| -}
media : List (MediaQuery a) -> Model a -> Model a
media queries (Model state) =
    let
        renderedMediaQueries =
            List.map (\( name, vary ) -> Style.Model.MediaQuery name (vary (Model state))) queries
    in
        Model { state | media = renderedMediaQueries }


{-| -}
properties : List ( String, String ) -> Model a -> Model a
properties props (Model style) =
    Model { style | properties = Just props }


{-| This is the only layout that allows for child elements to use `float` or `inline`.

If you try to assign a float or make an element inline that is not the child of a textLayout, the float or inline will be ignored and the element will be highlighted in red with a large warning.

Besides this, all immediate children are arranged as if they were `display: block`.

-}
textLayout : Model a -> Model a
textLayout (Model state) =
    Model { state | layout = Style.Model.TextLayout }


{-| This is the same as setting an element to `display:table`.

-}
tableLayout : Model a -> Model a
tableLayout (Model state) =
    Model { state | layout = Style.Model.TableLayout }


{-|

-}
type alias Flow =
    { wrap : Bool
    , horizontal : Alignment
    , vertical : VerticalAlignment
    }


{-| This is a flexbox based layout
-}
flowUp : Flow -> Model a -> Model a
flowUp { wrap, horizontal, vertical } model =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.Up
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        case model of
            Model state ->
                Model { state | layout = layout }


{-|

-}
flowDown : Flow -> Model a -> Model a
flowDown { wrap, horizontal, vertical } model =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.Down
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        case model of
            Model state ->
                Model { state | layout = layout }


{-| -}
flowRight : Flow -> Model a -> Model a
flowRight { wrap, horizontal, vertical } model =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.Right
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        case model of
            Model state ->
                Model { state | layout = layout }


{-| -}
flowLeft : Flow -> Model a -> Model a
flowLeft { wrap, horizontal, vertical } model =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.Left
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        case model of
            Model state ->
                Model { state | layout = layout }


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
all : Float -> ( Float, Float, Float, Float )
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


{-| Same as "display:none"
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
mediaQuery : String -> (Style.Model.Model class -> Style.Model.Model class) -> MediaQuery class
mediaQuery name variation =
    ( name, variation )


{-| -}
transition : Maybe Transition -> Model a -> Model a
transition trans (Model state) =
    Model { state | transition = trans }


{-| -}
type alias Animation class =
    { duration : Time
    , easing : String
    , repeat : Float
    , steps : List ( Float, Style.Model.Model class -> Style.Model.Model class )
    }


{-| Create an animation
-}
animate : Animation a -> Model a -> Model a
animate { duration, easing, repeat, steps } (Model state) =
    Model
        { state
            | animation =
                Just <|
                    Style.Model.Animation
                        { duration = duration
                        , easing = easing
                        , repeat = repeat
                        , steps = List.map (\( time, fn ) -> ( time, fn <| Model state )) steps
                        }
        }


{-| Add a property.  Not to be exported, `properties` is to be used instead.
-}
add : ( String, String ) -> Model a -> Model a
add prop (Model state) =
    Model
        { state
            | properties =
                case state.properties of
                    Nothing ->
                        Just [ prop ]

                    Just existing ->
                        Just (prop :: existing)
        }


{-| -}
hover : (Model a -> Model a) -> Model a -> Model a
hover vary (Model model) =
    let
        (Model state) =
            vary (Model model)

        clearedSubSubElements =
            Model { state | subelements = Nothing }
    in
        Model
            { model
                | subelements =
                    case state.subelements of
                        Nothing ->
                            Just { emptySubElements | hover = Just clearedSubSubElements }

                        Just subs ->
                            Just { subs | hover = Just clearedSubSubElements }
            }


{-| -}
focus : (Model a -> Model a) -> Model a -> Model a
focus vary (Model model) =
    let
        (Model state) =
            vary (Model model)

        clearedSubSubElements =
            Model { state | subelements = Nothing }
    in
        Model
            { model
                | subelements =
                    case state.subelements of
                        Nothing ->
                            Just { emptySubElements | focus = Just clearedSubSubElements }

                        Just subs ->
                            Just { subs | focus = Just clearedSubSubElements }
            }


{-| -}
checked : (Model a -> Model a) -> Model a -> Model a
checked vary (Model model) =
    let
        (Model state) =
            vary (Model model)

        clearedSubSubElements =
            Model { state | subelements = Nothing }
    in
        Model
            { model
                | subelements =
                    case state.subelements of
                        Nothing ->
                            Just { emptySubElements | checked = Just clearedSubSubElements }

                        Just subs ->
                            Just { subs | checked = Just clearedSubSubElements }
            }


{-| -}
selection : (Model a -> Model a) -> Model a -> Model a
selection vary (Model model) =
    let
        (Model state) =
            vary (Model model)

        clearedSubSubElements =
            Model { state | subelements = Nothing }
    in
        Model
            { model
                | subelements =
                    case state.subelements of
                        Nothing ->
                            Just { emptySubElements | selection = Just clearedSubSubElements }

                        Just subs ->
                            Just { subs | selection = Just clearedSubSubElements }
            }


{-| Requires a string which will be rendered as the 'content' property
-}
after : String -> (Model a -> Model a) -> Model a -> Model a
after content variation (Model model) =
    let
        (Model state) =
            (variation << add ( "content", content )) (Model model)

        clearedSubSubElements =
            Model { state | subelements = Nothing }
    in
        Model
            { model
                | subelements =
                    case state.subelements of
                        Nothing ->
                            Just { emptySubElements | after = Just clearedSubSubElements }

                        Just subs ->
                            Just { subs | after = Just clearedSubSubElements }
            }


{-| Requires a string which will be rendered as the 'content' property
-}
before : String -> (Model a -> Model a) -> Model a -> Model a
before content variation (Model model) =
    let
        (Model state) =
            (variation << add ( "content", content )) (Model model)

        clearedSubSubElements =
            Model { state | subelements = Nothing }
    in
        Model
            { model
                | subelements =
                    case state.subelements of
                        Nothing ->
                            Just { emptySubElements | before = Just clearedSubSubElements }

                        Just subs ->
                            Just { subs | before = Just clearedSubSubElements }
            }
