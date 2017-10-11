module Style.Internal.Prefixer exposing (prefix)

{-| Style Prefixes
-}


{-| -}
type Prefix
    = Value String (List String)
    | Property String (List String)


{-| -}
applyPrefix : Prefix -> ( String, String ) -> List ( String, String )
applyPrefix prefix ( name, value ) =
    case prefix of
        Value valueMatch newValues ->
            let
                pair name value =
                    ( name, value )
            in
            if value == valueMatch then
                ( name, value ) :: List.map (pair name) newValues
            else
                [ ( name, value ) ]

        Property nameMatch newNames ->
            let
                pairValue value name =
                    ( name, value )
            in
            if name == nameMatch then
                ( name, value ) :: List.map (pairValue value) newNames
            else
                [ ( name, value ) ]


{-| -}
prefix : List Prefix -> List ( String, String ) -> List ( String, String )
prefix prefixes attrs =
    let
        applyAll attr prefixedAttrs =
            List.foldr (\prefix prefixed -> applyPrefix prefix attr ++ prefixed) prefixedAttrs prefixes
    in
    List.foldr applyAll [] attrs
