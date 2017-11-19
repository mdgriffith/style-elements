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
import Html.Attributes
import Html.Events
import Html.Lazy
import Internal.Model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( { renderAs = NothingPlease, count = 0 }, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { renderAs : Render
    , count : Int
    }


type Render
    = HtmlPlease
    | StylePlease
    | NothingPlease


type Msg
    = RenderAs Render


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RenderAs mode ->
            ( { model
                | renderAs = mode
                , count =
                    if mode == model.renderAs then
                        model.count + 1
                    else
                        0
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.button [ Html.Events.onClick <| RenderAs HtmlPlease ] [ Html.text "Html, Please" ]
        , Html.button [ Html.Events.onClick <| RenderAs StylePlease ] [ Html.text "Style, Please" ]
        , Html.div [] [ Html.text (toString model.count) ]
        , case model.renderAs of
            HtmlPlease ->
                Html.div []
                    [ Html.node "style"
                        []
                        [ Html.text """
                        .html-column {
                            display: flex;
                            flex-direction: column;
                            width: 100%;
                            height: auto;
                            min-height: 100%;
                            background-color: green;
                        }
                        .html-el {
                            position: relative;
                            display: flex;
                            flex-direction: row;
                            box-sizing: border-box;
                            margin: 0;
                            padding: 0;
                            border-width: 0;
                            border-style: solid;
                            font: inherit;

                        }


                        """ ]
                    , Html.Lazy.lazy viewHtml 10000
                    ]

            StylePlease ->
                -- layout <|
                --     lazy viewTagged 10000
                Element.layout []
                    (Element.Lazy.lazy viewStyle 10000)

            NothingPlease ->
                Html.text "Nothing rendered.."
        ]



-- on second render, js time goes down to single digit ms, small bit of updating layout, and updating layout tree.


viewHtml x =
    Html.div [ Html.Attributes.class "html-column" ]
        (List.repeat x (Html.div [ Html.Attributes.class "html-el" ] [ Html.text "hello!" ]))



-- On 2nd render, all recalcs, layouts disappear, only Diff step.


viewHtmlStyle x =
    Element.layout [] <|
        -- Element.Lazy.lazy
        (Element.html << viewHtml)
        <|
            x


viewStyle x =
    Element.column []
        (List.repeat x (Element.el [] (Element.text "hello!")))


viewStyleHtml x =
    Element.layout []
        (viewStyle x)
