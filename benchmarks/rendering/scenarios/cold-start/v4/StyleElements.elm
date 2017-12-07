module Main exposing (..)

{-

   We want to make sure that lazy is able to perform correctly in style-elements.

   For the setup:

   Render an expensive thing in html.

   Rerender with Lazy.






-}

import Color exposing (..)
import Element
import Html exposing (Html)
import Style
import Style.Border as Border
import Style.Color as Color


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


type Style
    = None
    | Styled


styleSheet =
    Style.styleSheet
        [ Style.style Styled
            [ Color.text blue
            , Color.background red
            , Color.border yellow
            , Border.all 2
            ]
        ]


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
    Element.layout styleSheet
        (viewStyle 10000)


viewStyle x =
    Element.column None
        []
        (List.repeat x (Element.el Styled [] (Element.text "hello!")))
