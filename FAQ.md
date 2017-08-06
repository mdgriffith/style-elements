# Frequently Asked Questions

## How do I use `z-index`?

The z-index property isn't currently supported. We're trying to figure out the best API for layered elements, and you can help! Please submit your use cases to [issue #46](https://github.com/mdgriffith/style-elements/issues/46) so we can find the best solution for everyone.

While you're waiting, you can use the [`Style.prop` function](http://package.elm-lang.org/packages/mdgriffith/style-elements/latest/Style#prop) to get what you need:

```elm
zIndex : Int -> Property class variation
zIndex n =
    prop "z-index" (toString n)
```

## How do I set margins?

Supporting both margins and padding make consistent layouts difficult, so style-elements only uses padding.

If you need spacing between children in a layout, use [`Element.Attributes.spacing`](http://package.elm-lang.org/packages/mdgriffith/style-elements/latest/Element-Attributes#spacing).

To set more space around a single element, wrap the element in a spacer a set padding. This is more explicit and you can predict exactly how your element will be laid out.

## How do I use `em` instead of `px` for padding?

Style-elements doesn't support `em`s. They give inconsistent results depending on where in the tree they live.

Check out the functions in [`Style.Scale`](http://package.elm-lang.org/packages/mdgriffith/style-elements/latest/Style-Scale) to get something similar to `em`, but calculated in Elm.
