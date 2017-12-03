module Element.Area exposing (..)

{-| -}

import Internal.Model exposing (..)


primary : Attribute msg
primary =
    Describe Main


aside : Attribute msg
aside =
    Describe Complementary


navigation : Attribute msg
navigation =
    Describe Navigation



-- search : Attribute msg
-- search =
--     Describe Search


footer : Attribute msg
footer =
    Describe ContentInfo


heading : Int -> Attribute msg
heading =
    Describe << Heading


announceUrgently : Attribute msg
announceUrgently =
    Describe LiveAssertive


announce : Attribute msg
announce =
    Describe LivePolite
