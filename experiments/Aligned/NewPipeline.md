# Rendering Pipeline Revision

## Current Pipeline

`layout`

    The initial call which transforms Element -> Html

`Internal.renderRoot`

    - convert options to a OptionRecord
    - `Internal.element`


`Internal.element embedMode LayoutType nodeType attributes children`

    |> foldr Internal.gatherAttributes
    |> finalize
    |> asElement embedMode


gatherAttributes

    *Check if an attribute has already been assigned, skip it*

    addAttribute
    addStyle
    change Node type
    gather nearbys

finalize

    Stack transforms
        -> renderTransformationGroup
    Stack filters
    Stack box shadows
    Stack text shadows


asElement : EmbedStyle -> Children (Element msg) -> LayoutContext -> Gathered msg -> Element msg

    foldr gather/gatherKeyed 
        -> get styles
        -> convert elements to html

    renderNode gathered renderedChilren -> Html


renderNode 

    wrap in "u" or "s" element for alignment when width is not 'fill'




## New Pipeline

  - Capture information in an integer using 


