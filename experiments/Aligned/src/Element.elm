module Element
    exposing
        ( Attribute
        , Column
        , Element
        , FocusStyle
        , IndexedColumn
        , IndexedTable
        , Length
        , Link
        , Option
        , Table
        , above
        , alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , attribute
        , behind
        , below
        , center
        , centerY
        , clip
        , clipX
        , clipY
        , column
        , decorativeImage
        , description
        , download
        , downloadAs
        , el
        , empty
        , fill
        , fillPortion
        , focusStyle
        , forceHover
        , height
        , hidden
        , html
        , image
        , inFront
        , indexedTable
        , layout
        , layoutWith
        , link
        , map
        , mapAttribute
        , mouseOverScale
        , moveDown
        , moveLeft
        , moveRight
        , moveUp
        , newTabLink
        , noHover
        , onLeft
        , onRight
        , padding
        , paddingEach
        , paddingXY
        , paragraph
        , pointer
        , px
        , rotate
        , row
        , scale
        , scrollbarX
        , scrollbarY
        , scrollbars
        , shrink
        , spaceEvenly
        , spacing
        , spacingXY
        , table
        , text
        , textColumn
        , width
        )

{-|


## Basic Elements

@docs Element, Attribute, empty, text, el


## Rows and Columns

Rows and columns are the most common layouts.

@docs row, column


## Text Layout

Text needs it's own layout primitives.

@docs paragraph, textColumn


## Data Table

@docs Table, Column, table

@docs IndexedTable, IndexedColumn, indexedTable


## Rendering

@docs layout, layoutWith, Option, forceHover, noHover, focusStyle, FocusStyle


# Links and Images

@docs Link, link, newTabLink, download, downloadAs

@docs image, decorativeImage


# Attributes

@docs Attribute, hidden, description, pointer


## Width and Height

@docs width, height, Length, px, shrink, fill, fillPortion


## Padding and Spacing

There's no concept of margin in `style-elements`, instead we have padding and spacing.

Padding is what you'd expect, the distance between the outer edge and the content, and spacing is the space between children.

So, if we have the following row, with some padding and spacing.

    Element.row [ padding 10, spacing 7 ]
        [ Element.el [] empty
        , Element.el [] empty
        , Element.el [] empty
        ]

Here's what we can expect.

<img src="https://mdgriffith.gitbooks.io/style-elements/content/assets/spacing-400.png" alt="Three boxes spaced 7 pixels apart.  There's a 10 pixel distance from the edge of the parent to the boxes." />

@docs padding, paddingXY, paddingEach

@docs spacing, spacingXY, spaceEvenly


## Alignment

Alignment can be used to align an `Element` within another `Element`.

    Element.el [ center, alignTop ] (text "I'm centered and aligned top!")

If alignment is set on elements in a layout such as `row`, then the element will push the other elements in that direction. Here's an example.

    Element.row []
        [ Element.el [] Element.empty
        , Element.el [ alignLeft ] Element.empty
        , Element.el [ center ] Element.empty
        , Element.el [ alignRight ] Element.empty
        ]

will result in a layout like

    |-|-| |-| |-|

Where there are two elements on the left, one in the center, and on on the right.

@docs center, centerY, alignLeft, alignRight, alignTop, alignBottom


## Nearby Elements

It can be nice to position an element relative to another element, _without

Let's say we want a dropdown menu. Essentially we want to say: _put this element below this other element, but don't affect the layout when you do_.

    Elemenet.row []
        [ Element.el
            [ Element.below True (Element.text "I'm below!")
            ]
            (Element.text "I'm normal!")
        ]

This will result in

    |- I'm normal! -|
       I'm below

Where `"I'm Below"` doesn't change the size of `Element.row`.

This is very useful for things like dropdown menus or tooltips.

@docs above, below, onRight, onLeft, inFront, behind


## Adjustment

@docs moveRight, moveUp, moveLeft, moveDown, rotate, scale, mouseOverScale


## Clipping and Scrollbars

Clip the content if it overflows.

@docs clip, clipX, clipY

If these are present, the element will add a scrollbar if necessary.

@docs scrollbars, scrollbarY, scrollbarX


## Mapping

@docs map, mapAttribute


## Compatibility

@docs html, attribute

-}

import Color exposing (Color)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes
import Internal.Model as Internal


{-| The basic building block of your layout. Here we create a

    import Background
    import Element

    view =
        Element.el [] (Element.text "Hello!")

-}
type alias Element msg =
    Internal.Element msg


{-| -}
type alias Attribute msg =
    Internal.Attribute msg


{-| -}
html : Html msg -> Element msg
html =
    Internal.unstyled


{-| -}
attribute : Html.Attribute msg -> Attribute msg
attribute =
    Internal.Attr


{-| -}
map : (msg -> msg1) -> Element msg -> Element msg1
map =
    Internal.map


{-| -}
mapAttribute : (msg -> msg1) -> Attribute msg -> Attribute msg1
mapAttribute =
    Internal.mapAttr


{-| -}
type alias Length =
    Internal.Length


{-| -}
px : Int -> Length
px =
    Internal.Px


{-| -}
shrink : Length
shrink =
    Internal.Content


{-| Fill the available space. The available space will be split evenly between elements that have `width fill`.
-}
fill : Length
fill =
    Internal.Fill 1



-- between =
--     Internal.Between


{-| Sometimes you may not want to split available space evenly. In this case you can use `fillPortion` to define which elements should have what portion of the available space.

So, two elements, one with `width (fillPortion 2)` and one with `width (fillPortion 3)`. The first would get 2 portions of the available space, while the second would get 3.

Also: `fill == fillPortion 1`

-}
fillPortion : Int -> Length
fillPortion =
    Internal.Fill


{-| This is your top level node where you can turn `Element` into `Html`.
-}
layout : List (Attribute msg) -> Element msg -> Html msg
layout =
    layoutWith { options = [] }


{-| -}
layoutWith : { options : List Option } -> List (Attribute msg) -> Element msg -> Html msg
layoutWith { options } attrs child =
    Internal.renderRoot options
        (Background.color Color.blue
            :: Font.color Color.white
            :: Font.size 20
            :: Font.family
                [ Font.typeface "Open Sans"
                , Font.typeface "Helvetica"
                , Font.typeface "Verdana"
                , Font.sansSerif
                ]
            :: Internal.htmlClass "style-elements se el"
            :: Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: attrs
        )
        child


{-| -}
type alias Option =
    Internal.Option


{-| -}
defaultFocus :
    { borderColor : Maybe Color
    , backgroundColor : Maybe Color
    , shadow :
        Maybe
            { color : Color
            , offset : ( Int, Int )
            , blur : Int
            , size : Int
            }
    }
defaultFocus =
    Internal.focusDefaultStyle


{-| -}
type alias FocusStyle =
    { borderColor : Maybe Color
    , backgroundColor : Maybe Color
    , shadow :
        Maybe
            { color : Color
            , offset : ( Int, Int )
            , blur : Int
            , size : Int
            }
    }


{-| -}
focusStyle : FocusStyle -> Option
focusStyle =
    Internal.FocusStyleOption


{-| Disable all `mouseOver` styles.
-}
noHover : Option
noHover =
    Internal.HoverOption Internal.NoHover


{-| Any `hover` styles, aka attributes with `mouseOver` in the name, will be always turned on.

This is useful for when you're targeting a platform that has no mouse, such as mobile.

-}
forceHover : Option
forceHover =
    Internal.HoverOption Internal.ForceHover



-- {-| A helper function. This:
--     when (x == 5) (text "yay, it's 5")
-- is sugar for
--     if (x == 5) then
--         text "yay, it's 5"
--     else
--         empty
-- -}
-- when : Bool -> Element msg -> Element msg
-- when bool elm =
--     if bool then
--         elm
--     else
--         empty
-- {-| Another helper function that defaults to `empty`
--     whenJust (Just ("Hi!")) text
-- is sugar for
--     case maybe of
--         Nothing ->
--             empty
--         Just x ->
--             text x
-- -}
-- whenJust : Maybe a -> (a -> Element msg) -> Element msg
-- whenJust maybe view =
--     case maybe of
--         Nothing ->
--             empty
--         Just thing ->
--             view thing


{-| Nothing to see here!
-}
empty : Element msg
empty =
    Internal.Empty


{-| Create some plain text.

    text "Hello, you stylish developer!"

**Note** text does not wrap by default. In order to get text to wrap, check out `paragraph`!

-}
text : String -> Element msg
text content =
    Internal.Text content


{-| The basic building block of your layout.

    import Color exposing (blue, darkBlue)
    import Element exposing (Element)
    import Element.Background as Background
    import Element.Border as Border

    myElement : Element msg
    myElement =
        Element.el
            [ Background.color blue
            , Border.color darkBlue
            ]
            (Element.text "You've made a stylish element!")

-}
el : List (Attribute msg) -> Element msg -> Element msg
el attrs child =
    Internal.element Internal.noStyleSheet
        Internal.asEl
        Nothing
        (width shrink
            :: height shrink
            -- :: centerY
            :: center
            :: Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: attrs
        )
        (Internal.Unkeyed [ child ])


{-| If you want a row of elements, use `row`!
-}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    Internal.element
        Internal.noStyleSheet
        Internal.asRow
        Nothing
        (Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: width fill
            :: attrs
        )
        (Internal.Unkeyed <| Internal.rowEdgeFillers children)


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Internal.element Internal.noStyleSheet
        Internal.asColumn
        Nothing
        (Internal.Class "y-content-align" "content-top"
            :: Internal.Class "x-content-align" "content-center-x"
            :: height fill
            :: width fill
            :: attrs
        )
        (Internal.Unkeyed <| Internal.columnEdgeFillers children)


{-| -}
type alias Table records msg =
    { data : List records
    , columns : List (Column records msg)
    }


{-| -}
type alias Column record msg =
    { header : Element msg
    , view : record -> Element msg
    }


{-| Show some tabular data.

Start with a list of records and specify how each column should be rendered.

So, if we have a list of `persons`:

    type alias Person =
        { firstName : String
        , lastName : String
        }

    persons : List Person
    persons =
        [ { firstName = "David"
          , lastName = "Bowie"
          }
        , { firstName = "Florence"
          , lastName = "Welch"
          }
        ]

We could render it using

    Element.table []
        { data = persons
        , columns =
            [ { header = Element.text "First Name"
              , view =
                    (\person ->
                        Element.text person.firstName
                    )
              }
            , { header = Element.text "Last Name"
              , view =
                     (\person ->
                        Element.text person.lastName
                     )
              }
            ]
        }

**Note:** Sometimes you might not have a list of records directly in your model. In this case it can be really nice to write a function that transforms some part of your model into a list of records before feeding it into `Element.table`.

-}
table : List (Attribute msg) -> Table data msg -> Element msg
table attrs config =
    tableHelper attrs
        { data = config.data
        , columns =
            List.map InternalColumn config.columns
        }


{-| -}
type alias IndexedTable records msg =
    { data : List records
    , columns : List (IndexedColumn records msg)
    }


{-| -}
type alias IndexedColumn record msg =
    { header : Element msg
    , view : Int -> record -> Element msg
    }


{-| Same as `Element.table` except the `view` for each column will also receive the row index as well as the record.
-}
indexedTable : List (Attribute msg) -> IndexedTable data msg -> Element msg
indexedTable attrs config =
    tableHelper attrs
        { data = config.data
        , columns =
            List.map InternalIndexedColumn config.columns
        }


{-| -}
type alias InternalTable records msg =
    { data : List records
    , columns : List (InternalTableColumn records msg)
    }


{-| -}
type InternalTableColumn record msg
    = InternalIndexedColumn (IndexedColumn record msg)
    | InternalColumn (Column record msg)


tableHelper : List (Attribute msg) -> InternalTable data msg -> Element msg
tableHelper attrs config =
    let
        ( sX, sY ) =
            Internal.getSpacing attrs ( 0, 0 )

        columnHeader col =
            case col of
                InternalIndexedColumn colConfig ->
                    colConfig.header

                InternalColumn colConfig ->
                    colConfig.header

        maybeHeaders =
            List.map columnHeader config.columns
                |> (\headers ->
                        if List.all ((==) Internal.Empty) headers then
                            Nothing
                        else
                            Just (List.indexedMap (\col header -> onGrid 1 (col + 1) header) headers)
                   )

        template =
            Internal.StyleClass <|
                Internal.GridTemplateStyle
                    { spacing = ( px sX, px sY )
                    , columns = List.repeat (List.length config.columns) Internal.Content
                    , rows = List.repeat (List.length config.data) Internal.Content
                    }

        onGrid row column el =
            Internal.element
                Internal.noStyleSheet
                Internal.asEl
                Nothing
                [ Internal.StyleClass
                    (Internal.GridPosition
                        { row = row
                        , col = column
                        , width = 1
                        , height = 1
                        }
                    )
                ]
                (Internal.Unkeyed [ el ])

        add cell columnConfig cursor =
            case columnConfig of
                InternalIndexedColumn column ->
                    { cursor
                        | elements =
                            onGrid cursor.row cursor.column (column.view cursor.row cell)
                                :: cursor.elements
                        , column = cursor.column + 1
                    }

                InternalColumn column ->
                    { cursor
                        | elements =
                            onGrid cursor.row cursor.column (column.view cell)
                                :: cursor.elements
                        , column = cursor.column + 1
                    }

        build columns rowData cursor =
            let
                newCursor =
                    List.foldl (add rowData)
                        cursor
                        columns
            in
            { newCursor
                | row = cursor.row + 1
                , column = 1
            }

        children =
            List.foldl (build config.columns)
                { elements = []
                , row =
                    if maybeHeaders == Nothing then
                        1
                    else
                        2
                , column = 1
                }
                config.data
    in
    Internal.element Internal.noStyleSheet
        Internal.asGrid
        Nothing
        (width fill
            :: center
            :: template
            :: attrs
        )
        (Internal.Unkeyed
            (case maybeHeaders of
                Nothing ->
                    children.elements

                Just renderedHeaders ->
                    renderedHeaders ++ children.elements
            )
        )


{-| A paragraph will layout all children as wrapped, inline elements.

    import Element
    import Element.Font as Font

    Element.paragraph []
        [ text "lots of text ...."
        , el [ Font.bold ] (text "this is bold")
        , text "lots of text ...."
        ]

This is really useful when you want to markup text by having some parts be bold, or some be links, or whatever you so desire.

Also, if a child element has `alignLeft` or `alignRight`, then it will be moved to that side and the text will flow around it, (ah yes, `float` behavior).

This makes it particularly easy to do something like a [dropped capital](https://en.wikipedia.org/wiki/Initial).

    import Element
    import Element.Font as Font

    Element.paragraph []
        [ el
            [ alignLeft
            , padding 5
            , Font.lineHeight 1
            ]
            (text "S")
        , text "lots of text ...."
        ]

Which will look something like

<img src="https://mdgriffith.gitbooks.io/style-elements/content/assets/Screen%20Shot%202017-08-25%20at%209.41.52%20PM.png" />

-}
paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph attrs children =
    Internal.element Internal.noStyleSheet Internal.asParagraph (Just "p") (Internal.adjustParagraphSpacing attrs) (Internal.Unkeyed children)


{-| Now that we have a paragraph, we need someway to attach a bunch of paragraph's together.

To do that we can use a `textColumn`.

The main difference between a `column` and a `textColumn` is that `textColumn` will flow the text around elements that have `alignRight` or `alignLeft`, just like we just saw with paragraph.

In the following example, we have a `textColumn` where one child has `alignLeft`.

    Elment.textColumn [ spacing 10, padding 10 ]
        [ paragraph [] [ text "lots of text ...." ]
        , el [ alignLeft ] empty
        , paragraph [] [ text "lots of text ...." ]
        ]

Which will result in something like:

<img src="https://mdgriffith.gitbooks.io/style-elements/content/assets/Screen%20Shot%202017-08-25%20at%208.42.39%20PM.png" />

-}
textColumn : List (Attribute msg) -> List (Element msg) -> Element msg
textColumn attrs children =
    Internal.element
        Internal.noStyleSheet
        Internal.asTextColumn
        Nothing
        (width (px 650) :: attrs)
        (Internal.Unkeyed children)


{-| Both a source and a description are required for images. The description is used to describe the image to screen readers.
-}
image : List (Attribute msg) -> { src : String, description : String } -> Element msg
image attrs { src, description } =
    let
        imageAttributes =
            attrs
                |> List.filter
                    (\a ->
                        case a of
                            Internal.Width _ ->
                                True

                            Internal.Height _ ->
                                True

                            _ ->
                                False
                    )
    in
    Internal.element Internal.noStyleSheet
        Internal.asEl
        Nothing
        (clip
            :: attrs
        )
        (Internal.Unkeyed
            [ Internal.element Internal.noStyleSheet
                Internal.asEl
                (Just "img")
                (imageAttributes
                    ++ [ Internal.Attr <| Html.Attributes.src src
                       , Internal.Attr <| Html.Attributes.alt description
                       ]
                )
                (Internal.Unkeyed [])
            ]
        )


{-| If an image is purely decorative, you can skip the caption.
-}
decorativeImage : List (Attribute msg) -> { src : String } -> Element msg
decorativeImage attrs { src } =
    let
        imageAttributes =
            attrs
                |> List.filter
                    (\a ->
                        case a of
                            Internal.Width _ ->
                                True

                            Internal.Height _ ->
                                True

                            _ ->
                                False
                    )
    in
    Internal.element Internal.noStyleSheet
        Internal.asEl
        Nothing
        (clip
            :: attrs
        )
        (Internal.Unkeyed
            [ Internal.element Internal.noStyleSheet
                Internal.asEl
                (Just "img")
                (imageAttributes
                    ++ [ Internal.Attr <| Html.Attributes.src src
                       , Internal.Attr <| Html.Attributes.alt ""
                       ]
                )
                (Internal.Unkeyed [])
            ]
        )


{-| -}
type alias Link msg =
    { url : String
    , label : Element msg
    }


{-|

    link []
        { url = "google.com"
        , label = text "My Link to Google"
        }

-}
link : List (Attribute msg) -> Link msg -> Element msg
link attrs { url, label } =
    Internal.element Internal.noStyleSheet
        Internal.asEl
        (Just "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.rel "noopener noreferrer")
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        (Internal.Unkeyed [ label ])


{-| -}
newTabLink : List (Attribute msg) -> Link msg -> Element msg
newTabLink attrs { url, label } =
    Internal.element Internal.noStyleSheet
        Internal.asEl
        (Just "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.rel "noopener noreferrer")
            :: Internal.Attr (Html.Attributes.target "_blank")
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        (Internal.Unkeyed [ label ])


{-| A link to download a file.
-}
download : List (Attribute msg) -> Link msg -> Element msg
download attrs { url, label } =
    Internal.element Internal.noStyleSheet
        Internal.asEl
        (Just "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.download True)
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        (Internal.Unkeyed [ label ])


{-| A link to download a file, but you can specify the filename.
-}
downloadAs : List (Attribute msg) -> { label : Element msg, filename : String, url : String } -> Element msg
downloadAs attrs { url, filename, label } =
    Internal.element Internal.noStyleSheet
        Internal.asEl
        (Just "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.downloadAs filename)
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        (Internal.Unkeyed [ label ])


{-| -}
description : String -> Attribute msg
description =
    Internal.Describe << Internal.Label


{-| -}
below : Bool -> Element msg -> Attribute msg
below on element =
    if on then
        Internal.Nearby Internal.Below on element
    else
        Internal.NoAttribute


{-| `above` takes a `Bool` first so that you can easily toggle showing and hiding the element.
-}
above : Bool -> Element msg -> Attribute msg
above on element =
    Internal.Nearby Internal.Above on element


{-| -}
onRight : Bool -> Element msg -> Attribute msg
onRight on element =
    Internal.Nearby Internal.OnRight on element


{-| -}
onLeft : Bool -> Element msg -> Attribute msg
onLeft on element =
    Internal.Nearby Internal.OnLeft on element


{-| -}
inFront : Bool -> Element msg -> Attribute msg
inFront on element =
    Internal.Nearby Internal.InFront on element


{-| -}
behind : Bool -> Element msg -> Attribute msg
behind on element =
    Internal.Nearby Internal.Behind on element


{-| -}
width : Length -> Attribute msg
width =
    Internal.Width


{-| -}
height : Length -> Attribute msg
height =
    Internal.Height


{-| -}
scale : Float -> Attribute msg
scale n =
    Internal.Transform Nothing (Internal.Scale n n 1)


{-| -}
mouseOverScale : Float -> Attribute msg
mouseOverScale n =
    Internal.Transform (Just Internal.Hover) (Internal.Scale n n 1)


{-| -}
rotate : Float -> Attribute msg
rotate angle =
    Internal.Transform Nothing (Internal.Rotate 0 0 1 angle)



-- {-| -}
-- mouseOverRotate : Float -> Attribute msg
-- mouseOverRotate angle =
--     Internal.Transform (Just Internal.Hover) (Internal.Rotate 0 0 1 angle)


{-| -}
moveUp : Float -> Attribute msg
moveUp y =
    Internal.Transform Nothing (Internal.Move Nothing (Just (negate y)) Nothing)


{-| -}
moveDown : Float -> Attribute msg
moveDown y =
    Internal.Transform Nothing (Internal.Move Nothing (Just y) Nothing)


{-| -}
moveRight : Float -> Attribute msg
moveRight x =
    Internal.Transform Nothing (Internal.Move (Just x) Nothing Nothing)


{-| -}
moveLeft : Float -> Attribute msg
moveLeft x =
    Internal.Transform Nothing (Internal.Move (Just (negate x)) Nothing Nothing)


{-| -}
padding : Int -> Attribute msg
padding x =
    Internal.StyleClass (Internal.PaddingStyle x x x x)


{-| Set horizontal and vertical padding.
-}
paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    Internal.StyleClass (Internal.PaddingStyle y x y x)


{-| -}
paddingEach : { bottom : Int, left : Int, right : Int, top : Int } -> Attribute msg
paddingEach { top, right, bottom, left } =
    Internal.StyleClass (Internal.PaddingStyle top right bottom left)


{-| -}
center : Attribute msg
center =
    Internal.AlignX Internal.CenterX


{-| -}
centerY : Attribute msg
centerY =
    Internal.AlignY Internal.CenterY


{-| -}
alignTop : Attribute msg
alignTop =
    Internal.AlignY Internal.Top


{-| -}
alignBottom : Attribute msg
alignBottom =
    Internal.AlignY Internal.Bottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    Internal.AlignX Internal.Left


{-| -}
alignRight : Attribute msg
alignRight =
    Internal.AlignX Internal.Right


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    Internal.Class "x-align" "space-evenly"


{-| -}
spacing : Int -> Attribute msg
spacing x =
    Internal.StyleClass (Internal.SpacingStyle x x)


{-| In the majority of cases you'll just need to use `spacing`, which will work as intended.

However for some layouts, like `textColumn`, you may want to set a different spacing for the x axis compared to the y axis.

-}
spacingXY : Int -> Int -> Attribute msg
spacingXY x y =
    Internal.StyleClass (Internal.SpacingStyle x y)


{-| -}
hidden : Bool -> Attribute msg
hidden on =
    if on then
        Internal.class "hidden"
    else
        Internal.NoAttribute


{-| -}
scrollbars : Attribute msg
scrollbars =
    Internal.Class "overflow" "scrollbars"


{-| -}
scrollbarY : Attribute msg
scrollbarY =
    Internal.Class "overflow" "scrollbars-y"


{-| -}
scrollbarX : Attribute msg
scrollbarX =
    Internal.Class "overflow" "scrollbars-x"


{-| -}
clip : Attribute msg
clip =
    Internal.Class "overflow" "clip"


{-| -}
clipY : Attribute msg
clipY =
    Internal.Class "overflow" "clip-y"


{-| -}
clipX : Attribute msg
clipX =
    Internal.Class "overflow" "clip-x"


{-| Set the cursor to the pointer hand.
-}
pointer : Attribute msg
pointer =
    Internal.Class "cursor" "cursor-pointer"


type Device
    = Device


{-| <meta name="viewport" content="width=device-width, initial-scale=1">
-}
classifyDevice : { window | width : Int } -> Device
classifyDevice window =
    Device
