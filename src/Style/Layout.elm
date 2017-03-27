module Style.Layout exposing (..)

{-| -}


{-| This is the familiar block layout.  It's the only layout that allows for child elements to use `float` or `inline`.



-}
text : LayoutProperty animation variation msg
text =
    LayoutProperty (LayoutProp Style.Model.TextLayout)


{-| This is the same as setting an element to `display:table`.

-}
table : LayoutProperty animation variation msg
table =
    LayoutProperty (LayoutProp Style.Model.TableLayout)


{-|

-}
type alias Flow =
    { wrap : Bool
    , horizontal : Centerable Horizontal
    , vertical : Centerable Vertical
    }


{-| This is a flexbox based layout
-}
flowUp : Flow -> LayoutProperty animation variation msg
flowUp { wrap, horizontal, vertical } =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.Up
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        LayoutProperty (LayoutProp layout)


{-|

-}
flowDown : Flow -> LayoutProperty animation variation msg
flowDown { wrap, horizontal, vertical } =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.Down
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        LayoutProperty (LayoutProp layout)


{-| -}
flowRight : Flow -> LayoutProperty animation variation msg
flowRight { wrap, horizontal, vertical } =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.GoRight
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        LayoutProperty (LayoutProp layout)


{-| -}
flowLeft : Flow -> LayoutProperty animation variation msg
flowLeft { wrap, horizontal, vertical } =
    let
        layout =
            Style.Model.FlexLayout <|
                Style.Model.Flexible
                    { go = Style.Model.GoLeft
                    , wrap = wrap
                    , horizontal = horizontal
                    , vertical = vertical
                    }
    in
        LayoutProperty (LayoutProp layout)


{-| -}
alignTop : Centerable Vertical
alignTop =
    Other Top


{-| -}
alignBottom : Centerable Vertical
alignBottom =
    Other Bottom


{-|
-}
center : Centerable a
center =
    Center


{-|
-}
stretch : Centerable a
stretch =
    Stretch


{-| -}
justify : Centerable a
justify =
    stretch


{-| -}
justifyAll : Centerable a
justifyAll =
    stretch


{-| -}
alignLeft : Centerable Horizontal
alignLeft =
    Other Left


{-| -}
alignRight : Centerable Horizontal
alignRight =
    Other Right


{-| -}
spacing : ( Float, Float, Float, Float ) -> LayoutProperty animation variation msg
spacing s =
    LayoutProperty (Spacing s)
