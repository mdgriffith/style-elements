module Element.Device exposing (..)

{-| -}

import Window


type alias Device =
    { width : Int
    , height : Int
    , phone : Bool
    , tablet : Bool
    , desktop : Bool
    , bigDesktop : Bool
    , portrait : Bool
    }


match : Window.Size -> Device
match { width, height } =
    { width = width
    , height = height
    , phone = True
    , tablet = True
    , desktop = True
    , bigDesktop = True
    , portrait = width > height
    }
