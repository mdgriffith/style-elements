module Main exposing (..)

{-
   How performant is it to dynamically render a stylesheet?

   Is it comparable to inline styles?

-}

import AnimationFrame
import Html exposing (..)
import Html.Attributes exposing (..)
import Time exposing (Time)


model =
    { nodes =
        List.range 0 700
            |> List.map toFloat
    , time = 0
    , total = 0
    , skipped = 0
    , running = True
    }


main =
    Html.program
        { init = ( model, Cmd.none )
        , update = update
        , view = view
        , subscriptions =
            \model ->
                if model.running then
                    AnimationFrame.times Tick
                else
                    Sub.none
        }


type Msg
    = Tick Time


update msg model =
    case msg of
        Tick time ->
            let
                newSkipped =
                    if model.time /= 0 && time - model.time > Time.millisecond * 18 then
                        Debug.log "skipped frame" (time - model.time)
                    else
                        0

                newTotal =
                    if model.time == 0 then
                        0
                    else
                        model.total + (time - model.time)
            in
            ( { model
                | time = time
                , total = newTotal
                , skipped = model.skipped + newSkipped
              }
            , Cmd.none
            )


viewStats model =
    div [ class "stats" ]
        [ div [] [ text "skipped(ms)" ]
        , div [] [ text <| toString model.skipped ]
        , div [] [ text "skipped(frames)" ]
        , div [] [ text <| toString (model.skipped / 16.33) ]
        , div [] [ text "total time (seconds)" ]
        , div [] [ text <| toString <| round (Time.inSeconds model.total) ]
        , div [] [ text "frames skipped/minute" ]
        , div [] [ text <| toString (round <| (model.skipped / 16.33) / Time.inMinutes model.total) ]
        ]


view model =
    div []
        [ Html.node "style" [] [ text ".style{background-color:blue;width:10px;height:10px;border-radius:5px;}.stats{width:400px;position:absolute;right:20px;top:20px;}" ]
        , Html.node "style" [] [ text <| String.concat (List.map (style model.time) model.nodes) ]
        , viewStats model
        , div []
            (List.map viewNode model.nodes)
        ]


viewNode i =
    div [ class "style test" ] []


wrap : Float -> Float -> Float
wrap i bound =
    if i > bound then
        0
    else
        i


style : Time -> Float -> String
style time i =
    let
        value =
            Time.inSeconds time
                |> sin
                |> (*) 300.0
                |> (+) 500.0
    in
    ".test{ position:relative;top:0;transform:translateX(" ++ toString value ++ "px)}"



-- ".test-" ++ toString i ++ "{ position:relative;top:0;left:" ++ toString value ++ "px}"
