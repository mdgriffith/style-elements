module Calc exposing (..)

{-| -}

import BoundingBox exposing (Box)
import Element.Internal.Model as Model exposing (..)
import Style.Internal.Model as Style exposing (Length(..))


{-| Calculate the position of an element based on the attributes
-}
type ParentLayout
    = AbsolutelyPositioned
    | Layout Style.LayoutModel
    | NoLayout


type alias Parent variation msg =
    { box : Box
    , childElementInitialPosition : Box
    , attrs : List (Model.Attribute variation msg)
    , layout : ParentLayout
    , fillPortionX : Float
    , fillPortionY : Float
    , boxWithPadding : Box
    }



-- height : Float -> { b | box : { a | height : Float } } -> List (Attribute variation msg) -> Float


height parent attrs =
    let
        findHeight attr =
            case attr of
                Height len ->
                    case len of
                        Px px ->
                            Just <|
                                px

                        Percent pc ->
                            Just <|
                                (parent.box.height * (pc / 100.0))

                        Auto ->
                            -- How can we know the size of the content?
                            Nothing

                        Fill x ->
                            Just (x * parent.fillPortionY)

                        Calc percent adjust ->
                            Just <|
                                ((parent.box.height * percent) - adjust)

                _ ->
                    Nothing
    in
        List.filterMap findHeight attrs
            |> List.reverse
            |> List.head



-- |> Maybe.withDefault 0
-- |> Maybe.withDefault parent.box.height
-- width : Float -> { b | box : { a | width : Float } } -> List (Attribute variation msg) -> Float


width parent attrs =
    let
        findHeight attr =
            case attr of
                Width len ->
                    case len of
                        Px px ->
                            Just <|
                                px

                        Percent pc ->
                            Just <|
                                (parent.box.width * (pc / 100.0))

                        Auto ->
                            -- How can we know the size of the content?
                            Nothing

                        Fill x ->
                            Just (x * parent.fillPortionX)

                        Calc percent adjust ->
                            Just <|
                                ((parent.box.width * percent) - adjust)

                _ ->
                    Nothing
    in
        List.filterMap findHeight attrs
            |> List.reverse
            |> List.head



-- |> Maybe.withDefault parent.box.width


widthName attrs =
    let
        findHeight attr =
            case attr of
                Width len ->
                    case len of
                        Px px ->
                            Just "px width"

                        Percent pc ->
                            Just "percent width"

                        Auto ->
                            Just "auto width"

                        Fill x ->
                            Just "fill width"

                        Calc percent adjust ->
                            Just "calc width"

                _ ->
                    Nothing
    in
        List.filterMap findHeight attrs
            |> List.reverse
            |> List.head
            |> Maybe.withDefault "empty width"


heightName attrs =
    let
        findHeight attr =
            case attr of
                Height len ->
                    case len of
                        Px px ->
                            Just "px height"

                        Percent pc ->
                            Just "percent height"

                        Auto ->
                            Just "auto height"

                        Fill x ->
                            Just "fill height"

                        Calc percent adjust ->
                            Just "calc height"

                _ ->
                    Nothing
    in
        List.filterMap findHeight attrs
            |> List.reverse
            |> List.head
            |> Maybe.withDefault "empty height"


fillHeightPortions : List (Attribute variation msg) -> Float
fillHeightPortions attrs =
    let
        findPortion attr =
            case attr of
                Height len ->
                    case len of
                        Fill x ->
                            Just x

                        _ ->
                            Nothing

                _ ->
                    Nothing
    in
        List.filterMap findPortion attrs
            |> List.reverse
            |> List.head
            |> Maybe.withDefault 0


fillWidthPortions : List (Attribute variation msg) -> Float
fillWidthPortions attrs =
    let
        findPortion attr =
            case attr of
                Width len ->
                    case len of
                        Fill x ->
                            Just x

                        _ ->
                            Nothing

                _ ->
                    Nothing
    in
        List.filterMap findPortion attrs
            |> List.reverse
            |> List.head
            |> Maybe.withDefault 0


concreteWidth : Float -> List (Attribute variation msg) -> Float
concreteWidth parentWidth attrs =
    let
        findHeight attr =
            case attr of
                Width len ->
                    case len of
                        Px px ->
                            Just <|
                                px

                        Percent pc ->
                            Just <|
                                (parentWidth * (pc / 100.0))

                        Auto ->
                            -- How can we know the size of the content?
                            Nothing

                        Fill x ->
                            Nothing

                        Calc percent adjust ->
                            Just <|
                                ((parentWidth * percent) - adjust)

                _ ->
                    Nothing
    in
        List.filterMap findHeight attrs
            |> List.reverse
            |> List.head
            |> Maybe.withDefault 0


concreteHeight : Float -> List (Attribute variation msg) -> Float
concreteHeight parentHeight attrs =
    let
        findHeight attr =
            case attr of
                Height len ->
                    case len of
                        Px px ->
                            Just <|
                                px

                        Percent pc ->
                            Just <|
                                (parentHeight * (pc / 100.0))

                        Auto ->
                            -- How can we know the size of the content?
                            Nothing

                        Fill x ->
                            Nothing

                        Calc percent adjust ->
                            Just <|
                                ((parentHeight * percent) - adjust)

                _ ->
                    Nothing
    in
        List.filterMap findHeight attrs
            |> List.reverse
            |> List.head
            |> Maybe.withDefault 0



-- position : List a -> Box -> ( List String, Box )


position attrs parent boundingBoxOverride =
    let
        positionNearby ( label, positionBox ) =
            let
                forAnchor attr =
                    case attr of
                        PositionFrame frame ->
                            case frame of
                                Screen ->
                                    Nothing

                                Nearby Within ->
                                    Just
                                        ( label ++ [ "within" ]
                                        , { positionBox
                                            | top = parent.box.top
                                            , left = parent.box.left
                                            , right = parent.box.left + positionBox.width
                                            , bottom = parent.box.top + positionBox.height
                                          }
                                        )

                                Nearby Below ->
                                    Just
                                        ( label ++ [ "below" ]
                                        , { positionBox
                                            | top = parent.box.bottom
                                            , left = parent.box.left
                                            , right = parent.box.left + positionBox.width
                                            , bottom = parent.box.bottom + positionBox.height
                                          }
                                        )

                                Nearby Above ->
                                    Just
                                        ( label ++ [ "above" ]
                                        , { positionBox
                                            | top = parent.box.top - positionBox.height
                                            , left = parent.box.left
                                            , right = parent.box.left + positionBox.width
                                            , bottom = parent.box.top
                                          }
                                        )

                                Nearby OnLeft ->
                                    Just
                                        ( label ++ [ "on left" ]
                                        , { positionBox
                                            | top = parent.box.top
                                            , left = parent.box.left - positionBox.width
                                            , right = parent.box.left
                                            , bottom = parent.box.top + positionBox.height
                                          }
                                        )

                                Nearby OnRight ->
                                    Just
                                        ( label ++ [ "on right" ]
                                        , { positionBox
                                            | top = parent.box.top
                                            , left = parent.box.right
                                            , right = parent.box.right + positionBox.width
                                            , bottom = parent.box.top + positionBox.height
                                          }
                                        )

                                Relative ->
                                    -- used internally, not exposed to user
                                    Nothing

                                Absolute frame ->
                                    -- used internally, not exposed to user
                                    Nothing

                        _ ->
                            Nothing
            in
                List.filterMap forAnchor attrs
                    |> List.head
                    |> Maybe.withDefault ( label, positionBox )

        addWidthAndHeight ( label, positionBox ) =
            let
                childWidth =
                    width parent attrs
                        -- If no width set, then it's auto, so we cheat
                        |> Maybe.withDefault boundingBoxOverride.width

                childHeight =
                    height parent attrs
                        -- If no width set, then it's auto, so we cheat
                        |> Maybe.withDefault boundingBoxOverride.height
            in
                ( widthName attrs :: heightName attrs :: label
                , { positionBox
                    | width = childWidth
                    , height = childHeight
                    , bottom = positionBox.top + childHeight
                    , right = positionBox.left + childWidth
                  }
                )

        applyPositionAdjustment ( label, positionBox ) =
            let
                mergePos attr (( currentX, currentY, currentZ ) as pos) =
                    case attr of
                        Position x y z ->
                            let
                                newX =
                                    case x of
                                        Nothing ->
                                            currentX

                                        Just a ->
                                            Just a

                                newY =
                                    case y of
                                        Nothing ->
                                            currentY

                                        Just a ->
                                            Just a

                                newZ =
                                    case z of
                                        Nothing ->
                                            currentZ

                                        Just a ->
                                            Just a
                            in
                                ( newX, newY, newZ )

                        _ ->
                            pos

                withDefault ( dx, dy, dz ) ( mx, my, mz ) =
                    ( Maybe.withDefault dx mx
                    , Maybe.withDefault dy my
                    , Maybe.withDefault dz mz
                    )

                ( x, y, z ) =
                    attrs
                        |> List.foldl mergePos ( Nothing, Nothing, Nothing )
                        |> withDefault ( 0, 0, 0 )
            in
                ( label, move x y z positionBox )

        applyHAlignment ( label, positionBox ) =
            let
                forHAlign attr =
                    case attr of
                        HAlign alignment ->
                            Just <| alignment

                        _ ->
                            Nothing

                hAlign =
                    List.filterMap forHAlign attrs
                        |> List.reverse
                        |> List.head

                isNullified =
                    case parent.layout of
                        Layout x ->
                            case x of
                                Style.FlexLayout Style.GoRight _ ->
                                    True

                                Style.FlexLayout Style.GoLeft _ ->
                                    True

                                _ ->
                                    False

                        _ ->
                            False
            in
                if isNullified then
                    ( label, positionBox )
                else
                    case hAlign of
                        Nothing ->
                            ( label, positionBox )

                        Just Center ->
                            let
                                remaining =
                                    parent.box.width - positionBox.width
                            in
                                ( label ++ [ "centered" ]
                                , { positionBox
                                    | left = remaining / 2 + parent.box.left
                                    , right = remaining / 2 + parent.box.left + positionBox.width
                                  }
                                )

                        Just Left ->
                            ( label ++ [ "aligned left" ]
                            , { positionBox
                                | left = parent.box.left
                                , right = parent.box.left + positionBox.width
                              }
                            )

                        Just Right ->
                            ( label ++ [ "aligned right" ]
                            , { positionBox
                                | left = parent.box.right - positionBox.width
                                , right = parent.box.right
                              }
                            )

                        Just Justify ->
                            ( label ++ [ "justified" ], positionBox )

        applyVAlignment ( label, positionBox ) =
            let
                forVAlign attr =
                    case attr of
                        VAlign alignment ->
                            Just <| alignment

                        _ ->
                            Nothing

                vAlign =
                    List.filterMap forVAlign attrs
                        |> List.reverse
                        |> List.head

                isNullified =
                    case parent.layout of
                        Layout x ->
                            case x of
                                Style.FlexLayout Style.Down _ ->
                                    True

                                Style.FlexLayout Style.Up _ ->
                                    True

                                _ ->
                                    False

                        _ ->
                            False
            in
                if isNullified then
                    ( label, positionBox )
                else
                    case vAlign of
                        Nothing ->
                            ( label, positionBox )

                        Just Top ->
                            ( label ++ [ "aligned top" ]
                            , { positionBox
                                | bottom = parent.box.top + positionBox.height
                                , top = parent.box.top
                              }
                            )

                        Just VerticalCenter ->
                            let
                                remaining =
                                    parent.box.width - positionBox.width
                            in
                                ( label ++ [ "aligned vertical center" ]
                                , { positionBox
                                    | top = remaining / 2 + parent.box.top
                                    , bottom = remaining / 2 + parent.box.top + positionBox.height
                                  }
                                )

                        Just Bottom ->
                            ( label ++ [ "aligned bottom" ]
                            , { positionBox
                                | bottom = parent.box.bottom
                                , top = parent.box.bottom - positionBox.height
                              }
                            )

                        Just VerticalJustify ->
                            ( label, positionBox )
    in
        ( [], parent.childElementInitialPosition )
            |> addWidthAndHeight
            |> positionNearby
            |> applyHAlignment
            |> applyVAlignment
            |> applyPositionAdjustment


{-| Put the coordinates of a box in terms of another.
-}
relative : Box -> Box -> Box
relative parent element =
    { left = element.left - parent.left
    , right = element.right - parent.left
    , top = element.top - parent.top
    , bottom = element.bottom - parent.top
    , width = element.width
    , height = element.height
    }


move : Float -> Float -> Float -> Box -> Box
move x y z box =
    { left = box.left + x
    , right = box.right + x
    , top = box.top + y
    , bottom = box.bottom + y
    , width = box.width
    , height = box.height
    }


defaultPadding : ( Maybe Float, Maybe Float, Maybe Float, Maybe Float ) -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
defaultPadding ( mW, mX, mY, mZ ) ( w, x, y, z ) =
    ( Maybe.withDefault w mW
    , Maybe.withDefault x mX
    , Maybe.withDefault y mY
    , Maybe.withDefault z mZ
    )


adjustForPadding : List (Attribute variation msg) -> Box -> Box
adjustForPadding attrs box =
    let
        ( paddingTop, paddingRight, paddingBottom, paddingLeft ) =
            let
                forPadding attr =
                    case attr of
                        Padding top right bottom left ->
                            Just <| defaultPadding ( top, right, bottom, left ) ( 0, 0, 0, 0 )

                        _ ->
                            Nothing
            in
                List.filterMap forPadding attrs
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault ( 0, 0, 0, 0 )
    in
        { left = box.left + paddingLeft
        , right = box.right + paddingRight
        , top = box.top + paddingTop
        , bottom = box.bottom + paddingBottom
        , width = box.width - (paddingLeft + paddingRight)
        , height = box.height - (paddingTop + paddingBottom)
        }
