# The Style Elements Library for Elm

> This library is experimental.

It's easy to write impossible css, styles that invalidate themselves, or break due to an obscure quirk.

The style-elements library is an attempt to make the styling process more intuitive by only giving access to the good parts of css and limiting css's more mysterious behavior.  

Instead of relying on `classes` and `ids` to associate your style to the nodes in your view, the `style-elements` library focuses on creating collections of styled elements that you can pull from.  While this may seem bizarre, the benefit is that your views look cleaner and more meaningful and we still maintain our ability to express style variations like we would with classes.

For added polish, there is built-in support for css transitions and animations.

## Getting Started

Using this library generally falls into the following pattern.

 1. Establish a base style using the style-elements model.
 2. Create a collection of styled elements by binding variations of the base style to dom elements using the `Style.Elements.element` function.
 3. Build your view from that collection of styled elements

Here's [a simple example]().

Here's [a more complicated example with animations and patterns more common to real world applications]().
