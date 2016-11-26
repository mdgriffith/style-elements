module Style.Media
    exposing
        ( Query
        , query
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

@docs Query, query, phoneOnly, tabletPortraitUp, tabletPortraitOnly, tabletLandscapeUp, tabletLandscapeOnly, desktopUp, desktopOnly, bigDesktopUp


-}

import Style.Model exposing (Model)


{-| -}
type alias Query =
    ( String, Model -> Model )


{-| -}
query : String -> (Model -> Model) -> Query
query name variation =
    ( name, variation )


{-| -}
phoneOnly : (Model -> Model) -> Query
phoneOnly =
    query "(max-width: 599px)"


{-| -}
tabletPortraitUp : (Model -> Model) -> Query
tabletPortraitUp =
    query "(min-width: 600px)"


{-| -}
tabletPortraitOnly : (Model -> Model) -> Query
tabletPortraitOnly =
    query "(min-width: 600px) and (max-width: 899px)"


{-| -}
tabletLandscapeUp : (Model -> Model) -> Query
tabletLandscapeUp =
    query "(min-width: 900px)"


{-| -}
tabletLandscapeOnly : (Model -> Model) -> Query
tabletLandscapeOnly =
    query "(min-width: 900px) and (max-width: 1199px)"


{-| -}
desktopUp : (Model -> Model) -> Query
desktopUp =
    query "(min-width: 1200px)"


{-| -}
desktopOnly : (Model -> Model) -> Query
desktopOnly =
    query "(min-width: 1200px) and (max-width: 1799px)"


{-| -}
bigDesktopUp : (Model -> Model) -> Query
bigDesktopUp =
    query "(min-width: 1800px)"
