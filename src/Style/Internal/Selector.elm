module Style.Internal.Selector exposing (..)

{-| -}

import Style.Internal.Find as Findable


type Selector class variation animation
    = Select String (Findable.Element class variation animation)
    | Pseudo String
    | SelectChild (Selector class variation animation)
    | Free String
    | Stack (List (Selector class variation animation))


formatName : a -> String
formatName x =
    toString x
        |> String.words
        |> List.map uncapitalize
        |> String.join "_"


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


guard : String -> Selector class variation animation -> Selector class variation animation
guard guard selector =
    let
        addGuard str =
            str ++ "--" ++ guard

        onFindable findable =
            case findable of
                Findable.Style class name ->
                    Findable.Style class (addGuard name)

                Findable.Variation class variation name ->
                    Findable.Variation class variation (addGuard name)

                Findable.Animation class animation name ->
                    Findable.Animation class animation (addGuard name)

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


render : Maybe String -> Selector class variation animation -> String
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
                (spacer sel ++ render maybeGuard sel)
    in
        case selector of
            Select single _ ->
                "." ++ guard single

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


getFindable : Selector class variation animation -> List (Findable.Element class variation animation)
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


select : class -> Selector class variation animation
select class =
    Select (formatName class) <| Findable.Style class (formatName class)


child : Selector class variation animation -> Selector class variation animation -> Selector class variation animation
child parent selector =
    Stack [ parent, SelectChild selector ]


free : String -> Selector class variation animation
free str =
    Free str


variant : Selector class variation animation -> variation -> Selector class variation animation
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
pseudo : String -> Selector class variation animation -> Selector class variation animation
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
