module BoundingBox exposing (Box, get, documentSize)

import Native.BoundingBox


type alias Box =
    { left : Float
    , right : Float
    , top : Float
    , bottom : Float
    , width : Float
    , height : Float
    }


get : String -> Box
get =
    Native.BoundingBox.getBoundingBox


documentSize : () -> { width : Float, height : Float }
documentSize =
    Native.BoundingBox.documentSize
