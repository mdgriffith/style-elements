module Main exposing (..)

{-

   We want to make sure that lazy is able to perform correctly in style-elements.

   For the setup:

   Render an expensive thing in html.

   Rerender with Lazy.






-}

import Color exposing (..)
import Element
import Element.Border as Border
import Element.Color as Color
import Element.Lazy
import Html exposing (Html)
import Internal.Model as Internal


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Model =
    Int


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( 0, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Element.layoutMode Internal.WithVirtualCss
        []
        (viewStyle 10000)


viewStyle x =
    Element.column []
        (List.repeat x (Element.el [ Color.text blue, Color.background red, Color.border yellow, Border.all 2 ] (Element.text "hello!")))
