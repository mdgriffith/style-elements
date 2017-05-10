module Main exposing (..)

import Html
import Element exposing (..)
import Style exposing (..)
import Style.Border as Border
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Transitions as Transitions
import Style.Background as Background
import Style.Shadow
import Style.Color
import Color


(=>) =
    (,)


type Styles
    = None
    | Main
    | Page
    | Box
    | Container
    | Label


stylesheet =
    Element.stylesheet
        [ style None []
        , style Main
            [ Style.Color.palette
                { text = Color.darkCharcoal
                , background = Color.white
                , border = Color.lightGrey
                }
            , Border.width (all 1)
            , Border.solid
            , Style.Color.palette
                { text = Color.darkCharcoal
                , background = Color.white
                , border = Color.lightGrey
                }
            ]
        , style Page
            [ Border.rounded (all 5)
            , Border.width (all 5)
            , Border.solid
            , Style.Color.palette
                { text = Color.darkCharcoal
                , background = Color.white
                , border = Color.lightGrey
                }
            ]
        , style Label
            [ Font.size 25
            , Font.center
            ]
        , style Box
            [ Transitions.all
            , Style.Color.palette
                { text = Color.white
                , background = Color.blue
                , border = Color.blue
                }
            , Border.rounded (all 3)
            , paddingHint (all 20)
            , hover
                [ Style.Color.palette
                    { text = Color.white
                    , background = Color.red
                    , border = Color.red
                    }
                , cursor "pointer"
                ]
            ]
        , style Container
            [ Style.Color.palette
                { text = Color.black
                , background = Color.lightGrey
                , border = Color.lightGrey
                }
            , hover
                [ Style.Color.palette
                    { text = Color.black
                    , background = Color.grey
                    , border = Color.grey
                    }
                , cursor "pointer"
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


viewSpacingTest model =
    Element.root stylesheet <|
        row Container
            [ width (px 800), spacing 20 20 ]
            [ el Box [] empty
            , el Box [] empty
            , el Box [] empty
            ]


view model =
    Element.root stylesheet <|
        el None [ center, width (px 800) ] <|
            column Main
                [ spacing 50 50 ]
                [ el Container [ padding (leftRightAndTopBottom 20 5), moveZ 5 ] (text "Single Element")
                , el Container [ padding (leftRightAndTopBottom 20 5), center ] (text "Centered Element")
                , el Container [ padding (leftRightAndTopBottom 20 5), alignRight ] (text "Align Right")
                , el Container [ padding (leftRightAndTopBottom 20 5), center, spacing 20 20 ] (text "Centered ++ 20/20 Spacing Element")
                , row None
                    [ spacing 50 50
                    , center
                    ]
                    [ column None
                        [ spacing 20 40 ]
                        [ el Label [] (text "Anchored Elements")
                        , el Container [ width (px 200), height (px 200) ] empty
                            |> nearby
                                [ el Box [ alignTop, alignRight, width (px 20), height (px 20) ] empty
                                , el Box [ alignTop, alignLeft, width (px 20), height (px 20) ] empty
                                , el Box [ alignBottom, alignRight, width (px 20), height (px 20) ] empty
                                , el Box [ alignBottom, alignLeft, width (px 20), height (px 20) ] empty
                                , el Box [ alignTop, center, width (px 20), height (px 20) ] empty
                                , el Box [ alignBottom, center, width (px 20), height (px 20) ] empty
                                , el Box [ verticalCenter, center, width (px 20), height (px 20) ] empty
                                , el Box [ verticalCenter, alignRight, width (px 20), height (px 20) ] empty
                                , el Box [ verticalCenter, alignLeft, width (px 20), height (px 20) ] empty
                                ]
                        ]
                    , column None
                        [ spacing 20 40 ]
                        [ el Label [] (text "Nearby Elements")
                        , el Container [ width (px 200), height (px 200) ] empty
                            |> nearby
                                [ above <| el Box [ width (px 20), height (px 20) ] empty
                                , above <| el Box [ alignRight, width (px 20), height (px 20) ] empty
                                , above <| el Box [ center, width (px 20), height (px 20) ] empty
                                , below <| el Box [ width (px 20), height (px 20) ] empty
                                , below <| el Box [ alignRight, width (px 20), height (px 20) ] empty
                                , below <| el Box [ center, width (px 20), height (px 20) ] empty
                                , onRight <| el Box [ width (px 20), height (px 20) ] empty
                                , onRight <| el Box [ alignBottom, width (px 20), height (px 20) ] empty
                                , onRight <| el Box [ verticalCenter, width (px 20), height (px 20) ] empty
                                , onLeft <| el Box [ width (px 20), height (px 20) ] empty
                                , onLeft <| el Box [ alignBottom, width (px 20), height (px 20) ] empty
                                , onLeft <| el Box [ verticalCenter, width (px 20), height (px 20) ] empty
                                ]
                        ]
                    ]
                , el Label [] (text "Text Layout")
                , viewTextLayout
                , el Label [] (text "Row Layout")
                , row Container
                    [ spacing 20 20 ]
                    [ box
                    , box
                    , box
                    ]
                , el Label [] (text "Row Alignment")
                , row Container
                    [ spacing 20 20, height (px 400) ]
                    [ el Box [ width (px 100), height (px 100), alignTop ] (text "top")
                    , el Box [ width (px 100), height (px 100), verticalCenter ] (text "vcenter")
                    , el Box [ width (px 100), height (px 100), alignBottom ] (text "bottom")
                    , el Box [ width (px 100), height (px 100), alignRight ] (text "right(no effect)")
                    , el Box [ width (px 100), height (px 100), alignLeft ] (text "left(no effect)")
                    , el Box [ width (px 100), height (px 100), center ] (text "center(no effect)")
                    ]
                , el Label [] (text "Row Width/Heights")
                , row Container
                    [ spacing 20 20, height (px 800) ]
                    [ el Box [ width (px 200), height (fill 1) ] (text "fill height")
                    , el Box [ width (fill 1), height (px 200) ] (text "fill width")
                    ]
                , el Label [] (text "Row Center ++ Spacing")
                , row Container
                    [ center, spacing 20 20 ]
                    [ el Box [ width (px 200), height (px 200) ] empty
                    , el Box [ width (px 200), height (px 200) ] empty
                    , full Box [] (text "full element")
                    ]
                , el Label [] (text "Row Center ++ Spacing ++ padding")
                , row Container
                    [ center, spacing 20 20, padding (all 50) ]
                    [ el Box [ width (px 200), height (px 200) ] empty
                    , el Box [ width (px 200), height (px 200) ] empty
                    , full Box [] (text "full element")
                    ]
                , el Label [] (text "Wrapped Layout")
                , wrappedRow Container
                    [ spacing 20 20 ]
                    [ box
                    , box
                    , box
                    , box
                    , box
                    , box
                    , box
                    , box
                    , box
                    ]
                , el Label [] (text "Column Layout")
                , column Container
                    [ spacing 20 20 ]
                    [ box
                    , box
                    , box
                    ]
                , el Label [] (text "Column Alignments")
                , column Container
                    [ spacing 20 20 ]
                    [ el Box [ width (px 200), height (px 200), alignLeft ] empty
                    , el Box [ width (px 200), height (px 200), center ] empty
                    , el Box [ width (px 200), height (px 200), alignRight ] empty
                    , el Box [ width (px 200), height (px 200), alignTop ] empty
                    , el Box [ width (px 200), height (px 200), alignBottom ] empty
                    , el Box [ width (px 200), height (px 200), verticalCenter ] empty
                    , el Box [ width (fill 1), height (px 200) ] empty
                    ]
                , el Label [] (text "Grid Layout")
                , viewGridLayout
                , el Label [] (text "Named Grid Layout")
                , viewNamedGridLayout
                ]


update msg model =
    ( model, Cmd.none )


box =
    el Box [ width (px 200), height (px 200) ] empty


miniBox =
    el Box [ width (px 20), height (px 20) ] empty


viewTextLayout =
    textLayout Page
        [ padding (all 50)
        , spacing 25 25
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
            [ width (px 300)
            , center
            ]
            [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
            ]
        , full Box [] <|
            text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lectus eget lorem lobortis suscipit. Fusce porta auctor purus sed tempor. Mauris auctor sapien sit amet elementum egestas. Maecenas placerat consequat mauris, at dapibus enim tristique a. Quisque feugiat ultricies lorem nec volutpat. Sed risus enim, facilisis id fermentum quis, eleifend in diam. Suspendisse euismod, urna nec consectetur volutpat, massa libero aliquam urna, hendrerit venenatis leo lacus faucibus nulla. Curabitur et mattis dolor."
        ]


viewWrappedRowLayout =
    text "in progress"


viewGridLayout =
    grid Container
        { columns = [ px 100, px 100, px 100, px 100 ]
        , rows =
            [ px 100
            , px 100
            , px 100
            , px 100
            ]
        }
        []
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
            (el Box [] (text "box"))
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


viewNamedGridLayout =
    namedGrid Container
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
