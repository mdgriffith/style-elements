    This library is in beta

# Simplifying css for elm

It's easy to write _valid_ CSS that is still broken and frustrating.  What if we could just make frustrating CSS styles not expressible?

That's the aim of `style-elements` library. To give you the tools to write styles that are intuitive and robust, while still being productive and expressive.  To make styles that don't break.

And while we're at it, it wouldn't hurt to have built in support for `animations`, `transitions`, and `media queries` too.

Maybe styling can actually be _fun_ now.


#### Styling via pipes

```elm

import Style exposing (..)

title : Style.Simple
title =
    Style.foundation
        |> width (px 300)
        |> height auto
```

#### Easy layout

```elm

container : Style.Simple
container =
    Style.foundation
        |> flowLeft
            { wrap = True
            , horizontal = alignCenter
            , vertical = alignTop
            }
```


#### Animation

```elm
rotatingBox : Style.Simple
rotatingBox =
    Style.foundation
        |> width (px 50)
        |> height (px 50)
        |> animate
            { duration = (5 * second)
            , easing = "linear"
            , repeat = forever
            , steps =
                [ ( 0, transforms [ rotate 0 0 0 ] )
                , ( 100, transforms [ rotate 0 0 (2 * pi) ] )
                ]
            }
```

## Getting Started

 * [Getting Started/How it Works](https://github.com/mdgriffith/style-elements/blob/master/HowItWorks.md)
 * [Understanding Style - Designing the Style Elements Library](http://www.mechanical-elephant.com/articles/understanding-style-composition) - an article that goes in depth on how `style-elements` works.
 * [Documentation](http://package.elm-lang.org/packages/mdgriffith/style-elements/latest)
 * Simple example: [code](https://github.com/mdgriffith/elm-style-elements-simple-example) - [demo](https://mdgriffith.github.io/style-elements/simple/)
 * Realworld example that uses animations, media queries, and palettes: [code](https://github.com/mdgriffith/elm-style-elements-complex-example) - [demo](https://mdgriffith.github.io/style-elements/realworld/)



## Compared to elm-css

The goal of [elm-css](https://github.com/rtfeldman/elm-css/) library is to provide access all of CSS in a typesafe way (meaning you get a beautiful compiler error if you write something incorrectly).

It uses union types instead of strings to represent classes and ids.  This is inherently awesome and worth your consideration.


The `style-elements` library instead focuses on simplifying css, making it more robust and quicker to prototype in.

It does this by 
    * removing parts of css that cause the most trouble
    * setting smarter defaults
    * providing clean interfaces to the good parts like `media queries`, `flex-box` and `animations`.

It's meant to be a css preprocessor with css best practices built in.









