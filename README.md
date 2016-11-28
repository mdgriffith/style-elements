    This library is experimental

# Simplifying css for elm

The aim of `style-elements` library is to give you the tools to write styles that are intuitive and robust, while still being productive and expressive.  To make styles that don't break.

And while we're at it, it wouldn't hurt to have built in support for `animations`, `transitions`, and `media queries` too.

## Compared to elm-css

The goal of [elm-css](https://github.com/rtfeldman/elm-css/) library is to provide access _all_ of CSS in a typesafe way.  This is awesome and incredibly impressive.

The `style-elements` focuses on simplifying css.

It does this by 

 * removing parts of css that cause the most trouble
 * limiting available properties without limiting functionality (i.e. trying to make the CSS language smaller)
 * setting defaults
 * providing clean interfaces to the good parts like `media queries`, `flex-box` and `animations`.

It's meant to be a css preprocessor with css best practices built in.


#### Create a stylesheet

```elm

import Style exposing (..)


type Class 
    = Title
    | Nav
    | Container

stylesheet : StyleSheet Class msg
stylesheet =
    Style.render
        [ class Title
            [ width (px 300)
            , height auto
            ]
        , class Nav
            [ width (percent 100)
            , height (px 70)
            ]
        ]
```

This looks a _lot_ like elm-css.  That's because using union types and lists to represent style is generally a really good idea.

#### Easy layout

```elm
    class Container 
        [ flowLeft
            { wrap = True
            , horizontal = alignCenter
            , vertical = alignTop
            }
        ]
```

#### Animation

```elm

    class RotatingBox
        [ width (px 50)
        , height (px 50)
        , animate
            { duration = (5 * second)
            , easing = "linear"
            , repeat = forever
            , steps =
                [ ( 0, transforms [ rotate 0 0 0 ] )
                , ( 100, transforms [ rotate 0 0 (2 * pi) ] )
                ]
            }
        ]
```

#### Media Queries

```elm

import Style.Media
import Color

-- (..)
    class MediaQueryExample
        [ width (px 180)
        , height (px 180)
        , padding (all 20)
        , backgroundColor Color.blue
        , textColor Color.white
        , flowRight
            { wrap = True
            , horizontal = alignCenter
            , vertical = verticalCenter
            }
        , Style.Media.phoneOnly
            [ backgroundColor Color.red
            ]
        , Style.Media.tabletPortraitOnly
            [ borderWidth (all 5)
            , borderRadius (all 15)
            ]
        ]


```


## Getting Started

 * [Documentation](http://package.elm-lang.org/packages/mdgriffith/style-elements/latest)
 * Realworld example that uses animations, media queries, and palettes: [code](https://github.com/mdgriffith/elm-style-elements-complex-example) - [demo](https://mdgriffith.github.io/style-elements/realworld/)


#### Building a stylesheet

```elm

import Style exposing (..)

type Class 
    = Title
    | Nav

stylesheet : Stylesheet Class msg
stylesheet =
    Style.render
        [ class Title
            [ width (px 300)
            , height auto
            ]
        , class Nav
            [ width (percent 100)
            , height (px 70)
            ]

        ]

```

#### Embed that stylesheet in your view and use it to render a style class

```elm
view : Model -> Html msg
view model =
    div []
        [ Style.embed stylesheet
        , div [ stylesheet.class Title ] [ text "Hello!"]
        , div [ stylesheet.class Title ] [ text "Hello!"]
        ]
```




