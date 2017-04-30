module Style.Internal.Render.Css exposing (..)

import String


brace : Int -> String -> String
brace i str =
    " {\n" ++ str ++ "\n" ++ String.repeat i " " ++ "}"


prop : Int -> ( String, String ) -> String
prop i ( name, value ) =
    (String.repeat i " ") ++ name ++ ": " ++ value ++ ";"
