module Element
    exposing
        ( stylesheet
        , stylesheetWith
        , StyleSheet
        , Element
        , Attribute
        , empty
        , text
        , bold
        , italic
        , strike
        , underline
        , sub
        , super
        , el
        , circle
        , spacer
        , image
        , hairline
        , node
        , header
        , section
        , nav
        , article
        , aside
        , canvas
        , iframe
        , audio
        , video
        , form
        , radio
        , checkbox
        , label
        , labelBelow
        , textarea
        , inputtext
        , bullet
        , enumerate
        , full
        , textLayout
        , paragraph
        , row
        , column
        , wrappedRow
        , wrappedColumn
        , grid
        , namedGrid
        , area
        , named
        , span
        , spanAll
        , linked
        , when
        , within
        , above
        , below
        , onRight
        , onLeft
        , screen
        , render
        , root
        , embed
        , Device
        , classifyDevice
        , responsive
        )

{-|


## Basic Elements

@docs Element, empty, text, el, circle, spacer, full


## Layout

@docs textLayout, paragraph, row, column, wrappedRow, wrappedColumn, bullet, enumerate, grid, namedGrid, area, named, span, spanAll


## Positioning

@docs within, above, below, onRight, onLeft, screen


## Responsive

@docs Device, classifyDevice, responsive


## Markup

@docs bold, italic, strike, underline, sub, super


## Semantic Markup

@docs node, header, section, nav, article, aside, canvas, iframe, audio, video


## Form Elements

@docs form, radio, checkbox, label, labelBelow, textarea, inputtext

@docs StyleSheet, stylesheet, stylesheetWith, render, root, embed

@docs image, hairline, linked


## Misc

@docs when

-}

import Html exposing (Html)
import Html.Attributes
import Element.Internal.Model as Internal exposing (..)
import Style exposing (Style)
import Style.Internal.Model as Style exposing (Length)
import Style.Internal.Render.Value as Value
import Style.Internal.Batchable as Batchable exposing (Batchable)
import Element.Attributes as Attr
import Element.Internal.Render as Render
import Style.Sheet
import Color exposing (Color)
import Window


{-| The stylesheet contains the rendered css as a string, and two functions to lookup
-}
type alias StyleSheet style variation animation msg =
    Style.StyleSheet style variation animation msg


{-| -}
type alias Element style variation msg =
    Internal.Element style variation msg


{-| -}
type alias Attribute variation msg =
    Internal.Attribute variation msg


type alias Defaults =
    Internal.Defaults


presetDefaults : Defaults
presetDefaults =
    { typeface = [ "calibri", "helvetica", "arial", "sans-serif" ]
    , fontSize = 16
    , lineHeight = 1.3
    , textColor = Color.black
    }


reset : String
reset =
    """
/* http://meyerweb.com/eric/tools/css/reset/
   v2.0 | 20110126
   License: none (public domain)
*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video, hr {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  font: inherit;
  vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
  display: block;
}
body {
  line-height: 1;
}
ol, ul {
  list-style: none;
}
blockquote, q {
  quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
  content: '';
  content: none;
}
table {
  border-collapse: collapse;
  border-spacing: 0;
}
/** Borrowed from Normalize.css **/

/**
 * Prevent `sub` and `sup` elements from affecting the line height in
 * all browsers.
 */

sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sub {
  bottom: -0.25em;
}

sup {
  top: -0.5em;
}

a {
    text-decoration: none;
}

"""


{-| -}
stylesheet : List (Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheet styles =
    let
        defaults =
            Batchable.One
                (Style.RawStyle "style-elements-root"
                    [ ( "font-family", Value.typeface presetDefaults.typeface )
                    , ( "color", Value.color presetDefaults.textColor )
                    , ( "line-height", toString presetDefaults.lineHeight )
                    , ( "font-size", toString presetDefaults.fontSize ++ "px" )
                    ]
                )

        stylesheet =
            Style.Sheet.render
                (defaults :: styles)
    in
        { stylesheet | css = reset ++ stylesheet.css }


{-| -}
stylesheetWith : Defaults -> List (Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheetWith defaultProps styles =
    let
        defaults =
            Batchable.One
                (Style.RawStyle "style-elements-root"
                    [ ( "font-family", Value.typeface defaultProps.typeface )
                    , ( "color", Value.color defaultProps.textColor )
                    , ( "line-height", toString defaultProps.lineHeight )
                    , ( "font-size", toString defaultProps.fontSize ++ "px" )
                    ]
                )

        stylesheet =
            Style.Sheet.render
                (defaults :: styles)
    in
        { stylesheet | css = reset ++ stylesheet.css }


{-| -}
empty : Element style variation msg
empty =
    Empty


{-| -}
text : String -> Element style variation msg
text =
    Text NoDecoration


{-| -}
bold : String -> Element style variation msg
bold =
    Text Bold


{-| -}
italic : String -> Element style variation msg
italic =
    Text Italic


{-| -}
strike : String -> Element style variation msg
strike =
    Text Strike


{-| -}
underline : String -> Element style variation msg
underline =
    Text Underline


{-| -}
sub : String -> Element style variation msg
sub =
    Text Sub


{-| -}
super : String -> Element style variation msg
super =
    Text Super


{-| -}
el : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
el elem attrs child =
    Element Html.div (Just elem) attrs child Nothing


{-| -}
circle : Float -> style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
circle radius elem attrs child =
    Element Html.div
        (Just elem)
        (Attr
            (Html.Attributes.style
                [ ( "border-radius", toString radius ++ "px" ) ]
            )
            :: Width (Style.Px (2 * radius))
            :: Height (Style.Px (2 * radius))
            :: attrs
        )
        child
        Nothing


{-| Define a spacer in terms of a multiple of it's spacing.

So, if the parent element is a `column` that set spacing to `5`, and this spacer was a `2`. Then it would be a 10 pixel spacer.

-}
spacer : Float -> Element style variation msg
spacer =
    Spacer


{-| -}
image : style -> String -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
image elem src attrs child =
    Element Html.img (Just elem) (Attr (Html.Attributes.src src) :: attrs) child Nothing


{-| Creates a hairline horizontal. The Color is set in the defaults of the stylesheet.

If you want a horizontal rule that is something more specific, craft it with `el`!

-}
hairline : style -> Element style variation msg
hairline elem =
    Element Html.hr
        (Just elem)
        [ Height (Style.Px 1) ]
        empty
        Nothing



---------------------
--- Semantic Markup
---------------------


{-| -}
node : String -> (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
node str constructor elem attrs stuff =
    setNode (Html.node str) (constructor elem attrs stuff)


{-| -}
header : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
header constructor elem attrs stuff =
    setNode Html.header (constructor elem attrs stuff)


{-| -}
section : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
section constructor elem attrs stuff =
    setNode Html.section (constructor elem attrs stuff)


{-| -}
nav : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
nav constructor elem attrs stuff =
    setNode Html.nav (constructor elem attrs stuff)


{-| -}
article : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
article constructor elem attrs stuff =
    setNode Html.article (constructor elem attrs stuff)


{-| -}
aside : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
aside constructor elem attrs stuff =
    setNode Html.aside (constructor elem attrs stuff)



---------------------
--- Specialized Elements
---------------------


{-| -}
canvas : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
canvas constructor elem attrs stuff =
    setNode Html.canvas (constructor elem attrs stuff)


{-| -}
iframe : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
iframe constructor elem attrs stuff =
    setNode Html.iframe (constructor elem attrs stuff)


{-| -}
audio : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
audio constructor elem attrs stuff =
    setNode Html.audio (constructor elem attrs stuff)


{-| -}
video : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
video constructor elem attrs stuff =
    setNode Html.audio (constructor elem attrs stuff)



---------------------
--- Form and Input
---------------------


{-| -}
form : (style -> List (Attribute variation msg) -> stuff -> Element style variation msg) -> style -> List (Attribute variation msg) -> stuff -> Element style variation msg
form constructor elem attrs stuff =
    setNode Html.form (constructor elem attrs stuff)


{-| Create a labeled radio button.

So, if you wanted to make some radio buttons to choose lunch, here's how it's look:

    radio StyleClass [] "lunch" "burrito" True (text "A Burrito!")
    radio StyleClass [] "lunch" "taco" False (text "Some Tacos!")

**Advanced Note**
This creates the following html:

    <label class="styleClass" {attributes provided in arguments}>
        <input type=radio name="lunch" value="burrito" />
        A Burrito!
    </label>

Events are attached to the radio input element (to capture things like `onInput`, while all other attributes apply to the parent label element).

-}
radio : style -> List (Attribute variation msg) -> String -> String -> Bool -> Element style variation msg -> Element style variation msg
radio elem attrs group value on label =
    let
        ( events, other ) =
            List.partition forInputEvents attrs

        forInputEvents attr =
            case attr of
                InputEvent ev ->
                    True

                _ ->
                    False
    in
        Element Html.label
            (Just elem)
            other
            (inlineChildren Html.div
                Nothing
                []
                [ Element Html.input
                    (Just elem)
                    (Attr.type_ "radio"
                        :: Attr.name group
                        :: Attr.value value
                        :: Attr.checked on
                        :: events
                    )
                    empty
                    Nothing
                , label
                ]
            )
            Nothing


{-| An automatically labeled checkbox.
-}
checkbox : style -> List (Attribute variation msg) -> Bool -> Element style variation msg -> Element style variation msg
checkbox elem attrs on label =
    let
        ( events, other ) =
            List.partition forInputEvents attrs

        forInputEvents attr =
            case attr of
                InputEvent ev ->
                    True

                _ ->
                    False
    in
        Element Html.label
            (Just elem)
            other
            (inlineChildren Html.div
                Nothing
                []
                [ Element
                    Html.input
                    Nothing
                    (Attr.type_ "checkbox"
                        :: Attr.checked on
                        :: events
                    )
                    empty
                    Nothing
                , label
                ]
            )
            Nothing


{-| For input elements that are not automatically labeled (checkbox, radiobutton, selection), this will attach a label above the element.

label Label [] (text "check this out") <|
inputtext Style [] "The Value!"

-}
label : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg -> Element style variation msg
label elem attrs label input =
    let
        -- If naked text is provided, then flexbox won't work.
        -- In that case we wrap it in a div.
        containedLabel =
            case label of
                Text dec content ->
                    Element Html.div Nothing [] (Text dec content) Nothing

                l ->
                    l
    in
        (node "label" column)
            elem
            attrs
            [ label
            , input
            ]


{-| Same as `label`, but places the label below the input field.
-}
labelBelow : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg -> Element style variation msg
labelBelow elem attrs label input =
    let
        -- If naked text is provided, then flexbox won't work.
        -- In that case we wrap it in a div.
        containedLabel =
            case label of
                Text dec content ->
                    Element Html.div Nothing [] (Text dec content) Nothing

                l ->
                    l
    in
        (node "label" column)
            elem
            attrs
            [ input
            , label
            ]


{-| -}
textarea : style -> List (Attribute variation msg) -> String -> Element style variation msg
textarea elem attrs content =
    Element Html.textarea (Just elem) attrs (text content) Nothing


{-| labeled Label [] (text "check this out") <|
inputtext Style [] "The Value!"
-}
inputtext : style -> List (Attribute variation msg) -> String -> Element style variation msg
inputtext elem attrs content =
    Element Html.input (Just elem) (Attr.type_ "text" :: Attr.value content :: attrs) empty Nothing


{-| A bulleted list. Rendered as `<ul>`

A 'column' layout is implied.

Automatically sets children to use `<li>`

-}
bullet : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
bullet elem attrs children =
    Layout Html.ul (Style.FlexLayout Style.Down []) (Just elem) attrs (List.map (setNode Html.li) children)


{-| A numbered list. Rendered as `<ol>` with an implied 'column' layout.

Automatically sets children to use `<li>`

-}
enumerate : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
enumerate elem attrs children =
    Layout Html.ol (Style.FlexLayout Style.Down []) (Just elem) attrs (List.map (setNode Html.li) children)


{-| A 'full' element will ignore the spacing set for it by the parent, and also grow to cover the parent's padding.

This is mostly useful in text layouts.

-}
full : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
full elem attrs child =
    Element Html.div (Just elem) (Expand :: attrs) child Nothing


{-| -}
textLayout : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
textLayout elem attrs children =
    Layout Html.div (Style.TextLayout) (Just elem) attrs children


{-| Paragraph is actually a layout if you can believe it!

All of the children are set to 'inline'.

-}
paragraph : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
paragraph elem attrs children =
    inlineChildren Html.p (Just elem) attrs children


{-| -}
inlineChildren :
    HtmlFn msg
    -> Maybe style
    -> List (Attribute variation msg)
    -> List (Element style variation msg)
    -> Element style variation msg
inlineChildren node elem attrs children =
    let
        ( child, others ) =
            case children of
                [] ->
                    ( empty, Nothing )

                child :: others ->
                    ( addPropToNonText Inline child, Just <| List.map (addPropToNonText Inline) others )
    in
        Element node elem attrs child others


{-| -}
row : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
row elem attrs children =
    Layout Html.div (Style.FlexLayout Style.GoRight []) (Just elem) attrs children


{-| -}
column : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
column elem attrs children =
    Layout Html.div (Style.FlexLayout Style.Down []) (Just elem) attrs children


{-| -}
wrappedRow : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
wrappedRow elem attrs children =
    Layout Html.div (Style.FlexLayout Style.GoRight [ Style.Wrap True ]) (Just elem) attrs children


{-| -}
wrappedColumn : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
wrappedColumn elem attrs children =
    Layout Html.div (Style.FlexLayout Style.Down [ Style.Wrap True ]) (Just elem) attrs children


{-| -}
type alias Grid =
    { rows : List Length
    , columns : List Length
    }


{-| -}
grid : style -> Grid -> List (Attribute variation msg) -> List (OnGrid (Element style variation msg)) -> Element style variation msg
grid elem template attrs children =
    let
        prepare el =
            List.map (\(OnGrid x) -> x) el
    in
        Layout Html.div (Style.Grid (Style.GridTemplate template) []) (Just elem) attrs (prepare children)


{-| -}
type alias NamedGrid =
    { rows : List ( Length, List Style.NamedGridPosition )
    , columns : List Length
    }


{-| -}
namedGrid : style -> NamedGrid -> List (Attribute variation msg) -> List (NamedOnGrid (Element style variation msg)) -> Element style variation msg
namedGrid elem template attrs children =
    let
        prepare el =
            List.map (\(NamedOnGrid x) -> x) el
    in
        Layout Html.div (Style.Grid (Style.NamedGridTemplate template) []) (Just elem) attrs (prepare children)


{-| -}
type alias GridPosition =
    { start : ( Int, Int )
    , width : Int
    , height : Int
    }


{-| -}
type OnGrid thing
    = OnGrid thing


{-| -}
type NamedOnGrid thing
    = NamedOnGrid thing


{-| -}
area : GridPosition -> Element style variation msg -> OnGrid (Element style variation msg)
area box el =
    OnGrid <| addProp (GridCoords <| Style.GridPosition box) el


{-| -}
named : String -> Element style variation msg -> NamedOnGrid (Element style variation msg)
named name el =
    NamedOnGrid <| addProp (GridArea name) el


type alias NamedGridPosition =
    Style.NamedGridPosition


{-| -}
span : Int -> String -> NamedGridPosition
span i name =
    Style.Named (Style.SpanJust i) (Just name)


{-| -}
spanAll : String -> NamedGridPosition
spanAll name =
    Style.Named Style.SpanAll (Just name)


{-| Turn an element into a link.

Changes an element's node to `<a>` and sets the href and rel properties.

-}
linked : String -> Element style variation msg -> Element style variation msg
linked src el =
    el
        |> setNode Html.a
        |> addProp (Attr (Html.Attributes.href src))
        |> addProp (Attr (Html.Attributes.rel "noopener noreferrer"))


{-|

    when (x == 5) (text "yay, it's 5")

is sugar for

    if (x == 5) then
        text "yay, it's 5"
    else
        empty

-}
when : Bool -> Element style variation msg -> Element style variation msg
when bool elm =
    if bool then
        elm
    else
        empty


setNode : HtmlFn msg -> Element style variation msg -> Element style variation msg
setNode node el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout _ layout elem attrs children ->
            Layout node layout elem attrs children

        Element _ elem attrs child otherChildren ->
            Element node elem attrs child otherChildren

        Text dec content ->
            Element node Nothing [] (Text dec content) Nothing


addPropToNonText : Attribute variation msg -> Element style variation msg -> Element style variation msg
addPropToNonText prop el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Text dec content


addProp : Attribute variation msg -> Element style variation msg -> Element style variation msg
addProp prop el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Element Html.div Nothing [ prop ] (Text dec content) Nothing


removeProps : List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
removeProps props el =
    let
        match p =
            not <| List.member p props
    in
        case el of
            Empty ->
                Empty

            Spacer x ->
                Spacer x

            Layout node layout elem attrs els ->
                Layout node layout elem (List.filter match attrs) els

            Element node elem attrs el children ->
                Element node elem (List.filter match attrs) el children

            Text dec content ->
                Text dec content


addChild : Element style variation msg -> Element style variation msg -> Element style variation msg
addChild parent el =
    case parent of
        Empty ->
            Element Html.div Nothing [] Empty (Just [ el ])

        Spacer x ->
            Spacer x

        Layout node layout elem attrs children ->
            Layout node layout elem attrs (el :: children)

        Element node elem attrs child otherChildren ->
            case otherChildren of
                Nothing ->
                    Element node elem attrs child (Just [ el ])

                Just others ->
                    Element node elem attrs child (Just (el :: others))

        Text dec content ->
            Element Html.div Nothing [] (Text dec content) (Just [ el ])


{-| -}
within : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
within nearbys parent =
    let
        position el p =
            el
                |> addProp (PositionFrame Positioned)
                |> addChild p
    in
        List.foldl position parent nearbys


{-| -}
above : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
above nearbys parent =
    let
        position el p =
            el
                |> addProp (PositionFrame (Nearby Above))
                |> removeProps [ VAlign Top, VAlign Bottom ]
                |> addChild p
    in
        List.foldl position parent nearbys


{-| -}
below : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
below nearbys parent =
    let
        position el p =
            el
                |> addProp (PositionFrame (Nearby Below))
                |> removeProps [ VAlign Top, VAlign Bottom ]
                |> addChild p
    in
        List.foldl position parent nearbys


{-| -}
onRight : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
onRight nearbys parent =
    let
        position el p =
            el
                |> addProp (PositionFrame (Nearby OnRight))
                |> removeProps [ HAlign Right, HAlign Left ]
                |> addChild p
    in
        List.foldl position parent nearbys


{-| -}
onLeft : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
onLeft nearbys parent =
    let
        position el p =
            el
                |> addProp (PositionFrame (Nearby OnLeft))
                |> removeProps [ HAlign Right, HAlign Left ]
                |> addChild p
    in
        List.foldl position parent nearbys


{-| Position an element relative to the window.

Essentially the same as 'display: fixed'

-}
screen : Element style variation msg -> Element style variation msg
screen =
    addProp (PositionFrame Screen)


{-| Renders `Element`'s into `Html`.
-}
render :
    Style.StyleSheet style variation animation msg
    -> Element style variation msg
    -> Html msg
render =
    Render.render


{-| Embeds the stylesheet and renders the `Element`'s into `Html`.
-}
root :
    Style.StyleSheet style variation animation msg
    -> Element style variation msg
    -> Html msg
root =
    Render.root


{-| Embed a stylesheet.
-}
embed :
    Style.StyleSheet style variation animation msg
    -> Html msg
embed =
    Render.embed


{-| -}
type alias Device =
    { width : Int
    , height : Int
    , phone : Bool
    , tablet : Bool
    , desktop : Bool
    , bigDesktop : Bool
    , portrait : Bool
    }


{-| Takes in a Window.Size and returns a device profile which can be used for responsiveness.
-}
classifyDevice : Window.Size -> Device
classifyDevice { width, height } =
    { width = width
    , height = height
    , phone = width <= 600
    , tablet = width > 600 && width <= 1200
    , desktop = width > 1200 && width <= 1800
    , bigDesktop = width > 1800
    , portrait = width > height
    }


{-| Define two ranges that should linearly match up with each other.

Provide a value for the first and receive the calculated value for the second.

    fontsize =
        responsive ( 600, 1200 ) ( 16, 20 ) device.width

Will set the font-size between 16 and 20 when the device width is between 600 and 1200, using a linear scale.

-}
responsive : ( Float, Float ) -> ( Float, Float ) -> Float -> Float
responsive ( aMin, aMax ) ( bMin, bMax ) a =
    if a <= aMin then
        bMin
    else if a >= aMax then
        bMax
    else
        let
            deltaA =
                (a - aMin) / (aMax - aMin)
        in
            (deltaA * (bMax - bMin)) + bMin
