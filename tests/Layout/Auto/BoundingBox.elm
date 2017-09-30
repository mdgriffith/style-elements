module Layout.Auto.BoundingBox exposing (Box, documentSize, get)

{-| Get browser generated bounding box, or document size.
-}

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
