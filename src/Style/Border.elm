module Style.Border exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property(..))
import Style.Internal.Render as Render
import Color exposing (Color)


type alias Border =
    List Internal.BorderElement


{-| -}
color : Color -> Border -> Border
color borderColor border =
    Internal.BorderElement "border-color" (Render.color borderColor) :: border


{-| -}
width : ( Float, Float, Float, Float ) -> Border -> Border
width box border =
    Internal.BorderElement "border-width" (Render.box box) :: border


{-| -}
radius : ( Float, Float, Float, Float ) -> Border -> Border
radius box border =
    Internal.BorderElement "border-radius" (Render.box box) :: border


{-| -}
solid : Border -> Border
solid border =
    Internal.BorderElement "border-style" "solid" :: border


{-| -}
dashed : Border -> Border
dashed border =
    Internal.BorderElement "border-style" "dashed" :: border


{-| -}
dotted : Border -> Border
dotted border =
    Internal.BorderElement "border-style" "dotted" :: border
