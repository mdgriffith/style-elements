module Style.Font exposing (FontSet, FontSizes, create, createFrom, cast)

{-| Create a standard set of 9 font sizes for a font.

@docs FontSet, FontSizes, create, createFrom, cast

-}

import Style


{-| -}
type alias FontSet =
    { gigantic : Font
    , huge : Font
    , large : Font
    , big : Font
    , normal : Font
    , small : Font
    , little : Font
    , tiny : Font
    , mini : Font
    }


{-| -}
type alias FontSizes =
    { gigantic : FontSize
    , huge : FontSize
    , large : FontSize
    , big : FontSize
    , normal : FontSize
    , small : FontSize
    , little : FontSize
    , tiny : FontSize
    , mini : FontSize
    }


{-| -}
type alias FontSize =
    { size : Float
    , lineHeight : Float
    }


{-| Specify a font family and create a font in 9 sizes. The following defaults are used

 * 16px for the 'normal' fontsize
 * line height of 1.7em for 'normal'
 * not bold or italic
 * align left
 * no additional character offset
 * normal whitespace

-}
create : String -> FontSet
create family =
    let
        foundation =
            { font = font
            , size = 16
            , lineHeight = 1.7
            , characterOffset = Nothing
            , align = alignLeft
            , whitespace = normal
            , italic = False
            , bold = Nothing
            }
    in
        { gigantic =
            { foundation
                | size = 29
                , lineHeight = 1.125
            }
        , huge =
            { foundation
                | size = 23
                , lineHeight = 1.125
            }
        , large =
            { foundation
                | size = 21
                , lineHeight = 1.125
            }
        , big =
            { foundation
                | size = 18
                , lineHeight = 1.2
            }
        , normal =
            { foundation
                | size = 16
                , lineHeight = 1.6
            }
        , small =
            { foundation
                | size = 14
                , lineHeight = 1.285
            }
        , little =
            { foundation
                | size = 13
                , lineHeight = 1.33
            }
        , tiny =
            { foundation
                | size = 12
                , lineHeight = 1.33
            }
        , mini =
            { foundation
                | size = 11
                , lineHeight = 1.33
            }
        }


{-| Specify all values of a font and create 9 size variations.
-}
createFrom : Font -> FontSet
createFrom foundation =
    { gigantic =
        { foundation
            | size = foundaton.size * (29.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.125 / 1.6)
        }
    , huge =
        { foundation
            | size = foundaton.size * (23.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.125 / 1.6)
        }
    , large =
        { foundation
            | size = foundaton.size * (21.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.125 / 1.6)
        }
    , big =
        { foundation
            | size = foundaton.size * (18.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.2 / 1.6)
        }
    , normal =
        { foundation
            | size = foundaton.size * (16.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.6 / 1.6)
        }
    , small =
        { foundation
            | size = foundaton.size * (14.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.285 / 1.6)
        }
    , little =
        { foundation
            | size = foundaton.size * (13.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.33 / 1.6)
        }
    , tiny =
        { foundation
            | size = foundaton.size * (12.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.33 / 1.6)
        }
    , mini =
        { foundation
            | size = foundaton.size * (11.0 / 16.0)
            , lineHeight = foundation.lineHeight * (1.33 / 1.6)
        }
    }


{-| Specify all values of a font and provide 9 size variations to create.
-}
cast : Font -> FontSizes -> FontSet
cast foundation fontSizes =
    { gigantic =
        { foundation
            | size = fontSizes.gigantic.size
            , lineHeight = fontSizes.gigantic.lineHeight
        }
    , huge =
        { foundation
            | size = fontSizes.huge.size
            , lineHeight = fontSizes.huge.lineHeight
        }
    , large =
        { foundation
            | size = fontSizes.large.size
            , lineHeight = fontSizes.large.lineHeight
        }
    , big =
        { foundation
            | size = fontSizes.big.size
            , lineHeight = fontSizes.big.lineHeight
        }
    , normal =
        { foundation
            | size = fontSizes.normal.size
            , lineHeight = fontSizes.normal.lineHeight
        }
    , small =
        { foundation
            | size = fontSizes.small.size
            , lineHeight = fontSizes.small.lineHeight
        }
    , little =
        { foundation
            | size = fontSizes.little.size
            , lineHeight = fontSizes.little.lineHeight
        }
    , tiny =
        { foundation
            | size = fontSizes.tiny.size
            , lineHeight = fontSizes.tiny.lineHeight
        }
    , mini =
        { foundation
            | size = fontSizes.mini.size
            , lineHeight = fontSizes.mini.lineHeight
        }
    }
