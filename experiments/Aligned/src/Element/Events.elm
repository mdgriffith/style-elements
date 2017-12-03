module Element.Events
    exposing
        ( Options
        , defaultOptions
        , keyCode
        , on
        , onBlur
        , onClick
        , onDoubleClick
        , onFocus
        , onMouseDown
        , onMouseEnter
        , onMouseLeave
        , onMouseOut
        , onMouseOver
        , onMouseUp
        , onWithOptions
        , targetChecked
        , targetValue
        )

{-| This module is mirrored nearly completely from Html.Events

The only difference is that the HTML.Events are turned into Element.Events


# Mouse Helpers

@docs onClick, onDoubleClick, onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseOver, onMouseOut


# Focus Helpers

@docs onBlur, onFocus


# Custom Event Handlers

@docs on, onWithOptions, Options, defaultOptions


# Custom Decoders

@docs targetValue, targetChecked, keyCode

-}

import Html
import Html.Events
import Internal.Model as Internal exposing (Attribute(..))
import Json.Decode as Json
import VirtualDom


-- MOUSE EVENTS


{-| -}
onClick : msg -> Attribute msg
onClick =
    Attr << Html.Events.onClick


{-| -}
onDoubleClick : msg -> Attribute msg
onDoubleClick =
    Attr << Html.Events.onDoubleClick


{-| -}
onMouseDown : msg -> Attribute msg
onMouseDown =
    Attr << Html.Events.onMouseDown


{-| -}
onMouseUp : msg -> Attribute msg
onMouseUp =
    Attr << Html.Events.onMouseUp


{-| -}
onMouseEnter : msg -> Attribute msg
onMouseEnter =
    Attr << Html.Events.onMouseEnter


{-| -}
onMouseLeave : msg -> Attribute msg
onMouseLeave =
    Attr << Html.Events.onMouseLeave


{-| -}
onMouseOver : msg -> Attribute msg
onMouseOver =
    Attr << Html.Events.onMouseOver


{-| -}
onMouseOut : msg -> Attribute msg
onMouseOut =
    Attr << Html.Events.onMouseOut



-- FOCUS EVENTS


{-| -}
onBlur : msg -> Attribute msg
onBlur =
    Attr << Html.Events.onBlur


{-| -}
onFocus : msg -> Attribute msg
onFocus =
    Attr << Html.Events.onFocus



-- CUSTOM EVENTS


{-| Create a custom event listener. Normally this will not be necessary, but
you have the power! Here is how `onClick` is defined for example:

    import Json.Decode as Json

    onClick : msg -> Attribute msg
    onClick message =
        on "click" (Json.succeed message)

The first argument is the event name in the same format as with JavaScript's
[`addEventListener`][aEL] function.
The second argument is a JSON decoder. Read more about these [here][decoder].
When an event occurs, the decoder tries to turn the event object into an Elm
value. If successful, the value is routed to your `update` function. In the
case of `onClick` we always just succeed with the given `message`.
If this is confusing, work through the [Elm Architecture Tutorial][tutorial].
It really does help!
[aEL]: <https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener>
[decoder]: <http://package.elm-lang.org/packages/elm-lang/core/latest/Json-Decode>
[tutorial]: <https://github.com/evancz/elm-architecture-tutorial/>

-}
on : String -> Json.Decoder msg -> Attribute msg
on event decode =
    Attr <| Html.Events.on event decode


{-| Same as `on` but you can set a few options.
-}
onWithOptions : String -> Html.Events.Options -> Json.Decoder msg -> Attribute msg
onWithOptions event options decode =
    Attr <| Html.Events.onWithOptions event options decode



-- COMMON DECODERS


{-| Options for an event listener. If `stopPropagation` is true, it means the
event stops traveling through the DOM so it will not trigger any other event
listeners. If `preventDefault` is true, any built-in browser behavior related
to the event is prevented. For example, this is used with touch events when you
want to treat them as gestures of your own, not as scrolls.
-}
type alias Options =
    { stopPropagation : Bool
    , preventDefault : Bool
    }


{-| Everything is `False` by default.

    defaultOptions =
        { stopPropagation = False
        , preventDefault = False
        }

-}
defaultOptions : Options
defaultOptions =
    VirtualDom.defaultOptions



-- COMMON DECODERS


{-| A `Json.Decoder` for grabbing `event.target.value`. We use this to define
`onInput` as follows:

    import Json.Decode as Json

    onInput : (String -> msg) -> Attribute msg
    onInput tagger =
        on "input" (Json.map tagger targetValue)

You probably will never need this, but hopefully it gives some insights into
how to make custom event handlers.

-}
targetValue : Json.Decoder String
targetValue =
    Json.at [ "target", "value" ] Json.string


{-| A `Json.Decoder` for grabbing `event.target.checked`. We use this to define
`onCheck` as follows:

    import Json.Decode as Json

    onCheck : (Bool -> msg) -> Attribute msg
    onCheck tagger =
        on "input" (Json.map tagger targetChecked)

-}
targetChecked : Json.Decoder Bool
targetChecked =
    Json.at [ "target", "checked" ] Json.bool


{-| A `Json.Decoder` for grabbing `event.keyCode`. This helps you define
keyboard listeners like this:

    import Json.Decode as Json

    onKeyUp : (Int -> msg) -> Attribute msg
    onKeyUp tagger =
        on "keyup" (Json.map tagger keyCode)

**Note:** It looks like the spec is moving away from `event.keyCode` and
towards `event.key`. Once this is supported in more browsers, we may add
helpers here for `onKeyUp`, `onKeyDown`, `onKeyPress`, etc.

-}
keyCode : Json.Decoder Int
keyCode =
    Json.field "keyCode" Json.int
