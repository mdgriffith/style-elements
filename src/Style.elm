module Style
    exposing
        ( Model
        , ColorPalette
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
        , Anchor
        , PositionParent
        , Repeat
        , Animation
        , Transition
        , Option
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
        , empty
        , foundation
        , visibility
        , positionBy
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
        , inline
        , backgroundImage
        , shadows
        , transforms
        , filters
        , media
        , property
        , autoImportGoogleFonts
        , importCSS
        , importUrl
        )

{-|

This module is focused around composing a style.

@docs Simple, Model, foundation, empty, embed, render, class, selector

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

@docs colors, ColorPalette


# Visibility

@docs visibility, Visibility, hidden, opacity, transparency, visible


# Text/Font

@docs font, Font, Whitespace, normal, pre, preLine, preWrap, noWrap, italicize, bold, light, strike, underline, cursor


# Background Images

@docs backgroundImage, BackgroundImage, Repeat, repeat, repeatX, repeatY, noRepeat, round, space

@docs property


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

@docs media



-}

import Html exposing (Html, Attribute)
import Html.Attributes
import Time exposing (Time)
import Color exposing (Color)
import List.Extra
import String.Extra
import Style.Model exposing (Model(..), Property(..), Floating(..))
import Style.Render
import Style.Media


{-| -}
type alias Model =
    Style.Model.Model


{-| A style that comes with a set of defaults.

Use this as a starting point for the majority of your styles.

-}
foundation : Model
foundation =
    Model
        { selector = Style.Model.AutoClass
        , properties =
            [ Style.Model.Property "box-sizing" "border-box"
            , Style.Model.Len "width" auto
            , Style.Model.Len "height" auto
            , Style.Model.Box "padding" (all 0)
            , Style.Model.Box "border-width" (all 0)
            , Style.Model.Box "border-radius" (all 0)
            , Style.Model.Spacing (all 0)
            , Style.Model.TransitionProperty
                { property = "all"
                , duration = 300
                , easing = "ease-out"
                , delay = 0
                }
            , Style.Model.LayoutProp Style.Model.TextLayout
            , Style.Model.FontProp
                { font = "georgia"
                , size = 16
                , letterOffset = Nothing
                , lineHeight = 1.7
                , align = alignLeft
                , whitespace = normal
                }
            , Style.Model.Colors
                { background = Color.rgba 255 255 255 0
                , text = Color.darkCharcoal
                , border = Color.grey
                }
            , Style.Model.PositionProp ( Style.Model.AnchorTop, Style.Model.AnchorLeft ) 0 0
            , Style.Model.RelProp currentPosition
            ]
        }


{-| This is a completely empty style, there are no default properties set.

You should use `Style.foundation` for the majority of your styles.

`Style.empty` is specifically for cases where you want styles that can mix nicely with each other.


-}
empty : Model
empty =
    Model
        { selector = Style.Model.AutoClass
        , properties = []
        }


{-| -}
class : String -> Model -> Model
class cls (Model state) =
    Model { state | selector = Style.Model.Class cls }


{-| -}
selector : String -> Model -> Model
selector cls (Model state) =
    Model { state | selector = Style.Model.Exactly cls }


{-| Embed a style sheet into your html.
-}
embed : StyleSheet msg -> Html msg
embed stylesheet =
    Html.node "style" [] [ Html.text stylesheet.css ]


type alias StyleSheet msg =
    { class : Model -> Html.Attribute msg
    , classList : List ( Model, Bool ) -> Html.Attribute msg
    , css : String
    }


{-| Render styles into a stylesheet

-}
render : List Model -> StyleSheet msg
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
            (\model ->
                Html.Attributes.class (Style.Render.getName model)
            )
        , classList =
            (\models ->
                models
                    |> List.filter Tuple.second
                    |> List.map (Style.Render.getName << Tuple.first)
                    |> String.join " "
                    |> Html.Attributes.class
            )
        }


type Option
    = AutoImportGoogleFonts
    | Import String
    | ImportUrl String



--| BaseStyle


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


getFontNames : Model -> List String
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
renderWith : List Option -> List Model -> StyleSheet msg
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
debug : List Model -> StyleSheet msg
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
            (\model ->
                let
                    cls =
                        Style.Render.getName model

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
            (\models ->
                let
                    optionNames =
                        List.map
                            (\( model, included ) ->
                                ( Style.Render.getName model, included )
                            )
                            models

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
debugWith : List Option -> List Model -> StyleSheet msg
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
floatLeft : Model -> Model
floatLeft (Model state) =
    Model
        { state
            | properties = Style.Model.FloatProp Style.Model.FloatLeft :: state.properties
        }


{-|

-}
floatRight : Model -> Model
floatRight (Model state) =
    Model
        { state
            | properties = Style.Model.FloatProp Style.Model.FloatRight :: state.properties
        }


{-| Same as floatLeft, except it will ignore any top spacing that it's parent has set for it.

This is useful for floating things at the beginning of text.

-}
floatTopLeft : Model -> Model
floatTopLeft (Model state) =
    Model
        { state
            | properties = Style.Model.FloatProp Style.Model.FloatTopLeft :: state.properties
        }


{-|

-}
floatTopRight : Model -> Model
floatTopRight (Model state) =
    Model
        { state
            | properties = Style.Model.FloatProp Style.Model.FloatTopRight :: state.properties
        }


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
visibility : Visibility -> Model -> Model
visibility vis (Model state) =
    Model
        { state
            | properties =
                Style.Model.VisibilityProp vis :: state.properties
        }


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
positionBy : PositionParent -> Model -> Model
positionBy rel (Model state) =
    Model
        { state
            | properties =
                Style.Model.RelProp rel :: state.properties
        }


{-| -}
topLeft : Float -> Float -> Model -> Model
topLeft x y (Model state) =
    let
        anchor =
            Style.Model.AnchorTop => Style.Model.AnchorLeft
    in
        Model
            { state
                | properties =
                    Style.Model.PositionProp anchor x y
                        :: state.properties
            }


{-| -}
topRight : Float -> Float -> Model -> Model
topRight x y (Model state) =
    let
        anchor =
            Style.Model.AnchorTop => Style.Model.AnchorRight
    in
        Model
            { state
                | properties =
                    Style.Model.PositionProp anchor x y
                        :: state.properties
            }


{-| -}
bottomLeft : Float -> Float -> Model -> Model
bottomLeft x y (Model state) =
    let
        anchor =
            Style.Model.AnchorBottom => Style.Model.AnchorLeft
    in
        Model
            { state
                | properties =
                    Style.Model.PositionProp anchor x y
                        :: state.properties
            }


{-| -}
bottomRight : Float -> Float -> Model -> Model
bottomRight x y (Model state) =
    let
        anchor =
            Style.Model.AnchorBottom => Style.Model.AnchorRight
    in
        Model
            { state
                | properties =
                    Style.Model.PositionProp anchor x y
                        :: state.properties
            }


{-| -}
cursor : String -> Model -> Model
cursor value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property "cursor" value :: state.properties
        }


{-| -}
zIndex : Int -> Model -> Model
zIndex i (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property "z-index" (toString i) :: state.properties
        }


{-| -}
width : Length -> Model -> Model
width value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Len "width" value :: state.properties
        }


{-| -}
minWidth : Length -> Model -> Model
minWidth value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Len "min-width" value :: state.properties
        }


{-| -}
maxWidth : Length -> Model -> Model
maxWidth value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Len "max-width" value :: state.properties
        }


{-| -}
height : Length -> Model -> Model
height value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Len "height" value :: state.properties
        }


{-| -}
minHeight : Length -> Model -> Model
minHeight value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Len "min-height" value :: state.properties
        }


{-| -}
maxHeight : Length -> Model -> Model
maxHeight value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Len "max-height" value :: state.properties
        }


{-| -}
colors : ColorPalette -> Model -> Model
colors palette (Model state) =
    Model
        { state
            | properties =
                Style.Model.Colors palette :: state.properties
        }


{-| -}
spacing : ( Float, Float, Float, Float ) -> Model -> Model
spacing s (Model state) =
    Model
        { state
            | properties =
                Style.Model.Spacing s :: state.properties
        }


{-| -}
padding : ( Float, Float, Float, Float ) -> Model -> Model
padding value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Box "padding" value :: state.properties
        }


{-| -}
borderWidth : ( Float, Float, Float, Float ) -> Model -> Model
borderWidth value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Box "border-width" value :: state.properties
        }


{-| -}
borderRadius : ( Float, Float, Float, Float ) -> Model -> Model
borderRadius value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Box "border-radius" value :: state.properties
        }


{-| -}
font : Font -> Model -> Model
font text (Model state) =
    Model
        { state
            | properties = FontProp text :: state.properties
        }


{-| -}
underline : Model -> Model
underline (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property "text-decoration" "underline" :: state.properties
        }


{-| -}
strike : Model -> Model
strike (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property "text-decoration" "line-through" :: state.properties
        }


{-| -}
italicize : Model -> Model
italicize (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property "font-style" "italic" :: state.properties
        }


{-| -}
bold : Model -> Model
bold (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property "font-weight" "700" :: state.properties
        }


{-| -}
light : Model -> Model
light (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property "font-weight" "300" :: state.properties
        }


{-| -}
borderStyle : BorderStyle -> Model -> Model
borderStyle bStyle (Model state) =
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
        Model
            { state
                | properties =
                    Style.Model.Property "border-style" val :: state.properties
            }


{-| -}
backgroundImage : BackgroundImage -> Model -> Model
backgroundImage value (Model state) =
    Model
        { state
            | properties =
                Style.Model.BackgroundImageProp value :: state.properties
        }


{-| -}
shadows : List Shadow -> Model -> Model
shadows value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Shadows value :: state.properties
        }


{-| -}
transforms : List Transform -> Model -> Model
transforms value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Transforms value :: state.properties
        }


{-| -}
filters : List Filter -> Model -> Model
filters value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Filters value :: state.properties
        }


{-| Media Queries are created in the Style.Media module.

-}
media : List Style.Media.Query -> Model -> Model
media queries (Model state) =
    let
        renderedMediaQueries =
            List.map (\( name, vary ) -> Style.Model.MediaQuery name (vary (Model state))) queries
    in
        Model { state | properties = renderedMediaQueries ++ state.properties }


{-| Add a property.  Not to be exported, `properties` is to be used instead.
-}
property : String -> String -> Model -> Model
property name value (Model state) =
    Model
        { state
            | properties =
                Style.Model.Property name value :: state.properties
        }


{-| -}
inline : Model -> Model
inline (Model state) =
    Model
        { state
            | properties =
                Style.Model.LayoutProp Style.Model.InlineLayout :: state.properties
        }


{-| This is the only layout that allows for child elements to use `float` or `inline`.

If you try to assign a float or make an element inline that is not the child of a textLayout, the float or inline will be ignored and the element will be highlighted in red with a large warning.

Besides this, all immediate children are arranged as if they were `display: block`.

-}
textLayout : Model -> Model
textLayout (Model state) =
    Model
        { state
            | properties =
                Style.Model.LayoutProp Style.Model.TextLayout :: state.properties
        }


{-| This is the same as setting an element to `display:table`.

-}
tableLayout : Model -> Model
tableLayout (Model state) =
    Model
        { state
            | properties =
                Style.Model.LayoutProp Style.Model.TableLayout :: state.properties
        }


{-|

-}
type alias Flow =
    { wrap : Bool
    , horizontal : Alignment
    , vertical : VerticalAlignment
    }


{-| This is a flexbox foundationd layout
-}
flowUp : Flow -> Model -> Model
flowUp { wrap, horizontal, vertical } (Model state) =
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
        Model
            { state
                | properties =
                    Style.Model.LayoutProp layout :: state.properties
            }


{-|

-}
flowDown : Flow -> Model -> Model
flowDown { wrap, horizontal, vertical } (Model state) =
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
        Model
            { state
                | properties =
                    Style.Model.LayoutProp layout :: state.properties
            }


{-| -}
flowRight : Flow -> Model -> Model
flowRight { wrap, horizontal, vertical } (Model state) =
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
        Model
            { state
                | properties =
                    Style.Model.LayoutProp layout :: state.properties
            }


{-| -}
flowLeft : Flow -> Model -> Model
flowLeft { wrap, horizontal, vertical } (Model state) =
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
        Model
            { state
                | properties =
                    Style.Model.LayoutProp layout :: state.properties
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
transition : Transition -> Model -> Model
transition value (Model state) =
    Model
        { state
            | properties =
                Style.Model.TransitionProperty value :: state.properties
        }


{-| -}
type alias Animation =
    { duration : Time
    , easing : String
    , repeat : Float
    , steps : List ( Float, Style.Model.Model -> Style.Model.Model )
    }


{-| Create an animation
-}
animate : Animation -> Model -> Model
animate { duration, easing, repeat, steps } (Model state) =
    Model
        { state
            | properties =
                let
                    anim =
                        Style.Model.AnimationProp <|
                            Style.Model.Animation
                                { duration = duration
                                , easing = easing
                                , repeat = repeat
                                , steps = List.map (\( time, fn ) -> ( time, fn <| Model state )) steps
                                }
                in
                    anim :: state.properties
        }


{-| -}
hover : (Model -> Model) -> Model -> Model
hover vary (Model model) =
    Model
        { model
            | properties =
                (Style.Model.SubElement ":hover" (vary (Model model))) :: model.properties
        }


{-| -}
focus : (Model -> Model) -> Model -> Model
focus vary (Model model) =
    Model
        { model
            | properties =
                (Style.Model.SubElement ":focus" (vary (Model model))) :: model.properties
        }


{-| -}
checked : (Model -> Model) -> Model -> Model
checked vary (Model model) =
    Model
        { model
            | properties =
                (Style.Model.SubElement ":checked" (vary (Model model))) :: model.properties
        }


{-| -}
selection : (Model -> Model) -> Model -> Model
selection vary (Model model) =
    Model
        { model
            | properties =
                (Style.Model.SubElement ":selection" (vary (Model model))) :: model.properties
        }


{-| Requires a string which will be rendered as the 'content' property
-}
after : String -> (Model -> Model) -> Model -> Model
after content vary (Model model) =
    Model
        { model
            | properties =
                (Style.Model.SubElement "::after" ((vary << property "content" content) (Model model))) :: model.properties
        }


{-| Requires a string which will be rendered as the 'content' property
-}
before : String -> (Model -> Model) -> Model -> Model
before content vary (Model model) =
    Model
        { model
            | properties =
                (Style.Model.SubElement "::before" ((vary << property "content" content) (Model model))) :: model.properties
        }
