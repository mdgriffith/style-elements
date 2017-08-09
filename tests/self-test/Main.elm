module Main exposing (..)

import Html
import Html.Events exposing (..)
import AutoSelfTest
import Element exposing (..)
import Element.Attributes exposing (..)
import Style
import Test exposing (Test)


main : Program Never number Msg
main =
    Html.program
        { init =
            ( 5
            , Cmd.none
            )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = Refresh Test


update : Msg -> a -> ( a, Cmd msg )
update msg model =
    case msg of
        Refresh test ->
            -- let
            --     _ =
            --         Debug.log "box" ("get bounding box" ++ (toString <| BoundingBox.get "test"))
            -- in
            ( model, Cmd.none )


view : a -> Html.Html Msg
view _ =
    let
        ( elems, tests ) =
            AutoSelfTest.test elementView
    in
        Element.layout (stylesheet) elems


type Styles
    = None


stylesheet =
    Style.styleSheet []


elementView =
    Element.el None [ center, width (percent 60) ] (text "My first Element!")
