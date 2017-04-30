module Element exposing (..)

{-| -}

import Html exposing (Html)
import Html.Attributes
import Element.Internal.Model exposing (..)
import Element.Style.Internal.Model as Style exposing (Length)
import Element.Style.Internal.Render.Value as Value
import Element.Style.Internal.Batchable as Batchable exposing (Batchable)
import Element.Attributes as Attr
import Element.Style
import Time exposing (Time)
import Element.Device as Device exposing (Device)
import Element.Internal.Render as Render
import Element.Style.Sheet
import Task
import Window
import Color exposing (Color)


{-| The stylesheet contains the rendered css as a string, and two functions to lookup
-}
type alias StyleSheet class variation animation msg =
    Style.StyleSheet class variation animation msg


presetDefaults : Defaults
presetDefaults =
    { typeface = [ "calibri", "helvetica", "arial", "sans-serif" ]
    , fontSize = 16
    , lineHeight = 1.3
    , textColor = Color.black
    }


reset : String
reset =
    """
/* http://meyerweb.com/eric/tools/css/reset/
   v2.0 | 20110126
   License: none (public domain)
*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video, hr {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  font: inherit;
  vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
  display: block;
}
body {
  line-height: 1;
}
ol, ul {
  list-style: none;
}
blockquote, q {
  quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
  content: '';
  content: none;
}
table {
  border-collapse: collapse;
  border-spacing: 0;
}
/** Borrowed from Normalize.css **/

/**
 * Prevent `sub` and `sup` elements from affecting the line height in
 * all browsers.
 */

sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sub {
  bottom: -0.25em;
}

sup {
  top: -0.5em;
}

a {
    text-decoration: none;
}

"""


stylesheet : List (Element.Style.Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheet styles =
    let
        defaults =
            Batchable.One
                (Style.RawStyle "style-elements-root"
                    [ ( "font-family", Value.typeface presetDefaults.typeface )
                    , ( "color", Value.color presetDefaults.textColor )
                    , ( "line-height", toString presetDefaults.lineHeight )
                    , ( "font-size", toString presetDefaults.fontSize ++ "px" )
                    ]
                )

        stylesheet =
            Element.Style.Sheet.render
                (defaults :: styles)
    in
        { stylesheet | css = reset ++ stylesheet.css }


stylesheetWith : Defaults -> List (Element.Style.Style elem variation animation) -> StyleSheet elem variation animation msg
stylesheetWith defaultProps styles =
    let
        defaults =
            Batchable.One
                (Style.RawStyle "style-elements-root"
                    [ ( "font-family", Value.typeface defaultProps.typeface )
                    , ( "color", Value.color defaultProps.textColor )
                    , ( "line-height", toString defaultProps.lineHeight )
                    , ( "font-size", toString defaultProps.fontSize ++ "px" )
                    ]
                )

        stylesheet =
            Element.Style.Sheet.render
                (defaults :: styles)
    in
        { stylesheet | css = reset ++ stylesheet.css }


{-|

-}
empty : Element elem variation msg
empty =
    Empty


text : String -> Element elem variation msg
text =
    Text NoDecoration


bold : String -> Element elem variation msg
bold =
    Text Bold


italic : String -> Element elem variation msg
italic =
    Text Italic


strike : String -> Element elem variation msg
strike =
    Text Strike


underline : String -> Element elem variation msg
underline =
    Text Underline


sub : String -> Element elem variation msg
sub =
    Text Sub


super : String -> Element elem variation msg
super =
    Text Super


{-| Paragraph is actually a layout, if you can believe it!

All of the children are set to 'inline-block' if they are not already text elements.

-}
paragraph : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
paragraph elem attrs children =
    let
        ( child, others ) =
            case children of
                [] ->
                    ( empty, Nothing )

                child :: others ->
                    ( addPropToNonText Inline child, Just <| List.map (addPropToNonText Inline) others )
    in
        Element Html.p (Just elem) attrs child others


el : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
el elem attrs child =
    Element Html.div (Just elem) attrs child Nothing


{-| Define a spacer in terms of a multiple of it's spacing.

So, if the parent element is a `column` that set spacing to `5`, and this spacer was a `2`.  Then it would be a 10 pixel spacer.

-}
spacer : Float -> Element elem variation msg
spacer =
    Spacer


image : elem -> String -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
image elem src attrs child =
    Element Html.img (Just elem) (Attr (Html.Attributes.src src) :: attrs) child Nothing


{-| Creates a hairline horizontal.  The Color is set in the defaults of the stylesheet.

If you want a horizontal rule that is something more specific, craft it with `el`!

-}
hairline : elem -> Element elem variation msg
hairline elem =
    Element Html.hr (Just elem) (height (px 1) :: []) empty Nothing



---------------------
--- Semantic Markup
---------------------


node : String -> (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
node str constructor elem attrs stuff =
    setNode (Html.node str) (constructor elem attrs stuff)


header : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
header constructor elem attrs stuff =
    setNode Html.header (constructor elem attrs stuff)


section : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
section constructor elem attrs stuff =
    setNode Html.section (constructor elem attrs stuff)


nav : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
nav constructor elem attrs stuff =
    setNode Html.nav (constructor elem attrs stuff)


article : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
article constructor elem attrs stuff =
    setNode Html.article (constructor elem attrs stuff)


aside : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
aside constructor elem attrs stuff =
    setNode Html.aside (constructor elem attrs stuff)



---------------------
--- Specialized Elements
---------------------


canvas : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
canvas constructor elem attrs stuff =
    setNode Html.canvas (constructor elem attrs stuff)


iframe : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
iframe constructor elem attrs stuff =
    setNode Html.iframe (constructor elem attrs stuff)


audio : List (Attribute variation msg) -> List Source -> Element elem variation msg
audio attrs sources =
    let
        renderSource source =
            case source of
                Source src kind ->
                    (Element Html.source
                        Nothing
                        [ Attr.type_ kind
                        , Attr.src src
                        ]
                        empty
                        Nothing
                    )
    in
        Element Html.video
            Nothing
            attrs
            empty
            (Just (List.map renderSource sources))


video : List (Attribute variation msg) -> List Source -> Element elem variation msg
video attrs sources =
    let
        renderSource source =
            case source of
                Source src kind ->
                    (Element Html.source
                        Nothing
                        [ Attr.type_ kind
                        , Attr.src src
                        ]
                        empty
                        Nothing
                    )
    in
        Element Html.video
            Nothing
            attrs
            empty
            (Just (List.map renderSource sources))


type Source
    = Source String String


{-|
Create a source for video or audio.

Provide a src and a type.
-}
source : String -> String -> Source
source =
    Source



---------------------
--- Form and Input
---------------------


form : (elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg) -> elem -> List (Attribute variation msg) -> stuff -> Element elem variation msg
form constructor elem attrs stuff =
    setNode Html.form (constructor elem attrs stuff)


{-| Create a labeled radio button.

So, if you wanted to make some radio buttons to choose lunch, here's how it's look:

```
radio StyleClass [] "lunch" "burrito" True (text "A Burrito!")
radio StyleClass [] "lunch" "taco" False (text "Some Tacos!")

```

__Advanced Note__
This creates the following html:
```
<label class="styleClass" {attributes provided in arguments}>
    <input type=radio name="lunch" value="burrito" />
    A Burrito!
</label>

```

Events are attached to the radio input element (to capture things like `onInput`, while all other attributes apply to the label element).


-}
radio : elem -> List (Attribute variation msg) -> String -> String -> Bool -> Element elem variation msg -> Element elem variation msg
radio elem attrs group value on label =
    let
        ( events, other ) =
            List.partition forEvents attrs

        forEvents attr =
            case attr of
                Event ev ->
                    True

                _ ->
                    False

        attributes =
            Attr.type_ "radio" :: Attr.name group :: Attr.value value :: Attr.checked on :: events

        radioButton =
            Element Html.input (Just elem) attributes empty Nothing
    in
        Element Html.label
            (Just elem)
            other
            (paragraph elem
                attributes
                [ radioButton
                , label
                ]
            )
            Nothing


{-| An automatically labeled checkbox.
-}
checkbox : elem -> List (Attribute variation msg) -> Bool -> Element elem variation msg -> Element elem variation msg
checkbox elem attrs on label =
    let
        ( events, other ) =
            List.partition forEvents attrs

        forEvents attr =
            case attr of
                Event ev ->
                    True

                _ ->
                    False

        attributes =
            Attr.type_ "checkbox" :: Attr.checked on :: events

        checkedButton =
            Element Html.input (Just elem) attributes empty Nothing
    in
        Element Html.label
            (Just elem)
            other
            (paragraph elem
                attributes
                [ checkedButton
                , label
                ]
            )
            Nothing


{-| For input elements that are not automatically labeled (checkbox, radiobutton, selection), this will attach a label above the element.

label Label [] (text "check this out") <|
    inputtext Style [] "The Value!"

-}
label : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg -> Element elem variation msg
label elem attrs label input =
    let
        -- If naked text is provided, then flexbox won't work.
        -- In that case we wrap it in a div.
        containedLabel =
            case label of
                Text dec content ->
                    Element Html.div Nothing [] (Text dec content) Nothing

                l ->
                    l
    in
        (node "label" <| column)
            elem
            attrs
            [ label
            , input
            ]


{-| Same as `label`, but places the label below the input field.

-}
labelBelow : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg -> Element elem variation msg
labelBelow elem attrs label input =
    let
        -- If naked text is provided, then flexbox won't work.
        -- In that case we wrap it in a div.
        containedLabel =
            case label of
                Text dec content ->
                    Element Html.div Nothing [] (Text dec content) Nothing

                l ->
                    l
    in
        (node "label" <| column)
            elem
            attrs
            [ input
            , label
            ]


textarea : elem -> List (Attribute variation msg) -> String -> Element elem variation msg
textarea elem attrs content =
    Element Html.textarea (Just elem) attrs (text content) Nothing


{-|

labeled Label [] (text "check this out") <|
    inputtext Style [] "The Value!"

-}
inputtext : elem -> List (Attribute variation msg) -> String -> Element elem variation msg
inputtext elem attrs content =
    Element Html.input (Just elem) (Attr.type_ "text" :: Attr.value content :: attrs) empty Nothing


{-| A bulleted list.  Rendered as `<ul>`

A 'column' layout is implied.

Automatically sets children to use `<li>`
-}
bullet : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
bullet elem attrs children =
    Layout Html.ul (Style.FlexLayout Style.Down []) (Just elem) attrs (List.map (setNode Html.li) children)


{-| A numbered list.  Rendered as `<ol>`

A 'column' layout is implied.

Automatically sets children to use `<li>`
-}
enumerate : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
enumerate elem attrs children =
    Layout Html.ol (Style.FlexLayout Style.Down []) (Just elem) attrs (List.map (setNode Html.li) children)


full : elem -> List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
full elem attrs child =
    Element Html.div (Just elem) (Expand :: attrs) child Nothing


textLayout : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
textLayout elem attrs children =
    Layout Html.div (Style.TextLayout) (Just elem) attrs children


row : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
row elem attrs children =
    Layout Html.div (Style.FlexLayout Style.GoRight []) (Just elem) attrs children


column : elem -> List (Attribute variation msg) -> List (Element elem variation msg) -> Element elem variation msg
column elem attrs children =
    Layout Html.div (Style.FlexLayout Style.Down []) (Just elem) attrs children


type alias Grid =
    { rows : List Length
    , columns : List Length
    }


grid : Grid -> elem -> List (Attribute variation msg) -> List (OnGrid (Element elem variation msg)) -> Element elem variation msg
grid template elem attrs children =
    let
        prepare el =
            List.map (\(OnGrid x) -> x) el
    in
        Layout Html.div (Style.Grid (Style.GridTemplate template) []) (Just elem) attrs (prepare children)


type alias NamedGrid =
    { rows : List ( Length, List Style.NamedGridPosition )
    , columns : List Length
    }


namedGrid : NamedGrid -> elem -> List (Attribute variation msg) -> List (NamedOnGrid (Element elem variation msg)) -> Element elem variation msg
namedGrid template elem attrs children =
    let
        prepare el =
            List.map (\(NamedOnGrid x) -> x) el
    in
        Layout Html.div (Style.Grid (Style.NamedGridTemplate template) []) (Just elem) attrs (prepare children)


type GridBox
    = GridBox
        { rowRange : ( Int, Int )
        , colRange : ( Int, Int )
        }


type OnGrid thing
    = OnGrid thing


type NamedOnGrid thing
    = NamedOnGrid thing


area : GridBox -> Element elem variation msg -> OnGrid (Element elem variation msg)
area box el =
    OnGrid el


named : String -> Element elem variation msg -> NamedOnGrid (Element elem variation msg)
named name el =
    NamedOnGrid el


{-| Turn an element into a link.

Changes an element's node to `<a>` and sets the href and rel properties.
-}
linked : String -> Element elem variation msg -> Element elem variation msg
linked src el =
    el
        |> setNode Html.a
        |> addProp (Attr (Html.Attributes.href src))
        |> addProp (Attr (Html.Attributes.rel "noopener noreferrer"))


{-|
-}
when : Bool -> Element elem variation msg -> Element elem variation msg
when bool elm =
    if bool then
        elm
    else
        empty


setNode : HtmlFn msg -> Element elem variation msg -> Element elem variation msg
setNode node el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout _ layout elem attrs children ->
            Layout node layout elem attrs children

        Element _ elem attrs child otherChildren ->
            Element node elem attrs child otherChildren

        Text dec content ->
            Element node Nothing [] (Text dec content) Nothing


addPropToNonText : Attribute variation msg -> Element elem variation msg -> Element elem variation msg
addPropToNonText prop el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Text dec content


addProp : Attribute variation msg -> Element elem variation msg -> Element elem variation msg
addProp prop el =
    case el of
        Empty ->
            Empty

        Spacer x ->
            Spacer x

        Layout node layout elem attrs els ->
            Layout node layout elem (prop :: attrs) els

        Element node elem attrs el children ->
            Element node elem (prop :: attrs) el children

        Text dec content ->
            Element Html.div Nothing [ prop ] (Text dec content) Nothing


removeProps : List (Attribute variation msg) -> Element elem variation msg -> Element elem variation msg
removeProps props el =
    let
        match p =
            not <| List.member p props
    in
        case el of
            Empty ->
                Empty

            Spacer x ->
                Spacer x

            Layout node layout elem attrs els ->
                Layout node layout elem (List.filter match attrs) els

            Element node elem attrs el children ->
                Element node elem (List.filter match attrs) el children

            Text dec content ->
                Text dec content


addChild : Element elem variation msg -> Element elem variation msg -> Element elem variation msg
addChild parent el =
    case parent of
        Empty ->
            Element Html.div Nothing [] Empty (Just [ el ])

        Spacer x ->
            Spacer x

        Layout node layout elem attrs children ->
            Layout node layout elem attrs (el :: children)

        Element node elem attrs child otherChildren ->
            case otherChildren of
                Nothing ->
                    Element node elem attrs child (Just [ el ])

                Just others ->
                    Element node elem attrs child (Just (el :: others))

        Text dec content ->
            Element Html.div Nothing [] (Text dec content) (Just [ el ])


nearby : List (Nearby (Element elem variation msg)) -> Element elem variation msg -> Element elem variation msg
nearby nearbys parent =
    List.foldl (\(IsNearby el) p -> addChild p el) parent nearbys


above : Element elem variation msg -> Nearby (Element elem variation msg)
above el =
    el
        |> addProp (PositionFrame (Nearby Above))
        |> removeProps [ Align Top, Align Bottom ]
        |> IsNearby


below : Element elem variation msg -> Nearby (Element elem variation msg)
below el =
    el
        |> addProp (PositionFrame (Nearby Below))
        |> removeProps [ Align Top, Align Bottom ]
        |> IsNearby


onRight : Element elem variation msg -> Nearby (Element elem variation msg)
onRight el =
    el
        |> addProp (PositionFrame (Nearby OnRight))
        |> removeProps [ Align Right, Align Left ]
        |> IsNearby


onLeft : Element elem variation msg -> Nearby (Element elem variation msg)
onLeft el =
    el
        |> addProp (PositionFrame (Nearby OnLeft))
        |> removeProps [ Align Right, Align Left ]
        |> IsNearby


within : List (Anchored (Element elem variation msg)) -> Element elem variation msg -> Element elem variation msg
within insideEls parent =
    let
        applyAnchor (Anchored anchor el) parent =
            el
                |> addProp (PositionFrame (Within anchor))
                |> addChild parent
    in
        List.foldl applyAnchor parent insideEls


topLeft : Element elem variation msg -> Anchored (Element elem variation msg)
topLeft el =
    Anchored TopLeft el


topRight : Element elem variation msg -> Anchored (Element elem variation msg)
topRight el =
    Anchored TopRight el


bottomRight : Element elem variation msg -> Anchored (Element elem variation msg)
bottomRight el =
    Anchored BottomRight el


bottomLeft : Element elem variation msg -> Anchored (Element elem variation msg)
bottomLeft el =
    Anchored BottomLeft el


screen : Anchored (Element elem variation msg) -> Element elem variation msg
screen (Anchored anchor el) =
    addProp (PositionFrame (Screen anchor)) el


overlay : elem -> Int -> Element elem variation msg -> Element elem variation msg
overlay bg opac child =
    (screen << topLeft) <| el bg [ width (percent 100), height (percent 100), opacity opac ] child


center : Attribute variation msg
center =
    Align Center


vCenter : Attribute variation msg
vCenter =
    Align VerticalCenter


justify : Attribute variation msg
justify =
    Align Justify


alignTop : Attribute variation msg
alignTop =
    Align Top


alignBottom : Attribute variation msg
alignBottom =
    Align Bottom


alignLeft : Attribute variation msg
alignLeft =
    Align Left


alignRight : Attribute variation msg
alignRight =
    Align Right



{- Layout Attributes -}


{-| -}
width : Length -> Attribute variation msg
width =
    Width


{-| -}
height : Length -> Attribute variation msg
height =
    Height


{-| -}
px : Float -> Length
px =
    Style.Px


{-| Adjust the position of the element.

Arguemnts are given as x and y coordinates, where positive is right and down.

-}
move : Int -> Int -> Attribute variation msg
move =
    Position


{-| -}
percent : Float -> Length
percent =
    Style.Percent


{-| -}
vary : variation -> Bool -> Attribute variation msg
vary =
    Vary


{-| The horizontal and vertical spacing.
-}
spacing : Float -> Float -> Attribute variation msg
spacing =
    Spacing


{-|
-}
padding : ( Float, Float, Float, Float ) -> Attribute variation msg
padding =
    Padding


hidden : Attribute variation msg
hidden =
    Hidden


transparency : Int -> Attribute variation msg
transparency =
    Transparency


opacity : Int -> Attribute variation msg
opacity o =
    Transparency (1 - o)


programWithFlags :
    { init : flags -> ( model, Cmd msg )
    , stylesheet : StyleSheet elem variation animation msg
    , device : { width : Int, height : Int } -> device
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : device -> model -> Element elem variation msg
    }
    -> Program flags (ElemModel device elem variation animation model msg) (ElementMsg device msg)
programWithFlags prog =
    Html.programWithFlags
        { init = (\flags -> init prog.stylesheet prog.device (prog.init flags))
        , update = update prog.update
        , view = (\model -> Html.map Send <| deviceView prog.view model)
        , subscriptions =
            (\(ElemModel { model }) ->
                Sub.batch
                    [ Window.resizes (Resize prog.device)
                    , Sub.map Send <| prog.subscriptions model
                    ]
            )
        }


program :
    { stylesheet : StyleSheet elem variation animation msg
    , init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : device -> model -> Element elem variation msg
    , device : { width : Int, height : Int } -> device
    }
    -> Program Never (ElemModel device elem variation animation model msg) (ElementMsg device msg)
program prog =
    Html.program
        { init = init prog.stylesheet prog.device prog.init
        , update = update prog.update
        , view = (\model -> Html.map Send <| deviceView prog.view model)
        , subscriptions =
            (\(ElemModel { model }) ->
                Sub.batch
                    [ Window.resizes (Resize prog.device)
                    , Sub.map Send <| prog.subscriptions model
                    ]
            )
        }


beginnerProgram :
    { stylesheet : StyleSheet elem variation animation msg
    , model : model
    , view : model -> Element elem variation msg
    , update : msg -> model -> model
    }
    -> Program Never (ElemModel Device elem variation animation model msg) (ElementMsg Device msg)
beginnerProgram prog =
    Html.program
        { init = init prog.stylesheet Device.match <| withCmdNone prog.model
        , update = update (\msg model -> withCmdNone <| prog.update msg model)
        , view = (\model -> Html.map Send <| view prog.view model)
        , subscriptions =
            (\(ElemModel { model }) ->
                Sub.batch
                    [ Window.resizes (Resize Device.match)
                    ]
            )
        }


withCmdNone : model -> ( model, Cmd msg )
withCmdNone model =
    ( model, Cmd.none )


init : StyleSheet elem variation animation msg -> ({ width : Int, height : Int } -> device) -> ( model, Cmd msg ) -> ( ElemModel device elem variation animation model msg, Cmd (ElementMsg device msg) )
init elem match ( model, cmd ) =
    ( emptyModel elem match model
    , Cmd.batch
        [ Cmd.map Send cmd
        , Task.perform (Resize match) Window.size
        ]
    )


emptyModel :
    StyleSheet elem variation animation msg
    -> (Window.Size -> device)
    -> model
    -> ElemModel device elem variation animation model msg
emptyModel stylesheet match model =
    ElemModel
        { time = 0
        , device =
            match { width = 1000, height = 1200 }
        , stylesheet = stylesheet
        , model = model
        }


type ElementMsg device msg
    = Send msg
    | Tick Time
    | Resize (Window.Size -> device) Window.Size


type ElemModel device elem variation animation model msg
    = ElemModel
        { time : Time
        , device : device
        , stylesheet : StyleSheet elem variation animation msg
        , model : model
        }


update : (msg -> model -> ( model, Cmd msg )) -> ElementMsg device msg -> ElemModel device elem variation animation model msg -> ( ElemModel device elem variation animation model msg, Cmd (ElementMsg device msg) )
update appUpdate elemMsg elemModel =
    case elemMsg of
        Send msg ->
            ( elemModel, Cmd.none )

        Tick time ->
            ( elemModel, Cmd.none )

        Resize match size ->
            ( case elemModel of
                ElemModel elmRecord ->
                    ElemModel { elmRecord | device = match size }
            , Cmd.none
            )


deviceView : (device -> model -> Element elem variation msg) -> ElemModel device elem variation animation model msg -> Html msg
deviceView appView (ElemModel { device, stylesheet, model }) =
    Render.render stylesheet <| appView device model


view : (model -> Element elem variation msg) -> ElemModel Device elem variation animation model msg -> Html msg
view appView (ElemModel { device, stylesheet, model }) =
    Render.render stylesheet <| appView model
