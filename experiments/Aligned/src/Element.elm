module Element
    exposing
        ( Attribute
        , Column
        , Element
        , Length
        , Table
        , above
        , alignBottom
        , alignLeft
        , alignRight
        , alignTop
        , behind
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
        , fillPortion
        , focus
        , grayscale
        , height
        , inFront
        , layout
        , layoutMode
        , link
        , mouseOver
        , moveDown
        , moveLeft
        , moveRight
        , moveUp
        , newTabLink
        , onLeft
        , onRight
        , padding
        , paddingEach
        , paddingXY
        , paragraph
        , pointer
        , px
        , row
        , shrink
        , spaceEvenly
        , spacing
        , spacingXY
        , table
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
import Internal.Model as Internal
import VirtualDom


type alias Element msg =
    Internal.Element msg


type alias Attribute msg =
    Internal.Attribute msg


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


{-| -}
fill : Length
fill =
    Internal.Fill 1


{-| -}
fillPortion : Int -> Length
fillPortion =
    Internal.Fill


{-| -}
layoutMode : Internal.RenderMode -> List (Attribute msg) -> Element msg -> Html msg
layoutMode mode attrs child =
    Internal.renderRoot mode
        (Background.color Color.blue
            :: Font.color Color.white
            :: Font.size 20
            :: Font.family
                [ Font.typeface "Open Sans"
                , Font.typeface "georgia"
                , Font.serif
                ]
            :: Internal.htmlClass "style-elements se el"
            :: attrs
        )
        child


layout : List (Attribute msg) -> Element msg -> Html msg
layout attrs child =
    Internal.renderRoot Internal.Layout
        (Background.color Color.blue
            :: Font.color Color.white
            :: Font.size 20
            :: Font.family
                [ Font.typeface "Open Sans"
                , Font.typeface "georgia"
                , Font.serif
                ]
            :: Internal.htmlClass "style-elements se el"
            :: Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
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
    Internal.Empty


{-| -}
text : String -> Element msg
text content =
    Internal.Text content


{-| -}
el : List (Attribute msg) -> Element msg -> Element msg
el attrs child =
    Internal.el
        Nothing
        (width shrink
            :: height shrink
            -- :: centerY
            :: center
            :: Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: attrs
        )
        child


{-| -}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    Internal.row
        (Internal.Class "x-content-align" "content-center-x"
            :: Internal.Class "y-content-align" "content-center-y"
            :: width fill
            :: attrs
        )
        (Internal.Unkeyed <| Internal.rowEdgeFillers children)


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Internal.column
        (Internal.Class "y-content-align" "content-top"
            :: Internal.Class "x-content-align" "content-center-x"
            :: height fill
            :: width fill
            :: attrs
        )
        (Internal.Unkeyed <| Internal.columnEdgeFillers children)


{-| Grid

    grid [ width fill, height fill ]
        [ cell [ width (fillPortion 1) ]
            (text "hello!")
        ,

        ]



    table []
        [

        ]


    -- Problem with standard is that we're iterating through a list y times
    -- where y == number of fields
    -- could use different data source, which means

    table [ ]
        [ text "First name" :: List.map (text << .firstName) persons
        , text "Last name" :: List.map (text << .lastName) persons
        ]



    --
    table []
        [ { value = .firstName
        , header = text "First Name"
        , cell = text
        }
        , { value = .lastName
        , header = text "Last Name"
        , cell = text
        }
        ]

-- grid []
-- { columns = [ px 100, px 100, px 100, px 100 ]
-- , rows =
-- [ px 100
-- , px 100
-- , px 100
-- , px 100
-- ][ px 100
--             , px 100
--             , px 100
--             , px 100
--             ]
-- , cells =
-- [ cell
-- { start = ( 0, 0 )
-- , width = 1
-- , height = 1
-- , content =
-- el Box [] (text "box")
-- }
-- , cell
-- { start = ( 1, 1 )
-- , width = 1
-- , height = 2
-- , content =
-- el Box [] (text "box")
-- }
-- ][ cell
--                 { start = ( 0, 0 )
--                 , width = 1
--                 , height = 1
--                 , content =
--                     el Box [] (text "box")
--                 }
--             , cell
--                 { start = ( 1, 1 )
--                 , width = 1
--                 , height = 2
--                 , content =
--                     el Box [] (text "box")
--                 }
--             ]
-- }

    table []
        { data = persons
        , columns =
            [ { value = .firstName
            , header = Just (text "First Name")
            , view = text
            }
            , { value = .lastName
            , header = Just (text "Last Name")
            , view = text
            }
            ]
        }

    table []
        { data = persons
        , columns =
            [ { header = text "First Name"
              , view =
                    text << .firstName
              }
            , { header = text "Last Name"
              , view =
                    text << .lastName
              }
            ]
        }

-}
type alias Table records msg =
    { data : List records
    , columns : List (Column records msg)
    }


type alias Column record msg =
    { header : Element msg
    , view : record -> Element msg
    }


{-| -}
table : List (Attribute msg) -> Table data msg -> Element msg
table attrs config =
    let
        ( sX, sY ) =
            Internal.getSpacing attrs ( 0, 0 )

        template =
            Internal.StyleClass <|
                Internal.GridTemplateStyle
                    { spacing = ( px sX, px sY )
                    , columns = List.repeat (List.length config.columns) Internal.Content
                    , rows = List.repeat (List.length config.data) Internal.Content
                    }

        onGrid row column el =
            Internal.gridEl Nothing
                [ Internal.StyleClass
                    (Internal.GridPosition
                        { row = row
                        , col = column
                        , width = 1
                        , height = 1
                        }
                    )
                ]
                [ el ]

        add cell column cursor =
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
                , row = 1
                , column = 1
                }
                config.data
    in
    Internal.element Internal.asGrid
        Nothing
        (Internal.htmlClass "se grid"
            :: width fill
            :: center
            :: template
            :: attrs
        )
        (Internal.Unkeyed
            children.elements
        )



{-

   grid []
       { data = persons
       , columns =
           [ { header = text "First Name"
             , view =
                   text << .firstName
             }
           , { header = text "Last Name"
             , view =
                   text << .lastName
             }
           ]
       }




-}


{-| -}
paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph attrs children =
    Internal.paragraph (Internal.htmlClass "se paragraph" :: width fill :: attrs) (Internal.Unkeyed children)


{-| -}
textPage : List (Attribute msg) -> List (Element msg) -> Element msg
textPage attrs children =
    Internal.textPage (width (px 650) :: attrs) (Internal.Unkeyed children)


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
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.rel "noopener noreferrer")
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
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.rel "noopener noreferrer")
            :: Internal.Attr (Html.Attributes.target "_blank")
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
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.download True)
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
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.downloadAs filename)
            :: width shrink
            :: height shrink
            :: centerY
            :: center
            :: attrs
        )
        label


{-| -}
description : String -> Attribute msg
description =
    Internal.Describe << Internal.Label


{-| -}
below : Internal.Element msg -> Attribute msg
below =
    Internal.Nearby Internal.Below


{-| -}
above : Internal.Element msg -> Attribute msg
above =
    Internal.Nearby Internal.Above


{-| -}
onRight : Internal.Element msg -> Attribute msg
onRight =
    Internal.Nearby Internal.OnRight


{-| -}
onLeft : Internal.Element msg -> Attribute msg
onLeft =
    Internal.Nearby Internal.OnLeft


{-| -}
inFront : Internal.Element msg -> Attribute msg
inFront =
    Internal.Nearby Internal.InFront


{-| -}
behind : Internal.Element msg -> Attribute msg
behind =
    Internal.Nearby Internal.Behind


{-| -}
width : Length -> Attribute msg
width =
    Internal.Width


{-| -}
height : Length -> Attribute msg
height =
    Internal.Height


{-| -}
moveUp : Float -> Attribute msg
moveUp y =
    Internal.Move Nothing (Just (negate y)) Nothing


{-| -}
moveDown : Float -> Attribute msg
moveDown y =
    Internal.Move Nothing (Just y) Nothing


{-| -}
moveRight : Float -> Attribute msg
moveRight x =
    Internal.Move (Just x) Nothing Nothing


{-| -}
moveLeft : Float -> Attribute msg
moveLeft x =
    Internal.Move (Just (negate x)) Nothing Nothing


{-| -}
rotate : Float -> Attribute msg
rotate angle =
    Internal.Rotate 0 0 1 angle


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


{-| -}
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
    Internal.Class "scrollbars" "scrollbars"


{-| -}
scrollbarY : Attribute msg
scrollbarY =
    Internal.Class "scrollbars" "scrollbars-x"


{-| -}
scrollbarX : Attribute msg
scrollbarX =
    Internal.Class "scrollbars" "scrollbars-y"


{-| -}
pointer : Attribute msg
pointer =
    Internal.Class "cursor" "cursor-pointer"



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


type alias Style =
    Internal.Attribute Never


{-| -}
mouseOver : List Style -> Attribute msg
mouseOver attrs =
    Internal.Pseudo "hover" (List.map (Internal.mapAttr never) attrs)


{-| -}
focus : List Style -> Attribute msg
focus attrs =
    Internal.Pseudo "focus" (List.map (Internal.mapAttr never) attrs)


{-| -}
blur : Float -> Attribute msg
blur x =
    Internal.Filter (Internal.Blur x)


{-| -}
grayscale : Float -> Attribute msg
grayscale x =
    Internal.Filter (Internal.Grayscale x)
