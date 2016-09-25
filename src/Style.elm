module Style exposing (..)

import Html
import Html.Attributes
import Animation
import Color exposing (Color)
import String


type alias Model =
    { layout : Layout
    , visibility : Visibility
    , position : Position
    , size : Size
    , colors : Colors
    , padding : ( Float, Float, Float, Float )
    , text : Text
    , border : Border
    , cursor : String
    , float : Maybe Floating
    , shadows : List Shadow
    , textShadows : List Shadow
    , insetShadows : List Shadow
    , transforms : List Transform
    , filters : List Filter
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


type alias Colors =
    { background : Color
    , text : Color
    , textDecoration : Color
    , border : Color
    }


{-| can be renamed to better names
      Normally:  Static | Fixed | Relative | Absolute
      We're going to try:
-}
type RelativeTo
    = Screen
    | FlowPosition
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


type Length
    = Px Float
    | Percent Float
    | Auto


px x =
    Px x


percent x =
    Percent x


auto =
    Auto


type alias Size =
    { width : Length
    , height : Length
    }


type Layout
    = FlexLayout Flexible
    | TextLayout Textual
    | TableLayout Table


type alias Table =
    { spacing : Int
    }


type alias Textual =
    { spacing : Int
    }


type alias Flexible =
    { go : FlexOrientation
    , wrap : Bool
    , spacing : Int
    , align : ( HorizontalJustification, VerticalJustification )
    }


horizontal : Layout
horizontal =
    FlexLayout
        { go = Right
        , wrap = True
        , spacing = 10
        , align = center
        }


vertical : Layout
vertical =
    FlexLayout
        { go = Down
        , wrap = True
        , spacing = 10
        , align = center
        }


type FlexOrientation
    = Up
    | Right
    | Down
    | Left


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


type FontAlignment
    = AlignLeft
    | AlignRight
    | AlignCenter
    | Justify
    | JustifyAll


{-| All values are given in 'px' units
-}
type alias Text =
    { font : String
    , size : Float
    , lineHeight : Float
    , characterOffset : Maybe Float
    , italic : Bool
    , boldness : Maybe Float
    , align : FontAlignment
    , decoration : Maybe TextDecoration
    }


type alias TextDecoration =
    { style : TextDecorationStyle
    , position : TextDecorationPosition
    }


type TextDecorationStyle
    = Straight
    | Dashed
    | Double
    | Dotted
    | Wavy


type TextDecorationPosition
    = Underline
    | Overline
    | LineThrough


all : a -> ( a, a, a, a )
all x =
    ( x, x, x, x )



{- Border width and corners are always given in px -}


type alias Border =
    { style : BorderStyle
    , width : ( Float, Float, Float, Float )
    , corners : ( Float, Float, Float, Float )
    }


type BorderStyle
    = SolidBorder
    | DashedBorder
    | DottedBorder


type Visibility
    = Transparent Float
    | Hidden


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


default : Model
default =
    { layout = defaultLayout
    , visibility = defaultVisibility
    , position = defaultPosition
    , size = defaultSize
    , colors = defaultColors
    , cursor = "auto"
    , padding = ( 0, 0, 0, 0 )
    , text = defaultText
    , border = defaultBorder
    , float = Nothing
    , textShadows = []
    , shadows = []
    , insetShadows = []
    , transforms = []
    , filters = []
    }


defaultLayout : Layout
defaultLayout =
    TextLayout { spacing = 15 }


defaultVisibility : Visibility
defaultVisibility =
    Transparent 0


defaultSize : Size
defaultSize =
    { width = auto
    , height = auto
    }


defaultText : Text
defaultText =
    { font = "georgia"
    , size = 16
    , characterOffset = Nothing
    , lineHeight = 16
    , italic = False
    , boldness = Nothing
    , align = AlignLeft
    , decoration = Nothing
    }


defaultBorder : Border
defaultBorder =
    { style = SolidBorder
    , width = ( 0, 0, 0, 0 )
    , corners = ( 0, 0, 0, 0 )
    }


defaultColors : Colors
defaultColors =
    { background = Color.white
    , text = Color.black
    , border = Color.grey
    , textDecoration = Color.black
    }


defaultPosition : Position
defaultPosition =
    { relativeTo = FlowPosition
    , anchor = ( AnchorTop, AnchorLeft )
    , position = ( 0, 0 )
    }


(=>) =
    (,)



--type alias Model =
--    { layout : Layout
--    , visibility : Visibility
--    , position : Position
--    , size : Size
--    , colors : Colors
--    , spacing : Spacing
--    , text : Text
--    , border : Border
--    , cursor : String
--    , float : Maybe Floating
--    , shadow : List Shadow
--    , textShadow : List Shadow
--    , insetShadow : List Shadow
--    , transforms : List Transform
--    , filters : List Filter
--    }


render : Model -> ( List (Html.Attribute msg), List (Html.Attribute msg) )
render style =
    [ Html.Attributes.style <|
        List.concat
            [ renderLayout style.layout
            , renderPosition style.position
            , renderVisibility style.visibility
            , renderSize style.size
            , renderColors style.colors
            , renderText style.text
            , [ "cursor" => style.cursor
              , "padding" => render4tuplePx style.padding
              ]
            , renderBorder style.border
            , case style.float of
                Nothing ->
                    []

                Just floating ->
                    case floating of
                        FloatLeft ->
                            [ "float" => "left" ]

                        FloatRight ->
                            [ "float" => "right" ]
            , renderShadow "box-shadow" False style.shadows
            , renderShadow "box-shadow" True style.insetShadows
            , renderShadow "text-shadow" False style.textShadows
            , renderFilters style.filters
            ]
    ]
        => []


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
            SolidBorder ->
                "solid"

            DashedBorder ->
                "dashed"

            DottedBorder ->
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
    , "line-height" => (toString text.lineHeight ++ "px")
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
    , case text.decoration of
        Nothing ->
            "" => ""

        Just { style } ->
            case style of
                Straight ->
                    "text-decoration-style" => "solid"

                Dashed ->
                    "text-decoration-style" => "dashed"

                Double ->
                    "text-decoration-style" => "double"

                Dotted ->
                    "text-decoration-style" => "dotted"

                Wavy ->
                    "text-decoration-style" => "wavy"
    , case text.decoration of
        Nothing ->
            "" => ""

        Just { position } ->
            case position of
                Underline ->
                    "text-decoration-line" => "underline"

                Overline ->
                    "text-decoration-line" => "overline"

                LineThrough ->
                    "text-decoration-line" => "line-through"
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
renderColors { text, background, textDecoration, border } =
    [ "border-color" => colorToString border
    , "color" => colorToString text
    , "background-color" => colorToString background
    , "text-decoration-color" => colorToString textDecoration
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


renderSize : Size -> List ( String, String )
renderSize { width, height } =
    [ "width" => (renderLength width)
    , "height" => (renderLength height)
    ]


renderPosition : Position -> List ( String, String )
renderPosition { relativeTo, anchor, position } =
    let
        ( x, y ) =
            position
    in
        (case relativeTo of
            Screen ->
                "position" => "fixed"

            FlowPosition ->
                "position" => "relative"

            Parent ->
                "position" => "absolute"
        )
            :: case anchor of
                ( AnchorTop, AnchorLeft ) ->
                    [ "top" => toString (-1 * y)
                    , "left" => toString (-1 * x)
                    ]

                ( AnchorTop, AnchorRight ) ->
                    [ "top" => toString (-1 * y)
                    , "right" => toString x
                    ]

                ( AnchorBottom, AnchorLeft ) ->
                    [ "bottom" => toString y
                    , "left" => toString (-1 * x)
                    ]

                ( AnchorBottom, AnchorRight ) ->
                    [ "bottom" => toString y
                    , "right" => toString x
                    ]


renderVisibility : Visibility -> List ( String, String )
renderVisibility vis =
    case vis of
        Transparent t ->
            [ "opacity" => toString (100 - t) ]

        Hidden ->
            [ "display" => "none" ]


renderLayout : Layout -> List ( String, String )
renderLayout layout =
    case layout of
        TextLayout { spacing } ->
            [ "display" => "block" ]

        TableLayout { spacing } ->
            [ "display" => "block" ]

        FlexLayout flex ->
            [ "display" => "flex"
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



--{ layout : Layout
--    , visibility : Visibility
--    , position : Position
--    , size : Size
--    , colors : Colors
--    , spacing : Spacing
--    , text : Text
--    , border : Border
--    , shadow : List Shadow
--    , textShadow : List Shadow
--    , insetShadow : List Shadow
--    , transforms : List Transform
--    }


init : Model -> Animation.State
init style =
    Animation.style []



--toAnimProps : Model -> List Animation.Model.Property


toAnimProps style =
    []


build : (List (Html.Attribute msg) -> Html.Html msg) -> Html.Html msg
build el =
    el []


type alias Element msg =
    List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg



--element : Element msg -> Model -> List (Html.Attribute msg) -> (List (Html.Attribute msg) -> List (Html.Html msg)) -> List (Html.Attribute msg) -> Html.Html msg


element html sty attrs content inheritedAttrs =
    let
        ( parentSty, childModSty ) =
            render sty
    in
        html
            (parentSty ++ attrs ++ inheritedAttrs)
            (List.map (\cont -> cont childModSty) content)



--options : Element msg -> (a -> Model) -> a -> List (Html.Attribute msg) -> (List (Html.Attribute msg) -> List (Html.Html msg)) -> List (Html.Attribute msg) -> Html.Html msg


options html sty id attrs content inheritedAttrs =
    let
        ( parentSty, childModSty ) =
            render (sty id)
    in
        html
            (parentSty ++ attrs ++ inheritedAttrs)
            (List.map (\cont -> cont childModSty) content)



--animated : Element msg -> Animation.State -> List (Html.Attribute msg) -> (List (Html.Attribute msg) -> List (Html.Html msg)) -> List (Html.Attribute msg) -> Html.Html msg


animated html sty attrs content inheritedAttrs =
    html
        (Animation.render sty ++ attrs ++ inheritedAttrs)
        (List.map (\cont -> cont []) content)


animateTo : Model -> Animation.State -> Animation.State
animateTo style anim =
    Animation.interrupt
        [ Animation.to (toAnimProps style)
        ]
        anim
