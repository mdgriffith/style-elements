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
            ( 20
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
            ( 20, Cmd.none )


view i =
    Element.layoutWith
        { options =
            [--Internal.RenderModeOption Internal.NoStaticStyleSheet
            ]
        }
        []
    <|
        Element.row
            [ --     Font.color yellow
              Background.color purple

            -- , Font.center
            -- , Element.padding 50
            ]
            (flip List.map
                (List.range 1 i)
                (\j ->
                    Element.el
                        [ Background.color green
                        ]
                        Element.empty
                )
            )
