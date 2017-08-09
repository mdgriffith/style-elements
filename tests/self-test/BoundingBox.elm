module BoundingBox exposing (Box, get)

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
