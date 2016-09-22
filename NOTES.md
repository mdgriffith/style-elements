# Invalid CSS States and Conundrums

First off, disclaimer: this is an experiment :)  I present some of these ideas in an opinionated way, but I realize there may be a lot of cases I'm not accounting for and probably a good number.  Also who knows if this approach ultimately makes sense! Huray experimentation!


I believe there are a few reasons that css is irritating.

   1. *Able to write invalid styles* - There are a lot of invalid styles you can write.  Some properties will break other properties.
   2. *Secret Defaults* 
   3. *Most everything is obtusely named* :/
   4. *Multiple ways to accomplish a goal*  Do you want `position:relative;margin:0 auto;` or `position:absolute;margin-left:50%;width:500px;left:-250px;`?
   5. *Inheretance* means that where the element is in the DOM can modify what it looks like.  This means elements cannot move around the DOM and maintain their style.  
        - I like to think of it in similar terms to the idea of functional purity.  You call a function with the same arguments it always returns the same thing, right?  I believe the same should be the case for styling.  You styled an element...it shouldn't be restyled based on where it is in your DOM, or in what order you declared your rules in your css, only by what you've declared that it is.  I'm going to refer to this idea as *style mobility*.  
        - There are times where the parent being able to specify a tiny bit of what the child should do is really useful, but having it as a general rule I believe is harmful.

So, lets dig in, shall we?


## Position

`left`, `top`, `right`, and `bottom` - You can easily create invalid state by stating conflicting positions like `top` 0px, `bottom` 0px.  Also the naming is funky.  Left means "from the left" not "go left".

We actually have two things being expressed here.  The anchor point to start from, and where to go relative to that anchor point.

All of these properties are ignored if you have `position: static`.  (`position:static` also causes `z-index` to be ignored.)  The only argument for keeping `position: static` taht I can find is that it causes children elements with `position:absolute` to skip it and look one parent higher to base their position.  I'm not sure why you wouldnt just move the element to the correct level in that case though.

There are also a few other ways to specify position.  `translate` and the `x` and `y` properties for some svg elements. 

`translate` allows you to position stuff without having `position:relative`.  It doesn't affect the child element `position:absolute` skipping thing mentioned earlier.  It also doesn't hav a concept of an "anchor point".  `translate` is also gpu accelerated making it nice for animations.

`x` and `y` properties for svg elements are just left over from the svg spec.  There is no "flow layout" in svg, so its just absolute coords.


> Approach to a Solution
> -------------------------
> 
> We break this into two properties.  An anchor point, and a position given by x and y coords from that anchorpoint.  positive x coords means towards the right, negative to the left.  positive y coords means up, negative means down.  Position units can be given as either px or percent.  
> ```elm
> anchor = bottomLeft
> position = (px 20, px 80) 
> ```
>
> We rename `position:relative`, `position:absolute`, and `position:fixed` because if you think of these words, they're essentially meaninigless.  Relative to what?  Absolute, you mean positioned absolutely on the screen?  No, that's position: fixed.  Well, darn tootin.
>
>  Instead we have the following
> `position: absolute` -> `relativeTo: parent` 
> `position: relative` -> `relativeTo: flowPosition`
> `position: fixed` ->    `relativeTo: screen`
>
> `position: static` is removed from possible values.
> `relativeTo: flowPosition` is the default.  
>
> I'm not 100% sold on the `flowPosition` name, so suggestions are welcome!




## Specifying Size

If you have a `display: inline` property set, then `width` and `height` are ignored.  `display: inline` is generally used for things in text.  I'd actaully like to know if its equivalent to `display: inline-block; width: 0; height:0;`.

It's possible `display:inline` can be eliminated completely.  Let's move on without addressing this directly yet.



## Layout

`padding` and `margin` are interesting when you have a parent and a child element.  You now have two ways of specifying the spacing of the child element within the parent.  Either the `margin` on the child or the `padding` on the parent.  This causes anxiety in the developer.


> Approach to a Solution
> -----------------------
> 
> We're going to do a crazy thing and only allow `padding` to be set manually.


And we're going to move on and see if this works.


`flexbox` is an incredibly useful property.  We can specify if we want to orient the children horizontally in rows or vertically in columns.  I believe the default should be to wrap these elements as well (the general browser default is to not wrap).

With flexbox we run into an initial problem concerning `padding/margin`.  If we can only specify padding, then the spaces between the children is always 0, which is generally not what we want.  

The "best" way in normal css to get the spacing right is to set the margin on each child, and adjust the padding on the parent so that the math works out and you have even spacing.  So, to get exactly 10px of spacing.

```
.parent {
    display: flex;
    flex-direction: row;
    padding: 5px;
}

.child {
    margin: 5px;
}

```

Also, `flexbox` is really a marketing term, not a descriptive term.  What does it have to do with boxes or flex?  It has to do with the layout for children elements.  This sorta infects all the `flex` properties.


> Approach to a Solution
> -----------------------
> 
> the flex properties are captured in a new `Layout` record, which looks like the following:
>
>      ```
>      layout = 
>           { go = Right
>           , wrap = True
>           , spacing = 10
>           , align = center
>           }
>      ```
>
>  This may be insanity, but we're only going to only allow margin to be set by the parent.  And we're going to call it "spacing" on the parent's `layout` attribute.  This means we have to have a mechanism of specifying styles in children...but lets hold off on that for the moment.



## Organizing Properties

Here's a question I've been thinking about: "what other properties does a property care about?".  As in, when you modify a property, what other properties do you need to know in order to make a good design decision.

I want to organize properties by "what other properties they care about".  These are groups of properties/values that model a certain aspect of the style, and could be passed around as a coherent group.  We're going to call each of these a `style block`


### Color

So, for example lets start with color.  Background color, text color, text-decoration color, and border color all care about each other because you get real world errors if they don't jive.  The contrast between text and background doesn't work, or the border color doesnt match a palette with the other properties.

Fascinatingly `border-color` does not care _at all_ about other border properties, even though that is 90% who it's going to live next to in your css.

There may be one exception and that is shadow color....maybe. This is due to the fact that you can have a list of shadows.  So, storing shadow color separately from the other shadow properties is kinda difficult because you'd have to figure out how to match up which color applies to which shadow.


__Color Model__

```elm
colors =
    { background = blue
    , text = white
    , textDecoration = white
    , border = blue
    }
```


### Borders

I think the only property that might be organized separately from the other border properties is `border-radius`. I usually have `border: 1px solid green` in one place and `border-radius: 5px` somewhere else.

__Border Model__

```elm
border =
    { style = Solid
    , width = all (px 3)
    , rounding = all (px 5)
    }
```

### Text

Font sizes are always given as px values.  If you want relative values, you can use a function to calculate the new pixel value.

We don't want font sizes spcified in relative units because we want to maintain `style mobility`.

The main thing for font is name corrections for oddly named css properties.  No more `font-weight` to set boldness or `font-style: italic` to set italics.



__Text Model__

```elm
text =
    { font = "Comic Sans"
    , size = px 25
    , lineHeight = px 35
    , italic = False
    , boldness = Nothing
    , align = left
    , decoration = Just (Wavy Underline)
    }

```


# Where do we end up?

So, to achieve `style mobility`, we need to be have a set of properties that are mandatory for each style so that no inheritance occurs(r rather it only occurs when we specify it manually).  We also have some properties that are optional.


Here's what a full style would look like.

```elm

default : Style
default =
    { layout = 
           { go = Right
           , wrap = True
           , spacing = 10
           , align = center
           }
    , visibility = Transparent 0
    , position = 
            { relativeTo = FlowPosition
            , anchor = topLeft
            , position = (px 0, px 0)
            }
    , size = 
            { width = auto
            , height = 100
            }
    , colors = 
            { background = Color.white
            , text = Color.black
            , border = Color.grey
            , textDecoration = Color.black
            }
    , padding = all (px 15)
    , text = 
            { font = "georgia"
            , size = 16
            , lineHeight = 16
            , italics = False
            , boldness = Nothing
            , align = AlignLeft
            , decoration = Nothing
            }
    , border = 
            { style = Solid
            , width = all (px 0)
            , rounding = all (px 5)
            }
    , textShadow = []
    , shadow = []
    , insetShadow = []
    , transforms = []
    }


```

So, that's kinda big...It would suck to have to write that entire thing for every style.

Except we don't have to specify everything all at once for each style.  Take a look at your site through the lens of these `style block`s.  You might see that there are only so many `color blocks` or `layout blocks` or `text blocks`.  Interestingly you may only have 3-4 color blocks, 2-3 layout blocks, and 2-3 text blocks.  Our styles are just interesting combinations of those blocks.

We can simplify this a great deal by crafting one default style and modifying things based on that.  Essentially we're creating an explicit inheritance model.


```elm 
-- Including the default style from the above snippet

selectionColors : Colors
selectionColors =
    { background = Color.darkGrey
    , text = Color.white
    , border = Color.black
    , textDecoration = Color.red
    }

largeBorders : Border
largeBorders =
        { style = Solid
        , width = all (px 5)
        , rounding = all (px 5)
        }

newStyle : Style
newStyle = 
    { default 
        | color = selectionColors
        , border = largeBorders
    }

```


So what do we have.  We have these blocks which are incredibly portable and easy to compose together into a style.  We have mobile styles which will be true no matter where an element lives in the DOM.  Awesome.

Except we need to go even farther.

# Going Even Farther

We're going to bind the html node type and the style.

Wait, what?

Yeah, bear with me.  Ok so we have a limited number of html elements at our disposal, leading us to use a lot of `div` tags.  However it can be really useful to define our own tag types so that our view is more semantically constructed.

So, this library provides a function called `Style.element` which takes an html node, our recently created style model, a list of attributes and a list of children html nodes.

Here's an example of us creating a nav node that has a horizontal layout for its children.

```elm
nav : Style.Element msg
nav =
    Style.element
        Html.nav
        { default
            | layout = Style.horizontal
        }
```

When we use this, it looks exactly like normal.  Except in this case the `a` children elements also need to be `Style.Element`s.

```elm
nav []
    [ a [] [ text "home" ]
    , a [] [ text "about" ]
    , a [] [ text "articles" ]
    ]
```

So, our styling file turns into a library that we use to create our composable elements that we want to use on our site.  This makes our views super clean.  


Also, I mentioned earlier that we need a way to send style modifications to children in order to make out flex layout idea work easily.  By creating our own nodes, there's a way to propagate values to the child in the background.  I realize this is sorta bizarre, I'm open to different approaches.
























