module Main exposing (..)

-- import Next.Internal.Model exposing (..)
-- import Next.Element.Attributes exposing (..)

import AnimationFrame
import Color exposing (Color)
import Html
import Html.Attributes
import Html.Events
import Next.Element exposing (..)
import Next.Element.Content as Content
import Next.Element.Position as Position
import Next.Internal.Slim as Slim
import Next.Internal.Style as Internal
import Next.Style.Color as Color
import Next.Style.Font as Font
import Next.Style.Shadow as Shadow
import Time exposing (Time)


main =
    Html.program
        { init =
            ( { rendering = NoRendering }
            , Cmd.none
            )
        , view = view
        , update = update
        , subscriptions =
            \model -> Sub.none
        }


type RenderAs
    = NoRendering
    | RenderSlim
    | RenderInline


type Msg
    = NoOp
    | RenderSlimNow
    | RenderInlineNow


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RenderSlimNow ->
            ( { rendering = RenderSlim }, Cmd.none )

        RenderInlineNow ->
            ( { rendering = RenderInline }, Cmd.none )


view model =
    case model.rendering of
        NoRendering ->
            Html.div []
                [ Html.button [ Html.Events.onClick RenderSlimNow ] [ Html.text "render slim!" ]
                , Html.button [ Html.Events.onClick RenderInlineNow ] [ Html.text "render inline!" ]
                ]

        RenderSlim ->
            Slim.layout [] <|
                Slim.row
                    []
                    (List.repeat 1000
                        (Slim.el
                            [ Slim.backgroundColor Color.red
                            , Slim.textColor Color.blue
                            , Slim.fontSize 16
                            , Slim.border 1
                            , Slim.borderColor Color.yellow
                            ]
                            (Slim.text "hello")
                        )
                    )

        RenderInline ->
            Html.div
                [ Html.Attributes.style
                    [ ( "display", "flex" )
                    , ( "flex-direction", "row" )
                    ]
                ]
                (Html.node "style" [] [ Html.text Internal.rules ]
                    :: List.repeat 1000
                        (Html.div
                            [ Html.Attributes.class "se el"
                            , Html.Attributes.style
                                [ ( "background-color", "red" )
                                , ( "color", "blue" )
                                , ( "font-size", "16px" )
                                , ( "border-width", "1px" )
                                , ( "border-color", "yellow" )
                                ]
                            ]
                            [ Html.text "hello" ]
                        )
                )


ipsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
