module Internal.Style exposing (..)

import Dict
import Html


type Class
    = Class String (List Rule)


type Rule
    = Prop String String
    | Child String (List Rule)
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
    in
    [ Above
    , Below
    , OnRight
    , OnLeft
    , Within
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
            ".overlay"


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


type alias Intermediate =
    ( String, List ( String, String ) )


renderRules : String -> List Rule -> Dict.Dict String (List ( String, String ))
renderRules parent rules =
    let
        generateIntermediates rule rendered =
            case rule of
                Prop name val ->
                    Dict.update parent
                        (\x ->
                            case x of
                                Nothing ->
                                    Just <| [ ( name, val ) ]

                                Just props ->
                                    Just <| ( name, val ) :: props
                        )
                        rendered

                Adjacent selector adjRules ->
                    Dict.union
                        rendered
                        (renderRules (parent ++ " + " ++ selector) adjRules)

                Child child childRules ->
                    Dict.union
                        rendered
                        (renderRules (parent ++ " > " ++ child) childRules)

                Descriptor descriptor descriptorRules ->
                    Dict.union
                        rendered
                        (renderRules (parent ++ descriptor) descriptorRules)

                Batch batched ->
                    Dict.union
                        rendered
                        (renderRules parent batched)
    in
    List.foldr generateIntermediates Dict.empty rules


render : List Class -> String
render classes =
    let
        renderValues values =
            values
                |> List.map (\( x, y ) -> "  " ++ x ++ ": " ++ y ++ ";")
                |> String.join "\n"
    in
    classes
        |> List.foldr
            (\(Class name rules) existing ->
                Dict.toList (renderRules name rules) ++ existing
            )
            []
        |> List.map (\( cls, vals ) -> cls ++ " {\n" ++ renderValues vals ++ "\n}\n")
        |> String.join "\n"


viewportRules =
    """html, body {
    height: 100%;
    width: 100%;
} """ ++ rules


rulesElement =
    Html.node "style" [] [ Html.text rules ]


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
        , Class "input"
            [ Prop "border" "none"
            ]
        , Class "a"
            [ Prop "text-decoration" "none"
            , Prop "color" "inherit"
            ]
        , Class (class Root)
            [ Prop "width" "100%"
            , Prop "height" "auto"
            , Prop "min-height" "100%"
            ]
        , Class (class Any)
            [ Prop "position" "relative"
            , Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Prop "box-sizing" "border-box"
            , Prop "margin" "0"
            , Prop "padding" "0"
            , Prop "border-width" "0"
            , Prop "border-style" "solid"
            , Prop "font" "inherit"
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
                                    , Prop "display" "block"
                                    , Prop "top" "0"
                                    , Prop "height" "0"
                                    , Prop "z-index" "10"
                                    , Child ".height-fill"
                                        [ Prop "height" "auto"
                                        ]
                                    ]

                            Below ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "display" "block"
                                    , Prop "bottom" "0"
                                    , Prop "height" "0"
                                    , Prop "z-index" "10"
                                    , Child ".height-fill"
                                        [ Prop "height" "auto"
                                        ]
                                    ]

                            OnRight ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "display" "block"
                                    , Prop "left" "100%"
                                    , Prop "width" "0"
                                    , Prop "z-index" "10"
                                    ]

                            OnLeft ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "display" "block"
                                    , Prop "right" "100%"
                                    , Prop "width" "0"
                                    , Prop "z-index" "10"
                                    ]

                            Within ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "display" "block"
                                    , Prop "left" "0"
                                    , Prop "top" "0"
                                    , Prop "z-index" "10"
                                    ]
            , Descriptor ".bold"
                [ Prop "font-weight" "700"
                ]
            , Descriptor ".text-light"
                [ Prop "font-weight" "300"
                ]
            , Descriptor ".italic"
                [ Prop "font-style" "italic"
                ]
            , Descriptor ".strike"
                [ Prop "text-decoration" "line-through"
                ]
            , Descriptor ".underline"
                [ Prop "text-decoration" "underline"
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
            , Child ".height-fill"
                [ Prop "flex-grow" "100000"
                ]
            , Child ".width-fill"
                [ -- alignLeft, alignRight, centerX are overridden by width.
                  Prop "align-self" "stretch !important"
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
            , Prop "width" "100%"
            , Prop "height" "100%"
            , Prop "pointer-events" "none"
            ]
        , Class (class Row)
            [ Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Descriptor ".space-evenly"
                [ Prop "justify-content" "space-between"
                ]
            , Child ".height-fill"
                [ --Prop "height" "100%"
                  -- alignTop, centerY, and alignBottom need to be disabled
                  Prop "align-self" "stretch !important"
                ]
            , Child ".width-fill"
                [ Prop "flex-grow" "100000"
                ]

            -- this is to help with spacing
            -- , Child ".se:first-child.spacer"
            --     [ Prop "margin-left" "0"
            --     ]
            , Child ".spacer"
                [ Prop "margin-left" "0 !important"
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
                              -- , [ Prop "margin-left" "auto"
                              --   , Prop "margin-right" "auto"
                              --   ]
                            )

                        CenterY ->
                            ( [ Prop "align-items" "center" ]
                            , [ Prop "align-self" "center"
                              ]
                            )
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
            , Descriptor ".space-evenly"
                [ Prop "justify-content" "space-between"
                ]
            , Child ".se:first-child"
                [ Prop "margin-top" "0 !important"
                ]
            , Child ".spacer + .se"
                [ Prop "margin-top" "0"
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
            , Child "alignBottom.align-container-bottom"
                [ Prop "flex-basis" "auto"
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
            , Child ".container"
                [ Prop "flex-grow" "0"
                , Prop "flex-basis" "auto"
                , Prop "width" "100%"
                ]
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
            , Child (class Text)
                [ Prop "display" "inline"
                , Prop "white-space" "normal"
                ]
            , Child (class Single)
                [ Prop "display" "inline-flex"
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
