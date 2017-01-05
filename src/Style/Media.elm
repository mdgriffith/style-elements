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

import Style.Model exposing (Model, Property)


{-| -}
query : String -> List (Property variation) -> Property variation
query =
    Style.Model.MediaQuery


{-| -}
phoneOnly : List (Property variation) -> Property variation
phoneOnly =
    query "(max-width: 599px)"


{-| -}
tabletPortraitUp : List (Property variation) -> Property variation
tabletPortraitUp =
    query "(min-width: 600px)"


{-| -}
tabletPortraitOnly : List (Property variation) -> Property variation
tabletPortraitOnly =
    query "(min-width: 600px) and (max-width: 899px)"


{-| -}
tabletLandscapeUp : List (Property variation) -> Property variation
tabletLandscapeUp =
    query "(min-width: 900px)"


{-| -}
tabletLandscapeOnly : List (Property variation) -> Property variation
tabletLandscapeOnly =
    query "(min-width: 900px) and (max-width: 1199px)"


{-| -}
desktopUp : List (Property variation) -> Property variation
desktopUp =
    query "(min-width: 1200px)"


{-| -}
desktopOnly : List (Property variation) -> Property variation
desktopOnly =
    query "(min-width: 1200px) and (max-width: 1799px)"


{-| -}
bigDesktopUp : List (Property variation) -> Property variation
bigDesktopUp =
    query "(min-width: 1800px)"
