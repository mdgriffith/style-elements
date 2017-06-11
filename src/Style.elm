module Style
    exposing
        ( stylesheet
        , stylesheetWith
        , unguarded
        , Style
        , Property
        , Shadow
        , Filter
        , StyleSheet
        , Option
        , style
        , variation
        , prop
        , cursor
        , shadows
        , paddingHint
        , paddingLeftHint
        , paddingRightHint
        , paddingTopHint
        , paddingBottomHint
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
        , importUrl
        , importCss
        )

{-|


# The Style part of the Style Elements Library!

Here is where you an create your stylesheet.

One of the first concepts of `style-elements` is that layout, position, and width/height all live in your view through the `Element` module.

Your stylesheet handles everything else!

Check out the other `Style` modules for other properties.

Check out `Basic.elm` in the examples folder to see an example of a full stylesheet.


## The Basics

`style-elements` does away with CSS selectors entirely. Every style gets one identifier, which is ultimately rendered as a `class`.

@docs Style, style

Here's a basic example of a style that sets a few colors.

    import Style exposing (..)
    import Style.Color as Color
    import Color exposing (..)

    type Styles
        = Button

    stylesheet =
        Style.stylesheet
            [ style Button
                [ Color.background blue
                , Color.text white
                ]
            ]
    -- Which can be used in your view as:
    el Button [ ] (text "A button!")

@docs variation

Styles can have variations. Here's what it looks like to have a button style with a variation for `Disabled`

    import Style exposing (..)
    import Style.Color as Color
    import Color exposing (..)

    type Styles = Button

    -- You need to create a new type to capture vartiations.
    type Variations
            = Large


    stylesheet =
        Style.stylesheet
            [ style Button
                [ Font.size 16
                , variation Large
                    [ Font.size 20
                    ]
                ]
            ]

    -- which can be rendered in your view as

    el Button [ vary Disabled True ] (text "A Disabled button!")

Before you reach for a variation, consider just creating a subtype. So, something like:

    import Style exposing (..)
    import Style.Color as Color
    import Color exposing (..)

    type Styles
        = Button ButtonStyles

    type ButtonStyles
        = Active
        | Disabled


    stylesheet =
        Style.stylesheet
            [ style (Button Active)
                [ Color.background blue
                ]
            , style (Button Disabled)
                [ Color.background grey
                ]
            ]

    -- which can be rendered in your view as

    el (Button Active) [] (text "An Active button!")

The main difference between these two is that `variations` can combine with other `variations`, while subtypes are mutually exclusive.


## Properties

@docs Property, prop, opacity, cursor, paddingHint, paddingLeftHint, paddingRightHint, paddingTopHint, paddingBottomHint


## Shadows

Check out the `Style.Shadow` module for more about shadows.

@docs Shadow, shadows


## Filters

Check out the `Style.Filter` module for more about filters.

@docs Filter, filters


## Transformations

@docs origin, translate, rotate, rotateAround, scale


## Pseudo Classes

Psuedo classes can be nested.

@docs hover, checked, focus, pseudo


## Render into a Style Sheet

@docs StyleSheet, stylesheet, stylesheetWith, Option, unguarded, importUrl, importCss

-}

import Style.Internal.Model as Internal
import Style.Internal.Batchable as Batchable exposing (Batchable)
import Style.Internal.Intermediate as Intermediate exposing (Rendered(..))
import Style.Internal.Find as Find
import Style.Internal.Render as Render


{-| -}
type alias StyleSheet style variation =
    Internal.StyleSheet style variation


{-| -}
type alias Style class variation =
    Batchable (Internal.Style class variation)


{-| -}
type alias Property class variation =
    Internal.Property class variation


{-| -}
type alias Length =
    Internal.Length


{-| -}
type alias Transform =
    Internal.Transformation


{-| -}
importUrl : String -> Style class variation
importUrl url =
    Batchable.one (Internal.Import <| "url(\"" ++ url ++ "\")")


{-| -}
importCss : String -> Style class variation
importCss str =
    Batchable.one (Internal.Import <| "\"" ++ str ++ "\"")


{-| -}
style : class -> List (Property class variation) -> Style class variation
style cls props =
    Batchable.one (Internal.Style cls (prop "border-style" "solid" :: props))


{-| -}
variation : variation -> List (Property class Never) -> Property class variation
variation variation props =
    Internal.Variation variation props


{-| -}
prop : String -> String -> Property class variation
prop name val =
    Internal.Exact name val


{-| -}
opacity : Float -> Property class variation
opacity o =
    Internal.Exact "opacity" (toString o)


{-| -}
cursor : String -> Property class variation
cursor name =
    Internal.Exact "cursor" name


{-| You can give a hint about what the padding should be for this element, but the layout can override it.
-}
paddingHint : Float -> Property class variation
paddingHint x =
    Internal.Exact "padding" (toString x ++ "px")


{-| -}
paddingLeftHint : Float -> Property class variation
paddingLeftHint x =
    Internal.Exact "padding-left" (toString x ++ "px")


{-| -}
paddingRightHint : Float -> Property class variation
paddingRightHint x =
    Internal.Exact "padding-right" (toString x ++ "px")


{-| -}
paddingTopHint : Float -> Property class variation
paddingTopHint x =
    Internal.Exact "padding-top" (toString x ++ "px")


{-| -}
paddingBottomHint : Float -> Property class variation
paddingBottomHint x =
    Internal.Exact "padding-bottom" (toString x ++ "px")


{-| -}
type alias Shadow =
    Internal.ShadowModel


{-| -}
shadows : List Shadow -> Property class variation
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
filters : List Filter -> Property class variation
filters fs =
    Internal.Filters fs


{-| Set the transform origin.
-}
origin : Float -> Float -> Float -> Property class variation
origin x y z =
    Internal.Exact "transform-origin" (toString x ++ "px  " ++ toString y ++ "px " ++ toString z ++ "px")


{-| Units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.

-}
rotate : Float -> Property class variation
rotate a =
    Internal.Transform <| [ Internal.Rotate a ]


{-| Rotate around a vector.

Angle units always rendered as `radians`.

Use `degrees` or `turns` from the standard library if you want to use a different set of units.

-}
rotateAround : ( Float, Float, Float ) -> Float -> Property class variation
rotateAround ( x, y, z ) angle =
    Internal.Transform <| [ Internal.RotateAround x y z angle ]


{-| Units are always as pixels
-}
translate : Float -> Float -> Float -> Property class variation
translate x y z =
    Internal.Transform <| [ Internal.Translate x y z ]


{-| -}
scale : Float -> Float -> Float -> Property class variation
scale x y z =
    Internal.Transform <| [ Internal.Scale x y z ]


{-| Example:

    style Button
        [ Color.background blue
        , hover
            [ Color.background red
            ]
        ]

-}
hover :
    List (Property class variation)
    -> Property class variation
hover props =
    Internal.PseudoElement ":hover" props


{-| -}
focus :
    List (Property class variation)
    -> Property class variation
focus props =
    Internal.PseudoElement ":focus" props


{-| -}
checked :
    List (Property class variation)
    -> Property class variation
checked props =
    Internal.PseudoElement ":checked" props


{-| -}
pseudo :
    String
    -> List (Property class variation)
    -> Property class variation
pseudo psu props =
    Internal.PseudoElement (":" ++ psu) props


{-| Stylesheet options
-}
type Option
    = Unguarded



--| Critical (List class)


{-| Remove style hash guards from style classes.
-}
unguarded : Option
unguarded =
    Unguarded


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
em {
    font-style: italic;
}
strong {
    font-weight: bold;
}

a {
    text-decoration: none;
}

input, textarea {
    border-width: 0;
}

.clearfix:after {
  content: "";
  display: table;
  clear: both;
}


"""


{-| -}
stylesheet : List (Style elem variation) -> StyleSheet elem variation
stylesheet styles =
    stylesheetWith [] styles


{-| -}
stylesheetWith : List Option -> List (Style elem variation) -> StyleSheet elem variation
stylesheetWith options styles =
    let
        unguarded =
            List.any ((==) Unguarded) options
    in
        prepareSheet (Render.stylesheet reset (not <| unguarded) styles)


{-| -}
prepareSheet : Intermediate.Rendered class variation -> StyleSheet class variation
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
                (( parent, True ) :: varys)
    in
        { style = \class -> (Find.style class findable)
        , variations = \class varys -> variations class varys
        , css = css
        }
