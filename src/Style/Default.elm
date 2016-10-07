module Style.Default exposing (..)

import Style exposing (..)
import Color
import Html
import Dict


style : Model
style =
    { layout = textLayout { spacing = all 0 }
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
    , backgroundImage = Nothing
    , textShadows = []
    , shadows = []
    , insetShadows = []
    , transforms = []
    , filters = []
    , onHover = Nothing
    , onFocus = Nothing
    }


horizontal : Layout
horizontal =
    flowRight
        { wrap = True
        , spacing = all 10
        , align = center
        }


vertical : Layout
vertical =
    flowDown
        { wrap = True
        , spacing = all 10
        , align = center
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
    , align = Style.alignLeft
    , decoration = Nothing
    }


border : Border
border =
    { style = solid
    , width = all 0
    , corners = all 0
    }


colors : Colors
colors =
    { background = Color.white
    , text = Color.black
    , border = Color.grey
    }


position : Position
position =
    { relativeTo = currentPosition
    , anchor = topLeft
    , position = ( 0, 0 )
    }
