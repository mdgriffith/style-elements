module Main exposing (..)

import Color exposing (..)
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Internal.Model as Internal


main =
    Html.program
        { init =
            ( False
            , Cmd.none
            )
        , view = view
        , update = update
        , subscriptions =
            \model -> Sub.none
        }


type Msg
    = NoOp
    | Render


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Render ->
            ( True, Cmd.none )


view model =
    Element.layoutWith
        { options =
            [--Internal.RenderModeOption Internal.NoStaticStyleSheet
            ]
        }
        [ Font.color yellow
        , Background.color purple
        , Font.center
        , Element.padding 50
        ]
    <|
        Element.el
            [ Font.color yellow
            , Background.color green
            , Font.size 30
            , Border.width 3
            , Border.color yellow
            ]
            Element.empty
