module Style
    exposing
        ( stylesheet
        , stylesheetWith
        , Style
        , Property
        , Shadow
        , Filter
        , StyleSheet
        , Defaults
        , style
        , variation
        , prop
        , cursor
        , shadows
        , paddingHint
        , opacity
        , filters
        , origin
        , translate
        , rotate
        , rotateAround
        , scale
        , hover
        , checked
        , focus
        , pseudo
        , rounded
        , roundTopLeft
        , roundTopRight
        , roundBottomRight
        , roundBottomLeft
        )

{-|


# Welcome to the Style part of the Style Elements Library!

Here is where you an create your stylesheet.

One of the first concepts of `style-elements` is that layout, position, and width/height all live in your view.

Your stylesheet handles everything else!

There are some good reasons for this. Check out `http://elm.style` if you want more info.


## The Basics

`style-elements` does away with CSS selectors nearly entirely. Every style gets one identifier (which is ultimately rendered as a `class`).

@docs StyleSheet, stylesheet, stylesheetWith, Defaults

@docs Style, style, variation, Property, prop

@docs opacity, cursor, paddingHint

@docs Shadow, shadows

@docs Filter, filters

@docs origin, translate, rotate, rotateAround, scale

@docs hover, checked, focus, pseudo

@docs rounded, roundTopLeft, roundTopRight, roundBottomRight, roundBottomLeft

-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Value
import Style.Internal.Batchable as Batchable exposing (Batchable)
import Style.Internal.Intermediate as Intermediate exposing (Rendered(..))
import Color exposing (Color)
import Html.Attributes
import Style.Internal.Find as Find
import Style.Internal.Render as Render


{-| -}
type alias StyleSheet style variation animation msg =
    Internal.StyleSheet style variation animation msg


{-| -}
type alias Style class variation animation =
    Batchable (Internal.Style class variation animation)


{-| -}
type alias Property class variation animation =
    Internal.Property class variation animation


{-| -}
type alias Length =
    Internal.Length


{-| -}
type alias Transform =
    Internal.Transformation


{-| -}
style : class -> List (Property class variation animation) -> Style class variation animation
style cls props =
    Batchable.one (Internal.Style cls (prop "border-style" "solid" :: props))


{-| -}
variation : variation -> List (Property class Never animation) -> Property class variation animation
variation variation props =
    Internal.Variation variation props


{-| -}
prop : String -> String -> Property class variation animation
prop name val =
    Internal.Exact name val


{-| -}
opacity : Float -> Property class variation animation
opacity o =
    Internal.Exact "opacity" (toString o)


{-| -}
cursor : String -> Property class variation animation
cursor name =
    Internal.Exact "cursor" name


{-| You can give a hint about what the padding should be for this element, but the layout can override it.
-}
paddingHint : Float -> Property class variation animation
paddingHint x =
    Internal.Exact "padding" (toString x ++ "px")


{-| -}
paddingLeftHint : Float -> Property class variation animation
paddingLeftHint x =
    Internal.Exact "padding-left" (toString x ++ "px")


{-| -}
paddingRightHint : Float -> Property class variation animation
paddingRightHint x =
    Internal.Exact "padding-right" (toString x ++ "px")


{-| -}
paddingTopHint : Float -> Property class variation animation
paddingTopHint x =
    Internal.Exact "padding-top" (toString x ++ "px")


{-| -}
paddingBottomHint : Float -> Property class variation animation
paddingBottomHint x =
    Internal.Exact "padding-bottom" (toString x ++ "px")


{-| -}
type alias Shadow =
    Internal.ShadowModel


{-| -}
shadows : List Shadow -> Property class variation animation
shadows shades =
    Internal.Shadows shades


{-| -}
type alias Filter =
    Internal.Filter


{-| Apply a stack of filters. The actual filters are in `Style.Filter`.

    import Style.Filter as Filter
    import Style exposing (..)

    style MyFitleredStyle
        [ filters
            [ Filter.blur 0.5
            , Filter.invert 0.5
            ]

        ]

-}
filters : List Filter -> Property class variation animation
filters fs =
    Internal.Filters fs


{-| Set the transform origin.
-}
origin : Float -> Float -> Float -> Property class variation animation
origin x y z =
    Internal.Exact "transform-origin" (toString x ++ "px  " ++ toString y ++ "px " ++ toString z ++ "px")


{-| Units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.

-}
rotate : Float -> Property class variation animation
rotate a =
    Internal.Transform <| [ Internal.Rotate a ]


{-| Rotate around a vector.

Angle units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.

-}
rotateAround : ( Float, Float, Float ) -> Float -> Property class variation animation
rotateAround ( x, y, z ) angle =
    Internal.Transform <| [ Internal.RotateAround x y z angle ]


{-| Units are always as pixels
-}
translate : Float -> Float -> Float -> Property class variation animation
translate x y z =
    Internal.Transform <| [ Internal.Translate x y z ]


{-| -}
scale : Float -> Float -> Float -> Property class variation animation
scale x y z =
    Internal.Transform <| [ Internal.Scale x y z ]


{-| Round all corners.
-}
rounded : Float -> Property class variation animation
rounded box =
    Internal.Exact "border-radius" (toString box ++ "px")


{-| -}
roundTopLeft : Float -> Property class variation animation
roundTopLeft x =
    Internal.Exact "border-top-left-radius" (toString x ++ "px")


{-| -}
roundTopRight : Float -> Property class variation animation
roundTopRight x =
    Internal.Exact "border-top-right-radius" (toString x ++ "px")


{-| -}
roundBottomRight : Float -> Property class variation animation
roundBottomRight x =
    Internal.Exact "border-bottom-right-radius" (toString x ++ "px")


{-| -}
roundBottomLeft : Float -> Property class variation animation
roundBottomLeft x =
    Internal.Exact "border-bottom-left-radius" (toString x ++ "px")


{-| -}
hover :
    List (Property class variation animation)
    -> Property class variation animation
hover props =
    Internal.PseudoElement ":hover" props


{-| -}
focus :
    List (Property class variation animation)
    -> Property class variation animation
focus props =
    Internal.PseudoElement ":focus" props


{-| -}
checked :
    List (Property class variation animation)
    -> Property class variation animation
checked props =
    Internal.PseudoElement ":checked" props


{-| -}
pseudo :
    String
    -> List (Property class variation animation)
    -> Property class variation animation
pseudo psu props =
    Internal.PseudoElement (":" ++ psu) props


{-| -}
type alias Defaults =
    { typeface : List String
    , fontSize : Float
    , lineHeight : Float
    , textColor : Color
    }


presetDefaults : Defaults
presetDefaults =
    { typeface = [ "calibri", "helvetica", "arial", "sans-serif" ]
    , fontSize = 16
    , lineHeight = 1.3
    , textColor = Color.black
    }


reset : String
reset =
    """
/* http://meyerweb.com/eric/tools/css/reset/
   v2.0 | 20110126
   License: none (public domain)
*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video, hr {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  font: inherit;
  vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
  display: block;
}
body {
  line-height: 1;
}
ol, ul {
  list-style: none;
}
blockquote, q {
  quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
  content: '';
  content: none;
}
table {
  border-collapse: collapse;
  border-spacing: 0;
}
/** Borrowed from Normalize.css **/

/**
 * Prevent `sub` and `sup` elements from affecting the line height in
 * all browsers.
 */

sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sub {
  bottom: -0.25em;
}

sup {
  top: -0.5em;
}

a {
    text-decoration: none;
}

"""


{-| -}
stylesheet : List (Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheet styles =
    let
        defaults =
            Batchable.One
                (Internal.RawStyle "style-elements-root"
                    [ ( "font-family", Value.typeface presetDefaults.typeface )
                    , ( "color", Value.color presetDefaults.textColor )
                    , ( "line-height", toString presetDefaults.lineHeight )
                    , ( "font-size", toString presetDefaults.fontSize ++ "px" )
                    ]
                )

        stylesheet =
            render
                (defaults :: styles)
    in
        { stylesheet | css = reset ++ stylesheet.css }


{-| -}
stylesheetWith : Defaults -> List (Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheetWith defaultProps styles =
    let
        defaults =
            Batchable.One
                (Internal.RawStyle "style-elements-root"
                    [ ( "font-family", Value.typeface defaultProps.typeface )
                    , ( "color", Value.color defaultProps.textColor )
                    , ( "line-height", toString defaultProps.lineHeight )
                    , ( "font-size", toString defaultProps.fontSize ++ "px" )
                    ]
                )

        stylesheet =
            render
                (defaults :: styles)
    in
        { stylesheet | css = reset ++ stylesheet.css }


type Option class
    = Guard
    | Critical (List class)


{-| -}
guard : Option class
guard =
    Guard


{-| -}
critical : List class -> Option class
critical =
    Critical


{-| -}
render : List (Style class variation animation) -> StyleSheet class variation animation msg
render styles =
    prepareSheet (Render.stylesheet False styles)


{-| -}
renderWith : List (Option class) -> List (Style class variation animation) -> StyleSheet class variation animation msg
renderWith opts styles =
    let
        guard =
            List.any ((==) Guard) opts

        critical =
            List.concatMap criticalClasses opts

        criticalClasses opt =
            case opt of
                Critical class ->
                    class

                _ ->
                    []
    in
        prepareSheet (Render.stylesheet guard styles)


clearfix : String
clearfix =
    """
.clearfix:after {
  content: "";
  display: table;
  clear: both;
}

"""


{-| -}
prepareSheet : Intermediate.Rendered class variation animation -> StyleSheet class variation animation msg
prepareSheet (Rendered { css, findable }) =
    let
        variations class vs =
            let
                parent =
                    Find.style class findable

                varys =
                    vs
                        |> List.filter Tuple.second
                        |> List.map ((\vary -> Find.variation class vary findable) << Tuple.first)
                        |> List.map (\cls -> ( cls, True ))
            in
                Html.Attributes.classList (( parent, True ) :: varys)
    in
        { style = \class -> Html.Attributes.class (Find.style class findable)
        , variations = \class varys -> variations class varys
        , animations = []
        , css =
            clearfix ++ css
        }
