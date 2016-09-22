module Main exposing (..)

import Elements exposing (..)
import Html.App exposing (beginnerProgram)
import Html.Events exposing (onClick)
import Animation
import Style


type alias Model =
    { buttonStyle : Animation.State
    }


main =
    Html.App.program
        { init = { buttonStyle = Style.init (buttonVariations RedButton) } ! []
        , view = view
        , update = update
        , subscriptions = (\model -> Animation.subscription Animate [ model.buttonStyle ])
        }


view model =
    Style.build <|
        div []
            [ nav []
                [ a [] [ text "home" ]
                , a [] [ text "about" ]
                , a [] [ text "articles" ]
                ]
            , header [] [ text "heres my header" ]
            , h2 [] [ text "and my sub header" ]
            , p [] [ text """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse quis ligula at massa vehicula imperdiet vitae quis nisl. Nullam sit amet nulla imperdiet, volutpat mi non, elementum neque. Etiam feugiat, quam id eleifend rutrum, elit tortor sollicitudin libero, ut accumsan ante metus eu ipsum. Ut vestibulum bibendum lacinia. Donec tempor nisl ac nibh aliquet, nec vehicula turpis bibendum. Donec hendrerit diam eu justo finibus, at tincidunt lectus porta. Duis id augue purus. Nunc at nisl accumsan, accumsan sapien ut, bibendum risus. Morbi ac odio et dui ultricies vehicula in sit amet magna. Cras feugiat nibh ornare enim auctor mollis. Aenean vitae ex id tortor tempor tempor.""" ]
            , button NormalButton [] [ text "button 1" ]
            , button RedButton [] [ text "button 2" ]
            , animatedButton
                model.buttonStyle
                []
                [ text "button 2" ]
            ]


type Msg
    = Animate Animation.Msg
    | ChangeButton



--| ChangeButton


update msg model =
    case msg of
        Animate msg ->
            ( model, Cmd.none )

        ChangeButton ->
            { model
                | buttonStyle =
                    Style.animateTo (buttonVariations RedButton) model.buttonStyle
            }
                ! []



--ChangeButton ->
--    { model
--        | buttonStyle =
--            Style.animateTo RedButton model.buttonStyle
--    }
