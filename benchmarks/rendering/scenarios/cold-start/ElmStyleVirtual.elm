module Main exposing (..)

{-

   We want to make sure that lazy is able to perform correctly in style-elements.

   For the setup:

   Render an expensive thing in html.

   Rerender with Lazy.






-}

import Element
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
    Element.layout Internal.WithVirtualCss
        []
        (Element.Lazy.lazy viewStyle 10000)


viewStyle x =
    Element.column []
        (List.repeat x (Element.el [] (Element.text "hello!")))
