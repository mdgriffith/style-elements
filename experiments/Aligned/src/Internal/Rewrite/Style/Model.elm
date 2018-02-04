module Internal.Style.Model exposing (..)

{-| -}


type Class
    = Class String (List Rule)


type Rule
    = Prop String String
    | Child String (List Rule)
    | Supports ( String, String ) (List ( String, String ))
    | Descriptor String (List Rule)
    | Adjacent String (List Rule)
    | Batch (List Rule)


type PseudoClass
    = Focus
    | Hover
    | Active
