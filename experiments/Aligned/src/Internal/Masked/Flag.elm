module Internal.Masked.Flag exposing (..)

{-| -}

import Bitwise


type alias Flag =
    Int


none : Flag
none =
    0


{-| If the query is in the truth, return True
-}
present : Flag -> Flag -> Bool
present query truth =
    Bitwise.and query truth == query


{-| Flip all bits that are 1 in the first flag, in the second flag.
-}
add : Flag -> Flag -> Flag
add flipTo truth =
    Bitwise.or flipTo truth


col : Int -> Flag
col i =
    2 ^ i
