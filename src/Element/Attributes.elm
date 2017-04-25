module Element.Attributes
    exposing
        ( property
        , attribute
        , class
        , classList
        , id
        , title
        , hidden
        , type_
        , value
        , defaultValue
        , checked
        , placeholder
        , selected
        , accept
        , acceptCharset
        , action
        , autocomplete
        , autofocus
        , disabled
        , enctype
        , formaction
        , list
        , maxlength
        , minlength
        , method
        , multiple
        , name
        , novalidate
        , pattern
        , readonly
        , required
        , size
        , for
        , form
        , max
        , min
        , step
        , cols
        , rows
        , wrap
        , href
        , target
        , download
        , downloadAs
        , hreflang
        , media
        , ping
        , rel
        , ismap
        , usemap
        , shape
        , coords
        , src
        , alt
        , autoplay
        , controls
        , loop
        , preload
        , poster
        , default
        , kind
        , srclang
        , sandbox
        , seamless
        , srcdoc
        , reversed
        , start
        , align
        , colspan
        , rowspan
        , headers
        , scope
        , async
        , charset
        , content
        , defer
        , httpEquiv
        , language
        , scoped
        , accesskey
        , contenteditable
        , contextmenu
        , dir
        , draggable
        , dropzone
        , itemprop
        , lang
        , spellcheck
        , tabindex
        , challenge
        , keytype
        , cite
        , datetime
        , pubdate
        , manifest
        )

{-|

# Same as Html.Attributes


Helper functions for HTML attributes. They are organized roughly by
category. Each attribute is labeled with the HTML tags it can be used with, so
just search the page for `video` if you want video stuff.

If you cannot find what you are looking for, go to the [Custom
Attributes](#custom-attributes) section to learn how to create new helpers.

# Primitives
@docs style, property, attribute, map

# Super Common Attributes
@docs class, classList, id, title, hidden

# Inputs
@docs type_, value, defaultValue, checked, placeholder, selected

## Input Helpers
@docs accept, acceptCharset, action, autocomplete, autofocus,
    disabled, enctype, formaction, list, maxlength, minlength, method, multiple,
    name, novalidate, pattern, readonly, required, size, for, form

## Input Ranges
@docs max, min, step

## Input Text Areas
@docs cols, rows, wrap


# Links and Areas
@docs href, target, download, downloadAs, hreflang, media, ping, rel

## Maps
@docs ismap, usemap, shape, coords


# Embedded Content
@docs src, height, width, alt

## Audio and Video
@docs autoplay, controls, loop, preload, poster, default, kind, srclang

## iframes
@docs sandbox, seamless, srcdoc

# Ordered Lists
@docs reversed, start

# Tables
@docs align, colspan, rowspan, headers, scope

# Header Stuff
@docs async, charset, content, defer, httpEquiv, language, scoped

# Less Common Global Attributes
Attributes that can be attached to any HTML tag but are less commonly used.
@docs accesskey, contenteditable, contextmenu, dir, draggable, dropzone,
      itemprop, lang, spellcheck, tabindex

# Key Generation
@docs challenge, keytype

# Miscellaneous
@docs cite, datetime, pubdate, manifest

-}

import Element.Internal.Model as Internal exposing (Attribute(..))
import Html.Attributes
import Json.Decode as Json


{-| This function makes it easier to build a space-separated class attribute.
Each class can easily be added and removed depending on the boolean value it
is paired with. For example, maybe we want a way to view notices:

    viewNotice : Notice -> Html msg
    viewNotice notice =
      div
        [ classList
            [ ("notice", True)
            , ("notice-important", notice.isImportant)
            , ("notice-seen", notice.isSeen)
            ]
        ]
        [ text notice.content ]
-}
classList : List ( String, Bool ) -> Attribute variation msg
classList =
    Attr << Html.Attributes.classList



-- CUSTOM ATTRIBUTES


{-| Create *properties*, like saying `domNode.className = 'greeting'` in
JavaScript.

    import Json.Encode as Encode

    class : String -> Attribute variation msg
    class = Html.Attributes.class

Read more about the difference between properties and attributes [here][].

[here]: https://github.com/elm-lang/html/blob/master/properties-vs-attributes.md
-}
property : String -> Json.Value -> Attribute variation msg
property str val =
    Attr <| Html.Attributes.property str val


{-| Create *attributes*, like saying `domNode.setAttribute('class', 'greeting')`
in JavaScript.

    class : String -> Attribute variation msg
    class = Html.Attributes.class

Read more about the difference between properties and attributes [here][].

[here]: https://github.com/elm-lang/html/blob/master/properties-vs-attributes.md
-}
attribute : String -> String -> Attribute variation msg
attribute name val =
    Attr <| Html.Attributes.attribute name val



-- {-| Transform the messages produced by an `Attribute`.
-- -}
-- map : (a -> msg) -> Attribute a -> Attribute variation msg
-- map =
--     Html.Attributes.map
-- GLOBAL ATTRIBUTES


{-| Often used with CSS to style elements with common properties.
-}
class : String -> Attribute variation msg
class cls =
    Attr <| Html.Attributes.class cls


{-| Indicates the relevance of an element.
-}
hidden : Bool -> Attribute variation msg
hidden hide =
    Attr <| Html.Attributes.hidden hide


{-| Often used with CSS to style a specific element. The value of this
attribute must be unique.
-}
id : String -> Attribute variation msg
id str =
    Attr <| Html.Attributes.id str


{-| Text to be displayed in a tooltip when hovering over the element.
-}
title : String -> Attribute variation msg
title str =
    Attr <| Html.Attributes.title str



-- LESS COMMON GLOBAL ATTRIBUTES


{-| Defines a keyboard shortcut to activate or add focus to the element.
-}
accesskey : Char -> Attribute variation msg
accesskey char =
    Attr <| Html.Attributes.accesskey char


{-| Indicates whether the element's content is editable.
-}
contenteditable : Bool -> Attribute variation msg
contenteditable on =
    Attr <| Html.Attributes.contenteditable on


{-| Defines the ID of a `menu` element which will serve as the element's
context menu.
-}
contextmenu : String -> Attribute variation msg
contextmenu id =
    Attr <| Html.Attributes.contextmenu id


{-| Defines the text direction. Allowed values are ltr (Left-To-Right) or rtl
(Right-To-Left).
-}
dir : String -> Attribute variation msg
dir d =
    Attr <| Html.Attributes.dir d


{-| Defines whether the element can be dragged.
-}
draggable : String -> Attribute variation msg
draggable str =
    Attr <| Html.Attributes.draggable str


{-| Indicates that the element accept the dropping of content on it.
-}
dropzone : String -> Attribute variation msg
dropzone drop =
    Attr <| Html.Attributes.dropzone drop


{-| -}
itemprop : String -> Attribute variation msg
itemprop item =
    Attr <| Html.Attributes.itemprop item


{-| Defines the language used in the element.
-}
lang : String -> Attribute variation msg
lang str =
    Attr <| Html.Attributes.lang str


{-| Indicates whether spell checking is allowed for the element.
-}
spellcheck : Bool -> Attribute variation msg
spellcheck on =
    Attr <| Html.Attributes.spellcheck on


{-| Overrides the browser's default tab order and follows the one specified
instead.
-}
tabindex : Int -> Attribute variation msg
tabindex index =
    Attr <| Html.Attributes.tabindex index



-- HEADER STUFF


{-| Indicates that the `script` should be executed asynchronously.
-}
async : Bool -> Attribute variation msg
async on =
    Attr <| Html.Attributes.async on


{-| Declares the character encoding of the page or script. Common values include:

  * UTF-8 - Character encoding for Unicode
  * ISO-8859-1 - Character encoding for the Latin alphabet

For `meta` and `script`.
-}
charset : String -> Attribute variation msg
charset char =
    Attr <| Html.Attributes.charset char


{-| A value associated with http-equiv or name depending on the context. For
`meta`.
-}
content : String -> Attribute variation msg
content str =
    Attr <| Html.Attributes.content str


{-| Indicates that a `script` should be executed after the page has been
parsed.
-}
defer : Bool -> Attribute variation msg
defer def =
    Attr <| Html.Attributes.defer def


{-| This attribute is an indicator that is paired with the `content` attribute,
indicating what that content means. `httpEquiv` can take on three different
values: content-type, default-style, or refresh. For `meta`.
-}
httpEquiv : String -> Attribute variation msg
httpEquiv str =
    Attr <| Html.Attributes.httpEquiv str


{-| Defines the script language used in a `script`.
-}
language : String -> Attribute variation msg
language lang =
    Attr <| Html.Attributes.language lang


{-| Indicates that a `style` should only apply to its parent and all of the
parents children.
-}
scoped : Bool -> Attribute variation msg
scoped on =
    Attr <| Html.Attributes.scoped on



-- EMBEDDED CONTENT


{-| The URL of the embeddable content. For `audio`, `embed`, `iframe`, `img`,
`input`, `script`, `source`, `track`, and `video`.
-}
src : String -> Attribute variation msg
src s =
    Attr <| Html.Attributes.src s


{-| Alternative text in case an image can't be displayed. Works with `img`,
`area`, and `input`.
-}
alt : String -> Attribute variation msg
alt str =
    Attr <| Html.Attributes.alt str



-- AUDIO and VIDEO


{-| The `audio` or `video` should play as soon as possible.
-}
autoplay : Bool -> Attribute variation msg
autoplay on =
    Attr <| Html.Attributes.autoplay on


{-| Indicates whether the browser should show playback controls for the `audio`
or `video`.
-}
controls : Bool -> Attribute variation msg
controls on =
    Attr <| Html.Attributes.controls on


{-| Indicates whether the `audio` or `video` should start playing from the
start when it's finished.
-}
loop : Bool -> Attribute variation msg
loop on =
    Attr <| Html.Attributes.loop on


{-| Control how much of an `audio` or `video` resource should be preloaded.
-}
preload : String -> Attribute variation msg
preload str =
    Attr <| Html.Attributes.preload str


{-| A URL indicating a poster frame to show until the user plays or seeks the
`video`.
-}
poster : String -> Attribute variation msg
poster str =
    Attr <| Html.Attributes.poster str


{-| Indicates that the `track` should be enabled unless the user's preferences
indicate something different.
-}
default : Bool -> Attribute variation msg
default on =
    Attr <| Html.Attributes.default on


{-| Specifies the kind of text `track`.
-}
kind : String -> Attribute variation msg
kind k =
    Attr <| Html.Attributes.kind k



{--TODO: maybe reintroduce once there's a better way to disambiguate imports
{-| Specifies a user-readable title of the text `track`. -}
label : String -> Attribute variation msg
label = Html.Attributes.label
--}


{-| A two letter language code indicating the language of the `track` text data.
-}
srclang : String -> Attribute variation msg
srclang lang =
    Attr <| Html.Attributes.srclang lang



-- IFRAMES


{-| A space separated list of security restrictions you'd like to lift for an
`iframe`.
-}
sandbox : String -> Attribute variation msg
sandbox str =
    Attr <| Html.Attributes.sandbox str


{-| Make an `iframe` look like part of the containing document.
-}
seamless : Bool -> Attribute variation msg
seamless on =
    Attr <| Html.Attributes.seamless on


{-| An HTML document that will be displayed as the body of an `iframe`. It will
override the content of the `src` attribute if it has been specified.
-}
srcdoc : String -> Attribute variation msg
srcdoc doc =
    Attr <| Html.Attributes.srcdoc doc



-- INPUT


{-| Defines the type of a `button`, `input`, `embed`, `object`, `script`,
`source`, `style`, or `menu`.
-}
type_ : String -> Attribute variation msg
type_ t =
    Attr <| Html.Attributes.type_ t


{-| Defines a default value which will be displayed in a `button`, `option`,
`input`, `li`, `meter`, `progress`, or `param`.
-}
value : String -> Attribute variation msg
value val =
    Attr <| Html.Attributes.value val


{-| Defines an initial value which will be displayed in an `input` when that
`input` is added to the DOM. Unlike `value`, altering `defaultValue` after the
`input` element has been added to the DOM has no effect.
-}
defaultValue : String -> Attribute variation msg
defaultValue str =
    Attr <| Html.Attributes.defaultValue str


{-| Indicates whether an `input` of type checkbox is checked.
-}
checked : Bool -> Attribute variation msg
checked on =
    Attr <| Html.Attributes.checked on


{-| Provides a hint to the user of what can be entered into an `input` or
`textarea`.
-}
placeholder : String -> Attribute variation msg
placeholder place =
    Attr <| Html.Attributes.placeholder place


{-| Defines which `option` will be selected on page load.
-}
selected : Bool -> Attribute variation msg
selected on =
    Attr <| Html.Attributes.selected on



-- INPUT HELPERS


{-| List of types the server accepts, typically a file type.
For `form` and `input`.
-}
accept : String -> Attribute variation msg
accept str =
    Attr <| Html.Attributes.accept str


{-| List of supported charsets in a `form`.
-}
acceptCharset : String -> Attribute variation msg
acceptCharset char =
    Attr <| Html.Attributes.acceptCharset char


{-| The URI of a program that processes the information submitted via a `form`.
-}
action : String -> Attribute variation msg
action str =
    Attr <| Html.Attributes.action str


{-| Indicates whether a `form` or an `input` can have their values automatically
completed by the browser.
-}
autocomplete : Bool -> Attribute variation msg
autocomplete on =
    Attr <| Html.Attributes.autocomplete on


{-| The element should be automatically focused after the page loaded.
For `button`, `input`, `keygen`, `select`, and `textarea`.
-}
autofocus : Bool -> Attribute variation msg
autofocus on =
    Attr <| Html.Attributes.autofocus on


{-| Indicates whether the user can interact with a `button`, `fieldset`,
`input`, `keygen`, `optgroup`, `option`, `select` or `textarea`.
-}
disabled : Bool -> Attribute variation msg
disabled on =
    Attr <| Html.Attributes.disabled on


{-| How `form` data should be encoded when submitted with the POST method.
Options include: application/x-www-form-urlencoded, multipart/form-data, and
text/plain.
-}
enctype : String -> Attribute variation msg
enctype str =
    Attr <| Html.Attributes.enctype str


{-| Indicates the action of an `input` or `button`. This overrides the action
defined in the surrounding `form`.
-}
formaction : String -> Attribute variation msg
formaction action =
    Attr <| Html.Attributes.formaction action


{-| Associates an `input` with a `datalist` tag. The datalist gives some
pre-defined options to suggest to the user as they interact with an input.
The value of the list attribute must match the id of a `datalist` node.
For `input`.
-}
list : String -> Attribute variation msg
list l =
    Attr <| Html.Attributes.list l


{-| Defines the minimum number of characters allowed in an `input` or
`textarea`.
-}
minlength : Int -> Attribute variation msg
minlength i =
    Attr <| Html.Attributes.minlength i


{-| Defines the maximum number of characters allowed in an `input` or
`textarea`.
-}
maxlength : Int -> Attribute variation msg
maxlength i =
    Attr <| Html.Attributes.maxlength i


{-| Defines which HTTP method to use when submitting a `form`. Can be GET
(default) or POST.
-}
method : String -> Attribute variation msg
method str =
    Attr <| Html.Attributes.method str


{-| Indicates whether multiple values can be entered in an `input` of type
email or file. Can also indicate that you can `select` many options.
-}
multiple : Bool -> Attribute variation msg
multiple on =
    Attr <| Html.Attributes.multiple on


{-| Name of the element. For example used by the server to identify the fields
in form submits. For `button`, `form`, `fieldset`, `iframe`, `input`, `keygen`,
`object`, `output`, `select`, `textarea`, `map`, `meta`, and `param`.
-}
name : String -> Attribute variation msg
name str =
    Attr <| Html.Attributes.name str


{-| This attribute indicates that a `form` shouldn't be validated when
submitted.
-}
novalidate : Bool -> Attribute variation msg
novalidate on =
    Attr <| Html.Attributes.novalidate on


{-| Defines a regular expression which an `input`'s value will be validated
against.
-}
pattern : String -> Attribute variation msg
pattern str =
    Attr <| Html.Attributes.pattern str


{-| Indicates whether an `input` or `textarea` can be edited.
-}
readonly : Bool -> Attribute variation msg
readonly on =
    Attr <| Html.Attributes.readonly on


{-| Indicates whether this element is required to fill out or not.
For `input`, `select`, and `textarea`.
-}
required : Bool -> Attribute variation msg
required on =
    Attr <| Html.Attributes.required on


{-| For `input` specifies the width of an input in characters.

For `select` specifies the number of visible options in a drop-down list.
-}
size : Int -> Attribute variation msg
size i =
    Attr <| Html.Attributes.size i


{-| The element ID described by this `label` or the element IDs that are used
for an `output`.
-}
for : String -> Attribute variation msg
for id =
    Attr <| Html.Attributes.for id


{-| Indicates the element ID of the `form` that owns this particular `button`,
`fieldset`, `input`, `keygen`, `label`, `meter`, `object`, `output`,
`progress`, `select`, or `textarea`.
-}
form : String -> Attribute variation msg
form str =
    Attr <| Html.Attributes.form str



-- RANGES


{-| Indicates the maximum value allowed. When using an input of type number or
date, the max value must be a number or date. For `input`, `meter`, and `progress`.
-}
max : String -> Attribute variation msg
max str =
    Attr <| Html.Attributes.max str


{-| Indicates the minimum value allowed. When using an input of type number or
date, the min value must be a number or date. For `input` and `meter`.
-}
min : String -> Attribute variation msg
min str =
    Attr <| Html.Attributes.min str


{-| Add a step size to an `input`. Use `step "any"` to allow any floating-point
number to be used in the input.
-}
step : String -> Attribute variation msg
step s =
    Attr <| Html.Attributes.step s



--------------------------


{-| Defines the number of columns in a `textarea`.
-}
cols : Int -> Attribute variation msg
cols i =
    Attr <| Html.Attributes.cols i


{-| Defines the number of rows in a `textarea`.
-}
rows : Int -> Attribute variation msg
rows i =
    Attr <| Html.Attributes.rows i


{-| Indicates whether the text should be wrapped in a `textarea`. Possible
values are "hard" and "soft".
-}
wrap : String -> Attribute variation msg
wrap str =
    Attr <| Html.Attributes.wrap str



-- MAPS


{-| When an `img` is a descendent of an `a` tag, the `ismap` attribute
indicates that the click location should be added to the parent `a`'s href as
a query string.
-}
ismap : Bool -> Attribute variation msg
ismap on =
    Attr <| Html.Attributes.ismap on


{-| Specify the hash name reference of a `map` that should be used for an `img`
or `object`. A hash name reference is a hash symbol followed by the element's name or id.
E.g. `"#planet-map"`.
-}
usemap : String -> Attribute variation msg
usemap str =
    Attr <| Html.Attributes.usemap str


{-| Declare the shape of the clickable area in an `a` or `area`. Valid values
include: default, rect, circle, poly. This attribute can be paired with
`coords` to create more particular shapes.
-}
shape : String -> Attribute variation msg
shape str =
    Attr <| Html.Attributes.shape str


{-| A set of values specifying the coordinates of the hot-spot region in an
`area`. Needs to be paired with a `shape` attribute to be meaningful.
-}
coords : String -> Attribute variation msg
coords str =
    Attr <| Html.Attributes.coords str



-- KEY GEN


{-| A challenge string that is submitted along with the public key in a `keygen`.
-}
challenge : String -> Attribute variation msg
challenge str =
    Attr <| Html.Attributes.challenge str


{-| Specifies the type of key generated by a `keygen`. Possible values are:
rsa, dsa, and ec.
-}
keytype : String -> Attribute variation msg
keytype str =
    Attr <| Html.Attributes.keytype str



-- REAL STUFF


{-| Specifies the horizontal alignment of a `caption`, `col`, `colgroup`,
`hr`, `iframe`, `img`, `table`, `tbody`,  `td`,  `tfoot`, `th`, `thead`, or
`tr`.
-}
align : String -> Attribute variation msg
align str =
    Attr <| Html.Attributes.align str


{-| Contains a URI which points to the source of the quote or change in a
`blockquote`, `del`, `ins`, or `q`.
-}
cite : String -> Attribute variation msg
cite str =
    Attr <| Html.Attributes.cite str



-- LINKS AND AREAS


{-| The URL of a linked resource, such as `a`, `area`, `base`, or `link`.
-}
href : String -> Attribute variation msg
href str =
    Attr <| Html.Attributes.href str


{-| Specify where the results of clicking an `a`, `area`, `base`, or `form`
should appear. Possible special values include:

  * _blank &mdash; a new window or tab
  * _self &mdash; the same frame (this is default)
  * _parent &mdash; the parent frame
  * _top &mdash; the full body of the window

You can also give the name of any `frame` you have created.
-}
target : String -> Attribute variation msg
target str =
    Attr <| Html.Attributes.target str


{-| Indicates that clicking an `a` and `area` will download the resource
directly.
-}
download : Bool -> Attribute variation msg
download on =
    Attr <| Html.Attributes.download on


{-| Indicates that clicking an `a` and `area` will download the resource
directly, and that the downloaded resource with have the given filename.
-}
downloadAs : String -> Attribute variation msg
downloadAs str =
    Attr <| Html.Attributes.downloadAs str


{-| Two-letter language code of the linked resource of an `a`, `area`, or `link`.
-}
hreflang : String -> Attribute variation msg
hreflang str =
    Attr <| Html.Attributes.hreflang str


{-| Specifies a hint of the target media of a `a`, `area`, `link`, `source`,
or `style`.
-}
media : String -> Attribute variation msg
media str =
    Attr <| Html.Attributes.media str


{-| Specify a URL to send a short POST request to when the user clicks on an
`a` or `area`. Useful for monitoring and tracking.
-}
ping : String -> Attribute variation msg
ping str =
    Attr <| Html.Attributes.ping str


{-| Specifies the relationship of the target object to the link object.
For `a`, `area`, `link`.
-}
rel : String -> Attribute variation msg
rel str =
    Attr <| Html.Attributes.rel str



-- CRAZY STUFF


{-| Indicates the date and time associated with the element.
For `del`, `ins`, `time`.
-}
datetime : String -> Attribute variation msg
datetime str =
    Attr <| Html.Attributes.datetime str


{-| Indicates whether this date and time is the date of the nearest `article`
ancestor element. For `time`.
-}
pubdate : String -> Attribute variation msg
pubdate str =
    Attr <| Html.Attributes.pubdate str



-- ORDERED LISTS


{-| Indicates whether an ordered list `ol` should be displayed in a descending
order instead of a ascending.
-}
reversed : Bool -> Attribute variation msg
reversed on =
    Attr <| Html.Attributes.reversed on


{-| Defines the first number of an ordered list if you want it to be something
besides 1.
-}
start : Int -> Attribute variation msg
start i =
    Attr <| Html.Attributes.start i



-- TABLES


{-| The colspan attribute defines the number of columns a cell should span.
For `td` and `th`.
-}
colspan : Int -> Attribute variation msg
colspan i =
    Attr <| Html.Attributes.colspan i


{-| A space separated list of element IDs indicating which `th` elements are
headers for this cell. For `td` and `th`.
-}
headers : String -> Attribute variation msg
headers str =
    Attr <| Html.Attributes.headers str


{-| Defines the number of rows a table cell should span over.
For `td` and `th`.
-}
rowspan : Int -> Attribute variation msg
rowspan i =
    Attr <| Html.Attributes.rowspan i


{-| Specifies the scope of a header cell `th`. Possible values are: col, row,
colgroup, rowgroup.
-}
scope : String -> Attribute variation msg
scope str =
    Attr <| Html.Attributes.scope str


{-| Specifies the URL of the cache manifest for an `html` tag.
-}
manifest : String -> Attribute variation msg
manifest man =
    Attr <| Html.Attributes.manifest man



{--TODO: maybe reintroduce once there's a better way to disambiguate imports
{-| The number of columns a `col` or `colgroup` should span. -}
span : Int -> Attribute variation msg
span = Html.Attributes.span
--}
