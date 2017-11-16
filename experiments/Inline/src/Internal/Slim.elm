module Next.Internal.Slim exposing (..)

{-| Implement style elements using as few calls as possible
-}

import Color exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Json.Encode as Json
import Next.Internal.Style
import Set exposing (Set)
import VirtualDom


floatClass : Float -> String
floatClass x =
    toString <| round (x * 100)


formatColor : Color -> String
formatColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    ("rgba(" ++ toString red)
        ++ ("," ++ toString green)
        ++ ("," ++ toString blue)
        ++ ("," ++ toString alpha ++ ")")


formatColorClass : Color -> String
formatColorClass color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
    toString red
        ++ "-"
        ++ toString green
        ++ "-"
        ++ toString blue
        ++ "-"
        ++ floatClass alpha


{-| -}
backgroundColor : Color -> Attribute msg
backgroundColor clr =
    StyleClass <| Colored ("bg-" ++ formatColorClass clr) "background-color" clr


{-| -}
textColor : Color -> Attribute msg
textColor clr =
    StyleClass <| Colored ("text-color-" ++ formatColorClass clr) "color" clr


{-| -}
borderColor : Color -> Attribute msg
borderColor clr =
    StyleClass <| Colored ("border-color-" ++ formatColorClass clr) "border-color" clr


{-| Font size as `px`
-}
fontSize : Float -> Attribute msg
fontSize size =
    StyleClass <| Single ("font-size-" ++ floatClass size) "font-size" (toString size ++ "px")


{-| -}
border : Int -> Attribute msg
border v =
    StyleClass <| Single ("border-" ++ toString v) "border-width" (toString v ++ "px")


{-| -}
layout : List (Attribute msg) -> Element msg -> Html msg
layout attrs child =
    let
        ( styles, html ) =
            case child of
                Unstyled html ->
                    ( [], html )

                Styled styles html ->
                    ( styles, html )
    in
    VirtualDom.node "div"
        [ VirtualDom.property "className" (Json.string "style-elements") ]
        [ VirtualDom.node "style" [] [ Html.text Next.Internal.Style.rules ]
        , toStyleSheet styles
        , html
        ]


type Element msg
    = Styled (List Style) (Html msg)
    | Unstyled (Html msg)


type Style
    = Style String (List Property)
      -- | Keyed String (List ( String, List Property ))
      --       class  prop   val
    | Single String String String
    | Colored String String Color
    | SpacingStyle Int Int
    | PaddingStyle Int Int Int Int


type Property
    = Property String String


type Attribute msg
    = Attr (Html.Attribute msg)
      -- invalidation key and literal class
    | Class String String
    | KeyedStyleClass String Style
    | StyleClass Style
      -- | SingletonStyle String String String
      -- | SingletonColor String String Color
      -- | Height Length
      -- | Width Length
      -- | SpacingXY Int Int
    | Move (Maybe Float) (Maybe Float) (Maybe Float)
    | Rotate Float Float Float Float
    | Scale (Maybe Float) (Maybe Float) (Maybe Float)
      -- | Padding
      --     { top : Float
      --     , left : Float
      --     , bottom : Float
      --     , right : Float
      --     }
      -- | Overflow Axis
    | TextShadow
        { offset : ( Float, Float )
        , blur : Float
        , color : Color
        }
    | BoxShadow
        { inset : Bool
        , offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }
    | Filter FilterType


type FilterType
    = FilterUrl String
    | Blur Float
    | Brightness Float
    | Contrast Float
    | Grayscale Float
    | HueRotate Float
    | Invert Float
    | OpacityFilter Float
    | Saturate Float
    | Sepia Float
    | DropShadow
        { offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        }


type Length
    = Px Float
    | Content
    | Expand
    | Fill Float


type HorizontalAlign
    = AlignLeft
    | AlignRight
    | XCenter
    | Spread


type VerticalAlign
    = AlignTop
    | AlignBottom
    | YCenter
    | VerticalJustify


type Axis
    = XAxis
    | YAxis
    | AllAxis


class =
    Attr << Html.Attributes.class


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy fn a =
    case fn a of
        Unstyled _ ->
            Unstyled
                (VirtualDom.lazy (asHtml << fn) a)

        Styled styles _ ->
            Styled styles
                (VirtualDom.lazy (asHtml << fn) a)


{-| -}
lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
lazy2 fn a b =
    Unstyled
        (VirtualDom.lazy2 (\x y -> asHtml <| fn x y) a b)


{-| -}
lazy3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Element msg
lazy3 fn a b c =
    Unstyled
        (VirtualDom.lazy3 (\x y z -> asHtml <| fn x y z) a b c)


{-| -}
asHtml : Element msg -> Html msg
asHtml child =
    case child of
        Unstyled html ->
            html

        Styled styles html ->
            html


{-| -}
embed : Element msg -> Html msg
embed child =
    let
        ( styles, html ) =
            case child of
                Unstyled html ->
                    ( [], html )

                Styled styles html ->
                    ( styles, html )
    in
    VirtualDom.node "div"
        []
        [ toStyleSheet styles
        , html
        ]


empty : Element msg
empty =
    Unstyled (VirtualDom.text "")


text : String -> Element msg
text content =
    Unstyled <|
        VirtualDom.node "div"
            [ VirtualDom.property "className" (Json.string "se text width-fill") ]
            [ VirtualDom.text content ]


el : List (Attribute msg) -> Element msg -> Element msg
el attributes child =
    let
        ( children, childrenStyles ) =
            case child of
                Unstyled html ->
                    ( html, [] )

                Styled styles children ->
                    ( children, styles )

        ( renderedAttributes, renderedRules ) =
            case attributes of
                [] ->
                    ( [ VirtualDom.property "className" (Json.string "se el") ]
                    , childrenStyles
                    )

                attrs ->
                    List.foldr gatherAttributes { initGathered | rules = childrenStyles } attrs
                        |> (\{ rules, attributes } ->
                                ( VirtualDom.property "className" (Json.string "se el") :: attributes
                                , rules
                                )
                           )
    in
    Styled renderedRules
        (VirtualDom.node "div"
            renderedAttributes
            [ children ]
        )


row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    let
        rendered =
            List.foldr gatherAttributes initGathered attrs

        ( htmlChildren, styleChildren ) =
            List.foldr gather ( [], rendered.rules ) children

        gather child ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    ( html :: htmls, existingStyles )

                Styled styles html ->
                    ( html :: htmls, styles ++ existingStyles )

        -- |> formatTransformations
    in
    Styled styleChildren
        (VirtualDom.node "div"
            (VirtualDom.property "className" (Json.string "se el") :: rendered.attributes)
            htmlChildren
        )


gatherAttributes : Attribute msg -> Gathered msg -> Gathered msg
gatherAttributes attr gathered =
    case attr of
        SingletonStyle class name val ->
            { gathered
                | attributes = VirtualDom.property "className" (Json.string class) :: gathered.attributes
                , rules =
                    Single ("." ++ class) name val
                        :: gathered.rules
            }

        SingletonColor class name val ->
            { gathered
                | attributes = VirtualDom.property "className" (Json.string class) :: gathered.attributes
                , rules =
                    Colored ("." ++ class) name val
                        :: gathered.rules
            }

        Attr attr ->
            { gathered | attributes = attr :: gathered.attributes }



-- Height len ->
--     if gathered.hasHeight then
--         gathered
--     else
--         case len of
--             Px px ->
--                 let
--                     class =
--                         "height-px-" ++ floatClass px
--                 in
--                 { gathered
--                     | attributes = Html.Attributes.class class :: gathered.attributes
--                     , hasHeight = True
--                     , rules =
--                         Keyed class
--                             [ pair ("." ++ class) [ Property "height" (toString px ++ "px") ]
--                             ]
--                             :: gathered.rules
--                 }
--             Content ->
--                 { gathered
--                     | styleProperties = Property "height" "auto" :: gathered.styleProperties
--                     , hasHeight = True
--                 }
--             Expand ->
--                 { gathered
--                     | attributes = Html.Attributes.class "expand-height" :: gathered.attributes
--                     , hasHeight = True
--                 }
--             Fill portion ->
--                 { gathered
--                     | attributes = Html.Attributes.class "height-fill" :: gathered.attributes
--                     , hasHeight = True
--                 }
-- Width len ->
--     if gathered.hasWidth then
--         gathered
--     else
--         case len of
--             Px px ->
--                 -- add width: Xpx to current style
--                 let
--                     class =
--                         "width-px-" ++ floatClass px
--                 in
--                 { gathered
--                     | attributes = Html.Attributes.class class :: gathered.attributes
--                     , hasWidth = True
--                     , rules =
--                         Keyed class
--                             [ pair ("." ++ class) [ Property "width" (toString px ++ "px") ]
--                             ]
--                             :: gathered.rules
--                 }
--             Content ->
--                 { gathered
--                     | attributes = Html.Attributes.class "width-content" :: gathered.attributes
--                     , hasWidth = True
--                 }
--             Expand ->
--                 { gathered
--                     | attributes = Html.Attributes.class "expand-width" :: gathered.attributes
--                     , hasWidth = True
--                 }
--             Fill portion ->
--                 { gathered
--                     | attributes = Html.Attributes.class "width-fill" :: gathered.attributes
--                     , hasWidth = True
--                 }
-- ContentXAlign alignment ->
--     if gathered.hasXContentAlign then
--         gathered
--     else
--         case alignment of
--             AlignLeft ->
--                 { gathered
--                     | attributes = Html.Attributes.class "content-left" :: gathered.attributes
--                     , hasXContentAlign = True
--                 }
--             AlignRight ->
--                 { gathered
--                     | attributes =
--                         Html.Attributes.class "content-right" :: gathered.attributes
--                     , hasXContentAlign = True
--                 }
--             XCenter ->
--                 { gathered
--                     | attributes = Html.Attributes.class "content-center-x" :: gathered.attributes
--                     , hasXContentAlign = True
--                 }
--             Spread ->
--                 { gathered
--                     | attributes = Html.Attributes.class "spread" :: gathered.attributes
--                     , hasXContentAlign = True
--                 }
-- ContentYAlign alignment ->
--     if gathered.hasYContentAlign then
--         gathered
--     else
--         case alignment of
--             AlignTop ->
--                 { gathered
--                     | attributes = Html.Attributes.class "content-top" :: gathered.attributes
--                     , hasYContentAlign = True
--                 }
--             AlignBottom ->
--                 { gathered
--                     | attributes = Html.Attributes.class "content-bottom" :: gathered.attributes
--                     , hasYContentAlign = True
--                 }
--             YCenter ->
--                 { gathered
--                     | attributes = Html.Attributes.class "content-center-y" :: gathered.attributes
--                     , hasYContentAlign = True
--                 }
--             VerticalJustify ->
--                 { gathered
--                     | attributes = Html.Attributes.class "vertical-justify" :: gathered.attributes
--                     , hasYContentAlign = True
--                 }
-- SelfXAlign alignment ->
--     if gathered.hasXSelfAlign then
--         gathered
--     else
--         case alignment of
--             AlignLeft ->
--                 { gathered
--                     | attributes = Html.Attributes.class "self-left" :: gathered.attributes
--                     , hasXSelfAlign = True
--                 }
--             AlignRight ->
--                 { gathered
--                     | attributes = Html.Attributes.class "self-right" :: gathered.attributes
--                     , hasXSelfAlign = True
--                 }
--             XCenter ->
--                 { gathered
--                     | attributes = Html.Attributes.class "self-center-x" :: gathered.attributes
--                     , hasXSelfAlign = True
--                 }
--             Spread ->
--                 { gathered
--                     | attributes = Html.Attributes.class "spread" :: gathered.attributes
--                     , hasXSelfAlign = True
--                 }
-- SelfYAlign alignment ->
--     if gathered.hasYSelfAlign then
--         gathered
--     else
--         case alignment of
--             AlignTop ->
--                 { gathered
--                     | attributes = Html.Attributes.class "self-top" :: gathered.attributes
--                     , hasYSelfAlign = True
--                 }
--             AlignBottom ->
--                 { gathered
--                     | attributes = Html.Attributes.class "self-bottom" :: gathered.attributes
--                     , hasYSelfAlign = True
--                 }
--             YCenter ->
--                 { gathered
--                     | attributes = Html.Attributes.class "self-center-y" :: gathered.attributes
--                     , hasYSelfAlign = True
--                 }
--             VerticalJustify ->
--                 { gathered
--                     | attributes = Html.Attributes.class "vertical-justify" :: gathered.attributes
--                     , hasYSelfAlign = True
--                 }
-- Move mx my mz ->
--     -- add translate to the transform stack
--     let
--         addIfNothing val existing =
--             case existing of
--                 Nothing ->
--                     val
--                 x ->
--                     x
--         translate =
--             case gathered.translation of
--                 Nothing ->
--                     Just
--                         ( mx, my, mz )
--                 Just ( existingX, existingY, existingZ ) ->
--                     Just
--                         ( addIfNothing mx existingX
--                         , addIfNothing my existingY
--                         , addIfNothing mz existingZ
--                         )
--     in
--     { gathered | translation = translate }
-- Filter filter ->
--     case gathered.filters of
--         Nothing ->
--             { gathered | filters = Just (filterName filter) }
--         Just existing ->
--             { gathered | filters = Just (filterName filter ++ " " ++ existing) }
-- BoxShadow shadow ->
--     case gathered.boxShadows of
--         Nothing ->
--             { gathered | boxShadows = Just (formatBoxShadow shadow) }
--         Just existing ->
--             { gathered | boxShadows = Just (formatBoxShadow shadow ++ ", " ++ existing) }
-- TextShadow shadow ->
--     case gathered.textShadows of
--         Nothing ->
--             { gathered | textShadows = Just (formatTextShadow shadow) }
--         Just existing ->
--             { gathered | textShadows = Just (formatTextShadow shadow ++ ", " ++ existing) }
-- Rotate x y z angle ->
--     { gathered
--         | rotation =
--             Just
--                 ("rotate3d(" ++ toString x ++ "," ++ toString y ++ "," ++ toString z ++ "," ++ toString angle ++ "rad)")
--     }
-- Scale mx my mz ->
--     -- add scale to the transform stack
--     let
--         addIfNothing val existing =
--             case existing of
--                 Nothing ->
--                     val
--                 x ->
--                     x
--         scale =
--             case gathered.scale of
--                 Nothing ->
--                     Just
--                         ( mx
--                         , my
--                         , mz
--                         )
--                 Just ( existingX, existingY, existingZ ) ->
--                     Just
--                         ( addIfNothing mx existingX
--                         , addIfNothing my existingY
--                         , addIfNothing mz existingZ
--                         )
--     in
--     { gathered | scale = scale }
-- Opacity o ->
--     -- add opacity to style
--     { gathered
--         | styleProperties = Property "opacity" (toString o) :: gathered.styleProperties
--     }
-- Spacing spacing ->
--     if gathered.hasSpacing then
--         gathered
--     else
--         -- Add a new style > .children
--         let
--             name =
--                 "spacing-" ++ toString spacing
--             spaceCls =
--                 "." ++ name
--         in
--         { gathered
--             | rules =
--                 Keyed name
--                     [ pair (spaceCls ++ ".row > .se") [ Property "margin-left" (toString spacing ++ "px") ]
--                     , pair (spaceCls ++ ".row > .se:first-child") [ Property "margin-left" "0" ]
--                     , pair (spaceCls ++ ".column > .se") [ Property "margin-top" (toString spacing ++ "px") ]
--                     , pair (spaceCls ++ ".column > .se:first-child") [ Property "margin-top" "0" ]
--                     , pair (spaceCls ++ ".page > .se") [ Property "margin-top" (toString spacing ++ "px") ]
--                     , pair (spaceCls ++ ".page > .se:first-child") [ Property "margin-top" "0" ]
--                     , pair (spaceCls ++ ".page > .self-left") [ Property "margin-right" (toString spacing ++ "px") ]
--                     , pair (spaceCls ++ ".page > .self-right") [ Property "margin-left" (toString spacing ++ "px") ]
--                     , pair (spaceCls ++ ".grid")
--                         [ Property "grid-column-gap" (toString spacing ++ "px")
--                         , Property "grid-row-gap" (toString spacing ++ "px")
--                         ]
--                     ]
--                     :: gathered.rules
--             , attributes = Html.Attributes.class name :: gathered.attributes
--             , hasSpacing = True
--         }
-- SpacingXY x y ->
--     if gathered.hasSpacing then
--         gathered
--     else
--         let
--             name =
--                 "spacing-xy-" ++ toString x ++ "-" ++ toString y
--             spaceCls =
--                 "." ++ name
--         in
--         { gathered
--             | rules =
--                 Keyed name
--                     [ pair (spaceCls ++ ".row > .se") [ Property "margin-left" (toString x ++ "px") ]
--                     , pair (spaceCls ++ ".row > .se:first-child") [ Property "margin-left" "0" ]
--                     , pair (spaceCls ++ ".column > .se") [ Property "margin-top" (toString y ++ "px") ]
--                     , pair (spaceCls ++ ".column > .se:first-child") [ Property "margin-top" "0" ]
--                     , pair (spaceCls ++ ".page > .se") [ Property "margin-top" (toString y ++ "px") ]
--                     , pair (spaceCls ++ ".page > .se:first-child") [ Property "margin-top" "0" ]
--                     , pair (spaceCls ++ ".page > .self-left") [ Property "margin-right" (toString x ++ "px") ]
--                     , pair (spaceCls ++ ".page > .self-right") [ Property "margin-left" (toString x ++ "px") ]
--                     , pair (spaceCls ++ ".grid")
--                         [ Property "grid-column-gap" (toString x ++ "px")
--                         , Property "grid-row-gap" (toString y ++ "px")
--                         ]
--                     ]
--                     :: gathered.rules
--             , attributes = Html.Attributes.class name :: gathered.attributes
--             , hasSpacing = True
--         }
-- Padding padding ->
--     let
--         padCls =
--             "pad-"
--                 ++ toString padding.top
--                 ++ "-"
--                 ++ toString padding.right
--                 ++ "-"
--                 ++ toString padding.bottom
--                 ++ "-"
--                 ++ toString padding.left
--         name =
--             "." ++ padCls
--         expanded =
--             Keyed
--                 name
--                 [ pair name
--                     [ Property "padding"
--                         (toString padding.top
--                             ++ "px "
--                             ++ toString padding.right
--                             ++ "px "
--                             ++ toString padding.bottom
--                             ++ "px "
--                             ++ toString padding.left
--                             ++ "px"
--                         )
--                     ]
--                 , pair (name ++ ".el > .se.expand-width")
--                     [ Property "width" ("calc(100% + " ++ toString (padding.left + padding.right) ++ "px)")
--                     , Property "margin-left" (toString (negate padding.left) ++ "px")
--                     ]
--                 , pair (name ++ ".column > .se.expand-width")
--                     [ Property "width" ("calc(100% + " ++ toString (padding.left + padding.right) ++ "px)")
--                     , Property "margin-left" (toString (negate padding.left) ++ "px")
--                     ]
--                 , pair (name ++ ".row > .se.expand-width:first-child")
--                     [ Property "width" ("calc(100% + " ++ toString padding.left ++ "px)")
--                     , Property "margin-left" (toString (negate padding.left) ++ "px")
--                     ]
--                 , pair (name ++ ".row > .se.expand-width:last-child")
--                     [ Property "width" ("calc(100% + " ++ toString padding.right ++ "px)")
--                     , Property "margin-right" (toString (negate padding.right) ++ "px")
--                     ]
--                 , pair (name ++ ".row.has-nearby > .se.expand-width::nth-last-child(2)")
--                     [ Property "width" ("calc(100% + " ++ toString padding.right ++ "px)")
--                     , Property "margin-right" (toString (negate padding.right) ++ "px")
--                     ]
--                 , pair (name ++ ".page > .se.expand-width:first-child")
--                     [ Property "width" ("calc(100% + " ++ toString (padding.left + padding.right) ++ "px)")
--                     , Property "margin-left" (toString (negate padding.left) ++ "px")
--                     ]
--                 , pair (name ++ ".el > .se.expand-height")
--                     [ Property "height" ("calc(100% + " ++ toString (padding.top + padding.bottom) ++ "px)")
--                     , Property "margin-top" (toString (negate padding.top) ++ "px")
--                     ]
--                 , pair (name ++ ".row > .se.expand-height")
--                     [ Property "height" ("calc(100% + " ++ toString (padding.top + padding.bottom) ++ "px)")
--                     , Property "margin-top" (toString (negate padding.top) ++ "px")
--                     ]
--                 , pair (name ++ ".column > .se.expand-height:first-child")
--                     [ Property "height" ("calc(100% + " ++ toString padding.top ++ "px)")
--                     , Property "margin-top" (toString (negate padding.top) ++ "px")
--                     ]
--                 , pair (name ++ ".column > .se.expand-height:last-child")
--                     [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
--                     , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
--                     ]
--                 , pair (name ++ ".column.has-nearby > .se.expand-height::nth-last-child(2)")
--                     [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
--                     , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
--                     ]
--                 , pair (name ++ ".page > .se.expand-height:first-child")
--                     [ Property "height" ("calc(100% + " ++ toString padding.top ++ "px)")
--                     , Property "margin-top" (toString (negate padding.top) ++ "px")
--                     ]
--                 , pair (name ++ ".page > .se.expand-height:last-child")
--                     [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
--                     , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
--                     ]
--                 , pair (name ++ ".page > .se.expand-height::nth-last-child(2)")
--                     [ Property "height" ("calc(100% + " ++ toString padding.bottom ++ "px)")
--                     , Property "margin-bottom" (toString (negate padding.bottom) ++ "px")
--                     ]
--                 ]
--     in
--     { gathered
--         | attributes = Html.Attributes.class padCls :: gathered.attributes
--         , hasPadding = True
--         , rules = expanded :: gathered.rules
--     }
-- Overflow overflow ->
--     case overflow of
--         XAxis ->
--             { gathered
--                 | styleProperties = Property "overflow-x" "auto" :: gathered.styleProperties
--             }
--         YAxis ->
--             { gathered
--                 | styleProperties = Property "overflow-y" "auto" :: gathered.styleProperties
--             }
--         AllAxis ->
--             { gathered
--                 | styleProperties = Property "overflow" "auto" :: gathered.styleProperties
--             }
-- Attr attr ->
--     -- add to current attributes
--     { gathered | attributes = attr :: gathered.attributes }


type alias Gathered msg =
    { attributes : List (Html.Attribute msg)
    , styleProperties : List Property
    , rules : List Style
    , filters : Maybe String
    , boxShadows : Maybe String
    , textShadows : Maybe String
    , rotation : Maybe String
    , translation : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , scale : Maybe ( Maybe Float, Maybe Float, Maybe Float )
    , has : Set String

    -- , hasWidth : Bool
    -- , hasHeight : Bool
    -- , hasPadding : Bool
    -- , hasXContentAlign : Bool
    -- , hasYContentAlign : Bool
    -- , hasXSelfAlign : Bool
    -- , hasYSelfAlign : Bool
    -- , hasSpacing : Bool
    }


pair =
    (,)


initGathered =
    { attributes = []
    , styleProperties = []
    , rules = []
    , rotation = Nothing
    , translation = Nothing
    , scale = Nothing
    , filters = Nothing
    , boxShadows = Nothing
    , textShadows = Nothing
    , hasWidth = False
    , hasHeight = False
    , hasPadding = False
    , hasXContentAlign = False
    , hasYContentAlign = False
    , hasXSelfAlign = False
    , hasYSelfAlign = False
    , hasSpacing = False
    }


toStyleSheetNoReduction : List Style -> String
toStyleSheetNoReduction styles =
    let
        renderProps (Property key val) existing =
            existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

        renderStyle selector props =
            selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"

        combine style rendered =
            case style of
                Style selector props ->
                    rendered ++ "\n" ++ renderStyle selector props

                Keyed key styles ->
                    let
                        merge ( selector, props ) existing =
                            existing ++ "\n" ++ renderStyle selector props
                    in
                    List.foldl merge rendered styles

                Single class prop val ->
                    rendered ++ class ++ "{" ++ prop ++ ":" ++ val ++ "}\n"

                Colored class prop color ->
                    rendered ++ class ++ "{" ++ prop ++ ":" ++ formatColor color ++ "}\n"
    in
    List.foldl combine "" styles


toStyleSheet : List Style -> VirtualDom.Node msg
toStyleSheet stylesheet =
    case stylesheet of
        [] ->
            Html.text ""

        styles ->
            let
                renderProps (Property key val) existing =
                    existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

                renderStyle selector props =
                    selector ++ "{" ++ List.foldl renderProps "" props ++ "\n}"

                combine style ( rendered, cache ) =
                    case style of
                        Style selector props ->
                            ( rendered ++ "\n" ++ renderStyle selector props
                            , cache
                            )

                        Keyed key styles ->
                            if Set.member key cache then
                                ( rendered, cache )
                            else
                                let
                                    merge ( selector, props ) existing =
                                        existing ++ "\n" ++ renderStyle selector props
                                in
                                ( List.foldl merge rendered styles, Set.insert key cache )

                        Single class prop val ->
                            if Set.member class cache then
                                ( rendered, cache )
                            else
                                ( rendered ++ class ++ "{" ++ prop ++ ":" ++ val ++ "}\n"
                                , Set.insert class cache
                                )

                        Colored class prop color ->
                            if Set.member class cache then
                                ( rendered, cache )
                            else
                                ( rendered ++ class ++ "{" ++ prop ++ ":" ++ formatColor color ++ "}\n"
                                , Set.insert class cache
                                )
            in
            List.foldl combine ( "", Set.empty ) styles
                |> Tuple.first
                |> (\rendered -> VirtualDom.node "style" [] [ Html.text rendered ])
