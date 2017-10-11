module Style.Internal.Selector exposing (Selector, child, formatName, free, getFindable, guard, pseudo, render, select, topName, uncapitalize, variant)

{-| Representations of CSS selectors

@docs Selector, child, formatName, free, getFindable, guard, pseudo, render, select, topName, uncapitalize, variant

-}

import Regex
import Style.Internal.Find as Findable


{-| -}
type Selector class variation
    = Select String (Findable.Element class variation)
    | Pseudo String
    | SelectChild (Selector class variation)
    | Free String
    | Stack (List (Selector class variation))


{-| -}
formatName : a -> String
formatName x =
    toString x
        |> uncapitalize
        |> Regex.replace Regex.All (Regex.regex "[^a-zA-Z0-9_-]") (\_ -> "")
        |> Regex.replace Regex.All (Regex.regex "[A-Z0-9]+") (\{ match } -> " " ++ String.toLower match)
        |> Regex.replace Regex.All (Regex.regex "[\\s+]") (\_ -> "-")


{-| -}
uncapitalize : String -> String
uncapitalize str =
    let
        head =
            String.left 1 str
                |> String.toLower

        tail =
            String.dropLeft 1 str
    in
    head ++ tail


{-| -}
topName : Selector class variation -> String
topName selector =
    case selector of
        Select sel _ ->
            sel

        SelectChild selector ->
            topName selector

        Stack selectors ->
            List.map topName selectors
                |> List.reverse
                |> List.head
                |> Maybe.withDefault ""

        _ ->
            ""


{-| -}
guard : String -> Selector class variation -> Selector class variation
guard guard selector =
    let
        addGuard str =
            str ++ "__" ++ guard

        onFindable findable =
            case findable of
                Findable.Style class name ->
                    Findable.Style class (addGuard name)

                Findable.Variation class variation name ->
                    Findable.Variation class variation (addGuard name)

        onSelector sel =
            case sel of
                Select rendered findable ->
                    Select
                        (addGuard rendered)
                        (onFindable findable)

                SelectChild child ->
                    SelectChild (onSelector child)

                -- Free String
                Stack selectors ->
                    Stack (List.map onSelector selectors)

                x ->
                    x
    in
    onSelector selector


{-| -}
render : Maybe String -> Selector class variation -> String
render maybeGuard selector =
    let
        guard str =
            case maybeGuard of
                Nothing ->
                    str

                Just g ->
                    str ++ "--" ++ g

        spacer sel =
            case sel of
                Pseudo _ ->
                    ""

                _ ->
                    " "

        renderAndSpace i sel =
            if i == 0 then
                render maybeGuard sel
            else
                spacer sel ++ render maybeGuard sel
    in
    case selector of
        Select single _ ->
            ".style-elements ." ++ guard single

        SelectChild child ->
            "> " ++ render maybeGuard child

        Free single ->
            single

        Pseudo psu ->
            psu

        Stack sels ->
            sels
                |> List.indexedMap renderAndSpace
                |> String.concat


{-| -}
getFindable : Selector class variation -> List (Findable.Element class variation)
getFindable find =
    case find of
        Select _ findable ->
            [ findable ]

        SelectChild selector ->
            getFindable selector

        Stack selectors ->
            List.concatMap getFindable selectors
                |> List.reverse
                |> List.head
                |> Maybe.map (\x -> [ x ])
                |> Maybe.withDefault []

        _ ->
            []


{-| -}
select : class -> Selector class variation
select class =
    Select (formatName class) <| Findable.Style class (formatName class)


{-| -}
child : Selector class variation -> Selector class variation -> Selector class variation
child parent selector =
    Stack [ parent, SelectChild selector ]


{-| -}
free : String -> Selector class variation
free str =
    Free str


{-| -}
variant : Selector class variation -> variation -> Selector class variation
variant sel var =
    case sel of
        Pseudo psu ->
            Pseudo psu

        Select single findable ->
            Select (single ++ "-" ++ formatName var)
                (Findable.toVariation
                    var
                    (single ++ "-" ++ formatName var)
                    findable
                )

        SelectChild child ->
            SelectChild (variant child var)

        Free single ->
            Free single

        Stack sels ->
            let
                lastElem =
                    sels
                        |> List.reverse
                        |> List.head

                init =
                    sels
                        |> List.reverse
                        |> List.drop 1
                        |> List.reverse
            in
            case lastElem of
                Nothing ->
                    Stack sels

                Just last ->
                    Stack (init ++ [ variant last var ])


{-| Pseudo-classes are allowed anywhere in selectors while pseudo-elements may only be appended after the last simple selector of the selector.
-}
pseudo : String -> Selector class variation -> Selector class variation
pseudo psu sel =
    case sel of
        Pseudo existing ->
            Pseudo (existing ++ psu)

        Select single findable ->
            Stack [ Select single findable, Pseudo psu ]

        SelectChild child ->
            SelectChild (pseudo psu child)

        Free single ->
            Free single

        Stack sels ->
            let
                lastElem =
                    sels
                        |> List.reverse
                        |> List.head

                init =
                    sels
                        |> List.reverse
                        |> List.drop 1
                        |> List.reverse
            in
            case lastElem of
                Nothing ->
                    Stack sels

                Just last ->
                    Stack (init ++ [ pseudo psu last ])
