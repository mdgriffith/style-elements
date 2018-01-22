module Internal.Style exposing (..)

import Dict
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
            ".el"

        Row ->
            ".row"

        Column ->
            ".column"

        Page ->
            ".page"

        Paragraph ->
            ".paragraph"

        Text ->
            ".text"

        Grid ->
            ".grid"

        Spacer ->
            ".spacer"


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
        , Class ".se:focus .se.show-on-focus"
            [ Prop "opacity" "1"
            , Prop "pointer-events" "auto"
            ]
        , Class ".se.show-on-focus"
            [ Prop "opacity" "0"
            , Prop "pointer-events" "none"
            , Prop "transition"
                (String.join ", " <|
                    List.map (\x -> x ++ " 160ms")
                        [ "opacity"
                        ]
                )
            ]
        , Class (class Root)
            [ Prop "width" "100%"
            , Prop "height" "auto"
            , Prop "min-height" "100%"
            ]
        , Class (class Any)
            [ Prop "position" "relative"
            , Prop "border" "none"
            , Prop "text-decoration" "none"
            , Prop "flex-shrink" "0"
            , Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Prop "flex-basis" "auto"
            , Prop "resize" "none"

            -- , Prop "flex-basis" "0"
            , Prop "box-sizing" "border-box"
            , Prop "margin" "0"
            , Prop "padding" "0"
            , Prop "border-width" "0"
            , Prop "border-style" "solid"
            , Prop "font-size" "inherit"
            , Prop "color" "inherit"
            , Prop "font-family" "inherit"
            , Prop "line-height" "inherit"
            , Prop "font-weight" "normal"
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
            , Descriptor ".hover-transition"
                [ Prop "transition"
                    (String.join ", " <|
                        List.map (\x -> x ++ " 160ms")
                            [ "transform"
                            , "opacity"
                            , "filter"
                            , "background-color"
                            , "color"
                            ]
                    )
                ]
            , Descriptor ".overflow-hidden"
                [ Prop "overflow" "hidden"
                , Prop " -ms-overflow-style" "none"
                ]
            , Descriptor ".scrollbars"
                [ Prop "overflow" "auto"
                ]
            , Descriptor ".scrollbars-x"
                [ Prop "overflow-x" "auto"
                ]
            , Descriptor ".scrollbars-y"
                [ Prop "overflow-y" "auto"
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
                                    , Prop "pointer-events" "auto"
                                    ]

                            Behind ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "width" "100%"
                                    , Prop "height" "100%"
                                    , Prop "left" "0"
                                    , Prop "top" "0"
                                    , Prop "z-index" "0"
                                    , Prop "pointer-events" "auto"
                                    ]
            , Descriptor ".bold"
                [ Prop "font-weight" "700"
                , Child ".text"
                    [ Prop "font-weight" "700"
                    ]
                ]
            , Descriptor ".text-light"
                [ Prop "font-weight" "300"
                , Child ".text"
                    [ Prop "font-weight" "300"
                    ]
                ]
            , Descriptor ".italic"
                [ Prop "font-style" "italic"
                , Child ".text"
                    [ Prop "font-style" "italic"
                    ]
                ]
            , Descriptor ".strike"
                [ Prop "text-decoration" "line-through"
                , Child ".text"
                    [ Prop "text-decoration" "line-through"
                    ]
                ]
            , Descriptor ".underline"
                [ Prop "text-decoration" "underline"
                , Child ".text"
                    [ Prop "text-decoration" "underline"
                    ]
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
                [ Prop "flex-basis" "0"
                , Descriptor ".width-exact"
                    [ Prop "flex-basis" "auto"
                    ]
                ]
            , Child ".height-fill"
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
                , Prop "flex-basis" "0"
                , Prop "height" "100%"
                ]
            , Child "alignLeft:last-of-type.align-container-left"
                [ Prop "flex-grow" "1"
                ]
            , Child "alignRight:first-of-type.align-container-right"
                [ Prop "flex-grow" "1"
                ]
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
        , Class ".ignore"
            [ Prop "margin" "0 !important"
            ]
        , Class ".hidden"
            [ Prop "display" "none"
            ]
        ]
