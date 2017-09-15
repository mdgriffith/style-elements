module Main exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Style
import Html exposing (Html)
import Color
import Style.Color as Color
import Animation


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { style : Animation.State }


init : ( Model, Cmd Msg )
init =
    ( { style =
            Animation.style
                [ Animation.opacity 1.0
                ]
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.style ]


type Msg
    = FadeInFadeOut
    | Animate Animation.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        FadeInFadeOut ->
            ( { model
                | style =
                    Animation.interrupt
                        [ Animation.to
                            [ Animation.opacity 0
                            ]
                        , Animation.to
                            [ Animation.opacity 1
                            ]
                        ]
                        model.style
              }
            , Cmd.none
            )

        Animate animMsg ->
            ( { model
                | style = Animation.update animMsg model.style
              }
            , Cmd.none
            )


type Styles
    = Box


stylesheet : Style.StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ Style.style Box
            [ Color.background Color.green
            , Color.text Color.white
            ]
        ]


renderAnim : Animation.State -> List (Element.Attribute variation Msg) -> List (Element.Attribute variation Msg)
renderAnim animStyle otherAttrs =
    (List.map Element.Attributes.toAttr <| Animation.render animStyle) ++ otherAttrs


view : Model -> Html Msg
view model =
    Element.viewport stylesheet <|
        el Box
            (renderAnim model.style
                [ onClick FadeInFadeOut
                , padding 25
                , width (px 200)
                , height (px 200)
                , center
                , verticalCenter
                ]
            )
            (text "Click to Animate!")
