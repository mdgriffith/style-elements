# Style Rendering Benchmark

I put this together to get a sense of the most performant strategies for rendering dynamically styled elements.


There are a few different strategies:

* **Inline styles** - styles are calcualted and rendered inline
* **Concrete stylesheet** - styles are calculated at the element level and bubbled up into a `<style>` tag.
* **CssAnimation** - Html is static, each element is attached to the same css animation declaration, which was created statically.  This was to see a baseline.
* **VirtualCss** - Styles are calculated at the element level and virutally inserted into the stylesheet via `insertRule`.  
* **VirtualCssAndAnimation** - Transform properties are handled by a css animation, while all other properties are rendered via `insertRule`


Buttons to push:

* **Node count** - I generally turn this up to where things are moving, but obviously jittery for inline styles(for me that's 1k nodes)  Then I start playing around.
* **Lazy** - Render the html elements lazily.
* **Reducer** - For the *Concrete* stylesheet, the styles can either be reduced by storing them in a dict keyed by the class name, or we can just pass a big list of styles to the style tag.
* **Naming** - Either murmur3 hash of the style properties for the class name, or the DOM index.

**Note on VirtualCss**
  - The version in this test is a **very minimal** version.  It blows away the virtual stylesheet on every frame and recreates it.  It's the Schwarzenegger of virtualCSSes


# General Observations after Playtime
_YMMV of course:)_

Generally I go up to 1k nodes, and start changing stuff.

Also, the built in FPS meter, and the one that is provided by the browser doesn't seem to be accurate in all cases.  
Specifically in cases involving the GPU, where it's obvious there is silky smooth performance and the FPS meter reports something like 15 fps.

*Chrome*

 * **Concrete Styleshet** - 
    * Hashed class names are much faster than DomIndex.  
    * Reducing style definitions before adding to a style node doesn't seem to matter.
    * Lazy only applies to the **DomIndex** strategy, which seems to be bogged down enough rendering-wise for lazy not to matter.

 * **CssAnimation** -
    * Adding color to the css animation seems to significnatly slow it down.
    * Transforms are performant, as expected

 * **VirtualCss** -
    * More performant than inline!
    * It even looks to be more performant than css animations(wuuut?).
    * Hash Class names are much slower than DomIndex
    * Lazy doesn't seem to have an effect 
        - but it should be noted that this strategy would allow Lazy Html to be evaluated **separately** from lazy css.
        - Not sure how to test this beyond what I'm doing though.

    * **Weirdness!** -
        - Render 1k nodes inline (should be relatively slow)
        - Switch to VirtualCss (should be fast)
        - Switch **back** to inline....*and it has magically gotten fast*.  There's gotta be some secret gpu promotion somewhere.

  * **VirtualCss with CSS Animations** - Slower than pure virutalcss


*Safari*

* **Concrete Stylesheet**
  - No discenarble difference between hash and DomIndex
  - Roughly similar to inline styles

* **CssAnimations**
  - Silky smooth, color and everything

* **VirtualCss**
  - Noticable improvement over inline styles, initially.
  - Still has **Weirdness** with going back to inline styles.
  - Not as smooth as CssAnimations.
  - Hashed classes slow things down.

* **VirtualCssWith CSS Animation**
  - Silky smooth, Similar to pure CSSanimations

   
*Firefox*

* Similar in most(all?) ways to safari.


## Conclusions

This benchmark was more of a "how do things feel" type of thing than raw numbers, because the FPS reporting seems to be wacky.

## Chrome

**Pure virtualCSS with DomIndex class names** seems to be the winning strategy.   Css animations make things slow! 

I know there can be some class reshuffling if the first element in a long list is deleted, however I think with CSS, the _diffing/reload_ cost is much lower than in DOM-land.

This benchmark was compeletely rebuilding the virtual stylesheet and rerendering, and it was still faster than inline styles and css animations.

Also, it's unlikely that there would be class reshuffling on every frame.  Much more likely it would happen once and then an animation would proceed.


## Safari, Firefox

**The opposite of what I just said**

_Compiling to CSS animations, at least for transforms, seems to be the way to go.  VirtualCSS can be used for all other properties._

