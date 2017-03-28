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
    { border | color = Just ( "border-color", Render.color borderColor ) }


{-| -}
width : ( Float, Float, Float, Float ) -> Border -> Border
width box border =
    { border | color = Just ( "border-width", Render.box box ) }


{-| -}
radius : ( Float, Float, Float, Float ) -> Border -> Border
radius box border =
    { border | color = Just ( "border-radius", Render.box box ) }


{-| -}
solid : Border -> Border
solid border =
    { border | color = Just ( "border-style", "solid" ) }


{-| -}
dashed : Border -> Border
dashed border =
    { border | color = Just ( "border-style", "dashed" ) }


{-| -}
dotted : Border -> Border
dotted border =
    { border | color = Just ( "border-style", "dotted" ) }
