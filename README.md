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


## Create a stylesheet

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

It rendered as you'd expect, though the `style-elements` library also includes `display:block`, `position:relative`, `left:0;`, `top:0`, and `box-sizing:border-box` as default properties. You can remove or add to the defaults as you'd like.

```css
.title-cjdbfgdfgs {
  display: block;
  position: relative;
  top: 0px;
  left: 0px;
  box-sizing: border-box;
  width: 300px;
  height: auto;
}
.nav-jgdkdbabsb {
  display: block;
  position: relative;
  top: 0px;
  left: 0px;
  box-sizing: border-box;
  width: 100%;
  height: 70px;
}
```

Each class automatically gets the hash of it's style properties appended to the classname.  This means you get automatic namespacing!


## Easy layout

```elm
    class Container 
        [ flowRight
            { wrap = True
            , horizontal = alignCenter
            , vertical = alignTop
            }
        ]
```

generates the following css

```css
.container-bhabgdar {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  align-items: flex-start;
}

```

It's much easier to think about flex-box in terms of horizontal and vertical alignment, than in `justify-content`, and `align-items`, which change orientation depending on `flex-direction`.

Also, `row` is a direction?


## Animation

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

generates this css


```css

.rotating-box-fhghfhda {
  animation: animation-cjdbgdbchi 5000ms linear infinite;
}
@keyframes animation-cjdbgdbchi {
  0% {
    transform: rotateX(0rad) rotateY(0rad) rotateZ(0rad);
  }
  100% {
    transform: rotateX(0rad) rotateY(0rad) rotateZ(6.283185307179586rad);
  }
}


```

An animation name is generated using a murmur3 hash of the animation properties.

One less name you have to come up with!


## Media Queries

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

The `style-elements` library comes with some standard media queries built in.

How often do these things change anyway?


# Getting Started

 * [Documentation](http://package.elm-lang.org/packages/mdgriffith/style-elements/latest)
 * Realworld example that uses animations, media queries, and palettes: [code](https://github.com/mdgriffith/elm-style-elements-complex-example) - [demo](https://mdgriffith.github.io/style-elements/realworld/)


## Building a stylesheet

The `Style` module is intended to be imported unqualified, so it's recommended to put your styles in their own `.elm` file.

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

Embed that stylesheet in your view and use it to render a style class

```elm
view : Model -> Html msg
view model =
    div []
        [ Style.embed stylesheet
        , div [ stylesheet.class Nav ] 
            [ a [href "/profile"] [text "My Profile"]
            ]
        , div [ stylesheet.class Title ] [ text "Hello!"]
        ]
```


# More Advanced!

In addition to `render`, there is the `renderWith` function which allows you to set options for your stylesheet.


## Auto import google fonts

Setting this option will automatically try to import any non-standard webfonts in yor stylesheet from the google fonts library.

One less step for you.

```elm
stylesheet : Stylesheet Class msg
stylesheet =
    Style.renderWith [ Style.autoImportGoogleFonts ]
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

## Debug

While we try to catch most of our errors as compile-time error messages, we can't quite get them all.  Adding `Style.debug` to the `renderWith` options will log some errors and cause some other errors to show up graphically on your page.

The errors are

>  __Style missing from style-sheet__ - If you try to render a class of a style that is not in your stylesheet, an error will be logged.
> 
>  __Improper float or inline__ - In this library `float` and `inline` elements are only allowed in a `textLayout`(this is the standard layout that renders with `display:block`.)  Float and inline should only be used in text situations, not for page layout.  
>
>  Page layout should be handled by the `flex-box` functions, `flowRight`, `flowLeft`, `flowUp`, and `flowDown`.
>
>  If an element is floated or inlined incorrectly, debug mode will highlight it in yellow on your page and add a text error.


## Base

Remember when I said `style-elements` had some default properties?  Well you can change them by adding `Style.base yourListofDefaultProperties` to your rendering options.

The standard default properties are available as `Style.foundation` and it's highly recommended you use them.

