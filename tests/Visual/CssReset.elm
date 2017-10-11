module Visual.CssReset exposing (..)

{-| This is a test of the css reset that is included with the library.

  - No node should have a default style
  - No non-style-attribute on any node should affect style

-}

import Element.Internal.Render as Render
import Html exposing (..)
import Html.Attributes exposing (..)


testNode attrs label name =
    node name (class "el" :: attrs) [ text label ]


specialNodes =
    [ "hr"
    , "br"
    , "img"
    , "iframe"
    , "canvas"
    , "input"
    , "textarea"
    , "progress"
    , "meter"
    , "audio"
    , "video"
    , "source"
    , "track"
    , "select"
    , "optgroup"
    , "details"
    ]


styledNodes =
    [ "em"
    , "strong"
    , "i"
    , "b"
    , "u"

    -- , "sub"
    -- , "sup"
    , "s"
    ]


nodes =
    [ "h1"
    , "h2"
    , "h3"
    , "h4"
    , "h5"
    , "h6"
    , "div"
    , "p"
    , "pre"
    , "blockquote"
    , "span"
    , "a"
    , "code"
    , "ol"
    , "ul"
    , "li"
    , "dl"
    , "dt"
    , "dd"
    , "math"
    , "form"
    , "button"
    , "option"
    , "section"
    , "nav"
    , "article"
    , "aside"
    , "header"
    , "footer"
    , "address"
    , "main_"
    , "body"
    , "figure"
    , "figcaption"
    , "table"
    , "caption"
    , "colgroup"
    , "col"
    , "tbody"
    , "thead"
    , "tfoot"
    , "tr"
    , "td"
    , "th"
    , "fieldset"
    , "legend"
    , "label"
    , "datalist"
    , "keygen"
    , "output"
    , "embed"
    , "object"
    , "param"
    , "ins"
    , "del"
    , "small"
    , "cite"
    , "dfn"
    , "abbr"
    , "time"
    , "var"
    , "samp"
    , "kbd"
    , "q"
    , "mark"
    , "ruby"
    , "rt"
    , "rp"
    , "bdi"
    , "bdo"
    , "wbr"
    , "summary"
    , "menuitem"
    , "menu"
    ]


custom =
    """
html {
    -ms-text-size-adjust: 100%; /* 2 */
    -webkit-text-size-adjust: 100%; /* 2 */
    margin: 0;
    padding: 0;
    border: 0;
}

/**
* Remove the margin in all browsers (opinionated).
*/
body {
    margin: 0;
}

/*  Root reset */
.style-elements {
    display: block;
    position: relative;
    margin: 0;
    padding: 0;
    border: 0;
    font-size: 100%;
    font: inherit;
    box-sizing: border-box;
    line-height: 1.2; /* :NOTE: ADDED BY style-elements LIBRARY.
                         1.2 was chosen because it's the smallest line-height
                         that does not chop off the tail of a 'g'
                      */
}

/* General style elements reset */
.el {
    display: block;
    position: relative;
    margin: 0;
    padding: 0;
    border: 0;
    border-style: solid;
    font-size: 100%;
    font: inherit;
    box-sizing: border-box;
}


/*  Nodes that still have style meaning in style-elements */
em.el, i.el {
    font-style: italic;
}
b.el, strong.el {
    font-weight: bolder;
}
strike.el {
    text-decoration: line-through;
}
u.el {
    text-decoration: underline;
}

a.el {
    text-decoration: none;
    color: inherit;
    cursor: pointer;
}

/**
* Prevent `sub` and `sup` elements from affecting the line height in
* all browsers.
*/
img.el {
    border-style: none;
}

sub.el,
sup.el {
    display:inline;
    font-size: 75%;
    line-height: 0;
    position: relative;
    vertical-align: baseline;
}

sub.el {
    bottom: -0.25em;
}

sup.el {
    top: -0.5em;
}


/* added */
caption.el {
    text-align:left;
}
th.el {
    text-align:left;
}

ins.el {
    text-decoration: none;
}
del.el {
    text-decoration: none;
}
mark.el {
    background-color: transparent;
    color: inherit;
}
q.el::before, q.el::after {
    content: none;
}
button.el {
    background-color: transparent;

}
rt.el {
    text-align: left;
}

"""


main =
    div [ class "style-elements" ]
        -- [ node "style" [] [ text Render.miniNormalize ]
        [ node "style" [] [ text custom ]
        , div [ style [ ( "font-size", "25px" ), ( "line-height", "1.8" ) ] ] [ text "All of these nodes should be unstyled" ]
        , div []
            (List.map (testNode [] "we are all the same") nodes)
        , div [ style [ ( "font-size", "25px" ), ( "line-height", "1.8" ) ] ] [ text "Styled on Purpose!" ]
        , div []
            (List.map (testNode [] "we are stylish") styledNodes)
        , div [ style [ ( "font-size", "25px" ), ( "line-height", "1.8" ) ] ] [ text "Nodes with Specific Attributes" ]
        , a [ class "el", href "http://fruits.com" ] [ text "here's a link!" ]
        , div [ class "el" ] [ text "Subscript: H", sub [ class "el" ] [ text "2" ], text "O" ]
        , div [ class "el" ] [ text "Superscript: X", sup [ class "el" ] [ text "2" ] ]
        , div [ style [ ( "font-size", "25px" ), ( "line-height", "1.8" ) ] ] [ text "Weird Stuff! (style-elements should give them a better interface)" ]
        , div []
            (List.map (testNode [] "We are weird") specialNodes)
        ]
