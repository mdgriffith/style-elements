module Calc exposing (..)

{-| -}

import BoundingBox exposing (Box)
import Element.Internal.Model as Model exposing (..)
import Style.Internal.Model as Style exposing (Length(..))


{-| Calculate the position of an element based on the attributes
-}



-- position : List a -> Box -> ( List String, Box )


position attrs parent local =
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
                                    Just <| 5

                                Nearby Below ->
                                    Just <| 5

                                Nearby Above ->
                                    Just <| 5

                                Nearby OnLeft ->
                                    Just <| 5

                                Nearby OnRight ->
                                    Just <| 5

                                Relative ->
                                    -- used internally, not exposed to user
                                    Nothing

                                Absolute frame ->
                                    -- used internally, not exposed to user
                                    Nothing

                        _ ->
                            Nothing
            in
                ( label, positionBox )

        addWidthAndHeight ( label, positionBox ) =
            ( label
            , { positionBox
                | width = width
                , height = height
                , bottom = positionBox.top + height
                , right = positionBox.left + width
              }
            )

        height =
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
                                    Just <|
                                        parent.box.height

                                Calc percent adjust ->
                                    Just <|
                                        ((parent.box.height * percent) - adjust)

                        _ ->
                            Nothing
            in
                List.filterMap findHeight attrs
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault 0

        width =
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
                                    Just <|
                                        parent.box.width

                                Calc percent adjust ->
                                    Just <|
                                        ((parent.box.width * percent) - adjust)

                        _ ->
                            Nothing
            in
                List.filterMap findHeight attrs
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault 0

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
                ( label, move ( x, y, z ) positionBox )

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
            in
                case hAlign of
                    Nothing ->
                        ( label, positionBox )

                    Just Center ->
                        let
                            remaining =
                                parent.box.width - local.width
                        in
                            ( label ++ [ "centered" ]
                            , { positionBox
                                | left = remaining / 2 + parent.box.left
                                , right = remaining / 2 + parent.box.left + local.width
                              }
                            )

                    Just Left ->
                        ( label ++ [ "aligned left" ]
                        , { positionBox
                            | left = 0
                            , right = local.width
                          }
                        )

                    Just Right ->
                        ( label ++ [ "aligned right" ]
                        , { positionBox
                            | left = parent.box.width - local.width
                            , right = parent.box.width
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
            in
                case vAlign of
                    Nothing ->
                        ( label, positionBox )

                    Just Top ->
                        ( label ++ [ "aligned top" ], positionBox )

                    Just VerticalCenter ->
                        ( label ++ [ "aligned vertical center" ], positionBox )

                    Just Bottom ->
                        ( label ++ [ "aligned bottom" ], positionBox )
    in
        ( [], parent.inheritedPosition )
            |> addWidthAndHeight
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


move : ( Float, Float, Float ) -> Box -> Box
move ( x, y, z ) box =
    { left = box.left + x
    , right = box.right - x
    , top = box.top + y
    , bottom = box.bottom - y
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
