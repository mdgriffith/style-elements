module Internal.Style exposing (..)

import Html


type Class
    = Class String (List Rule)


type Rule
    = Prop String String
    | Child String (List Rule)
    | Supports ( String, String ) (List ( String, String ))
    | Descriptor String (List Rule)
    | Adjacent String (List Rule)
    | Batch (List Rule)


type StyleClasses
    = Root
    | Any
    | Single
    | Row
    | Column
    | Paragraph
    | Page
    | Text
    | Grid
    | Spacer


alignments =
    [ Top
    , Bottom
    , Right
    , Left
    , CenterX
    , CenterY
    ]


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | Within
    | Behind


locations =
    let
        loc =
            Above

        _ =
            case loc of
                Above ->
                    ()

                Below ->
                    ()

                OnRight ->
                    ()

                OnLeft ->
                    ()

                Within ->
                    ()

                Behind ->
                    ()
    in
    [ Above
    , Below
    , OnRight
    , OnLeft
    , Within
    , Behind
    ]


selfName desc =
    case desc of
        Self Top ->
            ".self-top"

        Self Bottom ->
            ".self-bottom"

        Self Right ->
            ".self-right"

        Self Left ->
            ".self-left"

        Self CenterX ->
            ".self-center-x"

        Self CenterY ->
            ".self-center-y"


contentName desc =
    case desc of
        Content Top ->
            ".content-top"

        Content Bottom ->
            ".content-bottom"

        Content Right ->
            ".content-right"

        Content Left ->
            ".content-left"

        Content CenterX ->
            ".content-center-x"

        Content CenterY ->
            ".content-center-y"


locationName loc =
    case loc of
        Above ->
            ".above"

        Below ->
            ".below"

        OnRight ->
            ".on-right"

        OnLeft ->
            ".on-left"

        Within ->
            ".infront"

        Behind ->
            ".behind"


describeAlignment values =
    let
        createDescription alignment =
            let
                ( content, indiv ) =
                    values alignment
            in
            [ Descriptor (contentName (Content alignment)) <|
                content
            , Child (class Any)
                [ Descriptor (selfName <| Self alignment) indiv
                ]
            ]
    in
    Batch <|
        List.concatMap createDescription alignments


gridAlignments values =
    let
        createDescription alignment =
            [ Child (class Any)
                [ Descriptor (selfName <| Self alignment) (values alignment)
                ]
            ]
    in
    Batch <|
        List.concatMap createDescription alignments


type SelfDescriptor
    = Self Alignment


type ContentDescriptor
    = Content Alignment


type Alignment
    = Top
    | Bottom
    | Right
    | Left
    | CenterX
    | CenterY


class : StyleClasses -> String
class cls =
    case cls of
        Root ->
            ".style-elements"

        Any ->
            ".se"

        Single ->
            ".se.el"

        Row ->
            ".se.row"

        Column ->
            ".se.column"

        Page ->
            ".se.page"

        Paragraph ->
            ".se.paragraph"

        Text ->
            ".se.text"

        Grid ->
            ".se.grid"

        Spacer ->
            ".se.spacer"


type Intermediate
    = Intermediate
        { selector : String
        , props : List ( String, String )
        , closing : String
        , others : List Intermediate
        }


emptyIntermediate : String -> String -> Intermediate
emptyIntermediate selector closing =
    Intermediate
        { selector = selector
        , props = []
        , closing = closing
        , others = []
        }


renderRules : Intermediate -> List Rule -> Intermediate
renderRules (Intermediate parent) rules =
    let
        generateIntermediates rule rendered =
            case rule of
                Prop name val ->
                    { rendered | props = ( name, val ) :: rendered.props }

                Supports ( prop, value ) props ->
                    { rendered
                        | others =
                            Intermediate
                                { selector = "@supports (" ++ prop ++ ":" ++ value ++ ") {" ++ parent.selector
                                , props = props
                                , closing = "\n}"
                                , others = []
                                }
                                :: rendered.others
                    }

                Adjacent selector adjRules ->
                    { rendered
                        | others =
                            renderRules
                                (emptyIntermediate (parent.selector ++ " + " ++ selector) "")
                                adjRules
                                :: rendered.others
                    }

                Child child childRules ->
                    { rendered
                        | others =
                            renderRules
                                (emptyIntermediate (parent.selector ++ " > " ++ child) "")
                                childRules
                                :: rendered.others
                    }

                Descriptor descriptor descriptorRules ->
                    { rendered
                        | others =
                            renderRules
                                (emptyIntermediate (parent.selector ++ descriptor) "")
                                descriptorRules
                                :: rendered.others
                    }

                Batch batched ->
                    { rendered
                        | others =
                            renderRules (emptyIntermediate parent.selector "") batched
                                :: rendered.others
                    }
    in
    Intermediate <| List.foldr generateIntermediates parent rules


render : List Class -> String
render classes =
    let
        renderValues values =
            values
                |> List.map (\( x, y ) -> "  " ++ x ++ ": " ++ y ++ ";")
                |> String.join "\n"

        renderClass rule =
            case rule.props of
                [] ->
                    ""

                _ ->
                    rule.selector ++ " {\n" ++ renderValues rule.props ++ rule.closing ++ "\n}"

        renderIntermediate (Intermediate rule) =
            renderClass rule
                ++ String.join "\n" (List.map renderIntermediate rule.others)
    in
    classes
        |> List.foldr
            (\(Class name rules) existing ->
                renderRules (emptyIntermediate name "") rules :: existing
            )
            []
        |> List.map renderIntermediate
        |> String.join "\n"


viewportRules : String
viewportRules =
    """html, body {
    height: 100%;
    width: 100%;
} """ ++ rules


rulesElement : Html.Html msg
rulesElement =
    Html.node "style" [] [ Html.text rules ]


viewportRulesElement : Html.Html msg
viewportRulesElement =
    Html.node "style" [] [ Html.text viewportRules ]


describeText : String -> List Rule -> Rule
describeText cls props =
    Descriptor cls
        (List.map makeImportant props
            ++ [ Child ".text"
                    props
               , Child ".el"
                    props
               , Child ".el > .text"
                    props
               ]
        )


makeImportant rule =
    case rule of
        Prop name prop ->
            Prop name (prop ++ " !important")

        _ ->
            rule


rules : String
rules =
    render
        [ Class "html,body"
            [ Prop "height" "100%"
            , Prop "padding" "0"
            , Prop "margin" "0"
            ]
        , Class ".se:focus"
            [ Prop "outline" "none"
            ]

        -- , Class ".se:focus .se.show-on-focus"
        --     [ Prop "opacity" "1"
        --     , Prop "pointer-events" "auto"
        --     ]
        -- , Class ".se.show-on-focus"
        --     [ Prop "opacity" "0"
        --     , Prop "pointer-events" "none"
        --     , Prop "transition"
        --         (String.join ", " <|
        --             List.map (\x -> x ++ " 160ms")
        --                 [ "opacity"
        --                 ]
        --         )
        --     ]
        , Class (class Root)
            [ Prop "width" "100%"
            , Prop "height" "auto"
            , Prop "min-height" "100%"
            , Descriptor ".se.el.height-content"
                [ Prop "height" "100%"
                , Child ".height-fill"
                    [ Prop "height" "100%"
                    ]
                ]
            , Descriptor ".wireframe .el"
                [ Prop "outline" "2px dashed black"
                ]
            , Descriptor ".wireframe .row"
                [ Prop "outline" "2px dashed black"
                ]
            , Descriptor ".wireframe .column"
                [ Prop "outline" "2px dashed black"
                ]
            ]
        , Class (class Any)
            [ Prop "position" "relative"
            , Prop "border" "none"
            , Prop "flex-shrink" "0"
            , Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Prop "flex-basis" "auto"
            , Prop "resize" "none"

            -- , Prop "flex-basis" "0%"
            , Prop "box-sizing" "border-box"
            , Prop "margin" "0"
            , Prop "padding" "0"
            , Prop "border-width" "0"
            , Prop "border-style" "solid"

            -- inheritable font properties
            , Prop "font-size" "inherit"
            , Prop "color" "inherit"
            , Prop "font-family" "inherit"
            , Prop "line-height" "inherit"
            , Prop "font-weight" "inherit"

            -- Text decoration is *mandatorily inherited* in the css spec.  There's no way to change this.
            , Prop "text-decoration" "none"
            , Prop "font-style" "inherit"
            , Descriptor ".no-text-selection"
                [ Prop "user-select" "none"
                , Prop "-ms-user-select" "none"
                ]
            , Descriptor ".cursor-pointer"
                [ Prop "cursor" "pointer"
                ]
            , Descriptor ".cursor-text"
                [ Prop "cursor" "text"
                ]
            , Descriptor ".pass-pointer-events"
                [ Prop "pointer-events" "none"
                ]
            , Descriptor ".capture-pointer-events"
                [ Prop "pointer-events" "nauto"
                ]
            , Descriptor ".transparent"
                [ Prop "opacity" "0"
                ]
            , Descriptor ".opaque"
                [ Prop "opacity" "1"
                ]
            , Descriptor ".hover-transparent:hover"
                [ Prop "opacity" "0"
                ]
            , Descriptor ".hover-opaque:hover"
                [ Prop "opacity" "1"
                ]
            , Descriptor ".hover-transparent:hover"
                [ Prop "opacity" "0"
                ]
            , Descriptor ".hover-opaque:hover"
                [ Prop "opacity" "1"
                ]
            , Descriptor ".focus-transparent:focus"
                [ Prop "opacity" "0"
                ]
            , Descriptor ".focus-opaque:focus"
                [ Prop "opacity" "1"
                ]
            , Descriptor ".active-transparent:active"
                [ Prop "opacity" "0"
                ]
            , Descriptor ".active-opaque:active"
                [ Prop "opacity" "1"
                ]
            , Descriptor ".transition"
                [ Prop "transition"
                    (String.join ", " <|
                        List.map (\x -> x ++ " 160ms")
                            [ "transform"
                            , "opacity"
                            , "filter"
                            , "background-color"
                            , "color"
                            , "font-size"
                            ]
                    )
                ]
            , Descriptor ".overflow-hidden"
                [ Prop "overflow" "hidden"
                , Prop " -ms-overflow-style" "none"
                ]
            , Descriptor ".scrollbars"
                [ Prop "overflow" "auto"
                , Prop "flex-shrink" "1"
                ]
            , Descriptor ".scrollbars-x"
                [ Prop "overflow-x" "auto"
                , Descriptor ".row"
                    [ Prop "flex-shrink" "1"
                    ]
                ]
            , Descriptor ".scrollbars-y"
                [ Prop "overflow-y" "auto"
                , Descriptor ".column"
                    [ Prop "flex-shrink" "1"
                    ]
                ]
            , Descriptor ".clip"
                [ Prop "overflow" "hidden"
                ]
            , Descriptor ".clip-x"
                [ Prop "overflow-x" "hidden"
                ]
            , Descriptor ".clip-y"
                [ Prop "overflow-y" "hidden"
                ]
            , Descriptor ".width-content"
                [ Prop "width" "auto"
                ]
            , Descriptor ".border-none"
                [ Prop "border-width" "0"
                ]
            , Descriptor ".border-dashed"
                [ Prop "border-style" "dashed"
                ]
            , Descriptor ".border-dotted"
                [ Prop "border-style" "dotted"
                ]
            , Descriptor ".border-solid"
                [ Prop "border-style" "solid"
                ]
            , Batch <|
                flip List.map locations <|
                    \loc ->
                        case loc of
                            Above ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "top" "0"
                                    , Prop "left" "0"
                                    , Prop "height" "0"
                                    , Prop "width" "100%"
                                    , Prop "z-index" "10"
                                    , Prop "pointer-events" "auto"
                                    , Child ".height-fill"
                                        [ Prop "height" "auto"
                                        ]
                                    , Child ".width-fill"
                                        [ Prop "width" "100%"
                                        ]
                                    , Child ".se"
                                        [ Prop "position" "absolute"
                                        , Prop "bottom" "0"
                                        ]
                                    ]

                            Below ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "bottom" "0"
                                    , Prop "height" "0"
                                    , Prop "width" "100%"
                                    , Prop "z-index" "10"
                                    , Prop "pointer-events" "auto"
                                    , Child ".height-fill"
                                        [ Prop "height" "auto"
                                        ]
                                    ]

                            OnRight ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "left" "100%"
                                    , Prop "height" "100%"
                                    , Prop "z-index" "10"
                                    , Prop "pointer-events" "auto"
                                    ]

                            OnLeft ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "right" "100%"
                                    , Prop "height" "100%"
                                    , Prop "z-index" "10"
                                    , Prop "pointer-events" "auto"
                                    ]

                            Within ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "width" "100%"
                                    , Prop "height" "100%"
                                    , Prop "left" "0"
                                    , Prop "top" "0"
                                    , Prop "z-index" "10"
                                    , Prop "pointer-events" "none"
                                    , Child ".se"
                                        [ Prop "pointer-events" "auto"
                                        ]
                                    ]

                            Behind ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "width" "100%"
                                    , Prop "height" "100%"
                                    , Prop "left" "0"
                                    , Prop "top" "0"
                                    , Prop "z-index" "0"
                                    , Prop "pointer-events" "none"
                                    , Child ".se"
                                        [ Prop "pointer-events" "auto"
                                        ]
                                    ]
            , Descriptor ".text-thin"
                [ Prop "font-weight" "100"
                ]
            , Descriptor ".text-extra-light"
                [ Prop "font-weight" "200"
                ]
            , Descriptor ".text-light"
                [ Prop "font-weight" "300"
                ]
            , Descriptor ".text-normal-weight"
                [ Prop "font-weight" "400"
                ]
            , Descriptor ".text-medium"
                [ Prop "font-weight" "500"
                ]
            , Descriptor ".text-semi-bold"
                [ Prop "font-weight" "600"
                ]
            , Descriptor ".bold"
                [ Prop "font-weight" "700"
                ]
            , Descriptor ".text-extra-bold"
                [ Prop "font-weight" "800"
                ]
            , Descriptor ".text-heavy"
                [ Prop "font-weight" "900"
                ]
            , Descriptor ".italic"
                [ Prop "font-style" "italic"
                ]
            , Descriptor ".strike"
                [ Prop "text-decoration" "line-through"
                ]
            , Descriptor ".underline"
                [ Prop "text-decoration" "underline"
                , Prop "text-decoration-skip-ink" "auto"
                , Prop "text-decoration-skip" "ink"
                ]
            , Descriptor ".text-unitalicized"
                [ Prop "font-style" "normal"
                ]
            , Descriptor ".text-justify"
                [ Prop "text-align" "justify"
                ]
            , Descriptor ".text-justify-all"
                [ Prop "text-align" "justify-all"
                ]
            , Descriptor ".text-center"
                [ Prop "text-align" "center"
                ]
            , Descriptor ".text-right"
                [ Prop "text-align" "right"
                ]
            , Descriptor ".text-left"
                [ Prop "text-align" "left"
                ]
            ]
        , Class (class Text)
            [ Prop "white-space" "pre"
            , Prop "display" "inline-block"
            ]
        , Class (class Spacer)
            [ Adjacent (class Any)
                [ Prop "margin-top" "0"
                , Prop "margin-left" "0"
                ]
            ]
        , Class (class Single)
            [ Prop "display" "flex"
            , Prop "flex-direction" "column"
            , Prop "white-space" "pre"
            , Descriptor ".se-button"
                -- Special default for text in a button.
                -- This is overridden is they put the text inside an `el`
                [ Child ".text"
                    [ Descriptor ".height-fill"
                        [ Prop "flex-grow" "0"
                        ]
                    , Descriptor ".width-fill"
                        [ Prop "align-self" "auto !important"
                        ]
                    ]
                ]
            , Child ".height-content"
                [ Prop "height" "auto"
                ]
            , Child ".height-fill"
                [ Prop "flex-grow" "100000"
                ]
            , Child ".width-fill"
                [ -- alignLeft, alignRight, centerX are overridden by width.
                  Prop "align-self" "stretch !important"
                ]
            , Descriptor ".width-content"
                [ Prop "width" "auto"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( [ Prop "justify-content" "flex-start" ]
                            , [ Prop "margin-bottom" "auto" ]
                            )

                        Bottom ->
                            ( [ Prop "justify-content" "flex-end" ]
                            , [ Prop "margin-top" "auto" ]
                            )

                        Right ->
                            ( [ Prop "align-items" "flex-end" ]
                            , [ Prop "align-self" "flex-end" ]
                            )

                        Left ->
                            ( [ Prop "align-items" "flex-start" ]
                            , [ Prop "align-self" "flex-start" ]
                            )

                        CenterX ->
                            ( [ Prop "align-items" "center" ]
                            , [ Prop "align-self" "center"
                              ]
                            )

                        CenterY ->
                            ( [ Prop "justify-content" "center" ]
                            , [ Prop "margin-top" "auto"
                              , Prop "margin-bottom" "auto"
                              ]
                            )
            ]
        , Class ".nearby"
            [ Prop "position" "absolute"
            , Prop "top" "0"
            , Prop "left" "0"
            , Prop "width" "100%"
            , Prop "height" "100%"
            , Prop "pointer-events" "none"
            , Prop "margin" "0 !important"
            , Adjacent ".se"
                [ Prop "margin-top" "0"
                , Prop "margin-left" "0"
                ]
            ]
        , Class ".modal"
            [ Prop "position" "fixed"
            , Prop "left" "0"
            , Prop "top" "0"
            , Prop "width" "100%"
            , Prop "height" "100%"
            , Prop "pointer-events" "none"
            ]
        , Class (class Row)
            [ Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Child (class Any)
                [ Prop "flex-basis" "0%"
                , Descriptor ".width-exact"
                    [ Prop "flex-basis" "auto"
                    ]
                ]
            , Child ".se:first-child"
                [ Prop "margin-left" "0 !important"
                ]
            , Child ".se.teleporting-spacer"
                [ Prop "margin-left" "0 !important"
                ]
            , Child ".height-fill"
                [ --Prop "height" "100%"
                  -- alignTop, centerY, and alignBottom need to be disabled
                  Prop "align-self" "stretch !important"
                ]
            , Child ".height-fill-portion"
                [ --Prop "height" "100%"
                  -- alignTop, centerY, and alignBottom need to be disabled
                  Prop "align-self" "stretch !important"
                ]
            , Child ".width-fill"
                [ Prop "flex-grow" "100000"
                ]
            , Child ".spacer"
                [ Prop "margin-left" "0 !important"
                , Prop "height" "auto !important"
                ]
            , Child ".spacer + .se"
                [ Prop "margin-left" "0 !important"
                ]
            , Child ".stylesheet + .se"
                [ Prop "margin-left" "0 !important"
                ]
            , Child ".nearby + .se"
                [ Prop "margin-left" "0 !important"
                ]
            , Child ".container"
                [ Prop "flex-grow" "0"
                , Prop "flex-basis" "0%"

                -- , Prop "height" "100%"
                , Prop "align-self" "stretch"
                ]
            , Child "alignLeft:last-of-type.align-container-left"
                [ Prop "flex-grow" "1"
                ]
            , Child "alignRight:first-of-type.align-container-right"
                [ Prop "flex-grow" "1"
                ]

            -- Working Area
            -- first center y
            , Child "centerX:first-of-type.align-container-center-x"
                [ Prop "flex-grow" "1"

                -- , Prop "justify-content" "flex-end"
                , Child ".self-center-y"
                    [ Prop "margin-bottom" "0 !important"
                    ]
                ]
            , Child "centerX:last-of-type.align-container-center-x"
                [ Prop "flex-grow" "1"

                -- , Prop "justify-content" "flex-start"
                , Child ".self-center-y"
                    [ Prop "margin-top" "0 !important"
                    ]
                ]

            -- lonley centerX
            , Child "centerX:only-of-type.align-container-center-x"
                [ Prop "flex-grow" "1"
                , Child ".self-center-y"
                    [ Prop "margin-top" "auto !important"
                    , Prop "margin-bottom" "auto !important"
                    ]
                ]

            -- alignBottom's after a centerX should not grow
            , Child "centerX:last-of-type.align-container-center-x ~ alignRight"
                [ Prop "flex-grow" "0"
                ]

            -- centerX's after an alignBottom should be ignored
            , Child "alignRight:first-of-type.align-container-right ~ centerX.align-container-center-x"
                -- Bottom alignment always overrides center alignment
                [ Prop "flex-grow" "0"
                ]

            -- End Working Area
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( [ Prop "align-items" "flex-start" ]
                            , [ Prop "align-self" "flex-start"
                              ]
                            )

                        Bottom ->
                            ( [ Prop "align-items" "flex-end" ]
                            , [ Prop "align-self" "flex-end"
                              ]
                            )

                        Right ->
                            ( [ Prop "justify-content" "flex-end"
                              ]
                            , []
                            )

                        Left ->
                            ( [ Prop "justify-content" "flex-start"
                              ]
                            , []
                            )

                        CenterX ->
                            ( [ Prop "justify-content" "center"
                              ]
                            , []
                            )

                        CenterY ->
                            ( [ Prop "align-items" "center" ]
                            , [ Prop "align-self" "center"
                              ]
                            )

            -- Must be below the alignment rules or else it interferes
            , Descriptor ".space-evenly"
                [ Prop "justify-content" "space-between"
                , Child ".spacer"
                    [ Prop "display" "none"
                    ]
                ]
            ]
        , Class (class Column)
            [ Prop "display" "flex"
            , Prop "flex-direction" "column"
            , Child ".height-fill"
                [ Prop "flex-grow" "100000"
                ]
            , Child ".width-fill"
                [ --Prop "width" "100%"
                  -- alignLeft, alignRight, centerX need to be disabled
                  Prop "align-self" "stretch !important"
                ]
            , Child ".width-fill-portion"
                [ --Prop "width" "100%"
                  -- alignLeft, alignRight, centerX need to be disabled
                  Prop "align-self" "stretch !important"
                ]
            , Child ".se:first-child"
                [ Prop "margin-top" "0 !important"
                ]
            , Child ".spacer + .se"
                [ Prop "margin-top" "0"
                ]
            , Child ".se.spacer"
                [ Prop "margin-top" "0 !important"
                ]
            , Child ".se.teleporting-spacer"
                [ Prop "margin-top" "0 !important"
                ]
            , Child ".stylesheet + .se"
                [ Prop "margin-top" "0"
                ]
            , Child ".nearby + .se"
                [ Prop "margin-top" "0"
                ]
            , Child "alignTop:last-of-type.align-container-top"
                [ Prop "flex-grow" "1"
                ]
            , Child "alignBottom:first-of-type.align-container-bottom"
                [ Prop "flex-grow" "1"
                ]
            , Child ".teleporting-spacer"
                [ Prop "flex-grow" "0"
                ]

            -- WORKIGN AREA
            -- first center y
            , Child "centerY:first-of-type.align-container-center-y"
                [ Prop "flex-grow" "1"

                -- , Prop "justify-content" "flex-end"
                , Child ".self-center-y"
                    [ Prop "margin-bottom" "0 !important"
                    ]
                ]
            , Child "centerY:last-of-type.align-container-center-y"
                [ Prop "flex-grow" "1"

                -- , Prop "justify-content" "flex-start"
                , Child ".self-center-y"
                    [ Prop "margin-top" "0 !important"
                    ]
                ]

            -- lonley centerY
            , Child "centerY:only-of-type.align-container-center-y"
                [ Prop "flex-grow" "1"
                , Child ".self-center-y"
                    [ Prop "margin-top" "auto !important"
                    , Prop "margin-bottom" "auto !important"
                    ]
                ]

            -- alignBottom's after a centerY should not grow
            , Child "centerY:last-of-type.align-container-center-y ~ alignBottom"
                [ Prop "flex-grow" "0"
                ]

            -- centerY's after an alignBottom should be ignored
            , Child "alignBottom:first-of-type.align-container-bottom ~ centerY.align-container-center-y"
                -- Bottom alignment always overrides center alignment
                [ Prop "flex-grow" "0"
                ]

            -- , Child "alignRight:first-of-type.align-container-right"
            --     [ Prop "flex-grow" "1"
            --     ]
            -- END WORKING AREA
            , Child ".se.self-center-y:first-child ~ .teleporting-spacer"
                [ Prop "flex-grow" "1"
                , Prop "order" "-1"
                ]
            , Child ".se.nearby + .se.self-center-y ~ .teleporting-spacer"
                [ Prop "flex-grow" "1"
                , Prop "order" "-1"
                ]
            , Child ".stylesheet + .se.self-center-y ~ .teleporting-spacer"
                [ Prop "flex-grow" "1"
                , Prop "order" "-1"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( [ Prop "justify-content" "flex-start" ]
                            , [ Prop "margin-bottom" "auto" ]
                            )

                        Bottom ->
                            ( [ Prop "justify-content" "flex-end" ]
                            , [ Prop "margin-top" "auto" ]
                            )

                        Right ->
                            ( [ Prop "align-items" "flex-end" ]
                            , [ Prop "align-self" "flex-end" ]
                            )

                        Left ->
                            ( [ Prop "align-items" "flex-start" ]
                            , [ Prop "align-self" "flex-start" ]
                            )

                        CenterX ->
                            ( [ Prop "align-items" "center" ]
                            , [ Prop "align-self" "center"
                              ]
                            )

                        CenterY ->
                            ( [ Prop "justify-content" "center" ]
                            , []
                            )
            , Child ".container"
                [ Prop "flex-grow" "0"
                , Prop "flex-basis" "auto"
                , Prop "width" "100%"
                , Prop "align-self" "stretch !important"
                ]
            , Descriptor ".space-evenly"
                [ Prop "justify-content" "space-between"
                , Child ".spacer"
                    [ Prop "display" "none"
                    ]
                ]
            ]
        , Class (class Grid)
            [ Prop "display" "-ms-grid"
            , Supports ( "display", "grid" )
                [ ( "display", "grid" )
                ]
            , gridAlignments <|
                \alignment ->
                    case alignment of
                        Top ->
                            [ Prop "justify-content" "flex-start" ]

                        Bottom ->
                            [ Prop "justify-content" "flex-end" ]

                        Right ->
                            [ Prop "align-items" "flex-end" ]

                        Left ->
                            [ Prop "align-items" "flex-start" ]

                        CenterX ->
                            [ Prop "align-items" "center" ]

                        CenterY ->
                            [ Prop "justify-content" "center" ]
            ]
        , Class (class Page)
            [ Prop "display" "block"
            , Child (class Any ++ ":first-child")
                [ Prop "margin" "0 !important"
                ]

            -- clear spacing of any subsequent element if an element is float-left
            , Child (class Any ++ selfName (Self Left) ++ ":first-child + .se")
                [ Prop "margin" "0 !important"
                ]
            , Child (class Any ++ selfName (Self Right) ++ ":first-child + .se")
                [ Prop "margin" "0 !important"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( []
                            , []
                            )

                        Bottom ->
                            ( []
                            , []
                            )

                        Right ->
                            ( []
                            , [ Prop "float" "right"
                              , Descriptor ":after:"
                                    [ Prop "content" "\"\""
                                    , Prop "display" "table"
                                    , Prop "clear" "both"
                                    ]
                              ]
                            )

                        Left ->
                            ( []
                            , [ Prop "float" "left"
                              , Descriptor ":after:"
                                    [ Prop "content" "\"\""
                                    , Prop "display" "table"
                                    , Prop "clear" "both"
                                    ]
                              ]
                            )

                        CenterX ->
                            ( []
                            , []
                            )

                        CenterY ->
                            ( []
                            , []
                            )
            ]
        , Class (class Paragraph)
            [ Prop "display" "block"
            , Prop "white-space" "normal"
            , Child (class Text)
                [ Prop "display" "inline"
                , Prop "white-space" "normal"
                ]
            , Child (class Single)
                [ Prop "display" "inline-flex"
                , Prop "white-space" "normal"
                , Child (class Text)
                    [ Prop "display" "inline"
                    , Prop "white-space" "normal"
                    ]
                ]
            , Child (class Row)
                [ Prop "display" "inline-flex"
                ]
            , Child (class Column)
                [ Prop "display" "inline-flex"
                ]
            , Child (class Grid)
                [ Prop "display" "inline-grid"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( []
                            , []
                            )

                        Bottom ->
                            ( []
                            , []
                            )

                        Right ->
                            ( []
                            , [ Prop "float" "right" ]
                            )

                        Left ->
                            ( []
                            , [ Prop "float" "left" ]
                            )

                        CenterX ->
                            ( []
                            , []
                            )

                        CenterY ->
                            ( []
                            , []
                            )
            ]
        , Class ".se.ignore"
            [ Prop "margin" "0 !important"
            ]
        , Class ".se.hidden"
            [ Prop "display" "none"
            ]
        ]
