module Element exposing (..)

{-| -}

import Html exposing (Html)
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


defaults : Defaults
defaults =
    { typeface = [ "georgia" ]
    , fontSize = 16
    , lineHeight = 1.7
    , spacing = ( 10, 10, 10, 10 )
    , textColor = Color.black
    }


elements : List (Element.Style.Style elem variation animation) -> ElementSheet elem variation animation msg
elements stylesheet =
    ElementSheet
        { defaults = defaults
        , stylesheet = Element.Style.Sheet.render stylesheet
        }


elementsWith : Defaults -> List (Element.Style.Style elem variation animation) -> ElementSheet elem variation animation msg
elementsWith defaults stylesheet =
    ElementSheet
        { defaults = defaults
        , stylesheet = Element.Style.Sheet.render stylesheet
        }


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


el : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
el elem attrs child =
    Element Html.div (Just elem) attrs child Nothing



-- header
-- {-| Sets all children as inline -}
-- paragraph : List Element -> Element
-- {-| Provides spcing as a multiple of the parent spacing -}
-- spacer : Float -> Element
-- sub
-- sup
-- section
-- nav
-- article
-- aside
-- image
-- canvas
-- iframe
-- nav
-- audio : [Sources]
-- video : [sources]
-- enumerate : Style [] children (Defaults to column layout)
-- list : Style [] children (Defaults to column layout)


full : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
full elem attrs child =
    Element Html.div (Just elem) (Spacing ( 0, 0, 0, 0 ) :: width (percent 100) :: height (percent 100) :: attrs) child Nothing


textLayout : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
textLayout elem attrs children =
    Layout Html.div (Style.TextLayout) (Just elem) attrs children


row : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
row elem attrs children =
    Layout Html.div (Style.FlexLayout Style.GoRight []) (Just elem) attrs children


column : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
column elem attrs children =
    Layout Html.div (Style.FlexLayout Style.Down []) (Just elem) attrs children



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


addProp : Attribute variation msg -> Element elem variation msg -> Element elem variation msg
addProp prop el =
    case el of
        Empty ->
            Empty

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
    List.foldl (\(Anchored el) p -> addChild p el) parent insideEls


topLeft : Element elem variation msg -> Anchored (Element elem variation msg)
topLeft el =
    el
        |> addProp (PositionFrame (Within TopLeft))
        |> removeProps [ Align Top, Align Bottom ]
        |> Anchored


topRight : Element elem variation msg -> Anchored (Element elem variation msg)
topRight el =
    el
        |> addProp (PositionFrame (Within TopRight))
        |> removeProps [ Align Top, Align Bottom ]
        |> Anchored


bottomRight : Element elem variation msg -> Anchored (Element elem variation msg)
bottomRight el =
    el
        |> addProp (PositionFrame (Within BottomRight))
        |> removeProps [ Align Top, Align Bottom ]
        |> Anchored


bottomLeft : Element elem variation msg -> Anchored (Element elem variation msg)
bottomLeft el =
    el
        |> addProp (PositionFrame (Within BottomLeft))
        |> removeProps [ Align Top, Align Bottom ]
        |> Anchored


screen : Element elem variation msg -> Element elem variation msg
screen el =
    addProp (PositionFrame (Screen TopLeft)) el


overlay : elem -> Int -> Element elem variation msg -> Element elem variation msg
overlay bg opac child =
    screen <| el bg [ width (percent 100), height (percent 100), opacity opac ] child


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


{-| -}
spacing : ( Float, Float, Float, Float ) -> Attribute variation msg
spacing =
    Spacing


{-| This isn't your grandpa's padding!

If you're new to this library, make sure to check out http://elm.style first!

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
    , elements : ElementSheet elem variation animation msg
    , device : { width : Int, height : Int } -> device
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : device -> model -> Element elem variation msg
    }
    -> Program flags (ElemModel device elem variation animation model msg) (ElementMsg device msg)
programWithFlags prog =
    Html.programWithFlags
        { init = (\flags -> init prog.elements prog.device (prog.init flags))
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
    { elements : ElementSheet elem variation animation msg
    , init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : device -> model -> Element elem variation msg
    , device : { width : Int, height : Int } -> device
    }
    -> Program Never (ElemModel device elem variation animation model msg) (ElementMsg device msg)
program prog =
    Html.program
        { init = init prog.elements prog.device prog.init
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
    { elements : ElementSheet elem variation animation msg
    , model : model
    , view : model -> Element elem variation msg
    , update : msg -> model -> model
    }
    -> Program Never (ElemModel Device elem variation animation model msg) (ElementMsg Device msg)
beginnerProgram prog =
    Html.program
        { init = init prog.elements Device.match <| withCmdNone prog.model
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


init : ElementSheet elem variation animation msg -> ({ width : Int, height : Int } -> device) -> ( model, Cmd msg ) -> ( ElemModel device elem variation animation model msg, Cmd (ElementMsg device msg) )
init elem match ( model, cmd ) =
    ( emptyModel elem match model
    , Cmd.batch
        [ Cmd.map Send cmd
        , Task.perform (Resize match) Window.size
        ]
    )


emptyModel :
    ElementSheet elem variation animation msg
    -> (Window.Size -> device)
    -> model
    -> ElemModel device elem variation animation model msg
emptyModel elem match model =
    ElemModel
        { time = 0
        , device =
            match { width = 1000, height = 1200 }
        , elements = elem
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
        , elements : ElementSheet elem variation animation msg
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
deviceView appView (ElemModel { device, elements, model }) =
    Render.render elements <| appView device model


view : (model -> Element elem variation msg) -> ElemModel Device elem variation animation model msg -> Html msg
view appView (ElemModel { device, elements, model }) =
    Render.render elements <| appView model
