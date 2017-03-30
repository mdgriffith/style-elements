module Style.Border exposing (..)

{-| -}

import Style.Internal.Model as Internal exposing (Property(..))
import Style.Internal.Render as Render
import Color exposing (Color)


type alias Border =
    Internal.BorderModel


{-| -}
color : Color -> Border -> Border
color borderColor border =
    { border | color = Just <| Render.color borderColor }


{-| -}
width : ( Float, Float, Float, Float ) -> Border -> Border
width box border =
    { border | width = Just <| Render.box box }


{-| -}
radius : ( Float, Float, Float, Float ) -> Border -> Border
radius box border =
    { border | radius = Just <| Render.box box }


{-| -}
solid : Border -> Border
solid border =
    { border | style = Just "solid" }


{-| -}
dashed : Border -> Border
dashed border =
    { border | style = Just "dashed" }


{-| -}
dotted : Border -> Border
dotted border =
    { border | style = Just "dotted" }
