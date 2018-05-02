module Internal.Style exposing (..)

{-| -}

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



-- lengths


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
            dot classes.alignTop

        Self Bottom ->
            dot classes.alignBottom

        Self Right ->
            dot classes.alignRight

        Self Left ->
            dot classes.alignLeft

        Self CenterX ->
            dot classes.alignCenterX

        Self CenterY ->
            dot classes.alignCenterY


contentName desc =
    case desc of
        Content Top ->
            dot classes.contentTop

        Content Bottom ->
            dot classes.contentBottom

        Content Right ->
            dot classes.contentRight

        Content Left ->
            dot classes.contentLeft

        Content CenterX ->
            dot classes.contentCenterX

        Content CenterY ->
            dot classes.contentCenterY


classes =
    { root = "style-elements"
    , any = "se"
    , single = "el"
    , row = "row"
    , column = "column"
    , page = "page"
    , paragraph = "paragraph"
    , text = "text"
    , grid = "grid"

    -- widhts/heights
    , widthFill = "width-fill"
    , widthContent = "width-content"
    , widthExact = "width-exact"
    , heightFill = "height-fill"
    , heightContent = "height-content"
    , heightExact = "height-exact"

    -- nearby elements
    , above = "above"
    , below = "below"
    , onRight = "on-right"
    , onLeft = "on-left"
    , inFront = "infront"
    , behind = "behind"

    -- alignments
    , alignTop = "self-top"
    , alignBottom = "self-bottom"
    , alignRight = "self-right"
    , alignLeft = "self-left"
    , alignCenterX = "self-center-x"
    , alignCenterY = "self-center-y"

    -- space evenly
    , spaceEvenly = "space-evenly"
    , container = "container"

    -- content alignments
    , contentTop = "content-top"
    , contentBottom = "content-bottom"
    , contentRight = "content-right"
    , contentLeft = "content-left"
    , contentCenterX = "content-center-x"
    , contentCenterY = "content-center-y"

    -- selection
    , noTextSelection = "no-text-selection"
    , cursorPointer = "cursor-pointer"
    , cursorText = "cursor-text"

    -- pointer events
    , passPointerEvents = "pass-pointer-events"
    , capturePointerEvents = "capture-pointer-events"
    , transparent = "transparent"
    , opaque = "opaque"
    , overflowHidden = "overflow-hidden"

    --scrollbars
    , scrollbars = "scrollbars"
    , scrollbarsX = "scrollbars-x"
    , scrollbarsY = "scrollbars-y"
    , clip = "clip"
    , clipX = "clip-x"
    , clipY = "clip-y"

    -- borders
    , borderNone = "border-none"
    , borderDashed = "border-dashed"
    , borderDotted = "border-dotted"
    , borderSolid = "border-solid"

    -- text weight
    , textThin = "text-thin"
    , textExtraLight = "text-extra-light"
    , textLight = "text-light"
    , textNormalWeight = "text-normal-weight"
    , textMedium = "text-medium"
    , textSemiBold = "text-semi-bold"
    , bold = "bold"
    , textExtraBold = "text-extra-bold"
    , textHeavy = "text-heavy"
    , italic = "italic"
    , strike = "strike"
    , underline = "underline"
    , textUnitalicized = "text-unitalicized"

    -- text alignment
    , textJustify = "text-justify"
    , textJustifyAll = "text-justify-all"
    , textCenter = "text-center"
    , textRight = "text-right"
    , textLeft = "text-left"
    }


{-| The indulgent unicode character version.
-}
unicode =
    { root = "style-elements"
    , any = "s"
    , single = "e"
    , row = "⋯"
    , column = "⋮"
    , page = "🗏"
    , paragraph = "p"
    , text = "text"
    , grid = "▦"

    -- widhts/heights
    , widthFill = "↔"
    , widthContent = "width-content"
    , widthExact = "width-exact"
    , heightFill = "↕"
    , heightContent = "height-content"
    , heightExact = "height-exact"

    -- nearby elements
    , above = "above"
    , below = "below"
    , onRight = "on-right"
    , onLeft = "on-left"
    , inFront = "infront"
    , behind = "behind"

    -- alignments
    , alignTop = "⤒"
    , alignBottom = "⤓"
    , alignRight = "⇥"
    , alignLeft = "⇤"
    , alignCenterX = "self-center-x"
    , alignCenterY = "self-center-y"

    -- space evenly
    , spaceEvenly = "space-evenly"
    , container = "container"

    -- content alignments
    , contentTop = "content-top"
    , contentBottom = "content-bottom"
    , contentRight = "content-right"
    , contentLeft = "content-left"
    , contentCenterX = "content-center-x"
    , contentCenterY = "content-center-y"

    -- selection
    , noTextSelection = "no-text-selection"
    , cursorPointer = "cursor-pointer"
    , cursorText = "cursor-text"

    -- pointer events
    , passPointerEvents = "pass-pointer-events"
    , capturePointerEvents = "capture-pointer-events"
    , transparent = "transparent"
    , opaque = "opaque"
    , overflowHidden = "overflow-hidden"

    --scrollbars
    , scrollbars = "scrollbars"
    , scrollbarsX = "scrollbars-x"
    , scrollbarsY = "scrollbars-y"
    , clip = "✂"
    , clipX = "✂x"
    , clipY = "✂y"

    -- borders
    , borderNone = "border-none"
    , borderDashed = "border-dashed"
    , borderDotted = "border-dotted"
    , borderSolid = "border-solid"

    -- text weight
    , textThin = "text-thin"
    , textExtraLight = "text-extra-light"
    , textLight = "text-light"
    , textNormalWeight = "text-normal-weight"
    , textMedium = "text-medium"
    , textSemiBold = "text-semi-bold"
    , bold = "bold"
    , textExtraBold = "text-extra-bold"
    , textHeavy = "text-heavy"
    , italic = "italic"
    , strike = "strike"
    , underline = "underline"
    , textUnitalicized = "text-unitalicized"

    -- text alignment
    , textJustify = "text-justify"
    , textJustifyAll = "text-justify-all"
    , textCenter = "text-center"
    , textRight = "text-right"
    , textLeft = "text-left"
    }


single =
    { root = "z"
    , any = "s"
    , single = "e"
    , row = "r"
    , column = "c"
    , page = "l"
    , paragraph = "p"
    , text = "t"
    , grid = "g"

    -- widhts/heights
    , widthFill = "↔"
    , widthContent = "wc"
    , widthExact = "w"
    , heightFill = "↕"
    , heightContent = "hc"
    , heightExact = "h"

    -- nearby elements
    , above = "o"
    , below = "u"
    , onRight = "r"
    , onLeft = "l"
    , inFront = "f"
    , behind = "b"

    -- alignments
    , alignTop = "⤒"
    , alignBottom = "⤓"
    , alignRight = "⇥"
    , alignLeft = "⇤"
    , alignCenterX = "self-center-x"
    , alignCenterY = "self-center-y"

    -- space evenly
    , spaceEvenly = "space-evenly"
    , container = "container"

    -- content alignments
    , contentTop = "c⤒"
    , contentBottom = "c⤓"
    , contentRight = "c⇥"
    , contentLeft = "c⇤"
    , contentCenterX = "content-center-x"
    , contentCenterY = "content-center-y"

    -- selection
    , noTextSelection = "no-text-selection"
    , cursorPointer = "cursor-pointer"
    , cursorText = "cursor-text"

    -- pointer events
    , passPointerEvents = "pass-pointer-events"
    , capturePointerEvents = "capture-pointer-events"
    , transparent = "transparent"
    , opaque = "opaque"
    , overflowHidden = "overflow-hidden"

    --scrollbars
    , scrollbars = "scrollbars"
    , scrollbarsX = "scrollbars-x"
    , scrollbarsY = "scrollbars-y"
    , clip = "✂"
    , clipX = "✂x"
    , clipY = "✂y"

    -- borders
    , borderNone = "border-none"
    , borderDashed = "border-dashed"
    , borderDotted = "border-dotted"
    , borderSolid = "border-solid"

    -- text weight
    , textThin = "text-thin"
    , textExtraLight = "text-extra-light"
    , textLight = "text-light"
    , textNormalWeight = "text-normal-weight"
    , textMedium = "text-medium"
    , textSemiBold = "text-semi-bold"
    , bold = "b"
    , textExtraBold = "text-extra-bold"
    , textHeavy = "text-heavy"
    , italic = "i"
    , strike = "-"
    , underline = "u"
    , textUnitalicized = "text-unitalicized"

    -- text alignment
    , textJustify = "text-justify"
    , textJustifyAll = "text-justify-all"
    , textCenter = "text-center"
    , textRight = "text-right"
    , textLeft = "text-left"
    }


describeAlignment values =
    let
        createDescription alignment =
            let
                ( content, indiv ) =
                    values alignment
            in
            [ Descriptor (contentName (Content alignment)) <|
                content
            , Child (dot classes.any)
                [ Descriptor (selfName <| Self alignment) indiv
                ]
            ]
    in
    Batch <|
        List.concatMap createDescription alignments


type Length
    = Shrink
    | Fill


lengths =
    [ Shrink
    , Fill
    ]


type Dimension
    = Width
    | Height


dimensionToString x =
    case x of
        Width ->
            "width"

        Height ->
            "height"


lenToString : Length -> String
lenToString len =
    case len of
        Shrink ->
            "content"

        Fill ->
            "fill"


describeLength dimension lenValue =
    let
        name =
            dimensionToString dimension

        renderLengthRule len =
            Child ("." ++ name ++ "-" ++ lenToString len)
                [ lenValue len
                ]
    in
    Batch
        (List.map renderLengthRule lengths)


gridAlignments values =
    let
        createDescription alignment =
            [ Child (dot classes.any)
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


renderCompact : List Class -> String
renderCompact classes =
    let
        renderValues values =
            values
                |> List.map (\( x, y ) -> "" ++ x ++ ":" ++ y ++ ";")
                |> String.join ""

        renderClass rule =
            case rule.props of
                [] ->
                    ""

                _ ->
                    rule.selector ++ "{" ++ renderValues rule.props ++ rule.closing ++ "}"

        renderIntermediate (Intermediate rule) =
            renderClass rule
                ++ String.join "" (List.map renderIntermediate rule.others)
    in
    classes
        |> List.foldr
            (\(Class name rules) existing ->
                renderRules (emptyIntermediate name "") rules :: existing
            )
            []
        |> List.map renderIntermediate
        |> String.join ""


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


makeImportant : Rule -> Rule
makeImportant rule =
    case rule of
        Prop name prop ->
            Prop name (prop ++ " !important")

        _ ->
            rule


dot c =
    "." ++ c


overrides =
    """@media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {
  .se.row > .se { flex-basis: auto !important; }
  .se.row > .se.container { flex-basis: auto !important; }
}"""


rules : String
rules =
    overrides
        ++ renderCompact
            [ Class "html,body"
                [ Prop "height" "100%"
                , Prop "padding" "0"
                , Prop "margin" "0"
                ]
            , Class (dot classes.any ++ ":focus")
                [ Prop "outline" "none"
                ]
            , Class (dot classes.root)
                [ Prop "width" "100%"
                , Prop "height" "auto"
                , Prop "min-height" "100%"
                , Descriptor ".se.el.height-content"
                    [ Prop "height" "100%"
                    , Child (dot classes.heightFill)
                        [ Prop "height" "100%"
                        ]
                    ]
                , Descriptor (".wireframe ." ++ classes.any)
                    [ Prop "outline" "2px dashed black"
                    ]
                ]
            , Class (dot classes.any)
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

                -- , Prop "line-height" "inherit"
                , Prop "line-height" "1"
                , Prop "font-weight" "inherit"

                -- Text decoration is *mandatorily inherited* in the css spec.
                -- There's no way to change this.  How crazy is that?
                , Prop "text-decoration" "none"
                , Prop "font-style" "inherit"
                , Descriptor (dot classes.noTextSelection)
                    [ Prop "user-select" "none"
                    , Prop "-ms-user-select" "none"
                    ]
                , Descriptor (dot classes.cursorPointer)
                    [ Prop "cursor" "pointer"
                    ]
                , Descriptor (dot classes.cursorText)
                    [ Prop "cursor" "text"
                    ]
                , Descriptor (dot classes.passPointerEvents)
                    [ Prop "pointer-events" "none"
                    ]
                , Descriptor (dot classes.capturePointerEvents)
                    [ Prop "pointer-events" "nauto"
                    ]
                , Descriptor (dot classes.transparent)
                    [ Prop "opacity" "0"
                    ]
                , Descriptor (dot classes.opaque)
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
                , Descriptor (dot classes.overflowHidden)
                    [ Prop "overflow" "hidden"
                    , Prop "-ms-overflow-style" "none"
                    ]
                , Descriptor (dot classes.scrollbars)
                    [ Prop "overflow" "auto"
                    , Prop "flex-shrink" "1"
                    ]
                , Descriptor (dot classes.scrollbarsX)
                    [ Prop "overflow-x" "auto"
                    , Descriptor (dot classes.row)
                        [ Prop "flex-shrink" "1"
                        ]
                    ]
                , Descriptor (dot classes.scrollbarsY)
                    [ Prop "overflow-y" "auto"
                    , Descriptor (dot classes.column)
                        [ Prop "flex-shrink" "1"
                        ]
                    ]
                , Descriptor (dot classes.clip)
                    [ Prop "overflow" "hidden"
                    ]
                , Descriptor (dot classes.clipX)
                    [ Prop "overflow-x" "hidden"
                    ]
                , Descriptor (dot classes.clipY)
                    [ Prop "overflow-y" "hidden"
                    ]
                , Descriptor (dot classes.widthContent)
                    [ Prop "width" "auto"
                    ]
                , Descriptor (dot classes.borderNone)
                    [ Prop "border-width" "0"
                    ]
                , Descriptor (dot classes.borderDashed)
                    [ Prop "border-style" "dashed"
                    ]
                , Descriptor (dot classes.borderDotted)
                    [ Prop "border-style" "dotted"
                    ]
                , Descriptor (dot classes.borderSolid)
                    [ Prop "border-style" "solid"
                    ]
                , Descriptor (dot classes.text)
                    [ Prop "white-space" "pre"
                    , Prop "display" "inline-block"
                    ]
                , Descriptor (dot classes.single)
                    [ Prop "display" "flex"
                    , Prop "flex-direction" "column"
                    , Prop "white-space" "pre"
                    , Descriptor ".se-button"
                        -- Special default for text in a button.
                        -- This is overridden is they put the text inside an `el`
                        [ Child (dot classes.text)
                            [ Descriptor (dot classes.heightFill)
                                [ Prop "flex-grow" "0"
                                ]
                            , Descriptor (dot classes.widthFill)
                                [ Prop "align-self" "auto !important"
                                ]
                            ]
                        ]
                    , Child (dot classes.heightContent)
                        [ Prop "height" "auto"
                        ]
                    , Child (dot classes.heightFill)
                        [ Prop "flex-grow" "100000"
                        ]
                    , Child (dot classes.widthFill)
                        [ -- alignLeft, alignRight, centerX are overridden by width.
                          Prop "align-self" "stretch !important"
                        ]
                    , Child (dot classes.widthContent)
                        [ Prop "align-self" "left"
                        ]
                    , describeAlignment <|
                        \alignment ->
                            case alignment of
                                Top ->
                                    ( [ Prop "justify-content" "flex-start" ]
                                    , [ Prop "margin-bottom" "auto !important"
                                      , Prop "margin-top" "0 !important"
                                      ]
                                    )

                                Bottom ->
                                    ( [ Prop "justify-content" "flex-end" ]
                                    , [ Prop "margin-top" "auto !important"
                                      , Prop "margin-bottom" "0 !important"
                                      ]
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
                                    ( [ -- Prop "justify-content" "center"
                                        Child (dot classes.any)
                                            [ Prop "margin-top" "auto"
                                            , Prop "margin-bottom" "auto"
                                            ]
                                      ]
                                    , [ Prop "margin-top" "auto !important"
                                      , Prop "margin-bottom" "auto !important"
                                      ]
                                    )
                    ]
                , Descriptor (dot classes.row)
                    [ Prop "display" "flex"
                    , Prop "flex-direction" "row"
                    , Child (dot classes.any)
                        [ Prop "flex-basis" "0%"
                        , Descriptor (dot classes.widthExact)
                            [ Prop "flex-basis" "auto"
                            ]
                        ]
                    , Child (dot classes.heightFill)
                        [ --Prop "height" "100%"
                          -- alignTop, centerY, and alignBottom need to be disabled
                          Prop "align-self" "stretch !important"
                        ]
                    , Child ".height-fill-portion"
                        [ --Prop "height" "100%"
                          -- alignTop, centerY, and alignBottom need to be disabled
                          Prop "align-self" "stretch !important"
                        ]
                    , Child ".height-fill-between"
                        [ Prop "align-self" "stretch"
                        , Descriptor ".aligned-vertically"
                            [ Prop "height" "100%"
                            ]
                        ]
                    , Child (dot classes.widthFill)
                        [ Prop "flex-grow" "100000"
                        ]
                    , Child (dot classes.container)
                        [ Prop "flex-grow" "0"
                        , Prop "flex-basis" "auto"
                        , Prop "align-self" "stretch"
                        ]

                    -- , Child "alignLeft:last-of-type.align-container-left"
                    --     [ Prop "flex-grow" "1"
                    --     ]
                    -- alignRight -> <u>
                    --centerX -> <s>
                    , Child "u:first-of-type.align-container-right"
                        [ Prop "flex-grow" "1"
                        ]

                    -- first center y
                    , Child "s:first-of-type.align-container-center-x"
                        [ Prop "flex-grow" "1"
                        , Child (dot classes.alignCenterX)
                            [ Prop "margin-left" "auto !important"
                            ]
                        ]
                    , Child "s:last-of-type.align-container-center-x"
                        [ Prop "flex-grow" "1"
                        , Child (dot classes.alignCenterX)
                            [ Prop "margin-right" "auto !important"
                            ]
                        ]

                    -- lonley centerX
                    , Child "s:only-of-type.align-container-center-x"
                        [ Prop "flex-grow" "1"
                        , Child (dot classes.alignCenterY)
                            [ Prop "margin-top" "auto !important"
                            , Prop "margin-bottom" "auto !important"
                            ]
                        ]

                    -- alignBottom's after a centerX should not grow
                    , Child "s:last-of-type.align-container-center-x ~ u"
                        [ Prop "flex-grow" "0"
                        ]

                    -- centerX's after an alignBottom should be ignored
                    , Child "u:first-of-type.align-container-right ~ s.align-container-center-x"
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
                    , Descriptor (dot classes.spaceEvenly)
                        [ Prop "justify-content" "space-between"
                        ]
                    ]
                , Descriptor (dot classes.column)
                    [ Prop "display" "flex"
                    , Prop "flex-direction" "column"
                    , Child (dot classes.heightFill)
                        [ Prop "flex-grow" "100000"
                        ]
                    , Child (dot classes.widthFill)
                        [ -- alignLeft, alignRight, centerX need to be disabled
                          Prop "align-self" "stretch !important"
                        ]
                    , Child ".width-fill-portion"
                        [ -- alignLeft, alignRight, centerX need to be disabled
                          Prop "align-self" "stretch !important"
                        ]
                    , Child ".width-fill-between"
                        [ Prop "align-self" "stretch"
                        , Descriptor ".aligned-horizontally"
                            [ Prop "width" "100%"
                            ]
                        ]
                    , Child (dot classes.widthContent)
                        [ Prop "align-self" "left"
                        ]

                    -- , Child "alignTop:last-of-type.align-container-top"
                    --     [ Prop "flex-grow" "1"
                    --     ]
                    , Child "u:first-of-type.align-container-bottom"
                        [ Prop "flex-grow" "1"
                        ]

                    -- centerY -> <s>
                    -- alignBottom -> <u>
                    -- first center y
                    , Child "s:first-of-type.align-container-center-y"
                        [ Prop "flex-grow" "1"
                        , Child (dot classes.alignCenterY)
                            [ Prop "margin-top" "auto !important"
                            , Prop "margin-bottom" "0 !important"
                            ]
                        ]
                    , Child "s:last-of-type.align-container-center-y"
                        [ Prop "flex-grow" "1"
                        , Child (dot classes.alignCenterY)
                            [ Prop "margin-bottom" "auto !important"
                            , Prop "margin-top" "0 !important"
                            ]
                        ]

                    -- lonley centerY
                    , Child "s:only-of-type.align-container-center-y"
                        [ Prop "flex-grow" "1"
                        , Child (dot classes.alignCenterY)
                            [ Prop "margin-top" "auto !important"
                            , Prop "margin-bottom" "auto !important"
                            ]
                        ]

                    -- alignBottom's after a centerY should not grow
                    , Child "s:last-of-type.align-container-center-y ~ u"
                        [ Prop "flex-grow" "0"
                        ]

                    -- centerY's after an alignBottom should be ignored
                    , Child "u:first-of-type.align-container-bottom ~ s.align-container-center-y"
                        -- Bottom alignment always overrides center alignment
                        [ Prop "flex-grow" "0"
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
                    , Child (dot classes.container)
                        [ Prop "flex-grow" "0"
                        , Prop "flex-basis" "auto"
                        , Prop "width" "100%"
                        , Prop "align-self" "stretch !important"
                        ]
                    , Descriptor (dot classes.spaceEvenly)
                        [ Prop "justify-content" "space-between"
                        ]
                    ]
                , Descriptor (dot classes.grid)
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
                , Descriptor (dot classes.page)
                    [ Prop "display" "block"
                    , Child (dot <| classes.any ++ ":first-child")
                        [ Prop "margin" "0 !important"
                        ]

                    -- clear spacing of any subsequent element if an element is float-left
                    , Child (dot <| classes.any ++ selfName (Self Left) ++ ":first-child + .se")
                        [ Prop "margin" "0 !important"
                        ]
                    , Child (dot <| classes.any ++ selfName (Self Right) ++ ":first-child + .se")
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
                , Descriptor (dot classes.paragraph)
                    [ Prop "display" "block"
                    , Prop "white-space" "normal"
                    , Child (dot classes.text)
                        [ Prop "display" "inline"
                        , Prop "white-space" "normal"
                        ]
                    , Child (dot classes.single)
                        [ Prop "display" "inline"
                        , Prop "white-space" "normal"
                        , Descriptor (dot classes.inFront)
                            [ Prop "display" "flex"
                            ]
                        , Descriptor (dot classes.behind)
                            [ Prop "display" "flex"
                            ]
                        , Descriptor (dot classes.above)
                            [ Prop "display" "flex"
                            ]
                        , Descriptor (dot classes.below)
                            [ Prop "display" "flex"
                            ]
                        , Descriptor (dot classes.onRight)
                            [ Prop "display" "flex"
                            ]
                        , Descriptor (dot classes.onLeft)
                            [ Prop "display" "flex"
                            ]
                        , Child (dot classes.text)
                            [ Prop "display" "inline"
                            , Prop "white-space" "normal"
                            ]
                        ]
                    , Child (dot classes.row)
                        [ Prop "display" "inline-flex"
                        ]
                    , Child (dot classes.column)
                        [ Prop "display" "inline-flex"
                        ]
                    , Child (dot classes.grid)
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
                , Descriptor ".hidden"
                    [ Prop "display" "none"
                    ]
                , Batch <|
                    flip List.map locations <|
                        \loc ->
                            case loc of
                                Above ->
                                    Descriptor (dot classes.above)
                                        [ Prop "position" "absolute"
                                        , Prop "bottom" "100%"
                                        , Prop "left" "0"
                                        , Prop "width" "100%"
                                        , Prop "z-index" "10"
                                        , Prop "margin" "0 !important"
                                        , Child (dot classes.heightFill)
                                            [ Prop "height" "auto"
                                            ]
                                        , Child (dot classes.widthFill)
                                            [ Prop "width" "100%"
                                            ]
                                        , Prop "pointer-events" "none"
                                        , Child (dot classes.any)
                                            [ Prop "pointer-events" "auto"
                                            ]
                                        ]

                                Below ->
                                    Descriptor (dot classes.below)
                                        [ Prop "position" "absolute"
                                        , Prop "bottom" "0"
                                        , Prop "left" "0"
                                        , Prop "height" "0"
                                        , Prop "width" "100%"
                                        , Prop "z-index" "10"
                                        , Prop "margin" "0 !important"
                                        , Prop "pointer-events" "auto"
                                        , Child (dot classes.heightFill)
                                            [ Prop "height" "auto"
                                            ]
                                        ]

                                OnRight ->
                                    Descriptor (dot classes.onRight)
                                        [ Prop "position" "absolute"
                                        , Prop "left" "100%"
                                        , Prop "top" "0"
                                        , Prop "height" "100%"
                                        , Prop "margin" "0 !important"
                                        , Prop "z-index" "10"
                                        , Prop "pointer-events" "auto"
                                        ]

                                OnLeft ->
                                    Descriptor (dot classes.onLeft)
                                        [ Prop "position" "absolute"
                                        , Prop "right" "100%"
                                        , Prop "top" "0"
                                        , Prop "height" "100%"
                                        , Prop "margin" "0 !important"
                                        , Prop "z-index" "10"
                                        , Prop "pointer-events" "auto"
                                        ]

                                Within ->
                                    Descriptor (dot classes.inFront)
                                        [ Prop "position" "absolute"
                                        , Prop "width" "100%"
                                        , Prop "height" "100%"
                                        , Prop "left" "0"
                                        , Prop "top" "0"
                                        , Prop "margin" "0 !important"
                                        , Prop "z-index" "10"
                                        , Prop "pointer-events" "none"
                                        , Child (dot classes.any)
                                            [ Prop "pointer-events" "auto"
                                            ]
                                        ]

                                Behind ->
                                    Descriptor (dot classes.behind)
                                        [ Prop "position" "absolute"
                                        , Prop "width" "100%"
                                        , Prop "height" "100%"
                                        , Prop "left" "0"
                                        , Prop "top" "0"
                                        , Prop "margin" "0 !important"
                                        , Prop "z-index" "0"
                                        , Prop "pointer-events" "none"
                                        , Child ".se"
                                            [ Prop "pointer-events" "auto"
                                            ]
                                        ]
                , Descriptor (dot classes.textThin)
                    [ Prop "font-weight" "100"
                    ]
                , Descriptor (dot classes.textExtraLight)
                    [ Prop "font-weight" "200"
                    ]
                , Descriptor (dot classes.textLight)
                    [ Prop "font-weight" "300"
                    ]
                , Descriptor (dot classes.textNormalWeight)
                    [ Prop "font-weight" "400"
                    ]
                , Descriptor (dot classes.textMedium)
                    [ Prop "font-weight" "500"
                    ]
                , Descriptor (dot classes.textSemiBold)
                    [ Prop "font-weight" "600"
                    ]
                , Descriptor (dot classes.bold)
                    [ Prop "font-weight" "700"
                    ]
                , Descriptor (dot classes.textExtraBold)
                    [ Prop "font-weight" "800"
                    ]
                , Descriptor (dot classes.textHeavy)
                    [ Prop "font-weight" "900"
                    ]
                , Descriptor (dot classes.italic)
                    [ Prop "font-style" "italic"
                    ]
                , Descriptor (dot classes.strike)
                    [ Prop "text-decoration" "line-through"
                    ]
                , Descriptor (dot classes.underline)
                    [ Prop "text-decoration" "underline"
                    , Prop "text-decoration-skip-ink" "auto"
                    , Prop "text-decoration-skip" "ink"
                    ]
                , Descriptor (dot classes.textUnitalicized)
                    [ Prop "font-style" "normal"
                    ]
                , Descriptor (dot classes.textJustify)
                    [ Prop "text-align" "justify"
                    ]
                , Descriptor (dot classes.textJustifyAll)
                    [ Prop "text-align" "justify-all"
                    ]
                , Descriptor (dot classes.textCenter)
                    [ Prop "text-align" "center"
                    ]
                , Descriptor (dot classes.textRight)
                    [ Prop "text-align" "right"
                    ]
                , Descriptor (dot classes.textLeft)
                    [ Prop "text-align" "left"
                    ]

                -- , Descriptor (dot classes.nearby)
                --     --".nearby"
                --     [ Prop "position" "absolute"
                --     , Prop "top" "0"
                --     , Prop "left" "0"
                --     , Prop "width" "100%"
                --     , Prop "height" "100%"
                --     , Prop "pointer-events" "none"
                --     , Prop "margin" "0 !important"
                --     , Adjacent ".se"
                --         [ Prop "margin-top" "0"
                --         , Prop "margin-left" "0"
                --         ]
                --     ]
                , Descriptor ".modal"
                    [ Prop "position" "fixed"
                    , Prop "left" "0"
                    , Prop "top" "0"
                    , Prop "width" "100%"
                    , Prop "height" "100%"
                    , Prop "pointer-events" "none"
                    ]
                ]
            ]
