module Main exposing (..)


property : Parser s AST
property =
    lazy
        (\_ ->
            (\_ key _ _ _ value _ -> Property key value)
                <$> spaces
                <*> propertyKey
                <*> spaces
                <*> equal
                <*> spaces
                <*> expression
                <*> spaces
        )
