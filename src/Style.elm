module Style
    exposing
        ( Font
        , Option
        , Property
        , Style
        , StyleSheet
        , Transform
        , checked
        , cursor
        , focus
        , hover
        , importCss
        , importUrl
        , opacity
        , origin
        , prop
        , pseudo
        , rotate
        , rotateAround
        , scale
        , style
        , styleSheet
        , styleSheetWith
        , translate
        , unguarded
        , variation
        )

{-|


# The Style part of the Style Elements Library!

Here is where you an create your style sheet.

One of the first concepts of `style-elements` is that layout, position, and width/height all live in your view through the `Element` module.

Your style sheet handles everything else!

Check out the other `Style` modules for other properties.

Check out `Basic.elm` in the examples folder to see an example of a full style sheet.


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
        Style.styleSheet
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

    -- You need to create a new type to capture variations.
    type Variations
        = Disabled


    stylesheet =
        Style.styleSheet
            [ style Button
                [ Color.background blue
                , Color.text white
                , variation Disabled
                    [ Color.background grey
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

@docs Property, prop, opacity, cursor, Font


## Transformations

@docs Transform, origin, translate, rotate, rotateAround, scale


## Pseudo Classes

Psuedo classes can be nested.

@docs hover, checked, focus, pseudo


## Render into a Style Sheet

@docs StyleSheet, styleSheet, styleSheetWith, Option, unguarded, importUrl, importCss

-}

import Style.Internal.Batchable as Batchable exposing (Batchable)
import Style.Internal.Find as Find
import Style.Internal.Intermediate as Intermediate exposing (Rendered(..))
import Style.Internal.Model as Internal
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
type alias Transform =
    Internal.Transformation


{-| -}
type alias Font =
    Internal.Font


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


{-| Remove style hash guards from style classes.
-}
unguarded : Option
unguarded =
    Unguarded


{-| -}
styleSheet : List (Style elem variation) -> StyleSheet elem variation
styleSheet styles =
    styleSheetWith [] styles


{-| -}
styleSheetWith : List Option -> List (Style elem variation) -> StyleSheet elem variation
styleSheetWith options styles =
    let
        unguarded =
            List.any ((==) Unguarded) options
    in
    prepareSheet (Render.stylesheet "" (not <| unguarded) styles)


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
            ( parent, True ) :: varys
    in
    { style = \class -> Find.style class findable
    , variations = \class varys -> variations class varys
    , css = css
    }
