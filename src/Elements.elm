module Elements exposing (..)

{-| -}

import Html exposing (Html)
import Style.Internal.Model as Internal exposing (Length)
import Element.Internal.Model exposing (..)
import Window
import Time exposing (Time)
import Element.Device as Device exposing (Device)
import Element.Internal.Render as Render


{-| In Hierarchy

-}
empty : Element elem variation
empty =
    Empty


text : String -> Element elem variation
text =
    Text


el : elem -> List (Attribute variation) -> Element elem variation -> Element elem variation
el =
    Element


row : elem -> List (Attribute variation) -> List (Element elem variation) -> Element elem variation
row elem attrs children =
    Layout (Internal.FlexLayout Internal.GoRight []) elem attrs children


column : elem -> List (Attribute variation) -> List (Element elem variation) -> Element elem variation
column elem attrs children =
    Layout (Internal.FlexLayout Internal.Down []) elem attrs children



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



--
-- Relative Positioning
--


above : Element elem variation -> Element elem variation -> Element elem variation
above a b =
    b


below : Element elem variation -> Element elem variation -> Element elem variation
below a b =
    b


toRight : Element elem variation -> Element elem variation -> Element elem variation
toRight a b =
    b


toLeft : Element elem variation -> Element elem variation -> Element elem variation
toLeft a b =
    b



--
-- from topLeft
-- screen : Element elem variation -> Element elem variation
-- screen =
--     identity
-- overlay : elem -> Element elem variation -> Element elem variation
-- overlay bg child =
--     screen <| Element bg [ width (percent 100), height (percent 100) ] child


{-| A synonym for the identity function.  Useful for relative
-}
nevermind : a -> a
nevermind =
    identity



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
vary : List ( Bool, variation ) -> Attribute variation
vary =
    Variations


spacing : Float -> Float -> Float -> Float -> Attribute variation
spacing =
    Spacing


hidden : Attribute variation
hidden =
    Hidden


transparency : Int -> Attribute variation
transparency =
    Transparency



--
-- In your attribute sheet


element : List (StyleAttribute elem variation animation msg) -> Styled elem variation animation msg
element =
    El Html.div


elementAs : HtmlFn msg -> List (StyleAttribute elem variation animation msg) -> Styled elem variation animation msg
elementAs =
    El


program :
    { elements : elem -> Styled elem variation animation msg
    , init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : Device -> model -> Element elem variation
    }
    -> Program Never (ElemModel elem variation animation model msg) (ElementMsg msg)
program prog =
    Html.program
        { init = init prog.elements prog.init
        , update = update prog.update
        , view = (\model -> Html.map Send <| view prog.view model)
        , subscriptions =
            (\(ElemModel { model }) ->
                Sub.batch
                    [ Window.resizes Resize
                    , Sub.map Send <| prog.subscriptions model
                    ]
            )
        }



-- Wiring Functions
-- program : -> Program Never model msg


init : (elem -> Styled elem variation animation msg) -> ( model, Cmd msg ) -> ( ElemModel elem variation animation model msg, Cmd (ElementMsg msg) )
init elem ( model, cmd ) =
    ( emptyModel elem model
    , Cmd.batch
        [ Cmd.map Send cmd
        ]
    )



-- emptyModel : ElemModel


emptyModel :
    (elem -> Styled elem variation animation msg)
    -> model
    -> ElemModel elem variation animation model msg
emptyModel elem model =
    ElemModel
        { time = 0
        , device =
            Device.match { width = 1000, height = 1200 }
        , elements = elem
        , model = model
        }


type ElementMsg msg
    = Send msg
    | Tick Time
    | Resize Window.Size


type ElemModel elem variation animation model msg
    = ElemModel
        { time : Time
        , device : Device
        , elements : elem -> Styled elem variation animation msg
        , model : model
        }


update : (msg -> model -> ( model, Cmd msg )) -> ElementMsg msg -> ElemModel elem variation animation model msg -> ( ElemModel elem variation animation model msg, Cmd (ElementMsg msg) )
update appUpdate elemMsg elemModel =
    case elemMsg of
        Send msg ->
            ( elemModel, Cmd.none )

        Tick time ->
            ( elemModel, Cmd.none )

        Resize size ->
            ( case elemModel of
                ElemModel elmRecord ->
                    ElemModel { elmRecord | device = Device.match size }
            , Cmd.none
            )


view : (Device -> model -> Element elem variation) -> ElemModel elem variation animation model msg -> Html msg
view appView (ElemModel { device, elements, model }) =
    Render.render elements <| appView device model
