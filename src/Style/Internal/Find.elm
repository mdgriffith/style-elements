module Style.Internal.Find exposing (Element(..), Findable, style, toVariation, variation)

{-| Findable Styles

@docs Element, Findable, style, variation, toVariation

-}


{-| -}
type Element class variation
    = Style class String
    | Variation class variation String


{-| -}
type alias Findable class variation =
    List (Element class variation)


{-| -}
toVariation : variation -> String -> Element class variation -> Element class variation
toVariation var newName element =
    case element of
        Style class name ->
            Variation class var newName

        Variation class variation name ->
            Variation class var newName


{-| -}
style : class -> Findable class variation -> String
style class elements =
    let
        find el =
            case el of
                Style cls name ->
                    if cls == class then
                        Just name
                    else
                        Nothing

                _ ->
                    Nothing

        found =
            List.filterMap find elements
                |> List.head
    in
    case found of
        Nothing ->
            Debug.log ("No style present for " ++ toString class) ""

        Just cls ->
            cls


{-| -}
variation : class -> variation -> Findable class variation -> String
variation class variation elements =
    let
        find el =
            case el of
                Variation cls var name ->
                    if class == cls && var == variation then
                        Just name
                    else
                        Nothing

                _ ->
                    Nothing

        found =
            List.filterMap find elements
                |> List.head
    in
    case found of
        Nothing ->
            Debug.log ("No " ++ toString variation ++ " variation  present for " ++ toString class) ""

        Just cls ->
            cls
