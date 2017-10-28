module Next.Internal.Style exposing (..)

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
        , Class (class Text)
            [ Prop "white-space" "pre"
            , Prop "width" "100%"
            ]
        , Class (class Spacer)
            [ Adjacent (class Any)
                [ Prop "margin-top" "0"
                , Prop "margin-left" "0"
                ]
            ]
        , Class (class Paragraph)
            [ Child (class Single)
                [ Prop "display" "inline-flex"
                , Child (class Text)
                    [ Prop "display" "inline"
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
            ]
        , Class (class Any)
            [ Prop "position" "relative"
            , Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Prop "box-sizing" "border-box"
            , Prop "margin" "0"
            , Prop "padding" "0"
            , Prop "border-width" "0"
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
            ]
        , Class (class Single)
            [ Prop "display" "flex"
            , Prop "flex-direction" "row"
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
        , Class ".hidden"
            [ Prop "display" "none"
            ]
        ]


static =
    """
.style-elements {
    width: 100%;
    height: 100%;
}

.el {
    position: relative;
    display: flex;
    flex-direction: row;
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    border-width: 0;
}

.el.vertical-center > .el {
    align-self: center;
}
.el.align-top > .el {
    align-self: flex-start;
}
.el.align-bottom > .el {
    align-self: flex-end;
}
.el.vertical-center > .el {
    align-self: center;
}
.el.center > .el {
    margin:0 auto;
}
.el.align-right > .el {
    margin-left: auto;
    margin-right: 0;
}
.el.align-left > .el {
    margin-right: auto;
    margin-left: 0;
}




.el > .align-top {
    align-self: flex-start;
}
.el > .align-bottom {
    align-self: flex-end;
}
.el > .vertical-center {
    align-self: center;
}
.el > .center {
    margin:0 auto;
}
.el > .align-right {
    margin-left: auto;
    margin-right: 0;
}
.el > .align-left {
    margin-right: auto;
    margin-left: 0;
}

.text {
    white-space: pre;
    text-overflow: ellipsis;
    overflow: hidden;
    display: block;
}


.paragraph > .el {
    display: inline;
}
.paragraph > .el > .text {
    display: inline;
}
.paragraph > .row {
    display: inline-flex;
}
.paragraph > .column {
    display: inline-flex;
}
.paragraph > .grid {
    display: inline-grid;
}

.row {
    display: flex;
    flex-direction: row;
}

.row > .align-top {
    align-self: flex-start;
}
.row > .align-bottom {
    align-self: flex-end;
}
.row > .vertical-center {
    align-self: center;
}

.row.align-left {
    justify-content: flex-start;
}
.row.align-right {
    justify-content: flex-end;
}

.row.center {
    justify-content: center;
}

.row.spread {
    justify-content: space-between;
}

.row.align-top {
    align-items: flex-start;
}
.row.align-bottom {
    align-items: flex-end;
}
.row.vertical-center {
    align-items: center;
}


.column {
    display: flex;
    flex-direction: column;
}
.column > .align-left {
    align-self: flex-start;
}
.column > .align-right {
    align-self: flex-end;
}
.column > .center {
    align-self: center;
}


.column.align-left {
    align-items: flex-start;
}
.column.align-right {
    align-items: flex-end;
}
.column.center {
    align-items: center;
}

.column.spread {
    justify-content: space-between;
}
.column.align-top {
    justify-content: flex-start;
}
.column.align-bottom {
    justify-content: flex-end;
}
.column.vertical-center {
    justify-content: center;
}


.el.below {
    position: absolute;
    bottom: 0;
    height: 0;
}
.el.above {
    position: absolute;
    top: 0;
    height: 0;
}
.el.on-right {
    position: absolute;
    left: 100%;
    width: 0;
}
.el.on-left {
    position: absolute;
    right: 100%;
    width: 0;
}
.el.overlay {
    position: absolute;
    left:0;
    top:0;
}



"""
