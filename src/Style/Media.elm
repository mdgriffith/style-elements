module Style.Media
    exposing
        ( Query
        , query
        , phoneOnly
        , tabletPortraitUp
        , tabletPortaitOnly
        , tablateLandscapeUp
        , tabletLandscapeOnly
        , desktopUp
        , desktopOnly
        , bigDesktopUp
        )

{-| Standard media query ranges.

Taken from the following article: https://medium.freecodecamp.com/the-100-correct-way-to-do-css-breakpoints-88d6a5ba1862#.lzjwmdyed

@docs Query, query, phoneOnly, tabletPortraitUp, tabletPortaitOnly, tablateLandscapeUp, tabletLandscapeOnly, desktopUp, desktopOnly, bigDesktopUp


-}


{-| -}
type alias Query =
    ( String, Model -> Model )


{-| -}
query : String -> (Style.Model.Model -> Style.Model.Model) -> Query
query name variation =
    ( name, variation )


{-| -}
phoneOnly : (Style.Model.Model -> Style.Model.Model) -> Query
phoneOnly =
    query "(max-width: 599px)"


{-| -}
tabletPortraitUp : (Style.Model.Model -> Style.Model.Model) -> Query
tabletPortraitUp =
    query "(min-width: 600px)"


{-| -}
tabletPortaitOnly : (Style.Model.Model -> Style.Model.Model) -> Query
tabletPortaitOnly =
    query "(min-width: 600px) and (max-width: 899px)"


{-| -}
tabletLandscapeUp : (Style.Model.Model -> Style.Model.Model) -> Query
tabletLandscapeUp =
    query "(min-width: 900px)"


{-| -}
tabletLandscapeOnly : (Style.Model.Model -> Style.Model.Model) -> Query
tabletLandscapeOnly =
    query "(min-width: 900px) and (max-width: 1199px)"


{-| -}
desktopUp : (Style.Model.Model -> Style.Model.Model) -> Query
desktopUp =
    query "(min-width: 1200px)"


{-| -}
desktopOnly : (Style.Model.Model -> Style.Model.Model) -> Query
desktopOnly =
    query "(min-width: 1200px) and (max-width: 1799px)"


{-| -}
bigDesktopUp : (Style.Model.Model -> Style.Model.Model) -> Query
bigDesktopUp =
    query "(min-width: 1800px)"
