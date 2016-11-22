module Style.Media exposing (..)

{-| Standard media query ranges.

Taken from the following article: https://medium.freecodecamp.com/the-100-correct-way-to-do-css-breakpoints-88d6a5ba1862#.lzjwmdyed

-}


{-| -}
phoneOnly : String
phoneOnly =
    "(max-width: 599px)"


{-| -}
tabletPortraitUp : String
tabletPortraitUp =
    "(min-width: 600px)"


{-| -}
tabletPortaitOnly : String
tabletPortaitOnly =
    "(min-width: 600px) and (max-width: 899px)"


{-| -}
tabletLandscapeUp : String
tabletLandscapeUp =
    "(min-width: 900px)"


{-| -}
tabletLandscapeOnly : String
tabletLandscapeOnly =
    "(min-width: 900px) and (max-width: 1199px)"


{-| -}
desktopUp : String
desktopUp =
    "(min-width: 1200px)"


{-| -}
desktopOnly : String
desktopOnly =
    "(min-width: 1200px) and (max-width: 1799px)"


{-| -}
bigDesktopUp : String
bigDesktopUp =
    "(min-width: 1800px)"
