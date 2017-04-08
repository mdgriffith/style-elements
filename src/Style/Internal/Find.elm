module Style.Internal.Find exposing (Element(..), Findable, style, variation, toVariation)

{-| -}


type Element class variation animation
    = Style class String
    | Variation class variation String
    | Animation class animation String


type alias Findable class variation animation =
    List (Element class variation animation)


toVariation : variation -> String -> Element class variation animation -> Element class variation animation
toVariation var newName element =
    case element of
        Style class name ->
            Variation class var newName

        Variation class variation name ->
            Variation class var newName

        Animation class animation name ->
            Variation class var newName


style : class -> Findable class variation animation -> String
style class elements =
    let
        _ =
            Debug.log "cache" elements

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


variation : class -> variation -> Findable class variation animation -> String
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
