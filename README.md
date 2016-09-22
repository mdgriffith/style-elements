# Style Blocks




# Potential Features
 * Prepare custom elements
 * Keep track of all composit models
 *






## Criticism Points


In the current system of using css or a less processor and html:

There are multiple places you can compose styles.
  * In the html itself by specifying multiple styles
  * In the CSS using mixins if you're using LESS
  * Accidentally, using inherited styles

When there are multiple places for composition, this means that one will usually use some degree of all of them.  Or, use one if you're more principled.  The issue is that everyone will have different principles.



Lets limit the places you can compose styles.



# Common tasks that need to be expressed

  [x] - Expressing Variations
        - Slightly varying styles that vary depending on each other
        - In your view, define which variation is being shown.
            - Change depending on model
        
  [ ] - Media Queries?
        - Must be rendered as a style sheet.

  [x] - Convert to elm-style-animation

  [ ] - Expressing Hover Styles



When using flexbox, the parent detirmines the layout of the children.  It probably makes sense to have it specify "spacing" of children as well.  However this requires setting fields on both the parent and the children to get the spacing to look decent.