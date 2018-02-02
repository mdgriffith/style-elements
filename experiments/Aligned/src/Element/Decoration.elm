module Element.Decoration
    exposing
        ( backgroundColor
        , borderColor
        , focused
        , fontColor
        , fontSize
        , mouseDown
        , mouseOver
        , moveDown
        , moveLeft
        , moveRight
        , moveUp
        , rotate
        , scale
        )

{-| For handling hover, focus, and pressed states.

@docs mouseOver, mouseDown, focused

@docs fontColor, fontSize, borderColor, backgroundColor

@docs moveUp, moveDown, moveRight, moveLeft, rotate, scale

-}

import Color exposing (Color)
import Element exposing (Attribute)
import Internal.Model as Internal


{-| -}
type Decoration
    = Decoration Internal.Style


tagAs : String -> Decoration -> Internal.Style
tagAs label attr =
    case attr of
        Decoration a ->
            case a of
                Internal.Single class prop val ->
                    Internal.Single (label ++ "-" ++ class) prop val

                Internal.Colored class prop val ->
                    Internal.Colored (label ++ "-" ++ class) prop val

                x ->
                    x


{-| -}
mouseOver : List Decoration -> Attribute msg
mouseOver decs =
    Internal.StyleClass <| Internal.PseudoSelector Internal.Hover (List.map (tagAs "hover") decs)


{-| -}
focused : List Decoration -> Attribute msg
focused decs =
    Internal.StyleClass <| Internal.PseudoSelector Internal.Focus (List.map (tagAs "focus") decs)


{-| -}
mouseDown : List Decoration -> Attribute msg
mouseDown decs =
    Internal.StyleClass <| Internal.PseudoSelector Internal.Active (List.map (tagAs "active") decs)


{-| -}
fontSize : a -> Decoration
fontSize size =
    Decoration (Internal.Single ("font-size-" ++ toString size) "font-size" (toString size ++ "px"))


{-| -}
borderColor : Color -> Decoration
borderColor color =
    Decoration (Internal.Colored ("border-color-" ++ Internal.formatColorClass color) "border-color" color)


{-| -}
backgroundColor : Color -> Decoration
backgroundColor color =
    Decoration (Internal.Colored ("bg-" ++ Internal.formatColorClass color) "background-color" color)


{-| -}
fontColor : Color -> Decoration
fontColor color =
    Decoration (Internal.Colored ("font-color-" ++ Internal.formatColorClass color) "color" color)


{-| -}
scale : Float -> Decoration
scale n =
    Decoration (Internal.Transform (Internal.Scale n n 1))


{-| -}
rotate : Float -> Decoration
rotate angle =
    Decoration (Internal.Transform (Internal.Rotate 0 0 1 angle))


{-| -}
moveUp : Float -> Decoration
moveUp y =
    Decoration (Internal.Transform (Internal.Move Nothing (Just (negate y)) Nothing))


{-| -}
moveDown : Float -> Decoration
moveDown y =
    Decoration (Internal.Transform (Internal.Move Nothing (Just y) Nothing))


{-| -}
moveRight : Float -> Decoration
moveRight x =
    Decoration (Internal.Transform (Internal.Move (Just x) Nothing Nothing))


{-| -}
moveLeft : Float -> Decoration
moveLeft x =
    Decoration (Internal.Transform (Internal.Move (Just (negate x)) Nothing Nothing))



-- shadow =
--     Decoration
-- transparent =
--     Decoration
