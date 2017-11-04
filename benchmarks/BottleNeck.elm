module Main exposing (..)

-- import Next.Internal.Model exposing (..)
-- import Next.Element.Attributes exposing (..)

import AnimationFrame
import Color exposing (Color)
import Html
import Html.Events
import Next.Element exposing (..)
import Next.Element.Content as Content
import Next.Element.Position as Position
import Next.Internal.Style as Internal
import Next.Style.Color as Color
import Next.Style.Font as Font
import Next.Style.Shadow as Shadow
import Time exposing (Time)


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
    if not model then
        Html.button [ Html.Events.onClick Render ] [ Html.text "render!" ]
    else
        layout
            [ Color.text Color.black
            , Color.background Color.white
            , Font.family
                [ Font.typeface "Garamond EB"
                , Font.typeface "georgia"
                , Font.serif
                ]
            ]
        <|
            column []
                [ row
                    [ Color.background Color.white
                    , height (px 80)
                    , Content.verticalCenter
                    ]
                    [ el
                        [ Content.verticalCenter
                        , Content.alignLeft
                        , Position.moveDown 80

                        --, center
                        -- , height fill
                        , Color.background Color.blue
                        , Color.text Color.white
                        ]
                        (text "My Logo")
                    , el
                        [ Content.verticalCenter
                        , Content.center
                        , Font.center

                        -- , center
                        ]
                        (text "My Name is Spartacus")
                    , row
                        [ Content.verticalCenter
                        , Content.alignRight
                        , Color.background Color.yellow
                        ]
                        [ text "hello!"
                        , text "hello!"
                        , el [ Content.verticalCenter ] (text "hello!")
                            |> below
                                (el [] (text "I am below, yup!"))
                        ]
                    ]
                , el
                    [ Font.family
                        [ Font.typeface "Inconsolata"
                        , Font.monospace
                        ]
                    , Content.paddingXY 30 50
                    , Position.center
                    , width (px 600)
                    ]
                    (text Internal.rules)
                , textPage
                    [ Content.spacing 10
                    , Position.center
                    ]
                    [ el
                        [ width (px 50)
                        , height (px 50)
                        , Color.background Color.blue
                        , Position.alignRight
                        ]
                        empty
                    , paragraph []
                        [ text ipsum
                        ]
                    , paragraph []
                        [ text ipsum
                        ]
                    , paragraph []
                        [ text ipsum
                        ]
                    , el
                        [ width (px 50)
                        , height (px 50)
                        , Color.background Color.blue
                        , Position.alignRight
                        ]
                        empty
                    , paragraph []
                        [ text ipsum
                        ]
                    ]
                , column [ Content.spacing 20, Content.paddingAll 20, width (px 200), Color.background Color.grey ]
                    [ el [ width fill, height (px 20), Color.background Color.blue ] empty
                    , el [ width expand, height (px 20), Color.background Color.blue ] empty
                    , el [ width fill, height (px 20), Color.background Color.blue ] empty
                    ]
                ]


ipsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."


{-| Can we propogate a width or height up the tree?

In the following case, we'd like all `el`'s to get width fill

-}
mainOff =
    layout [] <|
        el [] <|
            el
                [ Color.background Color.blue
                , Color.text Color.white
                , width (px 200)
                ]
                (text "fill!")


mainNearby =
    layout
        [ Content.center
        , Content.verticalCenter
        , width (px 200)
        , height (px 200)
        ]
        (text "Hello!"
            |> below
                (el [] (text "I am below, yup!"))
        )
