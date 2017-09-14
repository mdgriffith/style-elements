module Element.Location exposing (nav, navColumn, header, content, footer, sidebar, search, modal)

{-| This module is meant to capture the high-level, semantic areas of your page.

@docs nav, navColumn

@docs header, content, footer, sidebar, search

@docs modal

-}

import Element exposing (..)
import Element.Attributes as Attr
import Element.Internal.Model as Internal
import Style.Internal.Model as Style
import Element.Internal.Modify as Modify


{-| An area that houses the controls for running a search.

While `Element.Input.search` will create a literal search bar,
this element is meant to group all the controls that are involved with searching,
such as filter, and the search button.

-}
search : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
search style attrs child =
    Internal.Element
        { node = "div"
        , style = Just style
        , attrs = Attr.width Attr.fill :: Attr.attribute "role" "search" :: attrs
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| The main navigation of the site, rendered as a row.

The required `name` is used by accessibility software to describe to non-sighted users what this navigation element pertains to.

Don't leave `name` blank, even if you just put *"Main Navigation"* in it.

-}
nav : style -> List (Attribute variation msg) -> { options : List (Element style variation msg), name : String } -> Element style variation msg
nav style attrs { options, name } =
    Internal.Element
        { node = "nav"
        , style = Nothing
        , attrs = [ Attr.attribute "role" "navigation", Attr.attribute "aria-label" name ]
        , child =
            Internal.Layout
                { node = "ul"
                , style = Just style
                , layout = Style.FlexLayout Style.GoRight []
                , attrs = attrs
                , children =
                    options
                        |> List.map (Modify.setNode "li")
                        |> Internal.Normal
                , absolutelyPositioned = Nothing
                }
        , absolutelyPositioned = Nothing
        }


{-| -}
navColumn : style -> List (Attribute variation msg) -> { options : List (Element style variation msg), name : String } -> Element style variation msg
navColumn style attrs { options, name } =
    Internal.Element
        { node = "nav"
        , style = Nothing
        , attrs = [ Attr.attribute "role" "navigation", Attr.attribute "aria-label" name ]
        , child =
            Internal.Layout
                { node = "ul"
                , style = Just style
                , layout = Style.FlexLayout Style.Down []
                , attrs = attrs
                , children =
                    options
                        |> List.map (Modify.setNode "li")
                        |> Internal.Normal
                , absolutelyPositioned = Nothing
                }
        , absolutelyPositioned = Nothing
        }


{-| This is the main page header area.
-}
header : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
header style attrs child =
    Internal.Element
        { node = "header"
        , style = Just style
        , attrs = Attr.width Attr.fill :: Attr.attribute "role" "banner" :: attrs
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| This is the main page footer where your copyright and other infomation should live!

<footer, role=contentinfo>

-}
footer : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
footer style attrs child =
    Internal.Element
        { node = "footer"
        , style = Just style
        , attrs = Attr.width Attr.fill :: Attr.attribute "role" "contentinfo" :: attrs
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| This is a sidebar which contains complementary information to your main content.

It's rendered as a column.

-}
sidebar : style -> List (Attribute variation msg) -> List (Element style variation msg) -> Element style variation msg
sidebar style attrs children =
    Internal.Layout
        { node = "aside"
        , style = Just style
        , layout = Style.FlexLayout Style.Down []
        , attrs = Attr.attribute "role" "complementary" :: attrs
        , children = Internal.Normal children
        , absolutelyPositioned = Nothing
        }


{-| This is the main content of your page.
-}
content : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
content style attrs child =
    Internal.Element
        { node = "main"
        , style = Just style
        , attrs = Attr.width Attr.fill :: Attr.height Attr.fill :: Attr.attribute "role" "main" :: attrs
        , child = child
        , absolutelyPositioned = Nothing
        }


{-| This is a modal
-}
modal : style -> List (Attribute variation msg) -> Element style variation msg -> Element style variation msg
modal style attrs child =
    screen <|
        Internal.Element
            { node = "div"
            , style = Just style
            , attrs = Attr.attribute "role" "alertdialog" :: Attr.attribute "aria-modal" "true" :: attrs
            , child = child
            , absolutelyPositioned = Nothing
            }
