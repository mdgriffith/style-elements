module Element exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Element.Style.Internal.Model as Internal exposing (Length)
import Element.Internal.Model exposing (..)
import Time exposing (Time)
import Element.Device as Device exposing (Device)
import Element.Internal.Render as Render
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


elements : (elem -> Styled elem variation animation msg) -> ElementSheet elem variation animation msg
elements lookup =
    ElementSheet defaults lookup


elementsWith : Defaults -> (elem -> Styled elem variation animation msg) -> ElementSheet elem variation animation msg
elementsWith =
    ElementSheet


{-| In Hierarchy

-}
empty : Element elem variation
empty =
    Empty


text : String -> Element elem variation
text =
    Text NoDecoration


el : elem -> List (Attribute variation) -> Element elem variation -> Element elem variation
el elem attrs child =
    Element (Just elem) attrs child Nothing


full : elem -> List (Attribute variation) -> Element elem variation -> Element elem variation
full elem attrs child =
    Element (Just elem) (Spacing ( 0, 0, 0, 0 ) :: attrs) child Nothing


row : elem -> List (Attribute variation) -> List (Element elem variation) -> Element elem variation
row elem attrs children =
    Layout (Internal.FlexLayout Internal.GoRight []) SpacingAllowed (Just elem) attrs children


column : elem -> List (Attribute variation) -> List (Element elem variation) -> Element elem variation
column elem attrs children =
    Layout (Internal.FlexLayout Internal.Down []) SpacingAllowed (Just elem) attrs children



-- centered : elem -> List (Attribute variation) -> Element elem variation -> Element elem variation
-- centered elem attrs child =
--     Element elem (HCenter :: attrs) child
--


{-|
-}
when : Bool -> Element elem variation -> Element elem variation
when bool elm =
    if bool then
        elm
    else
        empty


addProp : Attribute variation -> Element elem variation -> Element elem variation
addProp prop el =
    case el of
        Empty ->
            Empty

        Layout layout spacing elem attrs els ->
            Layout layout spacing elem (prop :: attrs) els

        Element elem attrs el children ->
            Element elem (prop :: attrs) el children

        Text dec content ->
            Element Nothing [ prop ] (Text dec content) Nothing


removeProps : List (Attribute variation) -> Element elem variation -> Element elem variation
removeProps props el =
    let
        match p =
            not <| List.member p props
    in
        case el of
            Empty ->
                Empty

            Layout layout spacing elem attrs els ->
                Layout layout spacing elem (List.filter match attrs) els

            Element elem attrs el children ->
                Element elem (List.filter match attrs) el children

            Text dec content ->
                Text dec content


addChild : Element elem variation -> Element elem variation -> Element elem variation
addChild parent el =
    case parent of
        Empty ->
            Element Nothing [] Empty (Just [ el ])

        Layout layout spacingAllowed elem attrs children ->
            Layout layout spacingAllowed elem attrs (el :: children)

        Element elem attrs child otherChildren ->
            case otherChildren of
                Nothing ->
                    Element elem attrs child (Just [ el ])

                Just others ->
                    Element elem attrs child (Just (el :: others))

        Text dec content ->
            Element Nothing [] (Text dec content) (Just [ el ])


above : Element elem variation -> Element elem variation -> Element elem variation
above el parent =
    el
        |> addProp (PositionFrame Above)
        |> removeProps [ Anchor Top, Anchor Bottom ]
        |> addChild parent


below : Element elem variation -> Element elem variation -> Element elem variation
below el parent =
    el
        |> addProp (PositionFrame Below)
        |> removeProps [ Anchor Top, Anchor Bottom ]
        |> addChild parent


onRight : Element elem variation -> Element elem variation -> Element elem variation
onRight el parent =
    el
        |> addProp (PositionFrame OnRight)
        |> removeProps [ Anchor Right, Anchor Left ]
        |> addChild parent


onLeft : Element elem variation -> Element elem variation -> Element elem variation
onLeft el parent =
    el
        |> addProp (PositionFrame OnLeft)
        |> removeProps [ Anchor Right, Anchor Left ]
        |> addChild parent


screen : Element elem variation -> Element elem variation
screen el =
    addProp (PositionFrame Screen) el


overlay : elem -> Int -> Element elem variation -> Element elem variation
overlay bg opac child =
    screen <| el bg [ width (percent 100), height (percent 100), opacity opac ] child


{-| A synonym for the identity function.  Useful for relative
-}
nevermind : a -> a
nevermind =
    identity


alignTop : Attribute variation
alignTop =
    Anchor Top


alignBottom : Attribute variation
alignBottom =
    Anchor Bottom


alignLeft : Attribute variation
alignLeft =
    Anchor Left


alignRight : Attribute variation
alignRight =
    Anchor Right



{- Layout Attributes -}


{-| -}
width : Length -> Attribute variation
width =
    Width


{-| -}
height : Length -> Attribute variation
height =
    Height


{-| -}
px : Float -> Length
px =
    Internal.Px


adjust : Int -> Int -> Attribute variation
adjust =
    Position


{-| -}
percent : Float -> Length
percent =
    Internal.Percent


{-| -}
vary : List ( Bool, variation ) -> Attribute variation
vary =
    Variations


{-| -}
spacing : ( Float, Float, Float, Float ) -> Attribute variation
spacing =
    Spacing


{-| This isn't your grandfather's margin!

If you're new to this library, make sure to check out http://elm.style first!


-}
margin : ( Float, Float, Float, Float ) -> Attribute variation
margin =
    Margin


hidden : Attribute variation
hidden =
    Hidden


transparency : Int -> Attribute variation
transparency =
    Transparency


opacity : Int -> Attribute variation
opacity o =
    Transparency (1 - o)



--
-- In your attribute sheet


element : List (StyleAttribute elem variation animation msg) -> Styled elem variation animation msg
element =
    El Html.div


elementAs : HtmlFn msg -> List (StyleAttribute elem variation animation msg) -> Styled elem variation animation msg
elementAs =
    El


programWithFlags :
    { init : flags -> ( model, Cmd msg )
    , elements : ElementSheet elem variation animation msg
    , device : { width : Int, height : Int } -> device
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : device -> model -> Element elem variation
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
    , view : device -> model -> Element elem variation
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
    , view : model -> Element elem variation
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


deviceView : (device -> model -> Element elem variation) -> ElemModel device elem variation animation model msg -> Html msg
deviceView appView (ElemModel { device, elements, model }) =
    Render.render elements <| appView device model


view : (model -> Element elem variation) -> ElemModel Device elem variation animation model msg -> Html msg
view appView (ElemModel { device, elements, model }) =
    Render.render elements <| appView model
