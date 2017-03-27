module Style.Options exposing (..)

{-| -}


{-| A style rendering option to be used with `renderWith`
-}
type Option animation variation msg
    = AutoImportGoogleFonts
    | Import String
    | ImportUrl String
    | BaseStyle (List (Property animation variation msg))
    | DebugStyles


{-| An attempt will be made to import all non-standard webfonts that are in your styles.

If a font is not in the following list, then it will try to import it from google fonts.

    [ "arial"
    , "sans-serif"
    , "serif"
    , "courier"
    , "times"
    , "times new roman"
    , "verdana"
    , "tahoma"
    , "georgia"
    , "helvetica"
    ]


-}
autoImportGoogleFonts : Option animation variation msg
autoImportGoogleFonts =
    AutoImportGoogleFonts


{-|
-}
importCSS : String -> Option animation variation msg
importCSS =
    Import


{-|
-}
importUrl : String -> Option animation variation msg
importUrl =
    ImportUrl


{-| Set a base style.  All classes in this stylesheet will start with these properties.
-}
base : List (Property animation variation msg) -> Option animation variation msg
base =
    BaseStyle


{-| Log a warning if a style is missing from a style sheet.

Also shows a visual warning if a style uses float or inline in a table layout orflow/flex layout.

-}
debug : Option animation variation msg
debug =
    DebugStyles
