module VisualTest exposing (..)

import Color
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Keyed
import Html
import Style exposing (..)
import Style.Background as Background
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Transition as Transition


(=>) =
    (,)


type Styles
    = None
    | Main
    | Page
    | Box
    | Container
    | Label


options =
    [ Style.unguarded
    ]


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.stylesheetWith options
        [ style None []
        , style Main
            [ Border.all 1
            , Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            , Font.typeface [ "helvetica", "arial", "sans-serif" ]
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style Page
            [ Border.rounded 5
            , Border.all 5
            , Border.solid
            , Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            ]
        , style Label
            [ Font.size 25
            , Font.center
            ]
        , style Box
            [ Transition.all
            , Color.text Color.white
            , Color.background Color.blue
            , Color.border Color.blue
            , Border.rounded 3
            , paddingHint 20
            , hover
                [ Color.text Color.white
                , Color.background Color.red
                , Color.border Color.red
                , cursor "pointer"
                ]
            ]
        , style Container
            [ Color.text Color.black
            , Color.background Color.lightGrey
            , Color.border Color.lightGrey
            , hover
                [ Color.background Color.grey
                , Color.border Color.grey
                , cursor "pointer"
                ]
            ]
        ]


testForm =
    [ Element.form <|
        column
            Box
            [ spacingXY 10 20 ]
            [ checkbox True None [] (text "Yes, Lunch pls.")
            , label None [] (text "check this out") <|
                inputText None [] "The Value!"
            , label None [] (text "check this out") <|
                textArea None [] "The Value!"
            , radio "lunch"
                None
                []
                [ option "burrito" True (text "A Burrito!")
                , option "taco" False (text " A Taco!")
                ]
            , select "favorite-animal"
                None
                []
                [ option "manatee" False (text "Manatees are pretty cool")
                , option "pangolin" False (text "But so are pangolins")
                , option "bee" True (text "Bees")
                ]
            ]
    ]


main =
    Html.program
        { init = ( 0, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


viewDEP model =
    Element.root stylesheet <|
        el None [ center, width (px 800) ] <|
            column Main
                [ spacing 100, padding 10 ]
                [ el Box [ width (px 40), height (px 40) ] empty
                , el Box [ spacing 10, width (px 40), height (px 40) ] empty
                , el Box [ width (px 40), height (px 40) ] empty
                , el Box [ width (px 40), height (px 40) ] <|
                    el Box [ spacing 10, width (px 40), height (px 40) ] empty
                ]



-- view model =
--     Element.root stylesheet <|
--         el None [ center, width (px 800) ] <|
--             column None
--                 [ spacing 100, padding 100 ]
--                 [ row Container
--                     [ spacing 30, moveX 20, center ]
--                     [ el Box [ width (px 100), height (px 100) ] empty
--                     , el Box [ width (px 100), height (px 100) ] empty
--                     , el Box [ width (px 100), height (px 100) ] empty
--                     ]
--                 , textLayout None
--                     [ spacing 20, center ]
--                     [ row Container
--                         [ spacing 30, moveX 20, center ]
--                         [ el Box [ width (px 100), height (px 100) ] empty
--                         , el Box [ width (px 100), height (px 100) ] empty
--                         , el Box [ width (px 100), height (px 100) ] empty
--                         ]
--                     ]
--                 ]


view model =
    Element.root stylesheet <|
        el None [ center, width (px 800) ] <|
            column Main
                [ spacingXY 50 100, padding 10 ]
                (List.concat
                    [ basics
                    , anchored
                    , viewTextLayout
                    , viewRowLayouts
                    , viewColumnLayouts
                    , viewGridLayout
                    , viewNamedGridLayout
                    , testForm
                    ]
                )


basics =
    [ el Container [ paddingXY 20 5 ] (text "Single Element")
    , el Container [ moveX 20, moveY 20, paddingXY 20 5 ] (text "Single Element")
    , el Container [ paddingLeft 20, paddingRight 5 ] (text "Single Element")
    , el Container [ paddingXY 20 5, alignLeft ] (text "Single Element")
    , el Container [ paddingXY 20 5, center, width (px 200) ] (text "Centered Element")
    , el Container [ paddingXY 20 5, alignRight ] (text "Align Right")
    , el Container [ paddingXY 20 5, center, spacingXY 20 20, width (px 200) ] (text "Centered ++ 20/20 Spacing Element")
    , el Container [ paddingXY 20 5, center, width (percent 100) ] (text "Single Element")
    ]


anchored =
    [ row None
        [ spacingXY 150 150
        , center
        ]
        [ column None
            [ spacingXY 20 60 ]
            [ el Label [] (text "Anchored Elements")
            , el Container [ width (px 200), height (px 200) ] empty
                |> within
                    [ el Box [ alignTop, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ alignTop, alignLeft, width (px 40), height (px 40) ] empty
                    , el Box [ alignBottom, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ alignBottom, alignLeft, width (px 40), height (px 40) ] empty
                    , el Box [ alignTop, center, width (px 40), height (px 40) ] empty
                    , el Box [ alignBottom, center, width (px 40), height (px 40) ] empty
                    , el Box [ verticalCenter, center, width (px 40), height (px 40) ] empty
                    , el Box [ verticalCenter, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ verticalCenter, alignLeft, width (px 40), height (px 40) ] empty
                    ]
            ]
        , article <|
            column
                None
                [ spacingXY 20 60 ]
                [ section <| el Label [] (text "Nearby Elements")
                , el Container [ width (px 200), height (px 200) ] empty
                    |> above
                        [ el Box [ width (px 40), height (px 40) ] empty
                        , el Box [ alignRight, width (px 40), height (px 40) ] empty
                        , el Box [ center, width (px 40), height (px 40) ] empty
                        ]
                    |> below
                        [ el Box [ width (px 40), height (px 40) ] empty
                        , el Box [ alignRight, width (px 40), height (px 40) ] empty
                        , el Box [ center, width (px 40), height (px 40) ] empty
                        ]
                    |> onRight
                        [ el Box [ width (px 40), height (px 40) ] empty
                        , el Box [ alignBottom, width (px 40), height (px 40) ] empty
                        , el Box [ verticalCenter, width (px 40), height (px 40) ] empty
                        ]
                    |> onLeft
                        [ el Box [ width (px 40), height (px 40) ] empty
                        , el Box [ alignBottom, width (px 40), height (px 40) ] empty
                        , el Box [ verticalCenter, width (px 40), height (px 40) ] empty
                        ]
                ]
        ]
    , row None
        [ spacingXY 150 150
        , center
        ]
        [ column None
            [ spacingXY 20 60 ]
            [ el Label [] (text "Move 20 20")
            , el Container [ width (px 200), height (px 200) ] empty
                |> within
                    [ el Box [ moveXY 20 20, alignTop, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignTop, alignLeft, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignBottom, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignBottom, alignLeft, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignTop, center, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignBottom, center, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, verticalCenter, center, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, verticalCenter, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, verticalCenter, alignLeft, width (px 40), height (px 40) ] empty
                    ]
            ]
        , column None
            [ spacingXY 20 60 ]
            [ el Label [] (text "Move 20 20")
            , el Container [ width (px 200), height (px 200) ] empty
                |> above
                    [ el Box [ moveXY 20 20, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, center, width (px 40), height (px 40) ] empty
                    ]
                |> below
                    [ el Box [ moveXY 20 20, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignRight, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, center, width (px 40), height (px 40) ] empty
                    ]
                |> onRight
                    [ el Box [ moveXY 20 20, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignBottom, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, verticalCenter, width (px 40), height (px 40) ] empty
                    ]
                |> onLeft
                    [ el Box [ moveXY 20 20, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, alignBottom, width (px 40), height (px 40) ] empty
                    , el Box [ moveXY 20 20, verticalCenter, width (px 40), height (px 40) ] empty
                    ]
            ]
        ]
    ]


update msg model =
    ( model, Cmd.none )


box =
    el Box [ width (px 200), height (px 200) ] empty


miniBox =
    el Box [ width (px 20), height (px 20) ] empty


viewTextLayout =
    [ el Label [] (text "Text Layout")
    , textLayout Page
        [ padding 50
        , spacingXY 25 25
        ]
        [ el Box
            [ width (px 200)
            , height (px 300)
            , alignLeft
            ]
            empty
        , paragraph None
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , hairline Container
        , paragraph None
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , paragraph None
            [ width (px 500)
            , center
            ]
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , paragraph None
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , el Box
            [ width (px 200)
            , height (px 300)
            , alignRight
            , spacing 100
            ]
            empty
        , paragraph None
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , paragraph None
            []
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , full Box [] <|
            text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        ]
    ]


viewRowLayouts =
    [ el Label [] (text "Row Layout")
    , row Container
        [ spacingXY 20 20 ]
        [ box
        , box
        , box
        ]
    , el Label [] (text "Row Child Alignment")
    , row Container
        [ spacingXY 20 20, height (px 400) ]
        [ el Box [ width (px 100), height (px 100), alignTop ] (text "top")
        , el Box [ width (px 100), height (px 100), verticalCenter ] (text "vcenter")
        , el Box [ width (px 100), height (px 100), alignBottom ] (text "bottom")
        , el Box [ width (px 100), height (px 100), alignRight ] (text "right (no effect)")
        , el Box [ width (px 100), height (px 100), alignLeft ] (text "left (no effect)")
        , el Box [ width (px 100), height (px 100), center ] (text "center (no effect)")
        ]
    , el Label [] (text "Row Center Alignment")
    , row Container
        [ spacingXY 20 20, alignRight ]
        [ el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        ]
    , el Label [] (text "Row Width/Heights")
    , row Container
        [ spacingXY 20 20, height (px 800) ]
        [ el Box [ width (px 200), height (fill 1) ] (text "fill height")
        , el Box [ width (fill 1), height (px 200) ] (text "fill width")
        ]
    , el Label [] (text "Row Center ++ Spacing")
    , row Container
        [ center, spacingXY 20 20 ]
        [ el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        , full Box [ width (px 100) ] (text "full element")
        ]
    , el Label [] (text "Row Center ++ Spacing ++ padding")
    , row Container
        [ center, spacingXY 20 20, padding 50 ]
        [ el Box [ width (px 100), height (px 100) ] empty
        , el Box [ width (px 100), height (px 100) ] empty
        , full Box [ width (px 100) ] (text "full element")
        ]
    , el Label [] (text "Wrapped Row Layout")
    , wrappedRow Container
        [ spacingXY 20 20 ]
        [ el Box [ width (px 100), height (px 50) ] empty
        , el Box [ width (px 20), height (px 50) ] empty
        , el Box [ width (px 200), height (px 50) ] empty
        , el Box [ width (px 120), height (px 50) ] empty
        , el Box [ width (px 10), height (px 50) ] empty
        , el Box [ width (px 100), height (px 50) ] empty
        , el Box [ width (px 180), height (px 50) ] empty
        , el Box [ width (px 20), height (px 50) ] empty
        , el Box [ width (px 25), height (px 50) ] empty
        ]
    ]


viewColumnLayouts =
    [ el Label [] (text "Column Layout")
    , column Container
        [ spacingXY 20 20 ]
        [ box
        , box
        , box
        ]
    , el Label [] (text "Column Center ++ Spacing")
    , column Container
        [ spacingXY 20 20 ]
        [ el Box [ width (px 200), height (px 200) ] empty
        , el Box [ width (percent 100), height (px 200) ] (text "100% width")
        , el Box [ width (px 200), height (px 200) ] empty
        , full Box [ height (px 200) ] (text "full element")
        , el Box [ width (px 200), height (px 200) ] empty
        , full Box [ height (px 200) ] (text "full element")
        ]
    , el Label [] (text "Row Center ++ Spacing ++ padding")
    , column Container
        [ spacingXY 20 20, padding 50 ]
        [ el Box [ width (px 200), height (px 200) ] empty
        , el Box [ width (percent 100), height (px 200) ] (text "100% width")
        , el Box [ width (px 200), height (px 200) ] empty
        , full Box [ height (px 200) ] (text "full element")
        ]
    , el Label [] (text "Column Alignments")
    , column Container
        [ spacingXY 20 20 ]
        [ el Box [ width (px 200), height (px 200), alignLeft ] empty
        , el Box [ width (px 200), height (px 200), center ] empty
        , el Box [ width (px 200), height (px 200), alignRight ] empty
        , el Box [ width (px 200), height (px 200), alignTop ] empty
        , el Box [ width (px 200), height (px 200), alignBottom ] empty
        , el Box [ width (px 200), height (px 200), verticalCenter ] empty
        ]
    , el Label [] (text "Column Alignments ++ Width fill")
    , column Container
        [ spacingXY 20 20 ]
        [ el Box [ width (fill 1), height (px 200), alignLeft ] empty
        , el Box [ width (fill 1), height (px 200), center ] empty
        , el Box [ width (fill 1), height (px 200), alignRight ] empty
        , el Box [ width (fill 1), height (px 200), alignTop ] empty
        , el Box [ width (fill 1), height (px 200), alignBottom ] empty
        , el Box [ width (fill 1), height (px 200), verticalCenter ] empty
        ]
    , el Label [] (text "Column Alignments ++ Height fill")
    , column Container
        [ spacingXY 20 20 ]
        [ el Box [ width (px 200), height (fill 1), alignLeft ] empty
        , el Box [ width (px 200), height (fill 1), center ] empty
        , el Box [ width (px 200), height (fill 1), alignRight ] empty
        , el Box [ width (px 200), height (fill 1), alignTop ] empty
        , el Box [ width (px 200), height (fill 1), alignBottom ] empty
        , el Box [ width (px 200), height (fill 1), verticalCenter ] empty
        ]
    ]


viewGridLayout =
    [ el Label [] (text "Grid Layout")
    , grid Container
        { columns = [ px 100, px 100, px 100, px 100 ]
        , rows =
            [ px 100
            , px 100
            , px 100
            , px 100
            ]
        }
        [ spacing 20 ]
        [ area
            { start = ( 0, 0 )
            , width = 1
            , height = 1
            }
            (el Box [] (text "box"))
        , area
            { start = ( 1, 1 )
            , width = 1
            , height = 2
            }
            (el Box [ spacing 100 ] (text "box"))
        , area
            { start = ( 2, 1 )
            , width = 2
            , height = 2
            }
            (el Box [] (text "box"))
        , area
            { start = ( 1, 0 )
            , width = 1
            , height = 1
            }
            (el Box [] (text "box"))
        ]
    ]


viewNamedGridLayout =
    [ el Label [] (text "Named Grid Layout")
    , namedGrid Container
        { columns = [ px 200, px 200, px 200, fill 1 ]
        , rows =
            [ px 200 => [ spanAll "header" ]
            , px 200 => [ span 3 "content", span 1 "sidebar" ]
            , px 200 => [ span 3 "content", span 1 "sidebar" ]
            , px 200 => [ spanAll "footer" ]
            ]
        }
        []
        [ named "header"
            (el Box [] (text "box"))
        , named "sidebar"
            (el Box [] (text "box"))
        ]
    ]


viewTransforms =
    [ el Label [] (text "Transformations")
    , row Container
        [ spacingXY 20 20 ]
        [ el Box
            [ width (px 200)
            , height (fill 1)
            ]
            empty
        ]
    ]
