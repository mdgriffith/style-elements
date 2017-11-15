module Next.Slim.Element
    exposing
        ( column
        , el
        , empty
        , expand
        , fill
        , layout
        , paragraph
        , px
        , row
        , shrink
        , space
        , text
        , textPage
        , when
        , whenJust
        )

{-| -}

import Color
import Html exposing (Html)
import Html.Attributes
import Json.Encode as Json
import Next.Slim.Element.Attributes as Attributes
import Next.Slim.Element.Color as Color
import Next.Slim.Element.Events as Events
import Next.Slim.Element.Font as Font
import Next.Slim.Internal.Model exposing (..)
import Next.Slim.Internal.Style
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
expand : Length
expand =
    Expand


{-| -}
layout : List (Attribute msg) -> Element msg -> Html msg
layout attrs child =
    renderHtml Layout
        "div"
        (Color.background Color.blue
            :: Color.text Color.white
            :: Font.size 20
            :: Font.family
                [ Font.typeface "Open Sans"
                , Font.typeface "georgia"
                , Font.serif
                ]
            :: htmlClass "style-elements se el"
            :: attrs
        )
        [ child ]


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
    Unstyled (VirtualDom.text "")


{-| -}
text : String -> Element msg
text content =
    Unstyled <|
        VirtualDom.node "div"
            [ VirtualDom.property "className" (Json.string "se text width-fill") ]
            [ VirtualDom.text content ]


renderAttributes : List (Attribute msg) -> List Style -> ( List (Html.Attribute msg), List Style, Maybe (List (Html msg)) )
renderAttributes attributes styleChildren =
    case attributes of
        [] ->
            ( []
            , styleChildren
            , Nothing
            )

        attrs ->
            List.foldr gatherAttributes { initGathered | rules = styleChildren } attrs
                |> formatTransformations
                |> (\{ rules, attributes, nearbys } ->
                        case nearbys of
                            [] ->
                                ( attributes
                                , rules
                                , Nothing
                                )

                            additionalChildren ->
                                ( attributes
                                , rules
                                , Just additionalChildren
                                )
                   )


render : String -> List (Attribute msg) -> List (Element msg) -> Element msg
render name attributes children =
    let
        ( htmlChildren, styleChildren ) =
            List.foldr gather ( [], [] ) children

        gather child ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    ( html :: htmls, existingStyles )

                Styled styles html ->
                    ( html :: htmls, styles ++ existingStyles )

        ( renderedAttributes, renderedRules, additionalChildren ) =
            renderAttributes attributes styleChildren
    in
    Styled renderedRules
        (VirtualDom.node name
            renderedAttributes
            (case additionalChildren of
                Nothing ->
                    htmlChildren

                Just additional ->
                    htmlChildren
                        ++ [ VirtualDom.node "div" [ VirtualDom.property "className" (Json.string "se el nearby") ] additional ]
            )
        )


type RenderMode
    = Viewport
    | Layout
    | NoStaticStyleSheet


{-| -}
renderHtml : RenderMode -> String -> List (Attribute msg) -> List (Element msg) -> Html msg
renderHtml mode name attributes children =
    let
        ( htmlChildren, styleChildren ) =
            List.foldr gather ( [], [] ) children

        gather child ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    ( html :: htmls, existingStyles )

                Styled styles html ->
                    ( html :: htmls, styles ++ existingStyles )

        ( renderedAttributes, renderedRules, additionalChildren ) =
            renderAttributes attributes styleChildren

        styles =
            styleChildren ++ renderedRules

        styleSheets children =
            case mode of
                NoStaticStyleSheet ->
                    toStyleSheet styles :: children

                Layout ->
                    VirtualDom.node "style" [] [ Html.text Next.Slim.Internal.Style.rules ]
                        :: toStyleSheet styles
                        :: children

                Viewport ->
                    VirtualDom.node "style" [] [ Html.text Next.Slim.Internal.Style.viewportRules ]
                        :: toStyleSheet styles
                        :: children
    in
    VirtualDom.node name
        renderedAttributes
        (case additionalChildren of
            Nothing ->
                styleSheets htmlChildren

            Just additional ->
                styleSheets <|
                    htmlChildren
                        ++ [ VirtualDom.node "div"
                                [ VirtualDom.property "className" (Json.string "se el nearby") ]
                                additional
                           ]
        )


htmlClass : String -> Attribute msg
htmlClass cls =
    Attr <| VirtualDom.property "className" (Json.string cls)


{-| -}
el : List (Attribute msg) -> Element msg -> Element msg
el attrs child =
    render "div"
        (htmlClass "se el"
            :: Attributes.width shrink
            :: Attributes.height shrink
            :: Attributes.centerY
            :: Attributes.center
            :: attrs
        )
        [ child ]


{-| -}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    render "div"
        (htmlClass "se row"
            :: Class "y-content-align" "content-top"
            :: Class "x-content-align" "content-center-x"
            :: Attributes.spacing 20
            :: Attributes.width fill
            :: attrs
        )
        children


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    render "div"
        (htmlClass "se column"
            :: Attributes.spacing 20
            :: Class "y-content-align" "content-top"
            :: Attributes.height fill
            :: Attributes.width fill
            :: attrs
        )
        children


{-| -}
paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph attrs children =
    render "p" (htmlClass "se paragraph" :: Attributes.width fill :: attrs) children


{-| -}
textPage : List (Attribute msg) -> List (Element msg) -> Element msg
textPage attrs children =
    render "div" (htmlClass "se page" :: Attributes.width (px 650) :: attrs) children


{-| -}
space : Float -> Element msg
space pixels =
    let
        spacings =
            [ Style (".row > .spacer-" ++ toString pixels)
                [ Property "width" (toString pixels ++ "px")
                , Property "height" "0px"
                ]
            , Style (".column > .spacer-" ++ toString pixels)
                [ Property "height" (toString pixels ++ "px")
                , Property "width" "0px"
                ]
            ]
    in
    Styled spacings
        (Html.node "span"
            [ Html.Attributes.class ("se spacer spacer-" ++ toString pixels) ]
            []
        )


type alias Button msg =
    { onClick : msg
    , content : Element msg
    }


{-| For images, both a source and a caption are required. The caption will serve as the alt-text.
-}
image : List (Attribute Never) -> { src : String, caption : String } -> Element msg
image attrs { src, caption } =
    render "img"
        (Attr (Html.Attributes.src src)
            :: Attr (Html.Attributes.alt caption)
            :: List.map (mapAttr Basics.never) attrs
        )
        []


{-| If an image is purely decorative, you can skip the caption.
-}
decorativeImage : List (Attribute Never) -> { src : String } -> Element msg
decorativeImage attrs { src } =
    render "img"
        (Attr (Html.Attributes.src src)
            :: Attr (Html.Attributes.alt "")
            :: List.map (mapAttr Basics.never) attrs
        )
        []



-- {-| -}
-- h1 : List (Attribute msg) -> Element msg -> Element msg
-- h1 attrs child =
--     render "h1" attrs [ child ]
-- {-| -}
-- h2 : List (Attribute msg) -> Element msg -> Element msg
-- h2 attrs child =
--     render "h2" attrs [ child ]
-- {-| -}
-- h3 : List (Attribute msg) -> Element msg -> Element msg
-- h3 attrs child =
--     render "h3" attrs [ child ]
-- {-| -}
-- h4 : List (Attribute msg) -> Element msg -> Element msg
-- h4 attrs child =
--     render "h4" attrs [ child ]
-- {-| -}
-- h5 : List (Attribute msg) -> Element msg -> Element msg
-- h5 attrs child =
--     render "h5" attrs [ child ]
-- {-| -}
-- h6 : List (Attribute msg) -> Element msg -> Element msg
-- h6 attrs child =
--     render "h6" attrs [ child ]


{-| -}
button : List (Attribute msg) -> Button msg -> Element msg
button attrs { onClick, content } =
    render "button" (Events.onClick onClick :: attrs) [ content ]


{-| -}
link : List (Attribute msg) -> { url : String, element : Element msg } -> Element msg
link attrs { url, element } =
    render "a"
        (htmlClass "se el"
            :: Attr (Html.Attributes.href src)
            :: Attr (Html.Attributes.rel "noopener noreferrer")
            :: Attributes.width shrink
            :: Attributes.height shrink
            :: Attributes.centerY
            :: Attributes.center
            :: attrs
        )
        [ element ]


{-| -}
newTab : List (Attribute msg) -> { url : String, element : Element msg } -> Element msg
newTab attrs { url, element } =
    render "a"
        (htmlClass "se el"
            :: Attr (Html.Attributes.href src)
            :: Attr (Html.Attributes.rel "noopener noreferrer")
            :: Attr (Html.Attributes.target "_blank")
            :: Attributes.width shrink
            :: Attributes.height shrink
            :: Attributes.centerY
            :: Attributes.center
            :: attrs
        )
        [ element ]


{-|

    download []
        { url = "mydownload.pdf"
        , element = text "Download this"
        }

-}
download : List (Attribute msg) -> { url : String, element : Element msg } -> Element msg
download attrs { url, element } =
    render "a"
        (htmlClass "se el"
            :: Attr (Html.Attributes.href url)
            :: Attr (Html.Attributes.download True)
            :: Attributes.width shrink
            :: Attributes.height shrink
            :: Attributes.centerY
            :: Attributes.center
            :: attrs
        )
        [ element ]


{-|

     downloadAs []
        { url = "mydownload.pdf"
        , filename "your-thing.pdf"
        , element = text "Download this"
        }

-}
downloadAs : List (Attribute msg) -> { element : Element msg, filename : String, url : String } -> Element msg
downloadAs attrs { url, filename, element } =
    render "a"
        (htmlClass "se el"
            :: Attr (Html.Attributes.href url)
            :: Attr (Html.Attributes.downloadAs filename)
            :: Attributes.width shrink
            :: Attributes.height shrink
            :: Attributes.centerY
            :: Attributes.center
            :: attrs
        )
        [ element ]
