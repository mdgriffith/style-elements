port module Main exposing (..)

{-| -}

import Dict exposing (Dict)
import Element
import Html exposing (Html)
import Layout


-- match : Dict String Found -> Element -> Result String (Analyzed Element)
-- match dict el =
--     Debug.crash "yup"
-- {-| Render elements as Html
-- -}
-- render : Element -> Html msg
-- render el =
--     Html.text "yup"
-- type Test
--     = Placeholder
-- {-| Convert elements into a test suite
-- -}
-- test : Analyzed Element -> Test
-- test el =
--     Placeholder
{- Actual Rendering -}


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    ()


type Msg
    = NoOp
    | RefreshBoundingBox
        { id : String
        , bbox : Layout.BoundingBox
        , style : Layout.Style
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RefreshBoundingBox box ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.text "New Html Program"
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ styles RefreshBoundingBox
        ]


init : ( Model, Cmd Msg )
init =
    ( ()
    , Cmd.none
    )


port analyze : String -> Cmd msg


port styles : ({ id : String, bbox : Layout.BoundingBox, style : Layout.Style } -> msg) -> Sub msg
