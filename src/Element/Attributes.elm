module Element.Attributes
    exposing
        ( Length
        , alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , attribute
        , center
        , class
        , classList
        , clip
        , clipX
        , clipY
        , content
        , fill
        , fillPortion
        , height
        , hidden
        , id
        , inlineStyle
        , map
        , maxHeight
        , maxWidth
        , minHeight
        , minWidth
        , moveDown
        , moveLeft
        , moveRight
        , moveUp
        , padding
        , paddingBottom
        , paddingLeft
        , paddingRight
        , paddingTop
        , paddingXY
        , percent
        , property
        , px
        , scrollbars
        , spacing
        , spacingXY
        , spread
        , toAttr
          -- , ping
          -- , rel
        , vary
        , verticalCenter
        , verticalSpread
        , width
        , xScrollbar
        , yScrollbar
        )

{-|


# This module is a mirror of `Html.Attributes`

Some attributes have been added.

The only modification to the existing library is that `style` has been renamed `inlineStyle` to avoid collision with `Style.style`.

Since this is a style library, you shouldn't need it very often.


# Style Element Attributes

These are the new attributes that generally have to do with layout.

@docs hidden, vary


## Alignment

Alignment attributes are incredibly useful for adjusting your layout.

When applied to layout elements like `row` and `grid`, alignment will affect the alignment of the children.

When applied to singular elements like `el`, alignment will affect the alignment of that individual element.

@docs center, verticalCenter, alignTop, alignBottom, alignLeft, alignRight, spread, verticalSpread


## Sizing

@docs width, minWidth, maxWidth, height, minHeight, maxHeight, Length, px, fill, fillPortion, percent, content


## Spacing ++ Padding

Spacing allows a layout to set the distance between the children in the layout.

So this layout:

    row [ spacing 10, padding 10 ]
        [ el Box [] empty
        , el Box [] empty
        , el Box [] empty
        ]

Is rendered into something like this:

<img src="https://mdgriffith.github.io/style-elements/images/spacing.png" alt="Spacing" width="400">

@docs spacing, spacingXY, padding, paddingXY, paddingTop, paddingRight, paddingBottom, paddingLeft


## Positioning

@docs moveUp, moveDown, moveRight, moveLeft


## Scrollbars

@docs scrollbars, yScrollbar, xScrollbar


## Overflow

@docs clip, clipX, clipY


## Conversion

@docs toAttr


# Primitives

@docs inlineStyle, property, attribute, map


# Super Common Attributes

@docs class, classList, id

-}

import Element.Internal.Model as Internal exposing (..)
import Html
import Html.Attributes
import Json.Decode as Json
import Style.Internal.Model as Style
import Style.Internal.Render.Value as StyleValue
import VirtualDom


{-| -}
type alias Length =
    Style.Length


{-| -}
center : Attribute variation msg
center =
    HAlign Center


{-| -}
verticalCenter : Attribute variation msg
verticalCenter =
    VAlign VerticalCenter


{-| -}
verticalSpread : Attribute variation msg
verticalSpread =
    VAlign VerticalJustify


{-| -}
spread : Attribute variation msg
spread =
    HAlign Justify


{-| -}
alignTop : Attribute variation msg
alignTop =
    VAlign Top


{-| -}
alignBottom : Attribute variation msg
alignBottom =
    VAlign Bottom


{-| -}
alignLeft : Attribute variation msg
alignLeft =
    HAlign Left


{-| -}
alignRight : Attribute variation msg
alignRight =
    HAlign Right



{- Layout Attributes -}


{-| -}
moveUp : Float -> Attribute variation msg
moveUp y =
    Position Nothing (Just (negate y)) Nothing


{-| -}
moveDown : Float -> Attribute variation msg
moveDown y =
    Position Nothing (Just y) Nothing


{-| -}
moveRight : Float -> Attribute variation msg
moveRight x =
    Position (Just x) Nothing Nothing


{-| -}
moveLeft : Float -> Attribute variation msg
moveLeft x =
    Position (Just (negate x)) Nothing Nothing


{-| -}
width : Length -> Attribute variation msg
width =
    Width


{-| -}
minWidth : Length -> Attribute variation msg
minWidth len =
    Attr (Html.Attributes.style [ ( "min-width", StyleValue.length len ) ])


{-| -}
maxWidth : Length -> Attribute variation msg
maxWidth len =
    Attr (Html.Attributes.style [ ( "max-width", StyleValue.length len ) ])


{-| -}
minHeight : Length -> Attribute variation msg
minHeight len =
    Attr (Html.Attributes.style [ ( "min-height", StyleValue.length len ) ])


{-| -}
maxHeight : Length -> Attribute variation msg
maxHeight len =
    Attr (Html.Attributes.style [ ( "max-height", StyleValue.length len ) ])


{-| -}
height : Length -> Attribute variation msg
height =
    Height


{-| -}
px : Float -> Length
px =
    Style.Px


{-| -}
content : Length
content =
    Style.Auto


{-| -}
fill : Length
fill =
    Style.Fill 1


{-| -}
fillPortion : Int -> Length
fillPortion =
    Style.Fill << toFloat


{-| -}
percent : Float -> Length
percent =
    Style.Percent


{-| Apply a style variation.

    el MyButton [ vary Disabled True ] (text "My Disabled Button!")

-}
vary : variation -> Bool -> Attribute variation msg
vary =
    Vary


{-| Set the spacing between children in a layout.
-}
spacing : Float -> Attribute variation msg
spacing x =
    Spacing x x


{-| Set the horizontal and vertical spacing separately.

This is generally only useful in a textLayout or a grid.

-}
spacingXY : Float -> Float -> Attribute variation msg
spacingXY =
    Spacing


{-| -}
padding : Float -> Attribute variation msg
padding x =
    Padding (Just x) (Just x) (Just x) (Just x)


{-| Set horizontal and vertical padding.
-}
paddingXY : Float -> Float -> Attribute variation msg
paddingXY x y =
    Padding (Just y) (Just x) (Just y) (Just x)


{-| -}
paddingLeft : Float -> Attribute variation msg
paddingLeft x =
    Padding Nothing Nothing Nothing (Just x)


{-| -}
paddingRight : Float -> Attribute variation msg
paddingRight x =
    Padding Nothing (Just x) Nothing Nothing


{-| -}
paddingTop : Float -> Attribute variation msg
paddingTop x =
    Padding (Just x) Nothing Nothing Nothing


{-| -}
paddingBottom : Float -> Attribute variation msg
paddingBottom x =
    Padding Nothing Nothing (Just x) Nothing


{-| Remove the element from the view.
-}
hidden : Attribute variation msg
hidden =
    Hidden


{-| Turn on scrollbars if content overflows.
-}
scrollbars : Attribute variation msg
scrollbars =
    Overflow AllAxis


{-| Turn on scrollbars if content overflows vertically.
-}
yScrollbar : Attribute variation msg
yScrollbar =
    Overflow YAxis


{-| Turn on scrollbars if content overflows horizontally.
-}
xScrollbar : Attribute variation msg
xScrollbar =
    Overflow XAxis


{-| Clip content that overflows.
-}
clip : Attribute variation msg
clip =
    Attr <| VirtualDom.style [ ( "overflow", "hidden" ) ]


{-| -}
clipX : Attribute variation msg
clipX =
    Attr <| VirtualDom.style [ ( "overflow-x", "hidden" ) ]


{-| -}
clipY : Attribute variation msg
clipY =
    Attr <| VirtualDom.style [ ( "overflow-y", "hidden" ) ]


{-| This function makes it easier to build a space-separated class attribute.
Each class can easily be added and removed depending on the boolean value it
is paired with. For example, maybe we want a way to view notices:

    viewNotice : Notice -> Html msg
    viewNotice notice =
        div
            [ classList
                [ ( "notice", True )
                , ( "notice-important", notice.isImportant )
                , ( "notice-seen", notice.isSeen )
                ]
            ]
            [ text notice.content ]

-}
classList : List ( String, Bool ) -> Attribute variation msg
classList =
    Attr << Html.Attributes.classList


{-| This is the manual override for to specify inline css properties.

    myStyle : Attribute msg
    myStyle =
        inlineStyle
            [ ( "backgroundColor", "red" )
            , ( "height", "90px" )
            , ( "width", "100%" )
            ]

    greeting : Html msg
    greeting =
        el [ myStyle ] (text "Hello!")

Use it if you need to, though it's obviously recommended to use the `Style` module instead.

-}
inlineStyle : List ( String, String ) -> Attribute variation msg
inlineStyle =
    Attr << VirtualDom.style



-- CUSTOM ATTRIBUTES


{-| Create _properties_, like saying `domNode.className = 'greeting'` in
JavaScript.

    import Json.Encode as Encode

    class : String -> Attribute variation msg
    class =
        Html.Attributes.class

Read more about the difference between properties and attributes [here].

[here]: https://github.com/elm-lang/html/blob/master/properties-vs-attributes.md

-}
property : String -> Json.Value -> Attribute variation msg
property str val =
    Attr <| Html.Attributes.property str val


{-| Create _attributes_, like saying `domNode.setAttribute('class', 'greeting')`
in JavaScript.

    class : String -> Attribute variation msg
    class =
        Html.Attributes.class

Read more about the difference between properties and attributes [here].

[here]: https://github.com/elm-lang/html/blob/master/properties-vs-attributes.md

-}
attribute : String -> String -> Attribute variation msg
attribute name val =
    Attr <| Html.Attributes.attribute name val


{-| Transform the messages produced by an `Attribute`.
-}
map : (a -> msg) -> Attribute variation a -> Attribute variation msg
map fn attr =
    case attr of
        Attr a ->
            Attr <| Html.Attributes.map fn a

        Vary x y ->
            Vary x y

        Height h ->
            Height h

        Width h ->
            Width h

        Inline ->
            Inline

        Hidden ->
            Hidden

        PositionFrame x ->
            PositionFrame x

        Opacity x ->
            Opacity x

        Expand ->
            Expand

        Padding w x y z ->
            Padding w x y z

        PhantomPadding x ->
            PhantomPadding x

        Margin x ->
            Margin x

        GridArea x ->
            GridArea x

        GridCoords x ->
            GridCoords x

        PointerEvents x ->
            PointerEvents x

        Event x ->
            Event <| Html.Attributes.map fn x

        InputEvent x ->
            InputEvent <| Html.Attributes.map fn x

        Position x y z ->
            Position x y z

        Spacing x y ->
            Spacing x y

        VAlign h ->
            VAlign h

        HAlign h ->
            HAlign h

        Shrink i ->
            Shrink i

        Overflow x ->
            Overflow x



-- GLOBAL ATTRIBUTES


{-| Often used with CSS to style elements with common properties.
-}
class : String -> Attribute variation msg
class cls =
    Attr <| Html.Attributes.class cls



-- {-| Indicates the relevance of an element.
-- -}
-- hidden : Bool -> Attribute variation msg
-- hidden hide =
--     Attr <| Html.Attributes.hidden hide


{-| Often used with CSS to style a specific element. The value of this
attribute must be unique.
-}
id : String -> Attribute variation msg
id str =
    Attr <| Html.Attributes.id str



-- LESS COMMON GLOBAL ATTRIBUTES


{-| Defines the language used in the element.
-}
language : String -> Attribute variation msg
language str =
    Attr <| Html.Attributes.lang str



-- LINKS AND AREAS
--  Not entirely sure these should be removed, but I'll remove them for now.
--
-- {-| Specify a URL to send a short POST request to when the user clicks on an
-- `a` or `area`. Useful for monitoring and tracking.
-- -}
-- ping : String -> Attribute variation msg
-- ping str =
--     Attr <| Html.Attributes.ping str
-- {-| Specifies the relationship of the target object to the link object.
-- For `a`, `area`, `link`.
-- -}
-- rel : String -> Attribute variation msg
-- rel str =
--     Attr <| Html.Attributes.rel str


{-| Convert an existing `Html.Attribute` to an `Element.Attribute`.

This is useful for working with any library that returns a `Html.Attribute`.

-}
toAttr : Html.Attribute msg -> Attribute variation msg
toAttr =
    Attr
