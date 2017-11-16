module Internal.Style exposing (..)

import Dict


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


rules : String
rules =
    render
        [ Class (class Root)
            [ Prop "width" "100%"
            , Prop "height" "100%"
            ]
        , Class (class Any)
            [ Prop "position" "relative"
            , Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Prop "box-sizing" "border-box"
            , Prop "margin" "0"
            , Prop "padding" "0"
            , Prop "border-width" "0"
            , Descriptor ".width-content"
                [ Prop "width" "auto"
                ]
            , Batch <|
                flip List.map locations <|
                    \loc ->
                        case loc of
                            Above ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "top" "0"
                                    , Prop "height" "0"
                                    ]

                            Below ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "bottom" "0"
                                    , Prop "height" "0"
                                    ]

                            OnRight ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "left" "100%"
                                    , Prop "width" "0"
                                    ]

                            OnLeft ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "right" "100%"
                                    , Prop "width" "0"
                                    ]

                            Within ->
                                Descriptor (locationName loc)
                                    [ Prop "position" "absolute"
                                    , Prop "left" "0"
                                    , Prop "top" "0"
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
            , Prop "flex-direction" "row"
            , Child ".height-fill"
                [ Prop "height" "100%"
                ]
            , Child ".width-fill"
                [ Prop "width" "100%"
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
            ]
        , Class (class Row)
            [ Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Child ".height-fill"
                [ Prop "height" "100%"
                ]
            , Child ".width-fill"
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
            ]
        , Class (class Column)
            [ Prop "display" "flex"
            , Prop "flex-direction" "column"
            , Child ".height-fill"
                [ Prop "flex-grow" "1"
                ]
            , Child ".width-fill"
                [ Prop "width" "100%"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( [ Prop "justify-content" "flex-start" ]
                            , []
                            )

                        Bottom ->
                            ( [ Prop "justify-content" "flex-end" ]
                            , []
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
        , Class ".hidden"
            [ Prop "display" "none"
            ]
        ]
