module Element
    exposing
        ( Element
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
        , button
        , iframe
        , audio
        , video
        , form
        , radio
        , checkbox
        , label
        , labelBelow
        , textArea
        , inputText
        , full
        , textLayout
        , paragraph
        , row
        , column
        , wrappedRow
        , wrappedColumn
        , grid
        , table
        , namedGrid
        , area
        , named
        , span
        , spanAll
        , link
        , when
        , whenJust
        , within
        , above
        , below
        , onRight
        , onLeft
        , screen
        , render
        , root
        , embed
        , layout
        , viewport
        , toHtml
        , embedStylesheet
        , Device
        , classifyDevice
        , responsive
        , OnGrid
        , NamedOnGrid
        , Grid
        , NamedGrid
        , select
        , option
        , Option
        , html
        , break
        , map
        )

{-|


# Capture Layout in your View

Think of `Elements` as `Html` with layout!

By building your view with `Elements`, you have a single place to go to adjust or add to your layout, which is great because that's usually what you're doing in your view!


## Rendering

@docs layout, viewport


## Basic Elements

@docs Element, Attribute

@docs empty, text, el, html, map, when, whenJust


# Layout

A layout element will explicitly define how it's children are layed out.

Make sure to check out the Style Element specific attributes in `Element.Attributes` as they will help out when doing layout!


## Linear Layouts

@docs row, column, wrappedRow, wrappedColumn


## Text Layout

@docs textLayout, paragraph


## Grid Layout

@docs table, Grid, NamedGrid, grid, namedGrid, OnGrid, NamedOnGrid, area, named, span, spanAll


## Convenience Elements

@docs full, spacer, hairline, link, image, circle, break


## Positioning

It can be useful to position something near another element.

In CSS terms, this positions children using 'position:absolute'. So, to position three boxes below a container, we could do the following:

     el MyStyle [ width (px 200), height (px 200) ] empty
        |> below
            [ el Box [ width (px 40), height (px 40) ] empty
            -- below on the right
            , el Box [ alignRight, width (px 40), height (px 40) ] empty
            -- below and centered
            , el Box [ center, width (px 40), height (px 40) ] empty
            ]

@docs below, above, onRight, onLeft, within, screen


## Responsive

Since this library moves all layout and positioning logic to the view instead of the stylesheet, it doesn't make a ton of sense to support media queries in the stylesheet.

Instead, responsiveness is controlled directly in the view.

Here's how it's done:

1.  Set up a subscription to `Window.resizes` from the `Window` package.
2.  Use the `Element.classifyDevice` function which will convert `Window.width` and `Window.height` into a `Device` record, which you should store in your model.
3.  Use the `Device` record in your view to specify how your page changes with window size.
4.  If things get crazy, use the `responsive` function to map one range to another.

Check out the [elm.style website source](https://github.com/mdgriffith/elm.style) for a real example.

@docs Device, classifyDevice, responsive


## Text Markup

These elements are useful for quick text markup.

@docs bold, italic, strike, underline, sub, super


## Semantic Markup

This library made the opinionated choice to make layout a first class concern of your `view` function.

However it's still very useful to have semantic markup in places. The following nodes can be used to annotate your layouts.

So, if we wanted to make a standard element be rendered as a `section` node, we could do the following

    -- Regular element
    el MyStyle [] (text "Hello World!")

    -- Same element annotated as a `section`
    section <| el MyStyle [] (text "Hello World!")

@docs node, button, header, section, nav, article, aside, canvas, iframe, audio, video


## Form Elements

Some convient elements for working with forms.

@docs form, checkbox, label, labelBelow, inputText, textArea, radio, select, option, Option


## Advanced Rendering

@docs toHtml, embedStylesheet


### Deprecated

@docs root, embed, render

-}

import Html exposing (Html)
import Html.Attributes
import Element.Internal.Model as Internal exposing (..)
import Element.Internal.Modify as Modify
import Style exposing (Style, StyleSheet)
import Style.Internal.Model as Style exposing (Length)
import Element.Attributes as Attr
import Element.Internal.Render as Render
import Window


{-| You can think of an `Element` as `Html` with built-in layout.

It has one `style` identifier, which you can think of as a CSS class.

It can also have style `variations`, which are covered in the `Style` module.

-}
type alias Element style variation msg =
    Internal.Element style variation msg


{-| -}
type alias Attribute variation msg =
    Internal.Attribute variation msg


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


{-| The most basic element.

You need to specify a style, a list of attributes, and a single child.

    -- an element with the style `MyStyle`, that is aligned left, and has one child.
    el MyStyle [ alignLeft ] (text "Hello World!")

`el` can only have one child because in order to have multiple children, we need to specify how the layout would work.

-}
el : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
el style attrs child =
    Element
        { node = "div"
        , style = Just style
        , attrs = attrs
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| A simple circle. Provide the radius it should have.

Automatically sets the propery width, height, and corner rounded.

-}
circle : Float -> style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
circle radius style attrs child =
    Element
        { node = "div"
        , style = Just style
        , attrs =
            (Attr
                (Html.Attributes.style
                    [ ( "border-radius", toString radius ++ "px" ) ]
                )
                :: Width (Style.Px (2 * radius))
                :: Height (Style.Px (2 * radius))
                :: attrs
            )
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| An element for adding additional spacing. The `Float` is the multiple that should be used of the spacing that's being set by the parent.

So, if the parent element is a `column` that set spacing to `5`, and this spacer was a `2`. Then it would be a 10 pixel spacer.

-}
spacer : Float -> Element style variation msg
spacer =
    Spacer


{-| A convenience node for images. Accepts an image src as the first argument.
-}
image : String -> style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
image src style attrs child =
    Element
        { node = "img"
        , style = Just style
        , attrs = (Attr (Html.Attributes.src src) :: attrs)
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| Creates a 1 px tall horizontal line.

If you want a horizontal rule that is something more specific, craft it with `el`!

-}
hairline : style -> Element style variation msg
hairline style =
    Element
        { node = "hr"
        , style = Just style
        , attrs = [ Height (Style.Px 1) ]
        , child = empty
        , absolutelyPositioned = Nothing
        }


{-| Make a line-break.

You probably want to use `paragraph` instead. This is only for adjusting where a sentance should break, not for formating paragraphs.

-}
break : Element style variation msg
break =
    Element
        { node = "br"
        , style = Nothing
        , attrs = []
        , child = empty
        , absolutelyPositioned = Nothing
        }


{-| For when you want to embed `Html`.

If you're using this library, I'd encourage you to try to solve your problem without using this escape hatch.

Usage of this function makes the most sense when you're dealing with `Html` from another module or package.

-}
html : Html msg -> Element style variation msg
html =
    Raw



---------------------
--- Semantic Markup
---------------------


{-| -}
node : String -> Element style variation msg -> Element style variation msg
node str =
    Modify.setNode str


{-| -}
header : Element style variation msg -> Element style variation msg
header =
    Modify.setNode "header"


{-| -}
section : Element style variation msg -> Element style variation msg
section =
    Modify.setNode "section"


{-| -}
nav : Element style variation msg -> Element style variation msg
nav =
    Modify.setNode "nav"


{-| -}
article : Element style variation msg -> Element style variation msg
article =
    Modify.setNode "article"


{-| -}
aside : Element style variation msg -> Element style variation msg
aside =
    Modify.setNode "aside"


{-| -}
button : Element style variation msg -> Element style variation msg
button =
    Modify.setNode "button"



---------------------
--- Specialized Elements
---------------------


{-| -}
canvas : Element style variation msg -> Element style variation msg
canvas =
    Modify.setNode "canvas"


{-| -}
iframe : Element style variation msg -> Element style variation msg
iframe =
    Modify.setNode "iframe"


{-| -}
audio : Element style variation msg -> Element style variation msg
audio =
    Modify.setNode "audio"


{-| -}
video : Element style variation msg -> Element style variation msg
video =
    Modify.setNode "video"



---------------------
--- Form and Input
---------------------


{-| -}
form : Element style variation msg -> Element style variation msg
form =
    Modify.setNode "form"


{-| Create a list of labeled radio button.

This implies a column layout.

    radio "lunch" None []
        [ option "burrito" True (text "A Burrito!")
        , option "taco" False (text "A Taco!")
        ]

-}
radio : String -> style -> List (Attribute variation msg) -> List (Option style variation msg) -> Element style variation msg
radio group style attributes buttons =
    let
        toChild (Option value on child) =
            let
                style =
                    Modify.getStyle child

                attrs =
                    Modify.getAttrs child

                ( inputEvents, nonInputEventAttrs ) =
                    List.partition forInputEvents attrs

                forInputEvents attr =
                    case attr of
                        InputEvent ev ->
                            True

                        _ ->
                            False

                rune =
                    child
                        |> Modify.setNode "input"
                        |> Modify.addAttrList
                            ([ Attr.type_ "radio"
                             , Attr.name group
                             , Attr.value value
                             , Attr.checked on
                             ]
                                ++ inputEvents
                            )
                        |> Modify.removeContent
                        |> Modify.removeStyle

                literalLabel =
                    child
                        |> Modify.getChild
                        |> Modify.removeAllAttrs
                        |> Modify.removeStyle
            in
                Layout
                    { node = "layout"
                    , style = style
                    , layout = Style.FlexLayout Style.GoRight []
                    , attrs = nonInputEventAttrs
                    , children = Normal [ rune, literalLabel ]
                    , absolutelyPositioned = Nothing
                    }
    in
        column style attributes (List.map toChild buttons)


{-| Create an Option. Can only be used with `radio` and `select`.
-}
option : String -> Bool -> Element style variation msg -> Option style variation msg
option =
    Option


{-| -}
type Option style variation msg
    = Option String Bool (Element style variation msg)


{-| A standard html dropdown set of options.

    select "favorite-animal" MySelectionStyle []
        [ option "manatee" False (text "Manatees are pretty cool")
        , option "pangolin" False (text "But so are pangolins")
        , option "bee" True (text "Bees")
        ]

-}
select : String -> style -> List (Attribute variation msg) -> List (Option style variation msg) -> Element style variation msg
select group style attributes buttons =
    let
        toChild (Option value on child) =
            child
                |> Modify.setNode "option"
                |> Modify.addAttrList
                    [ Attr.value value
                    , Attr.selected on
                    ]
    in
        Modify.setNode "select" <|
            column style (Attr.name group :: attributes) (List.map toChild buttons)


{-| An automatically labeled checkbox.
-}
checkbox : Bool -> style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
checkbox on style attrs label =
    let
        ( events, notInputEvents ) =
            List.partition forInputEvents attrs

        forInputEvents attr =
            case attr of
                InputEvent ev ->
                    True

                _ ->
                    False
    in
        Element
            { node = "label"
            , style = (Just style)
            , attrs = notInputEvents
            , child =
                (inlineChildren "div"
                    Nothing
                    []
                    [ Element
                        { node = "input"
                        , style = Nothing
                        , attrs =
                            (Attr.type_ "checkbox"
                                :: Attr.checked on
                                :: events
                            )
                        , child = empty
                        , absolutelyPositioned = Nothing
                        }
                    , label
                    ]
                )
            , absolutelyPositioned = Nothing
            }


{-| For input elements that are not automatically labeled (checkbox, radio), this will attach a label above the element.

    label Label [] (text "check this out") <|
        inputText Style [] "The Value!"

-}
label : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg -> Element style variation msg
label elem attrs label input =
    let
        -- If naked text is provided, then flexbox won't work.
        -- In that case we wrap it in a div.
        containedLabel =
            case label of
                Text dec content ->
                    Element
                        { node = "div"
                        , style = Nothing
                        , attrs = []
                        , child = (Text dec content)
                        , absolutelyPositioned = Nothing
                        }

                l ->
                    l
    in
        node "label" <|
            column
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
                    Element
                        { node = "div"
                        , style = Nothing
                        , attrs = []
                        , child = (Text dec content)
                        , absolutelyPositioned = Nothing
                        }

                l ->
                    l
    in
        node "label" <|
            column
                elem
                attrs
                [ input
                , label
                ]


{-| -}
textArea : style -> List (Attribute variation msg) -> String -> Element style variation msg
textArea elem attrs content =
    Element
        { node = "textarea"
        , style = Just elem
        , attrs = attrs
        , child = text content
        , absolutelyPositioned = Nothing
        }


{-| Text input

    label LabelStyle [] (text "check this out") <|
        inputText Style [] "The Value!"

-}
inputText : style -> List (Attribute variation msg) -> String -> Element style variation msg
inputText elem attrs content =
    Element
        { node = "input"
        , style = Just elem
        , attrs = (Attr.type_ "text" :: Attr.value content :: attrs)
        , child = Empty
        , absolutelyPositioned = Nothing
        }


{-| A `full` element will ignore the spacing set for it by the parent, and also grow to cover the parent's padding.

This is mostly useful in text layouts.

-}
full : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
full elem attrs child =
    Element
        { node = "div"
        , style = Just elem
        , attrs = (Expand :: attrs)
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| A text layout.

Children that are aligned left or right will be floated left or right. Everything else if arranged in the standard 'block' layout of css, meaning a column flowing down.

-}
textLayout : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
textLayout style attrs children =
    Layout
        { node = "div"
        , style = Just style
        , layout = Style.TextLayout True
        , attrs = attrs
        , children = Normal children
        , absolutelyPositioned = Nothing
        }


{-| Paragraph is actually a layout if you can believe it!

This is the same as a textLayout, except all of the children are set to `display:inline`.

Because all the children are inline, they will not respect and width or height set on them.

-}
paragraph : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
paragraph style attrs children =
    -- Paragraph does not have clearfix, which is what the `TextLayout False` is all about
    Layout
        { node = "p"
        , style = Just style
        , layout = Style.TextLayout False
        , attrs = attrs
        , children = Normal <| List.map (Modify.addAttrToNonText Inline) children
        , absolutelyPositioned = Nothing
        }


{-| -}
inlineChildren :
    String
    -> Maybe style
    -> List (Attribute variation msg)
    -> List (Element style variation msg)
    -> Element style variation msg
inlineChildren node style attrs children =
    let
        ( child, others ) =
            case children of
                [] ->
                    ( empty, Nothing )

                child :: others ->
                    ( Modify.addAttrToNonText Inline child, Just <| List.map (Modify.addAttrToNonText Inline) others )
    in
        Element
            { node = node
            , style = style
            , attrs = attrs
            , child = child
            , absolutelyPositioned = others
            }


{-| -}
row : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
row style attrs children =
    Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.GoRight []
        , attrs = attrs
        , children = Normal children
        , absolutelyPositioned = Nothing
        }


{-| -}
column : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
column style attrs children =
    Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.Down []
        , attrs = attrs
        , children = Normal children
        , absolutelyPositioned = Nothing
        }


{-| -}
wrappedRow : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
wrappedRow style attrs children =
    Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.GoRight [ Style.Wrap True ]
        , attrs = attrs
        , children = Normal children
        , absolutelyPositioned = Nothing
        }


{-| -}
wrappedColumn : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
wrappedColumn style attrs children =
    Layout
        { node = "div"
        , style = Just style
        , layout = Style.FlexLayout Style.Down [ Style.Wrap True ]
        , attrs = attrs
        , children = Normal children
        , absolutelyPositioned = Nothing
        }


{-| -}
type alias Grid =
    { rows : List Length
    , columns : List Length
    }


{-| A table is a special grid
-}
table : style -> List (Attribute variation msg) -> List (List (Element style variation msg)) -> Element style variation msg
table style attrs rows =
    let
        children =
            List.concat <|
                List.indexedMap
                    (\row columns ->
                        List.indexedMap
                            (\col content ->
                                area
                                    { start = ( row, col )
                                    , width = 1
                                    , height = 1
                                    }
                                    content
                            )
                            columns
                    )
                    rows
    in
        grid style { columns = [], rows = [] } attrs children


{-| An interface to css grid. Here's a basic example:

    grid MyGridStyle
        { columns = [ px 100, px 100, px 100, px 100 ]
        , rows =
            [ px 100
            , px 100
            , px 100
            , px 100
            ]
        }
        []
        [ area
            { start = ( 0, 0 )
            , width = 1
            , height = 1
            }
            (el Box [] (text "box"))
        , area
            { start = ( 1, 1 )
            , width = 1
            , height = 2
            }
            (el Box [] (text "box"))
        ]

-}
grid : style -> Grid -> List (Attribute variation msg) -> List (OnGrid (Element style variation msg)) -> Element style variation msg
grid style template attrs children =
    let
        prepare el =
            Normal <| List.map (\(OnGrid x) -> x) el

        ( spacing, notSpacingAttrs ) =
            List.partition forSpacing attrs

        forSpacing attr =
            case attr of
                Spacing _ _ ->
                    True

                _ ->
                    False

        gridAttributes =
            case List.head <| List.reverse spacing of
                Nothing ->
                    []

                Just (Spacing x y) ->
                    [ Style.GridGap x y ]

                _ ->
                    []
    in
        Layout
            { node = "div"
            , style = Just style
            , layout = Style.Grid (Style.GridTemplate template) gridAttributes
            , attrs = notSpacingAttrs
            , children = prepare children
            , absolutelyPositioned = Nothing
            }


{-| -}
type alias NamedGrid =
    { rows : List ( Length, List Style.NamedGridPosition )
    , columns : List Length
    }


{-| With a named grid, you can name areas within the grid and use that name to place an element.

Here's an example:

    namedGrid MyGridStyle
        { columns = [ px 200, px 200, px 200, fill 1 ]
        , rows =
            [ px 200 => [ spanAll "header" ]
            , px 200 => [ span 3 "content", span 1 "sidebar" ]
            , px 200 => [ span 3 "content", span 1 "sidebar" ]
            , px 200 => [ spanAll "footer" ]
            ]
        }
        []
        [ named "header"
            (el Box [] (text "box"))
        , named "sidebar"
            (el Box [] (text "box"))
        ]

**note:** this example uses rocket(`=>`) as a synonym for creating a tuple. For more, check out the [rocket update](https://github.com/NoRedInk/rocket-update) package!

-}
namedGrid : style -> NamedGrid -> List (Attribute variation msg) -> List (NamedOnGrid (Element style variation msg)) -> Element style variation msg
namedGrid style template attrs children =
    let
        prepare el =
            Normal <| List.map (\(NamedOnGrid x) -> x) el

        ( spacing, notSpacingAttrs ) =
            List.partition forSpacing attrs

        forSpacing attr =
            case attr of
                Spacing _ _ ->
                    True

                _ ->
                    False

        gridAttributes =
            case List.head <| List.reverse spacing of
                Nothing ->
                    []

                Just (Spacing x y) ->
                    [ Style.GridGap x y ]

                _ ->
                    []
    in
        Layout
            { node = "div"
            , style = Just style
            , layout = Style.Grid (Style.NamedGridTemplate template) gridAttributes
            , attrs = notSpacingAttrs
            , children = (prepare children)
            , absolutelyPositioned = Nothing
            }


{-| -}
type alias GridPosition =
    { start : ( Int, Int )
    , width : Int
    , height : Int
    }


{-| -}
type alias OnGrid thing =
    Internal.OnGrid thing


{-| -}
type alias NamedOnGrid thing =
    Internal.NamedOnGrid thing


{-| Specify a specific position on a normal `grid`.
-}
area : GridPosition -> Element style variation msg -> OnGrid (Element style variation msg)
area box el =
    OnGrid <| Modify.addAttr (GridCoords <| Style.GridPosition box) el



{-
   Could make a dynamic positioner based on list index.

        at
           (\i ->
               { start :
                   ( i % 3
                   , i / 3
                   )
               , width = 1
               , height = 1
               }
           )
           (text "Hi!")
-}


{-| Specify a named postion on a `namedGrid`.
-}
named : String -> Element style variation msg -> NamedOnGrid (Element style variation msg)
named name el =
    NamedOnGrid <| Modify.addAttr (GridArea name) el


type alias NamedGridPosition =
    Style.NamedGridPosition


{-| Used to define named areas in a `namedGrid`.
-}
span : Int -> String -> NamedGridPosition
span i name =
    Style.Named (Style.SpanJust i) (Just name)


{-| Used to define named areas in a `namedGrid`.
-}
spanAll : String -> NamedGridPosition
spanAll name =
    Style.Named Style.SpanAll (Just name)


{-| Turn an element into a link.

    link "http://zombo.com"
        <| el MyStyle (text "Welcome to Zombocom")

Changes an element's node to `<a>` and sets the href. `rel` properties are set to `noopener` and `noreferrer`.

-}
link : String -> Element style variation msg -> Element style variation msg
link src el =
    el
        |> Modify.setNode "a"
        |> Modify.addAttrList
            [ Attr (Html.Attributes.href src)
            , Attr (Html.Attributes.rel "noopener noreferrer")
            ]


{-| A helper function. This:

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


{-| Another helper function that defaults to `empty`

    whenJust (Just ("Hi!")) text

is sugar for

    case maybe of
        Nothing ->
            empty
        Just x ->
            text x

-}
whenJust : Maybe a -> (a -> Element style variation msg) -> Element style variation msg
whenJust maybe view =
    case maybe of
        Nothing ->
            empty

        Just thing ->
            view thing


{-| -}
within : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
within nearbys parent =
    let
        position el p =
            el
                |> Modify.addAttr (PositionFrame (Nearby Within))
                |> Modify.addChild p
    in
        List.foldl position parent nearbys


{-| -}
above : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
above nearbys parent =
    let
        position el p =
            el
                |> Modify.addAttr (PositionFrame (Nearby Above))
                |> Modify.removeAttrs [ VAlign Top, VAlign Bottom ]
                |> Modify.addChild p
    in
        List.foldl position parent nearbys


{-| -}
below : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
below nearbys parent =
    let
        position el p =
            el
                |> Modify.addAttr (PositionFrame (Nearby Below))
                |> Modify.removeAttrs [ VAlign Top, VAlign Bottom ]
                |> Modify.addChild p
    in
        List.foldl position parent nearbys


{-| -}
onRight : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
onRight nearbys parent =
    let
        position el p =
            el
                |> Modify.addAttr (PositionFrame (Nearby OnRight))
                |> Modify.removeAttrs [ HAlign Right, HAlign Left ]
                |> Modify.addChild p
    in
        List.foldl position parent nearbys


{-| -}
onLeft : List (Element style variation msg) -> Element style variation msg -> Element style variation msg
onLeft nearbys parent =
    let
        position el p =
            el
                |> Modify.addAttr (PositionFrame (Nearby OnLeft))
                |> Modify.removeAttrs [ HAlign Right, HAlign Left ]
                |> Modify.addChild p
    in
        List.foldl position parent nearbys


{-| Position an element relative to the window.

Essentially the same as `display: fixed`

-}
screen : Element style variation msg -> Element style variation msg
screen el =
    Element
        { node = "div"
        , style = Nothing
        , attrs =
            [ PositionFrame Screen
            , Width (Style.Calc 100 0)
            , Height (Style.Calc 100 0)
            , PointerEvents False
            ]
        , child = empty
        , absolutelyPositioned = Nothing
        }
        |> within
            [ el
            ]


{-| Embeds the stylesheet and renders the `Element`'s into `Html`.
-}
layout : StyleSheet style variation -> Element style variation msg -> Html msg
layout =
    Render.root


{-| Same as `layout`, but the height and width of the site is set to the height and width of the screen.
-}
viewport : StyleSheet style variation -> Element style variation msg -> Html msg
viewport =
    Render.viewport


{-| Renders `Element`'s into `Html`, but does not embed a stylesheet.
-}
toHtml : StyleSheet style variation -> Element style variation msg -> Html msg
toHtml stylesheet el =
    Html.div []
        (Render.render stylesheet el)


{-| Embed a stylesheet.
-}
embedStylesheet : StyleSheet style variation -> Html msg
embedStylesheet sheet =
    -- We embed it not as a fullscreen
    Render.embed False sheet


{-| DEPRECATED, will be removed in the next major version. Use `toHtml` instead.
-}
render : StyleSheet style variation -> Element style variation msg -> Html msg
render stylesheet el =
    Html.div []
        (Render.render stylesheet el)


{-| DEPRECATED, will be removed in the next major version. Use `layout` instead.
-}
root : StyleSheet style variation -> Element style variation msg -> Html msg
root =
    Render.root


{-| DEPRECATED, will be removed in the next major version. Use `embedStylesheet` instead.
-}
embed : StyleSheet style variation -> Html msg
embed sheet =
    -- We embed it not as a fullscreen
    Render.embed False sheet


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
        responsive device.width ( 600, 1200 ) ( 16, 20 )

When the device width is between 600 and 1200, set the font-size between 16 and 20 using a linear scale.

-}
responsive : Float -> ( Float, Float ) -> ( Float, Float ) -> Float
responsive a ( aMin, aMax ) ( bMin, bMax ) =
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


{-| Change the msg that an Element is sending.

An analog of `Html.map`.

-}
map : (a -> msg) -> Element style variation a -> Element style variation msg
map =
    Internal.mapMsg
