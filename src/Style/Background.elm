module Style.Background exposing (..)

{-| -}

import Style.Internal.Model as Internal
import Style.Internal.Render as Render
import Color exposing (Color)
import Style exposing (Background, Repeat)


{-| -}
color : Color -> Background
color bgColor =
    Internal.BackgroundElement "background-color" (Render.color bgColor)


{-| -}
image : String -> Background
image src =
    Internal.BackgroundImage
        { src = src
        , position = ( 0, 0 )
        , repeat = noRepeat
        }


{-| -}
imageWith :
    { src : String
    , position : ( Float, Float )
    , repeat : Repeat
    }
imageWith =
    Internal.BackgroundImage


{-| -}
repeatX : Repeat
repeatX =
    Internal.RepeatX


{-| -}
repeatY : Repeat
repeatY =
    Internal.RepeatY


{-| -}
repeat : Repeat
repeat =
    Internal.Repeat


{-| -}
space : Repeat
space =
    Internal.Space


{-| -}
round : Repeat
round =
    Internal.Round


{-| -}
noRepeat : Repeat
noRepeat =
    Internal.NoRepeat
