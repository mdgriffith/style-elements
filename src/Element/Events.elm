module Element.Events
    exposing
        ( onClick
        , onDoubleClick
        , onMouseDown
        , onMouseUp
        , onMouseEnter
        , onMouseLeave
        , onMouseOver
        , onMouseOut
        , onInput
        , onCheck
        , onSubmit
        , onBlur
        , onFocus
        , on
        , onWithOptions
        )

{-| This module is mirrored nearly completely from Html.Events

The only difference is that the HTML.Events are turned into Element.Events


-}

import Html
import Html.Events
import Json.Decode as Json
import Element.Internal.Model as Internal exposing (Attribute(..))


-- MOUSE EVENTS


{-| Turn an Html Event into an Element event
-}
event : Html.Attribute msg -> Attribute variation msg
event =
    Event


{-| -}
onClick : msg -> Attribute variation msg
onClick =
    Event << Html.Events.onClick


{-| -}
onDoubleClick : msg -> Attribute variation msg
onDoubleClick =
    Event << Html.Events.onDoubleClick


{-| -}
onMouseDown : msg -> Attribute variation msg
onMouseDown =
    Event << Html.Events.onMouseDown


{-| -}
onMouseUp : msg -> Attribute variation msg
onMouseUp =
    Event << Html.Events.onMouseUp


{-| -}
onMouseEnter : msg -> Attribute variation msg
onMouseEnter =
    Event << Html.Events.onMouseEnter


{-| -}
onMouseLeave : msg -> Attribute variation msg
onMouseLeave =
    Event << Html.Events.onMouseLeave


{-| -}
onMouseOver : msg -> Attribute variation msg
onMouseOver =
    Event << Html.Events.onMouseOver


{-| -}
onMouseOut : msg -> Attribute variation msg
onMouseOut =
    Event << Html.Events.onMouseOut



-- FORM EVENTS


{-| Capture [input](https://developer.mozilla.org/en-US/docs/Web/Events/input)
events for things like text fields or text areas.
It grabs the **string** value at `event.target.value`, so it will not work if
you need some other type of information. For example, if you want to track
inputs on a range slider, make a custom handler with [`on`](#on).
For more details on how `onInput` works, check out [targetValue](#targetValue).
-}
onInput : (String -> msg) -> Attribute variation msg
onInput =
    InputEvent << Html.Events.onInput


{-| Capture [change](https://developer.mozilla.org/en-US/docs/Web/Events/change)
events on checkboxes. It will grab the boolean value from `event.target.checked`
on any input event.
Check out [targetChecked](#targetChecked) for more details on how this works.
-}
onCheck : (Bool -> msg) -> Attribute variation msg
onCheck =
    InputEvent << Html.Events.onCheck


{-| Capture a [submit](https://developer.mozilla.org/en-US/docs/Web/Events/submit)
event with [`preventDefault`](https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault)
in order to prevent the form from changing the page’s location. If you need
different behavior, use `onWithOptions` to create a customized version of
`onSubmit`.
-}
onSubmit : msg -> Attribute variation msg
onSubmit =
    Event << Html.Events.onSubmit



-- FOCUS EVENTS


{-| -}
onBlur : msg -> Attribute variation msg
onBlur =
    Event << Html.Events.onBlur


{-| -}
onFocus : msg -> Attribute variation msg
onFocus =
    Event << Html.Events.onFocus



-- CUSTOM EVENTS


{-| Create a custom event listener. Normally this will not be necessary, but
you have the power! Here is how `onClick` is defined for example:
    import Json.Decode as Json
    onClick : msg -> Attribute variation msg
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
[aEL]: https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
[decoder]: http://package.elm-lang.org/packages/elm-lang/core/latest/Json-Decode
[tutorial]: https://github.com/evancz/elm-architecture-tutorial/
-}
on : String -> Json.Decoder msg -> Attribute variation msg
on event decode =
    Event <| Html.Events.on event decode


{-| Same as `on` but you can set a few options.
-}
onWithOptions : String -> Html.Events.Options -> Json.Decoder msg -> Attribute variation msg
onWithOptions event options decode =
    Event <| Html.Events.onWithOptions event options decode
