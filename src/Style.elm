module Style
    exposing
        ( Model
        , Property
        , StyleSheet
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
        , PositionParent
        , Repeat
        , Animation
        , Transition
        , Option
        , foundation
        , embed
        , render
        , renderWith
        , debug
        , debugWith
        , class
        , selector
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
        , visibility
        , positionBy
        , textColor
        , backgroundColor
        , borderColor
        , font
        , textAlign
        , whitespace
        , letterOffset
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
        , inline
        , backgroundImage
        , shadows
        , transforms
        , filters
        , property
        , mix
        , autoImportGoogleFonts
        , importCSS
        , importUrl
        )

{-|

This module is focused around composing a style.

@docs Model, Property, StyleSheet, embed, render, renderWith, debug, debugWith, class, selector, foundation

## Rendering Options

@docs Option, importCSS, importUrl, autoImportGoogleFonts


# Positioning

The coordinates for the `position` value in the style model are x and y coordinates where right and down are the positive directions, same as the standard coordinate system for svg.

These coordinates are always rendered in pixels.

@docs topLeft, topRight, bottomLeft, bottomRight

@docs positionBy, PositionParent, parent, currentPosition, screen



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

@docs Floating, floatLeft, floatRight, floatTopLeft, floatTopRight

# Alignment

@docs Alignment, alignLeft, alignRight, justify, justifyAll, alignCenter

@docs VerticalAlignment, verticalCenter, verticalStretch, alignTop, alignBottom



# Colors

@docs textColor, backgroundColor, borderColor


# Visibility

@docs visibility, Visibility, hidden, opacity, transparency, visible


# Text/Font

@docs font, Font, textAlign, letterOffset, whitespace, Whitespace, normal, pre, preLine, preWrap, noWrap, italicize, bold, light, strike, underline, cursor


# Background Images

@docs backgroundImage, BackgroundImage, Repeat, repeat, repeatX, repeatY, noRepeat, round, space

@docs property, mix


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




-}

import Html exposing (Html, Attribute)
import Html.Attributes
import Time exposing (Time)
import Color exposing (Color)
import List.Extra
import String.Extra
import Style.Model exposing (Model(..), Property(..), Floating(..), Whitespace(..), Alignment(..))
import Style.Render
import Style.Media


{-| -}
type alias Model class =
    Style.Model.Model class


{-| -}
type alias Property =
    Style.Model.Property


{-|

Sets the following defaults:

    box-sizing: border-box
    display: block
    position: relative
    top: 0
    left: 0

-}
foundation : List Property
foundation =
    [ Style.Model.Property "box-sizing" "border-box"
    , Style.Model.LayoutProp Style.Model.TextLayout
    , Style.Model.PositionProp ( Style.Model.AnchorTop, Style.Model.AnchorLeft ) 0 0
    , Style.Model.RelProp currentPosition
    ]


{-|
-}
class : class -> List Property -> Model class
class cls props =
    Model
        { selector = Style.Model.Class cls
        , properties =
            foundation ++ props
        }


{-| -}
selector : String -> List Property -> Model class
selector sel props =
    Model
        { selector = Style.Model.Exactly sel
        , properties =
            [ Style.Model.Property "box-sizing" "border-box"
            , Style.Model.LayoutProp Style.Model.TextLayout
            , Style.Model.PositionProp ( Style.Model.AnchorTop, Style.Model.AnchorLeft ) 0 0
            , Style.Model.RelProp currentPosition
            ]
                ++ props
        }


{-| Embed a style sheet into your html.
-}
embed : StyleSheet class msg -> Html msg
embed stylesheet =
    Html.node "style" [] [ Html.text stylesheet.css ]


{-| -}
type alias StyleSheet class msg =
    { class : class -> Html.Attribute msg
    , classList : List ( class, Bool ) -> Html.Attribute msg
    , css : String
    }


{-| Render styles into a stylesheet

-}
render : List (Model class) -> StyleSheet class msg
render styles =
    let
        ( names, cssStyles ) =
            styles
                |> List.map Style.Render.render
                |> List.Extra.uniqueBy Tuple.first
                |> List.unzip
    in
        { css = String.join "\n" cssStyles
        , class =
            (\cls ->
                case Style.Render.find cls styles of
                    Nothing ->
                        Html.Attributes.class "missing-from-stylesheet"

                    Just style ->
                        Html.Attributes.class (Style.Render.getName style)
            )
        , classList =
            (\classes ->
                classes
                    |> List.filter Tuple.second
                    |> List.map Style.Render.formatName
                    |> String.join " "
                    |> Html.Attributes.class
            )
        }


{-| -}
type Option
    = AutoImportGoogleFonts
    | Import String
    | ImportUrl String


{-| An attempt will be made to import all non-standard webfonts that are in your styles.
-}
autoImportGoogleFonts : Option
autoImportGoogleFonts =
    AutoImportGoogleFonts


{-|
-}
importCSS : String -> Option
importCSS =
    Import


{-|
-}
importUrl : String -> Option
importUrl =
    ImportUrl


isWebfont : String -> Bool
isWebfont str =
    List.member (String.toLower str)
        [ "arial"
        , "sans-serif"
        , "serif"
        , "courier"
        , "times"
        , "times new roman"
        , "verdana"
        , "tahoma"
        , "georgia"
        , "helvetica"
        ]


getFontNames : Model class -> List String
getFontNames (Model model) =
    let
        getFonts prop =
            case prop of
                Style.Model.FontProp f ->
                    f.font
                        |> String.split ","
                        |> List.map (String.Extra.replace "'" "" << String.Extra.unquote << String.Extra.replace " " "+" << String.trim)

                _ ->
                    []
    in
        model.properties
            |> List.filter Style.Model.isFont
            |> List.concatMap getFonts


{-| -}
renderWith : List Option -> List (Model class) -> StyleSheet class msg
renderWith adds styles =
    let
        renderAdd add =
            case add of
                AutoImportGoogleFonts ->
                    styles
                        |> List.concatMap getFontNames
                        |> List.Extra.uniqueBy identity
                        |> List.filter (not << isWebfont)
                        |> String.join "|"
                        |> (\family -> "@import url('https://fonts.googleapis.com/css?family=" ++ family ++ "');")

                Import str ->
                    "@import " ++ str ++ ";"

                ImportUrl str ->
                    "@import url('" ++ str ++ "');"

        rendered =
            render styles
    in
        case List.map renderAdd adds of
            [] ->
                rendered

            rules ->
                { rendered
                    | css = String.join "\n" rules ++ "\n\n" ++ rendered.css
                }


{-| Render styles into a stylesheet and give visual ++ console log warnings if anything is off
-}
debug : List (Model class) -> StyleSheet class msg
debug styles =
    let
        ( names, cssStyles ) =
            styles
                |> List.map Style.Render.render
                |> List.Extra.uniqueBy Tuple.first
                |> List.unzip
    in
        { css =
            (String.join "\n" cssStyles)
                ++ Style.Render.inlineError
                ++ Style.Render.floatError
                ++ Style.Render.missingError
        , class =
            (\name ->
                let
                    cls =
                        Style.Render.formatName name

                    withPossibleError =
                        if not (List.member cls names) then
                            let
                                _ =
                                    Debug.log "style" (cls ++ " is not in your stylesheet, so things might look weird.")
                            in
                                (cls ++ " missing-from-stylesheet")
                        else
                            cls
                in
                    Html.Attributes.class withPossibleError
            )
        , classList =
            (\classes ->
                let
                    optionNames =
                        List.map
                            (\( name, included ) ->
                                ( Style.Render.formatName name, included )
                            )
                            classes

                    missing =
                        List.filterMap
                            (\( option, _ ) ->
                                if not (List.member option names) then
                                    Just option
                                else
                                    Nothing
                            )
                            optionNames

                    _ =
                        if List.isEmpty missing then
                            ""
                        else if List.length missing == 1 then
                            Debug.log "style" ((String.join ", " missing) ++ " is not in your stylesheet.")
                        else
                            Debug.log "style" ("the classes " ++ (String.join ", " missing) ++ " are not in your stylesheet.")
                in
                    optionNames
                        |> List.filter Tuple.second
                        |> List.map Tuple.first
                        |> (if List.isEmpty missing then
                                identity
                            else
                                (::) "missing-from-stylesheet"
                           )
                        |> String.join " "
                        |> Html.Attributes.class
            )
        }


{-| -}
debugWith : List Option -> List (Model class) -> StyleSheet class msg
debugWith adds styles =
    let
        renderAdd add =
            case add of
                AutoImportGoogleFonts ->
                    styles
                        |> List.concatMap getFontNames
                        |> List.Extra.uniqueBy identity
                        |> List.filter (not << isWebfont)
                        |> String.join "|"
                        |> (\family -> "@import url('https://fonts.googleapis.com/css?family=" ++ family ++ "');")

                Import str ->
                    "@import " ++ str ++ ";"

                ImportUrl str ->
                    "@import url('" ++ str ++ "');"

        rendered =
            debug styles
    in
        case List.map renderAdd adds of
            [] ->
                rendered

            rules ->
                { rendered
                    | css = String.join "\n" rules ++ "\n\n" ++ rendered.css
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
type alias PositionParent =
    Style.Model.PositionParent


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
floatLeft : Property
floatLeft =
    FloatProp Style.Model.FloatLeft


{-|

-}
floatRight : Property
floatRight =
    FloatProp Style.Model.FloatRight


{-| Same as floatLeft, except it will ignore any top spacing that it's parent has set for it.

This is useful for floating things at the beginning of text.

-}
floatTopLeft : Property
floatTopLeft =
    FloatProp Style.Model.FloatTopLeft


{-|

-}
floatTopRight : Property
floatTopRight =
    FloatProp Style.Model.FloatTopRight


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
visibility : Visibility -> Property
visibility vis =
    Style.Model.VisibilityProp vis


{-| -}
screen : PositionParent
screen =
    Style.Model.Screen


{-| -}
parent : PositionParent
parent =
    Style.Model.Parent


{-| -}
currentPosition : PositionParent
currentPosition =
    Style.Model.CurrentPosition


{-| -}
positionBy : PositionParent -> Property
positionBy =
    Style.Model.RelProp


{-| -}
topLeft : Float -> Float -> Property
topLeft x y =
    let
        anchor =
            Style.Model.AnchorTop => Style.Model.AnchorLeft
    in
        PositionProp anchor x y


{-| -}
topRight : Float -> Float -> Property
topRight x y =
    let
        anchor =
            Style.Model.AnchorTop => Style.Model.AnchorRight
    in
        PositionProp anchor x y


{-| -}
bottomLeft : Float -> Float -> Property
bottomLeft x y =
    let
        anchor =
            Style.Model.AnchorBottom => Style.Model.AnchorLeft
    in
        PositionProp anchor x y


{-| -}
bottomRight : Float -> Float -> Property
bottomRight x y =
    let
        anchor =
            Style.Model.AnchorBottom => Style.Model.AnchorRight
    in
        PositionProp anchor x y


{-| -}
cursor : String -> Property
cursor value =
    Property "cursor" value


{-| -}
zIndex : Int -> Property
zIndex i =
    Property "z-index" (toString i)


{-| -}
width : Length -> Property
width value =
    Len "width" value


{-| -}
minWidth : Length -> Property
minWidth value =
    Len "min-width" value


{-| -}
maxWidth : Length -> Property
maxWidth value =
    Len "max-width" value


{-| -}
height : Length -> Property
height value =
    Len "height" value


{-| -}
minHeight : Length -> Property
minHeight value =
    Len "min-height" value


{-| -}
maxHeight : Length -> Property
maxHeight value =
    Len "max-height" value


{-| -}
textColor : Color -> Property
textColor color =
    ColorProp "color" color


{-| -}
backgroundColor : Color -> Property
backgroundColor color =
    ColorProp "background-color" color


{-| -}
borderColor : Color -> Property
borderColor color =
    ColorProp "border-color" color


{-| -}
spacing : ( Float, Float, Float, Float ) -> Property
spacing s =
    Spacing s


{-| -}
padding : ( Float, Float, Float, Float ) -> Property
padding value =
    Box "padding" value


{-| -}
borderWidth : ( Float, Float, Float, Float ) -> Property
borderWidth value =
    Box "border-width" value


{-| -}
borderRadius : ( Float, Float, Float, Float ) -> Property
borderRadius value =
    Box "border-radius" value


{-| -}
font : Font -> Property
font text =
    FontProp text


{-| -}
letterOffset : Float -> Property
letterOffset offset =
    Property "letter-offset" (toString offset ++ "px")


{-| -}
textAlign : Alignment -> Property
textAlign alignment =
    case alignment of
        AlignLeft ->
            Property "text-align" "left"

        AlignRight ->
            Property "text-align" "right"

        AlignCenter ->
            Property "text-align" "center"

        Justify ->
            Property "text-align" "justify"

        JustifyAll ->
            Property "text-align" "justify-all"


{-| -}
whitespace : Whitespace -> Property
whitespace ws =
    case ws of
        Normal ->
            Property "white-space" "normal"

        Pre ->
            Property "white-space" "pre"

        PreWrap ->
            Property "white-space" "pre-wrap"

        PreLine ->
            Property "white-space" "pre-line"

        NoWrap ->
            Property "white-space" "no-wrap"


{-| -}
underline : Property
underline =
    Property "text-decoration" "underline"


{-| -}
strike : Property
strike =
    Property "text-decoration" "line-through"


{-| -}
italicize : Property
italicize =
    Property "font-style" "italic"


{-| -}
bold : Property
bold =
    Property "font-weight" "700"


{-| -}
light : Property
light =
    Property "font-weight" "300"


{-| -}
borderStyle : BorderStyle -> Property
borderStyle bStyle =
    let
        val =
            case bStyle of
                Style.Model.Solid ->
                    "solid"

                Style.Model.Dashed ->
                    "dashed"

                Style.Model.Dotted ->
                    "dotted"
    in
        Style.Model.Property "border-style" val


{-| -}
backgroundImage : BackgroundImage -> Property
backgroundImage value =
    BackgroundImageProp value


{-| -}
shadows : List Shadow -> Property
shadows value =
    Shadows value


{-| -}
transforms : List Transform -> Property
transforms value =
    Transforms value


{-| -}
filters : List Filter -> Property
filters value =
    Filters value


{-| -}
mix : List Property -> Property
mix =
    Mix


{-| Add a property.  Not to be exported, `properties` is to be used instead.
-}
property : String -> String -> Property
property name value =
    Property name value


{-| -}
inline : Property
inline =
    LayoutProp Style.Model.InlineLayout


{-| This is the only layout that allows for child elements to use `float` or `inline`.

If you try to assign a float or make an element inline that is not the child of a textLayout, the float or inline will be ignored and the element will be highlighted in red with a large warning.

Besides this, all immediate children are arranged as if they were `display: block`.

-}
textLayout : Property
textLayout =
    LayoutProp Style.Model.TextLayout


{-| This is the same as setting an element to `display:table`.

-}
tableLayout : Property
tableLayout =
    LayoutProp Style.Model.TableLayout


{-|

-}
type alias Flow =
    { wrap : Bool
    , horizontal : Alignment
    , vertical : VerticalAlignment
    }


{-| This is a flexbox foundationd layout
-}
flowUp : Flow -> Property
flowUp { wrap, horizontal, vertical } =
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
        LayoutProp layout


{-|

-}
flowDown : Flow -> Property
flowDown { wrap, horizontal, vertical } =
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
        LayoutProp layout


{-| -}
flowRight : Flow -> Property
flowRight { wrap, horizontal, vertical } =
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
        LayoutProp layout


{-| -}
flowLeft : Flow -> Property
flowLeft { wrap, horizontal, vertical } =
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
        LayoutProp layout


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
transition : Transition -> Property
transition value =
    Style.Model.TransitionProperty value


{-| -}
type alias Animation =
    { duration : Time
    , easing : String
    , repeat : Float
    , steps : List ( Float, List Property )
    }


{-| Create an animation
-}
animate : Animation -> Property
animate { duration, easing, repeat, steps } =
    Style.Model.AnimationProp <|
        Style.Model.Animation
            { duration = duration
            , easing = easing
            , repeat = repeat
            , steps = steps
            }


{-| -}
hover : List Property -> Property
hover props =
    Style.Model.SubElement ":hover" props


{-| -}
focus : List Property -> Property
focus props =
    Style.Model.SubElement ":focus" props


{-| -}
checked : List Property -> Property
checked props =
    Style.Model.SubElement ":checked" props


{-| -}
selection : List Property -> Property
selection props =
    Style.Model.SubElement ":selection" props


{-| Requires a string which will be rendered as the 'content' property
-}
after : String -> List Property -> Property
after content props =
    Style.Model.SubElement "::after" (property "content" content :: props)


{-| Requires a string which will be rendered as the 'content' property
-}
before : String -> List Property -> Property
before content props =
    Style.Model.SubElement "::before" (property "content" content :: props)
