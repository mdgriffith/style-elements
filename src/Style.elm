module Style exposing (..)

import Html
import Html.Attributes
import Animation
import Color exposing (Color)
import String


type alias HtmlNode msg =
    List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg


type Element msg
    = Element
        { style : Model msg
        , node : HtmlNode msg
        , attributes : List (Html.Attribute msg)
        , children : List (Element msg)
        }
    | Html (Html.Html msg)


type alias Model msg =
    { layout : Layout
    , visibility : Visibility
    , position : Position
    , cursor : String
    , width : Length
    , height : Length
    , colors : Colors
    , padding : ( Float, Float, Float, Float )
    , text : Text
    , border : Border
    , float : Maybe Floating
    , inline : Bool
    , shadows : List Shadow
    , textShadows : List Shadow
    , insetShadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
    , transitions : Maybe (Transitions msg)
    }


type Transitions msg
    = Transitions
        { id : String
        , onHover : Maybe (Model msg)
        , onFocus : Maybe (Model msg)
        }


type Filter
    = FilterUrl String
    | Blur Float
    | Brightness Float
    | Contrast Float
    | Grayscale Float
    | HueRotate Float
    | Invert Float
    | Opacity Float
    | Saturate Float
    | Sepia Float


{-| This type is only valid if the parent has its layout set to `TextLayout`

-}
type Floating
    = FloatLeft
    | FloatRight


{-|

-}
floatLeft : Floating
floatLeft =
    FloatLeft


{-|

-}
floatRight : Floating
floatRight =
    FloatRight


type alias Colors =
    { background : Color
    , text : Color
    , border : Color
    }


{-| can be renamed to better names
      Normally:  Static | Fixed | Relative | Absolute
      We're going to try:
-}
type RelativeTo
    = Screen
    | CurrentPosition
    | Parent


type AnchorVertical
    = AnchorTop
    | AnchorBottom


type AnchorHorizontal
    = AnchorLeft
    | AnchorRight


type alias Position =
    { relativeTo : RelativeTo
    , anchor : ( AnchorVertical, AnchorHorizontal )
    , position : ( Float, Float )
    }


type alias Anchor =
    ( AnchorVertical, AnchorHorizontal )


{-| -}
topLeft : Anchor
topLeft =
    AnchorTop => AnchorLeft


{-| -}
topRight : Anchor
topRight =
    AnchorTop => AnchorRight


{-| -}
bottomLeft : Anchor
bottomLeft =
    AnchorBottom => AnchorLeft


{-| -}
bottomRight : Anchor
bottomRight =
    AnchorBottom => AnchorRight


type Length
    = Px Float
    | Percent Float
    | Auto


{-| -}
px : Float -> Length
px x =
    Px x


{-| -}
percent : Float -> Length
percent x =
    Percent x


{-| -}
auto : Length
auto =
    Auto


type Layout
    = FlexLayout Flexible
    | TextLayout Textual
    | TableLayout Table


type alias Table =
    { spacing : ( Float, Float, Float, Float )
    }


type alias Textual =
    { spacing : ( Float, Float, Float, Float )
    }


type alias Flexible =
    { go : FlexOrientation
    , wrap : Bool
    , spacing : ( Float, Float, Float, Float )
    , align : ( HorizontalJustification, VerticalJustification )
    }


type FlexOrientation
    = Up
    | Right
    | Down
    | Left


{-| -}
center : ( HorizontalJustification, VerticalJustification )
center =
    ( HCenter, VCenter )


type HorizontalJustification
    = HLeft
    | HRight
    | HCenter
    | HStretch


type VerticalJustification
    = VTop
    | VBottom
    | VCenter
    | VStretch


type TextAlignment
    = AlignLeft
    | AlignRight
    | AlignCenter
    | Justify
    | JustifyAll


{-| -}
justify : TextAlignment
justify =
    Justify


{-| -}
justifyAll : TextAlignment
justifyAll =
    JustifyAll


{-| -}
alignLeft : TextAlignment
alignLeft =
    AlignLeft


{-| -}
alignRight : TextAlignment
alignRight =
    AlignRight


{-| -}
alignCenter : TextAlignment
alignCenter =
    AlignCenter


{-| All values are given in 'px' units
-}
type alias Text =
    { font : String
    , size : Float
    , lineHeight : Float
    , characterOffset : Maybe Float
    , italic : Bool
    , boldness : Maybe Float
    , align : TextAlignment
    , decoration : Maybe TextDecoration
    }


type TextDecoration
    = Underline
    | Overline
    | Strike


{-| -}
underline : TextDecoration
underline =
    Underline


{-| -}
overline : TextDecoration
overline =
    Overline


{-| -}
strike : TextDecoration
strike =
    Strike


{-| -}
all : a -> ( a, a, a, a )
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


{-| Border width and corners are always given in px
-}
type alias Border =
    { style : BorderStyle
    , width : ( Float, Float, Float, Float )
    , corners : ( Float, Float, Float, Float )
    }


type BorderStyle
    = Solid
    | Dashed
    | Dotted


{-| -}
solid : BorderStyle
solid =
    Solid


{-| -}
dashed : BorderStyle
dashed =
    Dashed


{-| -}
dotted : BorderStyle
dotted =
    Dotted


type Visibility
    = Transparent Float
    | Hidden


{-|
-}
hidden : Visibility
hidden =
    Hidden


{-| A Value between 0 and 1
-}
transparency : Float -> Visibility
transparency x =
    Transparent x


{-| A Value between 0 and 1
-}
opacity : Float -> Visibility
opacity x =
    Transparent (1.0 - x)


type alias Shadow =
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }


type Transform
    = Translate Float Float Float
    | Rotate Float Float Float
    | Scale Float Float Float


{-| Units always given as radians.

Use `x * deg` if you want to use a different set of units.
-}
rotate : Float -> Float -> Float -> Transform
rotate x y z =
    Rotate x y z


{-| Units always always as pixels
-}
translate : Float -> Float -> Float -> Transform
translate x y z =
    Translate x y z


{-| -}
scale : Float -> Float -> Float -> Transform
scale x y z =
    Scale x y z


(=>) =
    (,)


type alias Permissions =
    { floats : Bool
    , inline : Bool
    }


render : Model msg -> Permissions -> ( List (Html.Attribute msg), List (Html.Attribute msg), Permissions )
render style permissions =
    let
        ( layout, childLayout, childrenPermissions ) =
            renderLayout style.layout
    in
        ( [ Html.Attributes.style <|
                List.concat
                    [ layout
                    , renderPosition style.position
                    , if style.inline then
                        if permissions.inline then
                            [ "display" => "inline-block" ]
                        else
                            let
                                _ =
                                    Debug.log "style-blocks" "Elements can only be inline if they are in a text layout."
                            in
                                []
                      else
                        []
                    , renderVisibility style.visibility
                    , [ "width" => (renderLength style.width)
                      , "height" => (renderLength style.height)
                      , "cursor" => style.cursor
                      , "padding" => render4tuplePx style.padding
                      ]
                    , renderColors style.colors
                    , renderText style.text
                    , renderBorder style.border
                    , case style.float of
                        Nothing ->
                            []

                        Just floating ->
                            if permissions.floats then
                                case floating of
                                    FloatLeft ->
                                        [ "float" => "left" ]

                                    FloatRight ->
                                        [ "float" => "right" ]
                            else
                                let
                                    _ =
                                        Debug.log "style-blocks" "Elements can only use float if they are in a text layout."
                                in
                                    []
                    , renderShadow "box-shadow" False style.shadows
                    , renderShadow "box-shadow" True style.insetShadows
                    , renderShadow "text-shadow" False style.textShadows
                    , renderFilters style.filters
                    , renderTransforms style.transforms
                    ]
          ]
        , [ Html.Attributes.style childLayout ]
        , childrenPermissions
        )


renderTransforms : List Transform -> List ( String, String )
renderTransforms transforms =
    [ "transform"
        => String.join " "
            (List.map transformToString transforms)
    ]


transformToString : Transform -> String
transformToString transform =
    case transform of
        Translate x y z ->
            "transform3d("
                ++ toString x
                ++ ", "
                ++ toString y
                ++ ", "
                ++ toString z
                ++ ")"

        Rotate x y z ->
            "rotateX("
                ++ toString x
                ++ ")  rotateY("
                ++ toString y
                ++ ") rotateZ("
                ++ toString z
                ++ ")"

        Scale x y z ->
            "scale3d("
                ++ toString x
                ++ ", "
                ++ toString y
                ++ ", "
                ++ toString z
                ++ ")"


renderFilters : List Filter -> List ( String, String )
renderFilters filters =
    [ "filter"
        => (String.join " " <| List.map filterToString filters)
    ]


filterToString : Filter -> String
filterToString filter =
    case filter of
        FilterUrl url ->
            "url(" ++ url ++ ")"

        Blur x ->
            "blur(" ++ toString x ++ "px)"

        Brightness x ->
            "brightness(" ++ toString x ++ "%)"

        Contrast x ->
            "contrast(" ++ toString x ++ "%)"

        Grayscale x ->
            "grayscale(" ++ toString x ++ "%)"

        HueRotate x ->
            "hueRotate(" ++ toString x ++ "deg)"

        Invert x ->
            "invert(" ++ toString x ++ "%)"

        Opacity x ->
            "opacity(" ++ toString x ++ "%)"

        Saturate x ->
            "saturate(" ++ toString x ++ "%)"

        Sepia x ->
            "sepia(" ++ toString x ++ "%)"


renderShadow : String -> Bool -> List Shadow -> List ( String, String )
renderShadow shadowName inset shadows =
    [ shadowName
        => String.join ", " (List.map (shadowValue inset) shadows)
    ]


shadowValue : Bool -> Shadow -> String
shadowValue inset { offset, size, blur, color } =
    String.join " "
        [ if inset then
            "inset"
          else
            ""
        , toString (fst offset) ++ "px"
        , toString (snd offset) ++ "px"
        , toString blur ++ "px"
        , colorToString color
        ]


render4tuplePx : ( Float, Float, Float, Float ) -> String
render4tuplePx ( a, b, c, d ) =
    toString a ++ "px " ++ toString b ++ "px " ++ toString c ++ "px " ++ toString d ++ "px"


renderBorder : Border -> List ( String, String )
renderBorder { style, width, corners } =
    [ "border-style"
        => case style of
            Solid ->
                "solid"

            Dashed ->
                "dashed"

            Dotted ->
                "dotted"
    , "border-width"
        => render4tuplePx width
    , "border-radius"
        => render4tuplePx corners
    ]


renderText : Text -> List ( String, String )
renderText text =
    [ "font-family" => text.font
    , "font-size" => (toString text.size ++ "px")
    , "line-height" => (toString (text.size * text.lineHeight) ++ "px")
    , case text.characterOffset of
        Nothing ->
            ( "", "" )

        Just offset ->
            "letter-spacing" => (toString offset ++ "px")
    , if text.italic then
        "font-style" => "italic"
      else
        "font-style" => "normal"
    , case text.boldness of
        Nothing ->
            "" => ""

        Just bold ->
            "font-weight" => (toString bold)
    , case text.align of
        AlignLeft ->
            "text-align" => "left"

        AlignRight ->
            "text-align" => "right"

        AlignCenter ->
            "text-align" => "center"

        Justify ->
            "text-align" => "justify"

        JustifyAll ->
            "text-align" => "justify-all"
    , "text-decoration"
        => case text.decoration of
            Nothing ->
                "none"

            Just position ->
                case position of
                    Underline ->
                        "underline"

                    Overline ->
                        "overline"

                    Strike ->
                        "line-through"
    ]


colorToString : Color -> String
colorToString color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color
    in
        "rgba("
            ++ toString red
            ++ ","
            ++ toString green
            ++ ","
            ++ toString blue
            ++ ","
            ++ toString alpha
            ++ ")"


renderColors : Colors -> List ( String, String )
renderColors { text, background, border } =
    [ "border-color" => colorToString border
    , "color" => colorToString text
    , "background-color" => colorToString background
    ]


renderLength : Length -> String
renderLength l =
    case l of
        Px x ->
            toString x ++ "px"

        Percent x ->
            toString x ++ "%"

        Auto ->
            "auto"


renderPosition : Position -> List ( String, String )
renderPosition { relativeTo, anchor, position } =
    let
        ( x, y ) =
            position
    in
        (case relativeTo of
            Screen ->
                "position" => "fixed"

            CurrentPosition ->
                "position" => "relative"

            Parent ->
                "position" => "absolute"
        )
            :: case anchor of
                ( AnchorTop, AnchorLeft ) ->
                    [ "top" => (toString (-1 * y) ++ "px")
                    , "left" => (toString x ++ "px")
                    ]

                ( AnchorTop, AnchorRight ) ->
                    [ "top" => (toString (-1 * y) ++ "px")
                    , "right" => (toString (-1 * x) ++ "px")
                    ]

                ( AnchorBottom, AnchorLeft ) ->
                    [ "bottom" => (toString y ++ "px")
                    , "left" => (toString x ++ "px")
                    ]

                ( AnchorBottom, AnchorRight ) ->
                    [ "bottom" => (toString y ++ "px")
                    , "right" => (toString (-1 * x) ++ "px")
                    ]


renderVisibility : Visibility -> List ( String, String )
renderVisibility vis =
    case vis of
        Transparent t ->
            [ "opacity" => toString (1.0 - t) ]

        Hidden ->
            [ "display" => "none" ]


renderLayout : Layout -> ( List ( String, String ), List ( String, String ), Permissions )
renderLayout layout =
    case layout of
        TextLayout { spacing } ->
            ( [ "display" => "block" ]
            , [ "margin" => render4tuplePx spacing ]
            , { floats = True
              , inline = True
              }
            )

        TableLayout { spacing } ->
            ( [ "display" => "block" ]
            , [ "margin" => render4tuplePx spacing ]
            , { floats = False
              , inline = False
              }
            )

        FlexLayout flex ->
            ( [ "display" => "flex"
              , case flex.go of
                    Right ->
                        "flex-direction" => "row"

                    Left ->
                        "flex-direction" => "row-reverse"

                    Down ->
                        "flex-direction" => "column"

                    Up ->
                        "flex-direction" => "column-reverse"
              , if flex.wrap then
                    "flex-wrap" => "wrap"
                else
                    "flex-wrap" => "nowrap"
              , case flex.go of
                    Right ->
                        case fst flex.align of
                            HLeft ->
                                "justify-content" => "flex-start"

                            HRight ->
                                "justify-content" => "flex-end"

                            HCenter ->
                                "justify-content" => "center"

                            HStretch ->
                                "justify-content" => "stretch"

                    Left ->
                        case fst flex.align of
                            HLeft ->
                                "justify-content" => "flex-end"

                            HRight ->
                                "justify-content" => "flex-start"

                            HCenter ->
                                "justify-content" => "center"

                            HStretch ->
                                "justify-content" => "stretch"

                    Down ->
                        case fst flex.align of
                            HLeft ->
                                "align-items" => "flex-start"

                            HRight ->
                                "align-items" => "flex-end"

                            HCenter ->
                                "align-items" => "center"

                            HStretch ->
                                "align-items" => "stretch"

                    Up ->
                        case fst flex.align of
                            HLeft ->
                                "align-items" => "flex-start"

                            HRight ->
                                "align-items" => "flex-end"

                            HCenter ->
                                "align-items" => "center"

                            HStretch ->
                                "align-items" => "stretch"
              , case flex.go of
                    Right ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-start"

                            VBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Left ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-start"

                            VBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Down ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-start"

                            VBottom ->
                                "align-items" => "flex-end"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"

                    Up ->
                        case snd flex.align of
                            VTop ->
                                "align-items" => "flex-end"

                            VBottom ->
                                "align-items" => "flex-start"

                            VCenter ->
                                "align-items" => "center"

                            VStretch ->
                                "align-items" => "stretch"
              ]
            , [ "margin" => render4tuplePx flex.spacing ]
            , { floats = False
              , inline = False
              }
            )


buildWithTransitions : Element msg -> Html.Html msg
buildWithTransitions element =
    case element of
        Html html ->
            html

        Element model ->
            let
                ( parent, childStyle, childPermissions ) =
                    render model.style { floats = False, inline = False }

                ( children, childTransitions ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildChildWithTransitions childPermissions childStyle child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtTransitions
                                )
                        )
                        ( [], "" )
                        model.children

                transitionStyleSheet =
                    Html.node "style"
                        []
                        [ Html.text <|
                            case model.style.transitions of
                                Nothing ->
                                    childTransitions

                                Just trans ->
                                    renderCssTransitions trans ++ childTransitions
                        ]
            in
                model.node
                    (parent ++ model.attributes)
                    (transitionStyleSheet :: children)


buildChildWithTransitions : Permissions -> List (Html.Attribute msg) -> Element msg -> ( Html.Html msg, String )
buildChildWithTransitions permissions inherited element =
    case element of
        Html html ->
            ( html, "" )

        Element model ->
            let
                ( parent, childStyle, childPermissions ) =
                    render model.style permissions

                ( children, childTransitions ) =
                    List.foldl
                        (\child ( children, transitions ) ->
                            let
                                ( builtChild, builtTransitions ) =
                                    buildChildWithTransitions childPermissions childStyle child
                            in
                                ( children ++ [ builtChild ]
                                , transitions ++ builtTransitions
                                )
                        )
                        ( [], "" )
                        model.children
            in
                ( model.node
                    (parent ++ model.attributes)
                    children
                , case model.style.transitions of
                    Nothing ->
                        childTransitions

                    Just trans ->
                        renderCssTransitions trans ++ childTransitions
                )


build : Element msg -> Html.Html msg
build element =
    case element of
        Html html ->
            html

        Element model ->
            let
                ( parent, childStyle, childPermissions ) =
                    render model.style { floats = False, inline = False }
            in
                model.node
                    (parent ++ model.attributes)
                    (List.map
                        (buildChild childPermissions childStyle)
                        model.children
                    )


buildChild : Permissions -> List (Html.Attribute msg) -> Element msg -> Html.Html msg
buildChild permissions inherited element =
    case element of
        Html html ->
            html

        Element model ->
            let
                ( parent, childStyle, childrenPermissions ) =
                    render model.style permissions
            in
                model.node
                    (parent ++ inherited ++ model.attributes)
                    (List.map
                        (buildChild childrenPermissions childStyle)
                        model.children
                    )


html : Html.Html msg -> Element msg
html node =
    Html node


element : HtmlNode msg -> Model msg -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
element node styleModel attrs content =
    Element
        { style = styleModel
        , node = node
        , attributes = attrs
        , children = content
        }


hover : String -> Model msg -> Model msg -> Model msg
hover id targetModel baseModel =
    let
        newTransitions =
            case baseModel.transitions of
                Nothing ->
                    Just <|
                        Transitions
                            { id = id
                            , onFocus = Nothing
                            , onHover = Just targetModel
                            }

                Just (Transitions transitions) ->
                    Just <| Transitions { transitions | onHover = Just targetModel }
    in
        { baseModel
            | transitions = newTransitions
        }


focus : String -> Model msg -> Model msg -> Model msg
focus id targetModel baseModel =
    let
        newTransitions =
            case baseModel.transitions of
                Nothing ->
                    Just <|
                        Transitions
                            { id = id
                            , onFocus = Nothing
                            , onHover = Just targetModel
                            }

                Just (Transitions transitions) ->
                    Just <| Transitions { transitions | onHover = Just targetModel }
    in
        { baseModel
            | transitions = newTransitions
        }


renderTransitionStyle : Model msg -> String
renderTransitionStyle style =
    let
        stylePairs =
            List.concat
                [ renderVisibility style.visibility
                , [ "width" => (renderLength style.width)
                  , "height" => (renderLength style.height)
                  , "padding" => render4tuplePx style.padding
                  ]
                , renderColors style.colors
                , renderText style.text
                , renderBorder style.border
                , renderShadow "box-shadow" False style.shadows
                , renderShadow "box-shadow" True style.insetShadows
                , renderShadow "text-shadow" False style.textShadows
                , renderFilters style.filters
                , renderTransforms style.transforms
                ]
    in
        List.map (\( name, val ) -> "    " ++ name ++ ": " ++ val ++ ";\n") stylePairs
            |> String.concat


{-| Produces valid css code.
-}
renderCssTransitions : Transitions msg -> String
renderCssTransitions (Transitions { id, onHover, onFocus }) =
    let
        hover =
            case onHover of
                Nothing ->
                    ""

                Just hoverStyle ->
                    "."
                        ++ id
                        ++ ":hover {\n"
                        ++ renderTransitionStyle hoverStyle
                        ++ "\n}\n"

        focus =
            case onFocus of
                Nothing ->
                    ""

                Just focusStyle ->
                    "."
                        ++ id
                        ++ ":focus {\n"
                        ++ renderTransitionStyle focusStyle
                        ++ "\n}\n"
    in
        hover ++ focus



--= Transitions
--        { onHover : Model msg
--        , onFocus : Model msg
--        }
--init : Model msg -> Animation.State
--init style =
--toAnimProps style =
--    []
--animated : Model msg -> Animation.State -> List (Html.Attribute msg) -> List (Element msg) -> Element msg
--animated el animStyle attrs content =
--    Element
--        { el
--            | attributes = el.attributes ++ Animation.render animStyle ++ attrs
--            , children = Children (getChildren el.children ++ content)
--        }
--animateTo : Model -> Animation.State -> Animation.State
--animateTo style anim =
--    Animation.interrupt
--        [ Animation.to (toAnimProps style)
--        ]
--        anim
