module Style exposing (..)

import Html
import Html.Attributes
import Animation
import Color exposing (Color)


type alias Model =
    { layout : Layout
    , visibility : Visibility
    , position : Position
    , size : Size
    , colors : Colors
    , spacing : Spacing
    , text : Text
    , border : Border
    , cursor : String
    , float : Maybe Floating
    , shadow : List Shadow
    , textShadow : List Shadow
    , insetShadow : List Shadow
    , transforms : List Transform
    , filters : List Filter
    }


type Filter
    = Blur Int
    | Greyscale


{-| This type is only valid if the parent has its layout set to `TextLayout`

-}
type Floating
    = FloatLeft
    | FloatRight


type alias Colors =
    { background : Color
    , text : Color
    , textDecoration : Color
    , textHighlight : Color
    , border : Color
    }


type alias Spacing =
    { padding : ( Float, Float, Float, Float )
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


type alias Size =
    { width : Float
    , height : Float
    }


type Layout
    = FlowLayout Flexible
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
    Flex
        { go = Right
        , wrap = True
        , spacing = 10
        , align = center
        }


vertical : Layout
vertical =
    Flex
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


type alias FontStyle =
    { italic : Bool
    , boldness : Boldness
    }


type Boldness
    = Normal
    | Bold
    | Light


type FontAlignment
    = AlignLeft
    | AlignRight
    | AlignCenter
    | Justify
    | JustifyAll


{-| All values are given in 'rem' units
-}
type alias Text =
    { font : String
    , size : Float
    , lineHeight : Float
    , characterOffset : Float
    , style : FontStyle
    , align : FontAlignment
    , decoration : Maybe TextDecoration
    }


type alias TextDecoration =
    { style : TextDecorationStyle
    , position : TextDecorationPosition
    }


type TextDecorationStyle
    = Solid TextDecorationPosition
    | DashedDecoration TextDecorationPosition
    | Double TextDecorationPosition
    | Dotted TextDecorationPosition
    | Wavy TextDecorationPosition


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
    = Solid
    | Dashed
    | Dotted


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
    , spacing = defaultSpacing
    , text = defaultText
    , border = defaultBorder
    , textShadow = []
    , shadow = []
    , insetShadow = []
    , transforms = []
    }


defaultLayout : Layout
defaultLayout =
    Standard


defaultVisibility : Visibility
defaultVisibility =
    Transparent 0


defaultSpacing : Spacing
defaultSpacing =
    { padding = ( 0, 0, 0, 0 )
    }


defaultSize : Size
defaultSize =
    { width = 100
    , height = 100
    }


defaultText : Text
defaultText =
    { font = "georgia"
    , size = 16
    , lineHeight = 16
    , italics = False
    , boldness = Nothing
    , align = AlignLeft
    , decoration = Nothing
    }


defaultBorder : Border
defaultBorder =
    { style = Solid
    , width = ( 0, 0, 0, 0 )
    , corners = ( 0, 0, 0, 0 )
    }


defaultColors : Colors
defaultColors =
    { background = Color.white
    , text = Color.black
    , border = Color.grey
    }


defaultPosition : Position
defaultPosition =
    { relativeTo = FlowPosition
    , anchor = ( AnchorTop, AnchorLeft )
    , position = ( 0, 0 )
    }


(=>) =
    (,)


render : Model -> ( List (Html.Attribute msg), List (Html.Attribute msg) )
render style =
    [ Html.Attributes.style
        (List.concat
            [ renderLayout style.layout
            ]
        )
    ]
        => []


renderLayout : Layout -> List ( String, String )
renderLayout layout =
    case layout of
        NoLayout ->
            [ "display" => "block" ]

        Flex flex ->
            [ "display" => "flex"
            , case ( flex.orientation, flex.direction ) of
                ( Horizontal, Forward ) ->
                    "flex-direction" => "row"

                ( Horizontal, Reverse ) ->
                    "flex-direction" => "row-reverse"

                ( Vertical, Forward ) ->
                    "flex-direction" => "column"

                ( Vertical, Reverse ) ->
                    "flex-direction" => "column-reverse"
            , case flex.wrap of
                NoWrap ->
                    "flex-wrap" => "nowrap"

                Wrap ->
                    "flex-wrap" => "wrap"
            , case flex.justification of
                FlexStart ->
                    "justify-content" => "flex-start"

                FlexEnd ->
                    "justify-content" => "flex-end"

                FlexCenter ->
                    "justify-content" => "center"

                SpaceBetween ->
                    "justify-content" => "space-between"

                SpaceAround ->
                    "justify-content" => "space-around"
            , case flex.alignment.items of
                FlexAlignStart ->
                    "align-items" => "flex-start"

                FlexAlignEnd ->
                    "align-items" => "flex-end"

                FlexAlignCenter ->
                    "align-items" => "center"

                FlexAlignBaseline ->
                    "align-items" => "baseline"

                FlexAlignStretch ->
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
