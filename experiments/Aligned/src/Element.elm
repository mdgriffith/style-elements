module Element
    exposing
        ( above
        , alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , below
        , blur
        , center
        , centerY
        , column
        , description
        , download
        , downloadAs
        , el
        , empty
        , fill
        , grayscale
        , height
        , layout
        , layoutMode
        , link
        , moveDown
        , moveLeft
        , moveRight
        , moveUp
        , newTabLink
        , onLeft
        , onRight
        , overlay
        , padding
        , paddingEach
        , paddingXY
        , paragraph
        , px
        , row
        , shrink
        , spaceEvenly
        , spacing
        , spacingXY
        , text
        , textPage
        , when
        , whenJust
        , width
        )

{-| -}

import Color
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes
import Internal.Model as Internal exposing (..)
import VirtualDom


{-| -}
px : Float -> Length
px =
    Px


{-| -}
shrink : Length
shrink =
    Content


{-| -}
fill : Length
fill =
    Fill 1


{-| -}
layoutMode : RenderMode -> List (Attribute msg) -> Element msg -> Html msg
layoutMode mode attrs child =
    renderRoot mode
        (Background.color Color.blue
            :: Font.color Color.white
            :: Font.size 20
            :: Font.family
                [ Font.typeface "Open Sans"
                , Font.typeface "georgia"
                , Font.serif
                ]
            :: htmlClass "style-elements se el"
            :: attrs
        )
        child


layout : List (Attribute msg) -> Element msg -> Html msg
layout attrs child =
    renderRoot Layout
        (Background.color Color.blue
            :: Font.color Color.white
            :: Font.size 20
            :: Font.family
                [ Font.typeface "Open Sans"
                , Font.typeface "georgia"
                , Font.serif
                ]
            :: htmlClass "style-elements se el"
            :: attrs
        )
        child


{-| A helper function. This:

    when (x == 5) (text "yay, it's 5")

is sugar for

    if (x == 5) then
        text "yay, it's 5"
    else
        empty

-}
when : Bool -> Element msg -> Element msg
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
whenJust : Maybe a -> (a -> Element msg) -> Element msg
whenJust maybe view =
    case maybe of
        Nothing ->
            empty

        Just thing ->
            view thing


{-| -}
empty : Element msg
empty =
    Empty


{-| -}
text : String -> Element msg
text content =
    Text content


{-| -}
el : List (Attribute msg) -> Element msg -> Element msg
el attrs child =
    Internal.el
        Nothing
        (width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        child


{-| -}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    Internal.row
        (--Class "y-content-align" "content-top"
         Class "x-content-align" "content-center-x"
            -- :: Attributes.spacing 20
            :: width fill
            :: attrs
        )
        (rowEdgeFillers children)


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Internal.column
        (Class "y-content-align" "content-top"
            -- :: Attributes.spacing 20
            :: height fill
            :: width fill
            :: attrs
        )
        children


{-| -}
paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph attrs children =
    Internal.paragraph (htmlClass "se paragraph" :: width fill :: attrs) children


{-| -}
textPage : List (Attribute msg) -> List (Element msg) -> Element msg
textPage attrs children =
    Internal.textPage (width (px 650) :: attrs) children


{-| For images, both a source and a description are required. The description will serve as the alt-text.
-}
image : List (Attribute msg) -> { src : String, description : String } -> Element msg
image attrs { src, description } =
    Internal.el
        Nothing
        attrs
        (Internal.unstyled <|
            VirtualDom.node "img"
                [ Html.Attributes.src src
                , Html.Attributes.alt description
                ]
                []
        )


{-| If an image is purely decorative, you can skip the caption.
-}
decorativeImage : List (Attribute msg) -> { src : String } -> Element msg
decorativeImage attrs { src } =
    Internal.el
        Nothing
        attrs
        (Internal.unstyled <|
            VirtualDom.node "img"
                [ Html.Attributes.src src
                , Html.Attributes.alt ""
                ]
                []
        )


{-|

    link []
        { url = "google.com"
        , label = text "My Link to Google"
        }

-}
link : List (Attribute msg) -> { url : String, label : Element msg } -> Element msg
link attrs { url, label } =
    Internal.el
        (Just "a")
        (Attr (Html.Attributes.href url)
            :: Attr (Html.Attributes.rel "noopener noreferrer")
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        label


{-| -}
newTabLink : List (Attribute msg) -> { url : String, label : Element msg } -> Element msg
newTabLink attrs { url, label } =
    Internal.el
        (Just "a")
        (Attr (Html.Attributes.href url)
            :: Attr (Html.Attributes.rel "noopener noreferrer")
            :: Attr (Html.Attributes.target "_blank")
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        label


{-|

    download []
        { url = "mydownload.pdf"
        , label = text "Download this"
        }

-}
download : List (Attribute msg) -> { url : String, label : Element msg } -> Element msg
download attrs { url, label } =
    Internal.el
        (Just "a")
        (Attr (Html.Attributes.href url)
            :: Attr (Html.Attributes.download True)
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        label


{-|

     downloadAs []
        { url = "mydownload.pdf"
        , filename "your-thing.pdf"
        , label = text "Download this"
        }

-}
downloadAs : List (Attribute msg) -> { label : Element msg, filename : String, url : String } -> Element msg
downloadAs attrs { url, filename, label } =
    Internal.el
        (Just "a")
        (Attr (Html.Attributes.href url)
            :: Attr (Html.Attributes.downloadAs filename)
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        label


description : String -> Attribute msg
description =
    Describe << Label


{-| -}
below : Internal.Element msg -> Attribute msg
below =
    Nearby Below


{-| -}
above : Internal.Element msg -> Attribute msg
above =
    Nearby Above


{-| -}
onRight : Internal.Element msg -> Attribute msg
onRight =
    Nearby OnRight


{-| -}
onLeft : Internal.Element msg -> Attribute msg
onLeft =
    Nearby OnLeft


{-| -}
overlay : Internal.Element msg -> Attribute msg
overlay =
    Nearby Overlay


{-| -}
width : Length -> Attribute msg
width =
    Width



-- case len of
--     Px px ->
--         StyleClass (Single ("width-px-" ++ Internal.floatClass px) "width" (toString px ++ "px"))
--     Content ->
--         Class "width" "width-content"
--     Fill portion ->
--         -- TODO: account for fill /= 1
--         Class "width" "width-fill"


{-| -}
height : Length -> Attribute msg
height =
    Height



-- case len of
--     Px px ->
--         StyleClass (Single ("height-px-" ++ Internal.floatClass px) "height" (toString px ++ "px"))
--     Content ->
--         Class "height" "height-content"
--     Fill portion ->
--         -- TODO: account for fill /= 1
--         Class "height" "height-fill"


{-| -}
moveUp : Float -> Attribute msg
moveUp y =
    Move Nothing (Just (negate y)) Nothing


{-| -}
moveDown : Float -> Attribute msg
moveDown y =
    Move Nothing (Just y) Nothing


{-| -}
moveRight : Float -> Attribute msg
moveRight x =
    Move (Just x) Nothing Nothing


{-| -}
moveLeft : Float -> Attribute msg
moveLeft x =
    Move (Just (negate x)) Nothing Nothing


{-| -}
rotate : Float -> Attribute msg
rotate angle =
    Rotate 0 0 1 angle


{-| -}
padding : Int -> Attribute msg
padding x =
    StyleClass (PaddingStyle x x x x)


{-| Set horizontal and vertical padding.
-}
paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    StyleClass (PaddingStyle y x y x)


{-| -}
paddingEach : { bottom : Int, left : Int, right : Int, top : Int } -> Attribute msg
paddingEach { top, right, bottom, left } =
    StyleClass (PaddingStyle top right bottom left)


{-| -}
center : Attribute msg
center =
    AlignX CenterX


{-| -}
centerY : Attribute msg
centerY =
    AlignY CenterY


{-| -}
alignTop : Attribute msg
alignTop =
    AlignY Top


{-| -}
alignBottom : Attribute msg
alignBottom =
    AlignY Bottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    AlignX Left


{-| -}
alignRight : Attribute msg
alignRight =
    AlignX Right


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    Class "x-align" "space-evenly"


{-| -}
spacing : Int -> Attribute msg
spacing x =
    StyleClass (SpacingStyle x x)


{-| -}
spacingXY : Int -> Int -> Attribute msg
spacingXY x y =
    StyleClass (SpacingStyle x y)


{-| -}
hidden : Bool -> Attribute msg
hidden on =
    if on then
        Internal.class "hidden"
    else
        NoAttribute



-- type alias Cursor =
--     { color
--     }
-- {-| -}
-- cursor : Color -> Attribute msg
-- cursor clr =
--     StyleClass (Colored ("cursor-color-" ++ formatColorClass clr) "cursor-color" clr)
-- {-| If we have this construct, it makes it easier to change states for something like a button.
--     el
--         [ Color.background blue
--         , onClick Send
--         , mixIf model.disabled
--             [ Color.background grey
--             , onClick NoOp
--             ]
--         ]
-- Does it allow elimination of event handlers? Would have to rely on html behavior for that if it's true.
-- People could implement systems that involve multiple properties being set together.
-- Example of a disabled button
--     Input.button
--         [ Color.background
--             ( if disabled then
--                 grey
--              else
--                 blue
--             )
--         , Color.border
--             ( if disabled then
--                 grey
--              else
--                 blue
--             )
--         ]
--         { onPress = switch model.disabled Send
--         , label = text "Press me"
--         }
-- Advantages: no new constructs(!)
-- Disadvantages: could get verbose in the case of many properties set.
--   - How many properties would likely vary in this way?
--   - Would a `Color.palette {text, background, border}` go help?
--     Input.button
--     [ Color.palette
--     ( if disabled then
--     { background = grey
--     , text = darkGrey
--     , border = grey
--     }
--     else
--     { background = blue
--     , text = black
--     , border = blue
--     }
--     )
--     ]
--     { onPress = switch model.disabled Send
--     , label = text "Press me"
--     }
-- -- with mixIf
--     Input.button
--         [ Color.background blue
--         , mixIf model.disabled
--             [ Color.background grey
--             ]
--         ]
--         { onPress = (if model.disabled then Nothing else Just Send )
--         , label = text "Press me"
--         }
-- Advantages:
--   - Any properties can be set together.
--   - Would allow `above`/`below` type elements to be triggered manually.
-- Disadvantages:
--   - Does binding certain properties together lead to a good experience?
-- -}
-- mixIf : Bool -> List (Attribute msg) -> List (Attribute msg)
-- mixIf on attrs =
--     if on then
--         attrs
--     else
--         []
-- {-| For the hover pseudoclass, the considerations:
-- 1.  What happens on mobile/touch devices?
--       - Let the platform handle it
-- 2.  We can make the hover event show a 'nearby', like 'below' or something.
--       - what happens on mobile? Do first clicks now perform that action?
-- -}
-- hover : List (Attribute msg) -> Attribute msg
-- hover x =
--     hidden True
-- {-| -}
-- focus : List (Attribute msg) -> Attribute msg
-- focus x =
--     hidden True


{-| -}
blur : Float -> Attribute msg
blur x =
    Filter (Blur x)


{-| -}
grayscale : Float -> Attribute msg
grayscale x =
    Filter (Grayscale x)
