module Style
    exposing
        ( Style
        , Property
        , Font
        , Background
        , Position
        , Border
        , Repeat
        , Shadow
        , Transform
        , Filter
        , FlexBox
        , ColorElement
        , GradientDirection
        , GradientStep
        , hidden
        , invisible
        , opacity
        , block
        , blockSpaced
        , row
        , rowSpaced
        , column
        , columnSpaced
        , flowRight
        , flowDown
        , flowUp
        , flowLeft
        , style
        , variation
        , child
        , prop
        , cursor
        , font
        , background
        , shadows
        , position
        , border
        , palette
        , box
        , width
        , height
        , padding
        , margin
        , maxHeight
        , minHeight
        , maxWidth
        , minWidth
        , transforms
        , filters
        , px
        , percent
        , auto
        , all
        , left
        , right
        , top
        , bottom
        , topBottom
        , leftRight
        , leftRightAndTopBottom
        , leftRightTopBottom
        , allButTop
        , allButLeft
        , allButRight
        , allButBottom
        , hover
        , focus
        , after
        , before
        , pseudo
        )

{-|
# Welcome to the Style Elements Library!


@docs Style, Property

@docs style, variation, child

@docs prop

@docs cursor

@docs hidden, invisible, opacity

@docs palette, ColorElement

@docs position

@docs block, blockSpaced, row, rowSpaced, column, columnSpaced,  FlexBox, flowRight, flowDown, flowUp, flowLeft

@docs Border, border

@docs box, px, auto, percent, width, maxWidth, minWidth, height, maxHeight, minHeight, padding, margin

@docs Shadow, shadows

@docs Transform, transforms

@docs Filter, filters

@docs Font, font

@docs background, Background, Repeat, GradientDirection, GradientStep

@docs all, top, left, right, bottom, leftRight, leftRightAndTopBottom, leftRightTopBottom, allButTop, allButLeft, allButRight, allButBottom

@docs hover, focus, pseudo, after, before


-}

import Style.Internal.Model as Internal
import Style.Internal.Render.Value as Value
import Style.Internal.Batchable as Batchable exposing (Batchable)


{-| -}
type alias Style class variation animation =
    Batchable (Internal.Style class variation animation)


{-| -}
type alias Property class variation animation =
    Internal.Property class variation animation


{-| -}
type alias Length =
    Internal.Length


{-| -}
type alias FlexBox =
    Internal.FlexBoxElement


{-| -}
type alias Border =
    Internal.BorderElement


{-| -}
type alias Box =
    Internal.BoxElement


{-| -}
type alias Position =
    Internal.PositionElement


{-| -}
type alias Font =
    Internal.FontElement


{-| -}
type alias Background =
    Internal.BackgroundElement


{-| -}
type alias Repeat =
    Internal.Repeat


{-| -}
type alias Transform =
    Internal.Transformation


{-| -}
type alias ColorElement =
    Internal.ColorElement


{-| -}
type alias GradientDirection =
    Internal.GradientDirection


{-| -}
type alias GradientStep =
    Internal.GradientStep


{-| -}
style : class -> List (Property class variation animation) -> Style class variation animation
style cls props =
    Batchable.one (Internal.Style cls props)


{-| -}
variation : variation -> List (Property class Never animation) -> Property class variation animation
variation variation props =
    Internal.Variation variation props


{-| -}
child : class -> List (Property class variation animation) -> Property class variation animation
child class props =
    Internal.Child class props


{-| -}
importCss : String -> Style class variation animation
importCss css =
    Batchable.one <| Internal.Import css


{-| -}
importUrl : String -> Style class variation animation
importUrl url =
    Batchable.one <| Internal.Import <| "url('" ++ url ++ "')"


{-| -}
prop : String -> String -> Property class variation animation
prop =
    Internal.Exact


{-| -}
cursor : String -> Property class variation animation
cursor =
    Internal.Exact "cursor"


{-| -}
border : List Border -> Property class variation animation
border elems =
    Internal.Border (Internal.BorderElement "border-style" "solid" :: elems)


{-| -}
background : List Background -> Property class variation animation
background =
    Internal.Background


{-| -}
font : List Font -> Property class variation animation
font =
    Internal.Font


{-| -}
position : List Position -> Property class variation animation
position =
    Internal.Position


{-| -}
box : List Box -> Property class variation animation
box =
    Internal.Box


{-| -}
palette : List ColorElement -> Property class variation animation
palette =
    Internal.Palette


{-| -}
px : Float -> Length
px =
    Internal.Px


{-| -}
auto : Length
auto =
    Internal.Auto


{-| -}
percent : Float -> Length
percent =
    Internal.Percent


{-| -}
width : Length -> Box
width len =
    Internal.BoxProp "width" (Value.length len)


{-| -}
minWidth : Length -> Box
minWidth len =
    Internal.BoxProp "min-width" (Value.length len)


{-| -}
maxWidth : Length -> Box
maxWidth len =
    Internal.BoxProp "max-width" (Value.length len)


{-| -}
height : Length -> Box
height len =
    Internal.BoxProp "height" (Value.length len)


{-| -}
minHeight : Length -> Box
minHeight len =
    Internal.BoxProp "min-height" (Value.length len)


{-| -}
maxHeight : Length -> Box
maxHeight len =
    Internal.BoxProp "max-height" (Value.length len)


{-| -}
padding : ( Float, Float, Float, Float ) -> Box
padding pad =
    Internal.BoxProp "padding" (Value.box pad)


{-| Check out Layout.spacing, which sets the margin for all children elements.  Usually


-}
margin : ( Float, Float, Float, Float ) -> Box
margin pad =
    Internal.BoxProp "margin" (Value.box pad)


{-| Same as `display:none`.
-}
hidden : Property class variation animation
hidden =
    Internal.Visibility Internal.Hidden


{-| Same as `visibility: hidden`.

Meaning the element will be:
  * present in the flow
  * transparent
  * not respond to events

-}
invisible : Property class variation animation
invisible =
    Internal.Visibility Internal.Invisible


{-| A value between 0 and 1
-}
opacity : Float -> Property class variation animation
opacity x =
    Internal.Visibility <| Internal.Opacity <| (toFloat ((round (x * 1000)) % 1000)) / 1000



------------------------------
-- Layouts!
------------------------------


{-| This is the familiar block layout.

It's called `text` because this layout should generally only be used for doing text layouts.

__Note:__ It's the only layout that allows for child elements to use `Position.float` or `Position.inline`.

-}
block : Property class variation animation
block =
    Internal.Layout <|
        Internal.TextLayout { spacing = Nothing }


{-| Same as `Layout.text`, but sets margin on all children.

-}
blockSpaced : ( Float, Float, Float, Float ) -> Property class variation animation
blockSpaced space =
    Internal.Layout <|
        Internal.TextLayout { spacing = (Just space) }


{-| -}
row : Property class variation animation
row =
    Internal.Layout <|
        Internal.FlexLayout Internal.GoRight []


{-| -}
rowSpaced : ( Float, Float, Float, Float ) -> Property class variation animation
rowSpaced i =
    Internal.Layout <|
        Internal.FlexLayout Internal.GoRight
            [ Internal.Spacing i
            ]


{-| -}
column : Property class variation animation
column =
    Internal.Layout <|
        Internal.FlexLayout Internal.Down
            []


{-| -}
columnSpaced : ( Float, Float, Float, Float ) -> Property class variation animation
columnSpaced i =
    Internal.Layout <|
        Internal.FlexLayout Internal.Down
            [ Internal.Spacing i
            ]


{-| -}
flowRight : List FlexBox -> Property class variation animation
flowRight flexbox =
    Internal.FlexLayout Internal.GoRight flexbox
        |> Internal.Layout


{-| -}
flowLeft : List FlexBox -> Property class variation animation
flowLeft flexbox =
    Internal.FlexLayout Internal.GoLeft flexbox
        |> Internal.Layout


{-| -}
flowDown : List FlexBox -> Property class variation animation
flowDown flexbox =
    Internal.FlexLayout Internal.Down flexbox
        |> Internal.Layout


{-| -}
flowUp : List FlexBox -> Property class variation animation
flowUp flexbox =
    Internal.FlexLayout Internal.Up flexbox
        |> Internal.Layout



{-
   Shadows
-}


{-| -}
type alias Shadow =
    Internal.ShadowModel


{-| -}
shadows : List Shadow -> Property class variation animation
shadows =
    Internal.Shadows


{-| -}
transforms : List Transform -> Property class variation animation
transforms =
    Internal.Transform


{-| -}
type alias Filter =
    Internal.Filter


{-| -}
filters : List Filter -> Property class variation animation
filters =
    Internal.Filters



{- Box Constructors


-}


{-| -}
all : Float -> ( Float, Float, Float, Float )
all x =
    ( x, x, x, x )


{-| -}
left : Float -> ( Float, Float, Float, Float )
left x =
    ( 0, 0, 0, x )


{-| -}
right : Float -> ( Float, Float, Float, Float )
right x =
    ( 0, x, 0, 0 )


{-| -}
top : Float -> ( Float, Float, Float, Float )
top x =
    ( x, 0, 0, 0 )


{-| -}
bottom : Float -> ( Float, Float, Float, Float )
bottom x =
    ( 0, 0, x, 0 )


{-| -}
topBottom : Float -> ( Float, Float, Float, Float )
topBottom x =
    ( x, 0, x, 0 )


{-| -}
leftRight : Float -> ( Float, Float, Float, Float )
leftRight x =
    ( 0, x, 0, x )


{-| -}
leftRightAndTopBottom : Float -> Float -> ( Float, Float, Float, Float )
leftRightAndTopBottom x y =
    ( y, x, y, x )


{-| -}
leftRightTopBottom : Float -> Float -> Float -> Float -> ( Float, Float, Float, Float )
leftRightTopBottom l r t b =
    ( t, r, b, l )


{-| -}
allButRight : Float -> ( Float, Float, Float, Float )
allButRight x =
    ( x, 0, x, x )


{-| -}
allButLeft : Float -> ( Float, Float, Float, Float )
allButLeft x =
    ( x, x, x, 0 )


{-| -}
allButTop : Float -> ( Float, Float, Float, Float )
allButTop x =
    ( 0, x, x, x )


{-| -}
allButBottom : Float -> ( Float, Float, Float, Float )
allButBottom x =
    ( x, x, 0, x )


{-| -}
hover : List (Property class variation animation) -> Property class variation animation
hover =
    Internal.PseudoElement ":hover"


{-| -}
focus : List (Property class variation animation) -> Property class variation animation
focus =
    Internal.PseudoElement ":focus"


{-| -}
checked : List (Property class variation animation) -> Property class variation animation
checked =
    Internal.PseudoElement ":checked"


{-| -}
pseudo : String -> List (Property class variation animation) -> Property class variation animation
pseudo psu =
    Internal.PseudoElement (":" ++ psu)


{-| -}
after : String -> List (Property class variation animation) -> Property class variation animation
after content props =
    Internal.PseudoElement ":after" (prop "content" ("'" ++ content ++ "'") :: props)


{-| -}
before : String -> List (Property class variation animation) -> Property class variation animation
before content props =
    Internal.PseudoElement ":before" (prop "content" ("'" ++ content ++ "'") :: props)
