module Style.Media
    exposing
        ( query
        , phoneOnly
        , tabletPortraitUp
        , tabletPortraitOnly
        , tabletLandscapeUp
        , tabletLandscapeOnly
        , desktopUp
        , desktopOnly
        , bigDesktopUp
        )

{-| Standard media query ranges.

Taken from the following article: https://medium.freecodecamp.com/the-100-correct-way-to-do-css-breakpoints-88d6a5ba1862#.lzjwmdyed

@docs query, phoneOnly, tabletPortraitUp, tabletPortraitOnly, tabletLandscapeUp, tabletLandscapeOnly, desktopUp, desktopOnly, bigDesktopUp


-}

import Style.Internal.Model as Internal exposing (Property)


{-| -}
query : String -> List (Property class variation animation) -> Property class variation animation
query =
    Internal.MediaQuery


{-| -}
phoneOnly : List (Property class variation animation) -> Property class variation animation
phoneOnly =
    query "(max-width: 599px)"


{-| -}
tabletPortraitUp : List (Property class variation animation) -> Property class variation animation
tabletPortraitUp =
    query "(min-width: 600px)"


{-| -}
tabletPortraitOnly : List (Property class variation animation) -> Property class variation animation
tabletPortraitOnly =
    query "(min-width: 600px) and (max-width: 899px)"


{-| -}
tabletLandscapeUp : List (Property class variation animation) -> Property class variation animation
tabletLandscapeUp =
    query "(min-width: 900px)"


{-| -}
tabletLandscapeOnly : List (Property class variation animation) -> Property class variation animation
tabletLandscapeOnly =
    query "(min-width: 900px) and (max-width: 1199px)"


{-| -}
desktopUp : List (Property class variation animation) -> Property class variation animation
desktopUp =
    query "(min-width: 1200px)"


{-| -}
desktopOnly : List (Property class variation animation) -> Property class variation animation
desktopOnly =
    query "(min-width: 1200px) and (max-width: 1799px)"


{-| -}
bigDesktopUp : List (Property class variation animation) -> Property class variation animation
bigDesktopUp =
    query "(min-width: 1800px)"
