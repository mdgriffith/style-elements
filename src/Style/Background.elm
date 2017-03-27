module Style.Background exposing (..)

{-| -}


{-| -}
type alias Image =
    { src : String
    , position : ( Float, Float )
    , repeat : Repeat
    }


{-| -}
backgroundColor : Color -> Property animation variation msg
backgroundColor color =
    (ColorProp "background-color" color)


{-| -}
backgroundImage : Image -> Property animation variation msg
backgroundImage value =
    BackgroundImageProp value


{-| -}
repeatX : Repeat
repeatX =
    Style.Model.RepeatX


{-| -}
repeatY : Repeat
repeatY =
    Style.Model.RepeatY


{-| -}
repeat : Repeat
repeat =
    Style.Model.Repeat


{-| -}
space : Repeat
space =
    Style.Model.Space


{-| -}
round : Repeat
round =
    Style.Model.Round


{-| -}
noRepeat : Repeat
noRepeat =
    Style.Model.NoRepeat
