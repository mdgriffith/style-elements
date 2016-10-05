module Style.Default exposing (..)

import Style exposing (..)
import Color
import Html
import Dict


style : Model msg
style =
    { layout = textLayout
    , visibility = visibility
    , position = position
    , colors = colors
    , text = text
    , border = border
    , cursor = "auto"
    , width = auto
    , height = auto
    , padding = all 0
    , float = Nothing
    , inline = False
    , textShadows = []
    , shadows = []
    , insetShadows = []
    , transforms = []
    , filters = []
    , onHover = Nothing
    , onFocus = Nothing
    }


textLayout : Layout
textLayout =
    TextLayout
        { spacing = Style.all 0
        }


horizontal : Layout
horizontal =
    FlexLayout
        { go = Style.Right
        , wrap = True
        , spacing = Style.all 10
        , align = center
        }


vertical : Layout
vertical =
    FlexLayout
        { go = Style.Down
        , wrap = True
        , spacing = Style.all 10
        , align = Style.center
        }


visibility : Visibility
visibility =
    transparency 0


text : Text
text =
    { font = "georgia"
    , size = 16
    , characterOffset = Nothing
    , lineHeight = 1.0
    , italic = False
    , boldness = Nothing
    , align = Style.AlignLeft
    , decoration = Nothing
    }


border : Border
border =
    { style = Style.solid
    , width = Style.all 0
    , corners = Style.all 0
    }


colors : Colors
colors =
    { background = Color.white
    , text = Color.black
    , border = Color.grey
    }


position : Position
position =
    { relativeTo = Style.CurrentPosition
    , anchor = Style.topLeft
    , position = ( 0, 0 )
    }
