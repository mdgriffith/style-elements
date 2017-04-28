module Element exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Element.Internal.Model exposing (..)
import Element.Style.Internal.Model as Style exposing (Length)
import Element.Style
import Time exposing (Time)
import Element.Device as Device exposing (Device)
import Element.Internal.Render as Render
import Element.Style.Sheet
import Task
import Window
import Color exposing (Color)


{-| The stylesheet contains the rendered css as a string, and two functions to lookup
-}
type alias StyleSheet class variation animation msg =
    Style.StyleSheet class variation animation msg


defaults : Defaults
defaults =
    { typeface = [ "georgia" ]
    , fontSize = 16
    , lineHeight = 1.7
    , spacing = ( 10, 10, 10, 10 )
    , textColor = Color.black
    }


stylesheet : List (Element.Style.Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheet styles =
    Element.Style.Sheet.render styles


stylesheetWith : Defaults -> List (Element.Style.Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheetWith defaults styles =
    Element.Style.Sheet.render styles


{-|

-}
empty : Element elem variation msg
empty =
    Empty


text : String -> Element elem variation msg
text =
    Text NoDecoration


bold : String -> Element elem variation msg
bold =
    Text Bold


italic : String -> Element elem variation msg
italic =
    Text Italic


strike : String -> Element elem variation msg
strike =
    Text Strike


underline : String -> Element elem variation msg
underline =
    Text Underline


sub : String -> Element elem variation msg
sub =
    Text Sub


super : String -> Element elem variation msg
super =
    Text Super


{-| Paragraph is actually a layout, if you can believe it!

All of the children are set to 'inline-block' if they are not already text elements.

-}
paragraph : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
paragraph elem attrs children =
    Layout Html.p (Style.TextLayout) (Just elem) attrs (List.map (addProp Inline) children)


el : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
el elem attrs child =
    Element Html.div (Just elem) attrs child Nothing


{-| Define a spacer in terms of a multiple of it's spacing.

So, if the parent element is a `column` that set spacing to `5`, and this spacer was a `2`.  Then it would be a 10 pixel spacer.

-}
spacer : Float -> Element elem variation msg
spacer =
    Spacer


image : elem -> String -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
image elem src attrs child =
    Element Html.img (Just elem) (Attr (Html.Attributes.src src) :: attrs) child Nothing


{-| Creates a horizontal hairline.  The Color is set in the defaults of the stylesheet.

If you want a horizontal rule that is something more specific, craft it with `el`!

-}
hairline : Element elem variation msg
hairline =
    Element Html.hr Nothing (width (percent 100) :: height (px 1) :: []) empty Nothing



-- header :: List (Elm) -> List (Elm)
-- {-| Provides spcing as a multiple of the parent spacing -}
-- section
-- nav
-- article
-- aside
-- canvas
-- iframe
-- nav
-- audio : [Sources]
-- video : [sources]


{-| A bulleted list.  Rendered as `<ul>`

A 'column' layout is implied.

Automatically sets children to use `<li>`
-}
list : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
list elem attrs children =
    Layout Html.ul (Style.FlexLayout Style.Down []) (Just elem) attrs (List.map (setNode Html.li) children)


{-| A bulleted list.  Rendered as `<ol>`

A 'column' layout is implied.

Automatically sets children to use `<li>`
-}
enumerate : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
enumerate elem attrs children =
    Layout Html.ol (Style.FlexLayout Style.Down []) (Just elem) attrs (List.map (setNode Html.li) children)


full : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
full elem attrs child =
    Element Html.div (Just elem) (Expand :: attrs) child Nothing


textLayout : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
textLayout elem attrs children =
    Layout Html.div (Style.TextLayout) (Just elem) attrs children


row : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
row elem attrs children =
    Layout Html.div (Style.FlexLayout Style.GoRight []) (Just elem) attrs children


column : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
column elem attrs children =
    Layout Html.div (Style.FlexLayout Style.Down []) (Just elem) attrs children


type alias Grid =
    { rows : List Length
    , columns : List Length
    }


grid : Grid -> elem -> List (Attribute variation msg) -> List (OnGrid (Element elem variation msg)) -> Element elem variation msg
grid template elem attrs children =
    let
        prepare el =
            List.map (\(OnGrid x) -> x) el
    in
        Layout Html.div (Style.Grid (Style.GridTemplate template) []) (Just elem) attrs (prepare children)


type alias NamedGrid =
    { rows : List ( Length, List Style.NamedGridPosition )
    , columns : List Length
    }


namedGrid : NamedGrid -> elem -> List (Attribute variation msg) -> List (NamedOnGrid (Element elem variation msg)) -> Element elem variation msg
namedGrid template elem attrs children =
    let
        prepare el =
            List.map (\(NamedOnGrid x) -> x) el
    in
        Layout Html.div (Style.Grid (Style.NamedGridTemplate template) []) (Just elem) attrs (prepare children)


type GridBox
    = GridBox
        { rowRange : ( Int, Int )
        , colRange : ( Int, Int )
        }


type OnGrid thing
    = OnGrid thing


type NamedOnGrid thing
    = NamedOnGrid thing


area : GridBox -> Element elem variation msg -> OnGrid (Element elem variation msg)
area box el =
    OnGrid el


named : String -> Element elem variation msg -> NamedOnGrid (Element elem variation msg)
named name el =
    NamedOnGrid el


linked : String -> Element elem variation msg -> Element elem variation msg
linked src el =
    Element Html.a Nothing [ Attr (Html.Attributes.href src), Attr (Html.Attributes.rel "noopener noreferrer") ] el Nothing



-- centered : elem -> List (Attribute variation msg) -> Element elem variation -> Element elem variation
-- centered elem attrs child =
--     Element elem (HCenter :: attrs) child
--


{-|
-}
when : Bool -> Element elem variation msg -> Element elem variation msg
when bool elm =
    if bool then
        elm
    else
        empty


setNode : HtmlFn msg -> Element elem variation msg -> Element elem variation msg
setNode node el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout _ layout elem attrs children ->
            Layout node layout elem attrs children

        Element _ elem attrs child otherChildren ->
            Element node elem attrs child otherChildren

        Text dec content ->
            Text dec content


addProp : Attribute variation msg -> Element elem variation msg -> Element elem variation msg
addProp prop el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Element Html.div Nothing [ prop ] (Text dec content) Nothing


removeProps : List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
removeProps props el =
    let
        match p =
            not <| List.member p props
    in
        case el of
            Empty ->
                Empty

            Spacer x ->
                Spacer x

            Layout node layout elem attrs els ->
                Layout node layout elem (List.filter match attrs) els

            Element node elem attrs el children ->
                Element node elem (List.filter match attrs) el children

            Text dec content ->
                Text dec content


addChild : Element elem variation msg -> Element elem variation msg -> Element elem variation msg
addChild parent el =
    case parent of
        Empty ->
            Element Html.div Nothing [] Empty (Just [ el ])

        Spacer x ->
            Spacer x

        Layout node layout elem attrs children ->
            Layout node layout elem attrs (el :: children)

        Element node elem attrs child otherChildren ->
            case otherChildren of
                Nothing ->
                    Element node elem attrs child (Just [ el ])

                Just others ->
                    Element node elem attrs child (Just (el :: others))

        Text dec content ->
            Element Html.div Nothing [] (Text dec content) (Just [ el ])


nearby : List (Nearby (Element elem variation msg)) -> Element elem variation msg -> Element elem variation msg
nearby nearbys parent =
    List.foldl (\(IsNearby el) p -> addChild p el) parent nearbys


above : Element elem variation msg -> Nearby (Element elem variation msg)
above el =
    el
        |> addProp (PositionFrame (Nearby Above))
        |> removeProps [ Align Top, Align Bottom ]
        |> IsNearby


below : Element elem variation msg -> Nearby (Element elem variation msg)
below el =
    el
        |> addProp (PositionFrame (Nearby Below))
        |> removeProps [ Align Top, Align Bottom ]
        |> IsNearby


onRight : Element elem variation msg -> Nearby (Element elem variation msg)
onRight el =
    el
        |> addProp (PositionFrame (Nearby OnRight))
        |> removeProps [ Align Right, Align Left ]
        |> IsNearby


onLeft : Element elem variation msg -> Nearby (Element elem variation msg)
onLeft el =
    el
        |> addProp (PositionFrame (Nearby OnLeft))
        |> removeProps [ Align Right, Align Left ]
        |> IsNearby


within : List (Anchored (Element elem variation msg)) -> Element elem variation msg -> Element elem variation msg
within insideEls parent =
    let
        applyAnchor (Anchored anchor el) parent =
            el
                |> addProp (PositionFrame (Within anchor))
                |> addChild parent
    in
        List.foldl applyAnchor parent insideEls


topLeft : Element elem variation msg -> Anchored (Element elem variation msg)
topLeft el =
    Anchored TopLeft el


topRight : Element elem variation msg -> Anchored (Element elem variation msg)
topRight el =
    Anchored TopRight el


bottomRight : Element elem variation msg -> Anchored (Element elem variation msg)
bottomRight el =
    Anchored BottomRight el


bottomLeft : Element elem variation msg -> Anchored (Element elem variation msg)
bottomLeft el =
    Anchored BottomLeft el


screen : Anchored (Element elem variation msg) -> Element elem variation msg
screen (Anchored anchor el) =
    addProp (PositionFrame (Screen anchor)) el


overlay : elem -> Int -> Element elem variation msg -> Element elem variation msg
overlay bg opac child =
    (screen << topLeft) <| el bg [ width (percent 100), height (percent 100), opacity opac ] child


alignTop : Attribute variation msg
alignTop =
    Align Top


alignBottom : Attribute variation msg
alignBottom =
    Align Bottom


alignLeft : Attribute variation msg
alignLeft =
    Align Left


alignRight : Attribute variation msg
alignRight =
    Align Right



{- Layout Attributes -}


{-| -}
width : Length -> Attribute variation msg
width =
    Width


{-| -}
height : Length -> Attribute variation msg
height =
    Height


{-| -}
px : Float -> Length
px =
    Style.Px


{-| Adjust the position of the element.

Arguemnts are given as x and y coordinates, where positive is right and down.

-}
move : Int -> Int -> Attribute variation msg
move =
    Position


{-| -}
percent : Float -> Length
percent =
    Style.Percent


{-| -}
vary : variation -> Bool -> Attribute variation msg
vary =
    Vary


{-| The horizontal and vertical spacing.
-}
spacing : Float -> Float -> Attribute variation msg
spacing =
    Spacing


{-|
-}
padding : ( Float, Float, Float, Float ) -> Attribute variation msg
padding =
    Padding


hidden : Attribute variation msg
hidden =
    Hidden


transparency : Int -> Attribute variation msg
transparency =
    Transparency


opacity : Int -> Attribute variation msg
opacity o =
    Transparency (1 - o)


programWithFlags :
    { init : flags -> ( model, Cmd msg )
    , stylesheet : StyleSheet elem variation animation msg
    , device : { width : Int, height : Int } -> device
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : device -> model -> Element elem variation msg
    }
    -> Program flags (ElemModel device elem variation animation model msg) (ElementMsg device msg)
programWithFlags prog =
    Html.programWithFlags
        { init = (\flags -> init prog.stylesheet prog.device (prog.init flags))
        , update = update prog.update
        , view = (\model -> Html.map Send <| deviceView prog.view model)
        , subscriptions =
            (\(ElemModel { model }) ->
                Sub.batch
                    [ Window.resizes (Resize prog.device)
                    , Sub.map Send <| prog.subscriptions model
                    ]
            )
        }


program :
    { stylesheet : StyleSheet elem variation animation msg
    , init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : device -> model -> Element elem variation msg
    , device : { width : Int, height : Int } -> device
    }
    -> Program Never (ElemModel device elem variation animation model msg) (ElementMsg device msg)
program prog =
    Html.program
        { init = init prog.stylesheet prog.device prog.init
        , update = update prog.update
        , view = (\model -> Html.map Send <| deviceView prog.view model)
        , subscriptions =
            (\(ElemModel { model }) ->
                Sub.batch
                    [ Window.resizes (Resize prog.device)
                    , Sub.map Send <| prog.subscriptions model
                    ]
            )
        }


beginnerProgram :
    { stylesheet : StyleSheet elem variation animation msg
    , model : model
    , view : model -> Element elem variation msg
    , update : msg -> model -> model
    }
    -> Program Never (ElemModel Device elem variation animation model msg) (ElementMsg Device msg)
beginnerProgram prog =
    Html.program
        { init = init prog.stylesheet Device.match <| withCmdNone prog.model
        , update = update (\msg model -> withCmdNone <| prog.update msg model)
        , view = (\model -> Html.map Send <| view prog.view model)
        , subscriptions =
            (\(ElemModel { model }) ->
                Sub.batch
                    [ Window.resizes (Resize Device.match)
                    ]
            )
        }


withCmdNone : model -> ( model, Cmd msg )
withCmdNone model =
    ( model, Cmd.none )


init : StyleSheet elem variation animation msg -> ({ width : Int, height : Int } -> device) -> ( model, Cmd msg ) -> ( ElemModel device elem variation animation model msg, Cmd (ElementMsg device msg) )
init elem match ( model, cmd ) =
    ( emptyModel elem match model
    , Cmd.batch
        [ Cmd.map Send cmd
        , Task.perform (Resize match) Window.size
        ]
    )


emptyModel :
    StyleSheet elem variation animation msg
    -> (Window.Size -> device)
    -> model
    -> ElemModel device elem variation animation model msg
emptyModel stylesheet match model =
    ElemModel
        { time = 0
        , device =
            match { width = 1000, height = 1200 }
        , stylesheet = stylesheet
        , model = model
        }


type ElementMsg device msg
    = Send msg
    | Tick Time
    | Resize (Window.Size -> device) Window.Size


type ElemModel device elem variation animation model msg
    = ElemModel
        { time : Time
        , device : device
        , stylesheet : StyleSheet elem variation animation msg
        , model : model
        }


update : (msg -> model -> ( model, Cmd msg )) -> ElementMsg device msg -> ElemModel device elem variation animation model msg -> ( ElemModel device elem variation animation model msg, Cmd (ElementMsg device msg) )
update appUpdate elemMsg elemModel =
    case elemMsg of
        Send msg ->
            ( elemModel, Cmd.none )

        Tick time ->
            ( elemModel, Cmd.none )

        Resize match size ->
            ( case elemModel of
                ElemModel elmRecord ->
                    ElemModel { elmRecord | device = match size }
            , Cmd.none
            )


deviceView : (device -> model -> Element elem variation msg) -> ElemModel device elem variation animation model msg -> Html msg
deviceView appView (ElemModel { device, stylesheet, model }) =
    Render.render stylesheet <| appView device model


view : (model -> Element elem variation msg) -> ElemModel Device elem variation animation model msg -> Html msg
view appView (ElemModel { device, stylesheet, model }) =
    Render.render stylesheet <| appView model
