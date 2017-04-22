module Main exposing (..)

{-| The basic organization

view function ->
    * layout
    * positioning
    * width/height
    * overlay
    * media querying => on variations


-}


type Element elem
    = Layout
    | Overlay
    | Element
    | Variation
    | Spacer Int
    | Full
    | Empty
    | Text String


type Annotations x
    = Full x
    | Lazy
    | Keyed


type Device model
    = Device DeviceData model


type alias DeviceData =
    { dimensions : ( Int, Int )
    , phone : Bool
    , tablet : Bool
    , desktop : Bool
    , largeDesktop : Bool
    , portrait : Bool
    }


withScreen : Device model -> (DeviceData -> Model -> Html msg)
withScreen deviceAndModel view =
    view (device deviceAndModel) (model deviceAndModel)



-- update :


subscription : Style.Update -> Sub msg
subscription =
    Sub.batch
        [ Window.resizes Resize
        , AnimationFrame Tick
        ]


render : Defaults -> (elem -> Rendered msg) -> Tree (Element msg) -> Html msg
render =
    Debug.crash "yup"



-- keyed : (model -> List item) -> (item -> String) -> (item -> elem) -> List (Rendered elem)
-- type Rendered elem
--     = Rendered Html
--     | Resolving (Trace elem) (List elem)
-- type Trace elem
--     = Trace
--         { depth : Int
--         , stack : List elem
--         }
-- resolve : (elem -> Rendered elem) -> elem -> Rendered elem
-- resolve fn elem =
-- keyed fromModel key =
