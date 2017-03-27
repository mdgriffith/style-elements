module Style
    exposing
        ( Model
        , Property
        , StyleSheet
        , Shadow
        , Visibility
        , Vertical
        , Horizontal
        , BackgroundImage
        , Transform
        , Filter
        , Floating
        , BorderStyle
        , Flow
        , Layout
        , Whitespace
        , PositionParent
        , Repeat
        , Animation
        , Transition
        , Option
        , Border
        , foundation
        , embed
        , render
        , renderWith
        , style
        , layout
        , position
        , variation
        , withPosition
        , withLayout
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
        , justify
        , justifyAll
        , center
        , stretch
        , alignTop
        , alignBottom
        , alignLeft
        , alignRight
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
        , font
        , fontsize
        , lineHeight
        , textAlign
        , whitespace
        , letterSpacing
        , italicize
        , bold
        , light
        , strike
        , underline
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
        , base
        , debug
        )

{-|

This module is focused around composing a style.

@docs Model, Property

# Rendering

We use `render` to create a style sheet and `embed` to embed it in our view.

@docs render, renderWith, StyleSheet, embed

## Rendering Options

@docs Option, importCSS, importUrl, debug, base, foundation, autoImportGoogleFonts

# Creating Styles

@docs style, layout, position, variation, selector


# Positioning

The coordinates for position always have the same coordinate system, right and down are the positive directions, same as the standard coordinate system for svg.

These coordinates are always rendered in pixels.

The name of the position property refers on which corner of the css box to start at.

@docs topLeft, topRight, bottomLeft, bottomRight

@docs positionBy, PositionParent, parent, currentPosition, screen



# Width/Height

@docs height, minHeight, maxHeight, width, minWidth, maxWidth

# Units

Most values in this library have one set of units to the library that are required to be used.

This is to encourage relative units to be expressed in terms of your elm code instead of relying on DOM hierarchy.

However, `width` and `height` values can be pixels, percent, or auto.

@docs percent, px, auto


# A Note on Padding and Margins

With `padding` and `margin` you have two ways of specifying the spacing of the child element within the parent.  Either the `margin` on the child or the `padding` on the parent.

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

@docs Border, border, borderStyle, BorderStyle, borderWidth, solid, dotted, dashed, borderRadius

# Layouts

Layouts affect how child elements are arranged.

@docs Layout, textLayout, tableLayout

@docs Flow, flowUp, flowDown, flowRight, flowLeft


@docs inline

@docs Floating, floatLeft, floatRight, floatTopLeft, floatTopRight

# Alignment

@docs Horizontal, alignLeft, alignRight, center, stretch, justify, justifyAll

@docs Vertical, alignTop, alignBottom


# Colors

@docs textColor, backgroundColor, borderColor


# Visibility

@docs visibility, Visibility, hidden, opacity, transparency, visible


# Text/Font

@docs font, fontsize, lineHeight, textAlign, letterSpacing, whitespace, Whitespace, normal, pre, preLine, preWrap, noWrap, italicize, bold, light, strike, underline, cursor


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


@docs withPosition, withLayout

-}

import Html exposing (Html, Attribute)
import Html.Attributes
import Time exposing (Time)
import Color exposing (Color)
import List.Extra
import String.Extra
import Style.Model exposing (Model(..), Property(..), LayoutProperty(..), PositionProperty(..), Floating(..), Whitespace(..), Centerable(..), Vertical(..), Horizontal(..))
import Style.Render
import Style.Media


{-| A style model which keeps of a list of style properties and the class for a given style.

The `class` type variable is the type you use to write your css classes.

-}
type alias Model class layoutClass positionClass variation animation msg =
    Style.Model.Model class layoutClass positionClass variation animation msg


{-| This type represents any style property.  The Model has a list of these.

-}
type alias Property animation variation msg =
    Style.Model.Property animation variation msg


{-|

Sets the following defaults:

    box-sizing: border-box
    display: block
    position: relative
    top: 0
    left: 0

-}
foundation : List (Property animation variation msg)
foundation =
    [ (Style.Model.Property "box-sizing" "border-box")
    ]


positionFoundation : List (PositionProperty animation variation msg)
positionFoundation =
    [ topLeft 0 0
    , positionBy currentPosition
    ]


{-|

Sets the following defaults:

    box-sizing: border-box
    display: block
    position: relative
    top: 0
    left: 0

-}
layoutFoundation : List (LayoutProperty animation variation msg)
layoutFoundation =
    [ textLayout
    ]


{-| Set the class for a given style.  You should use a union type!
-}
style : class -> List (Property animation variation msg) -> Model class layoutClass positionClass variation animation msg
style cls props =
    StyleModel
        { selector = Style.Model.Class cls
        , properties = props
        }


{-| Set the class for a layout.  You should use a union type!
-}
layout : layoutClass -> List (LayoutProperty animation variation msg) -> Model class layoutClass positionClass variation animation msg
layout cls props =
    LayoutModel
        { selector = Style.Model.Class cls
        , properties = List.map Style.Model.layoutToProperty props
        }


{-| Set the class for a layout.  You should use a union type!
-}
position : positionClass -> List (PositionProperty animation variation msg) -> Model class layoutClass positionClass variation animation msg
position cls props =
    PositionModel
        { selector = Style.Model.Class cls
        , properties = List.map Style.Model.positionToProperty props
        }


{-| Set the class for a variation.  You should use a union type!
-}
variation : class -> List (Property animation class msg) -> Property animation class msg
variation cls props =
    Style.Model.Variation cls props


{-| Embed a style sheet into your html.
-}
embed : StyleSheet class layoutClass positionClass variation msg -> Html msg
embed stylesheet =
    Html.node "style" [] [ Html.text stylesheet.css ]


{-| The stylesheet contains the rendered css as a string, and two functions to lookup

-}
type alias StyleSheet class layoutClass positionClass variation msg =
    { style : class -> Html.Attribute msg
    , styleVariation : class -> List ( variation, Bool ) -> Html.Attribute msg
    , layout : layoutClass -> Html.Attribute msg
    , position : positionClass -> Html.Attribute msg
    , css : String
    }


{-| Render styles into a stylesheet

-}
render : List (Model class layoutClass positionClass variation animation msg) -> StyleSheet class layoutClass positionClass variation msg
render styles =
    renderWith [] styles


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


getFontNames : Model class layoutClass positionClass variation animation msg -> List String
getFontNames state =
    let
        styleProperties stylemodel =
            case stylemodel of
                StyleModel model ->
                    model.properties

                _ ->
                    []

        getFonts prop =
            case prop of
                Style.Model.Property name family ->
                    if name == "font-family" then
                        family
                            |> String.split ","
                            |> List.map (String.Extra.replace "'" "" << String.Extra.unquote << String.Extra.replace " " "+" << String.trim)
                            |> Just
                    else
                        Nothing

                _ ->
                    Nothing
    in
        state
            |> styleProperties
            |> List.filterMap getFonts
            |> List.concat


{-| Render a stylesheet with options
-}
renderWith : List (Option animation variation msg) -> List (Model class layoutClass positionClass variation animation msg) -> StyleSheet class layoutClass positionClass variation msg
renderWith opts styles =
    let
        forBase opt =
            case opt of
                BaseStyle style ->
                    Just style

                _ ->
                    Nothing

        forLayoutBase opt =
            case opt of
                _ ->
                    Nothing

        forPositionBase opt =
            case opt of
                _ ->
                    Nothing

        base =
            opts
                |> List.filterMap forBase
                |> List.head
                |> Maybe.withDefault foundation

        layoutBase =
            opts
                |> List.filterMap forLayoutBase
                |> List.head
                |> Maybe.withDefault layoutFoundation
                |> List.map Style.Model.layoutToProperty

        positionBase =
            opts
                |> List.filterMap forPositionBase
                |> List.head
                |> Maybe.withDefault positionFoundation
                |> List.map Style.Model.positionToProperty

        basedStyles =
            List.map
                (\model ->
                    case model of
                        StyleModel state ->
                            StyleModel
                                { state
                                    | properties = flatten (base ++ state.properties)
                                }

                        LayoutModel state ->
                            LayoutModel
                                { state
                                    | properties = layoutBase ++ state.properties
                                }

                        PositionModel state ->
                            PositionModel
                                { state
                                    | properties = positionBase ++ state.properties
                                }
                )
                styles

        debug =
            List.any (\x -> x == DebugStyles) opts

        renderAdd add =
            case add of
                AutoImportGoogleFonts ->
                    basedStyles
                        |> List.concatMap getFontNames
                        |> List.Extra.uniqueBy identity
                        |> List.filter (not << isWebfont)
                        |> String.join "|"
                        |> (\family ->
                                case family of
                                    "" ->
                                        Nothing

                                    _ ->
                                        Just ("@import url('https://fonts.googleapis.com/css?family=" ++ family ++ "');")
                           )

                Import str ->
                    Just ("@import " ++ str ++ ";")

                ImportUrl str ->
                    Just ("@import url('" ++ str ++ "');")

                BaseStyle _ ->
                    Nothing

                DebugStyles ->
                    Just (Style.Render.inlineError ++ Style.Render.floatError)

        renderStyle styles =
            let
                ( names, cssStyles ) =
                    styles
                        |> List.map Style.Render.render
                        |> List.Extra.uniqueBy Tuple.first
                        |> List.unzip
            in
                { css = String.join "\n" cssStyles
                , layout =
                    (\layoutCls ->
                        case Style.Render.findLayout layoutCls styles of
                            Nothing ->
                                if debug then
                                    let
                                        _ =
                                            Debug.log "style" ("The layout, " ++ toString layoutCls ++ ", is not in your stylesheet.")
                                    in
                                        Html.Attributes.class (Style.Render.formatName layoutCls)
                                else
                                    Html.Attributes.class (Style.Render.formatName layoutCls)

                            Just style ->
                                Html.Attributes.class (Style.Render.getName style)
                    )
                , position =
                    (\positionCls ->
                        case Style.Render.findPosition positionCls styles of
                            Nothing ->
                                if debug then
                                    let
                                        _ =
                                            Debug.log "style" ("The position model, " ++ toString positionCls ++ ", is not in your stylesheet.")
                                    in
                                        Html.Attributes.class (Style.Render.formatName positionCls)
                                else
                                    Html.Attributes.class (Style.Render.formatName positionCls)

                            Just style ->
                                Html.Attributes.class (Style.Render.getName style)
                    )
                , style =
                    (\cls ->
                        case Style.Render.findStyle cls styles of
                            Nothing ->
                                if debug then
                                    let
                                        _ =
                                            Debug.log "style" (toString cls ++ " is not in your stylesheet.")
                                    in
                                        Html.Attributes.class (Style.Render.formatName cls)
                                else
                                    Html.Attributes.class (Style.Render.formatName cls)

                            Just style ->
                                Html.Attributes.class (Style.Render.getName style)
                    )
                , styleVariation =
                    (\baseClass variations ->
                        let
                            foundBase =
                                Style.Render.findStyle baseClass styles
                        in
                            foundBase
                                |> (\foundStyle ->
                                        case foundStyle of
                                            Nothing ->
                                                let
                                                    _ =
                                                        Debug.log "style" (toString baseClass ++ " is not in your stylesheet.")
                                                in
                                                    []

                                            Just style ->
                                                let
                                                    confirmed =
                                                        Style.Render.verifyVariations style (List.map Tuple.first variations)

                                                    variationNames =
                                                        variations
                                                            |> List.filter Tuple.second
                                                            |> List.map (Tuple.first >> Style.Render.variationName)

                                                    _ =
                                                        confirmed
                                                            |> List.filter (not << Tuple.second)
                                                            |> List.map
                                                                ((\notFoundVariation ->
                                                                    Debug.log "style" ("The " ++ toString notFoundVariation ++ " variation can't be found for the " ++ toString baseClass ++ " style!")
                                                                 )
                                                                    << Tuple.first
                                                                )
                                                in
                                                    Style.Render.getName style :: variationNames
                                   )
                                |> String.join " "
                                |> Html.Attributes.class
                    )
                }

        rendered =
            renderStyle basedStyles
    in
        case List.filterMap renderAdd opts of
            [] ->
                rendered

            rules ->
                { rendered
                    | css = String.join "\n" rules ++ "\n\n" ++ rendered.css
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
type alias Horizontal =
    Style.Model.Horizontal


{-|
-}
type alias Vertical =
    Style.Model.Vertical


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
visibility : Visibility -> Property animation variation msg
visibility vis =
    (Style.Model.VisibilityProp vis)


{-| -}
cursor : String -> Property animation variation msg
cursor value =
    (Property "cursor" value)


{-| -}
width : Length -> Property animation variation msg
width value =
    Len "width" value


{-| -}
minWidth : Length -> Property animation variation msg
minWidth value =
    (Len "min-width" value)


{-| -}
maxWidth : Length -> Property animation variation msg
maxWidth value =
    (Len "max-width" value)


{-| -}
height : Length -> Property animation variation msg
height value =
    (Len "height" value)


{-| -}
minHeight : Length -> Property animation variation msg
minHeight value =
    (Len "min-height" value)


{-| -}
maxHeight : Length -> Property animation variation msg
maxHeight value =
    (Len "max-height" value)


{-| -}
padding : ( Float, Float, Float, Float ) -> Property animation variation msg
padding value =
    (Box "padding" value)


{-| -}
shadows : List Shadow -> Property animation variation msg
shadows value =
    Shadows value


{-| -}
transforms : List Transform -> Property animation variation msg
transforms value =
    Transforms value


{-| -}
filters : List Filter -> Property animation variation msg
filters value =
    Filters value


{-| Add a custom property.
-}
property : String -> String -> Property animation variation msg
property name value =
    Property name value


{-| -}
alignTop : Centerable Vertical
alignTop =
    Other Top


{-| -}
alignBottom : Centerable Vertical
alignBottom =
    Other Bottom


{-|
-}
center : Centerable a
center =
    Center


{-|
-}
stretch : Centerable a
stretch =
    Stretch


{-| -}
justify : Centerable a
justify =
    stretch


{-| -}
justifyAll : Centerable a
justifyAll =
    stretch


{-| -}
alignLeft : Centerable Horizontal
alignLeft =
    Other Left


{-| -}
alignRight : Centerable Horizontal
alignRight =
    Other Right


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
transition : Transition -> Property animation variation msg
transition value =
    Style.Model.TransitionProperty value


{-| -}
type alias Animation prop =
    { duration : Time
    , easing : String
    , repeat : Float
    , steps : List ( Float, List prop )
    }


{-| Create an animation
-}
animate : Animation (Property animation variation msg) -> Property animation variation msg
animate { duration, easing, repeat, steps } =
    Style.Model.AnimationProp <|
        Style.Model.Animation
            { duration = duration
            , easing = easing
            , repeat = repeat
            , steps = steps
            }


{-| -}
hover : List (Property animation variation msg) -> Property animation variation msg
hover props =
    Style.Model.SubElement ":hover" props


{-| -}
focus : List (Property animation variation msg) -> Property animation variation msg
focus props =
    Style.Model.SubElement ":focus" props


{-| -}
checked : List (Property animation variation msg) -> Property animation variation msg
checked props =
    Style.Model.SubElement ":checked" props


{-| -}
selection : List (Property animation variation msg) -> Property animation variation msg
selection props =
    Style.Model.SubElement ":selection" props


{-| Requires a string which will be rendered as the 'content' property
-}
after : String -> List (Property animation variation msg) -> Property animation variation msg
after content props =
    Style.Model.SubElement "::after" (property "content" content :: props)


{-| Requires a string which will be rendered as the 'content' property
-}
before : String -> List (Property animation variation msg) -> Property animation variation msg
before content props =
    Style.Model.SubElement "::before" (property "content" content :: props)
