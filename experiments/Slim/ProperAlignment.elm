module Main exposing (..)

import Color exposing (Color)
import Element exposing (..)
import Element.Area
import Element.Attributes exposing (..)
import Element.Color as Color
import Html exposing (Html)
import Input as Input
import Internal.Style as Internal
import Json.Decode as Json
import Mouse
import Time exposing (Time)
import VirtualDom


main =
    Html.program
        { init =
            ( Debug.log "init"
                { timeline = 0
                , trackingMouse = False
                }
            , Cmd.none
            )
        , view = view
        , update = update
        , subscriptions =
            \model -> Sub.none
        }


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



{- There are two tricky scenarios with alignment.

      1.  Visually Spaced Elements.

      Right now we have spaceEvenly which makes the spaces between elements even, but if you have three things the middle one will be off center if a side element is larger than the other one.

      |-|  |-|  |---|
      |------|------|

      Design-wise, it's very common to have a preference for the item to be in the center:

      |-|   |-| |---|
      |------|------|

      I believe this can be achieved with some sort of thing around `flex-basis`


      2. Same-axis alignment within a layout.

      Currently, this doesn't work.

      row []
          [ el [ alignLeft ] (text "Move me left, pls") ]

      Which isn't great because it violates what `alignLeft` is supposed to do!

      Flexbox, where the parent has `display:flex;flex-direction:row;`, also doesn't provide a direct mechanism to do this.


      An `el` is able to handle all alignments by using margin for x-axis stuff, and flexbox for y-axis.


      One solution would be to wrap each child in a container element.

      container-element:
          flex-basis: 0; --(no intrinsic width)





   -------

   Ok, after a lot of testing, here are the two solutions that are open.

   1. Using custom node names and first-of-type/last-of-type


   empty placeholder nodes are placed at the beginning and end

           <div class="row">
           <alignLeft class="container"></alignLeft>
           <div class="el">Hi</div>
           <alignRight class="container"></alignRight>
           </div>


           .container {
               flex-basis:0;
               /*   flex-grow:1; */
               flex-grow:0;
               flex-shrink:0;
               display:flex;
               background-color:#EEE;
               border-left:1px solid #CCC;
               border-right:1px solid #FFF;
           }

           alignLeft.container {
               flex-grow:0;
           }
           alignLeft:last-of-type {
               flex-grow:1;
           }

           alignRight.container {
               flex-grow:0;
           }
           alignRight:first-of-type {
             flex-grow:1;
           }

   If an aligned element is added, it is captured in a container with the node name of that alignment

           <alignRight class="container"><div class="el align-right">Hi</div></alignRight>


   The alignments then can "push" aside other elements.

           <div class="row">
               <alignLeft class="container"></alignLeft>
               <div class="el">Hi</div>
               <div class="el">HI</div>
               <alignRight class="container"><div class="el align-right">Hi</div></alignRight>
               <div class="el">Hi</div>
               <div class="el">HfdafasfdafdaI</div>
               <alignRight class="container"></alignRight>
           </div>


   Concerns:

     - Is there a meaningful performance hit from using `first-of-type`?
     - Is this actually intuitive behavior?  I beleive it is because you can build up to the "pushing" behavior, which is the only weird bit.
     - What if all elements are `width-fill`?  Won't there still be a space on the left and right?
        - fill-width needs to be set to a higher order of magnitude, like 10k, to override the spacers.
        - All fill portions are then multiplied by 10k.


   Other approach:

     - First and last element are automatically bounded in a container

           <div class="row-margin-test">
               <div class="container"><div class="el align-left">Hi</div></div>
               <div class="el">Hi</div>
               <div class="el">Hi</div>
               <div class="container"><div class="el align-right">HI</div></div>
           </div>


           .row-margin-test {
               display:flex;
               flex-direction:row;
               width: 100%;
               justify-content: center;
           }
           .row-margin-test > .container:first-child > .el {
               margin-left:auto;
           }
           .row-margin-test > .container:last-child > .el {
               margin-right:auto;
           }

           .row-margin-test > .container:first-child > .el.align-left {
               margin-right:auto;
               margin-left:0;
           }
           .row-margin-test > .container:last-child > .el.align-right {
               margin-left:auto;
               margin-right:0;
           }


     Concerns:
       - Only the first element can be aligned left
       - Only the last element can be aligned right
       - margins make the spacing weird.






-}


view model =
    layout [] <|
        column []
            [ row
                [ height (px 100)
                , Color.background Color.green
                , Color.text Color.white
                , spaceEvenly
                ]
                [ link
                    [ --link "http://zombo.com"
                      --height (px 8000)
                      --   alignTop
                      alignLeft
                    , Element.Area.heading 1
                    ]
                    { url = "www.zombo.com"
                    , label = text "Hello World!!"
                    }
                , el
                    [--height (px 8000)
                     --   alignTop
                    ]
                    (text "Hello World!!")
                , el
                    [ --height (px 8000)
                      --   alignTop
                      alignRight
                    ]
                    (text "Hello World!! BLABLABLABLABLABLBALA")
                ]
            , el [] (text "MAIN CONTENT")
            , Input.text [ center, width (px 800) ]
                { text = "Helloooooo!"
                , onChange = always NoOp
                , placeholder = Nothing
                , label = Input.LabelOnRight empty
                }
            ]



-- {-
--    Needed in post-creation modification:
--       - Layouttype for alignment
--       - Embed stylesheet via lazy
--       -
-- -}
-- -- type Element msg
-- --     = Unstyled (Html msg)
-- --     | Unresolved (List Style) String (List (Html.Attribute msg)) (List (Html msg))
-- type Style
--     = Style
-- type Elm msg
--     = Styled
--         { styles : List Style
--         , children : List (Elm msg)
--         , html : StyleSheet -> LayoutAlignment -> Html msg
--         }
--     | Unstyled (LayoutAlignment -> Html msg)
-- type LayoutAlignment
--     = AsRow
--     | AsColumn
--     | AsEl
-- asRow =
--     AsRow
-- asColumn =
--     AsColumn
-- asEl =
--     AsEl
-- {-| -}
-- lazy : (a -> Elm msg) -> a -> Elm msg
-- lazy fn a =
--     Unstyled <| VirtualDom.lazy3 embed fn a
-- -- {-| -}
-- -- lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
-- -- lazy2 fn a b =
-- --     Unstyled <| VirtualDom.lazy3 embed2 fn a b
-- {-| -}
-- embed : (a -> Elm msg) -> a -> LayoutAlignment -> Html msg
-- embed fn a =
--     case fn a of
--         Unstyled html ->
--             html
--         Styled { styles, children, html } ->
--             html (toStyleSheet styles children)
-- type StyleSheet
--     = StyleSheet
-- toStyleSheet style styleChildren =
--     StyleSheet
-- -- Unresolved styles node attrs children ->
-- --     VirtualDom.node node
-- --         attrs
-- --         (children ++ [ toStyleSheet styles ])
-- type Attribute msg
--     = Attribute
-- render : Maybe String -> LayoutAlignment -> List (Attribute msg) -> List (Elm msg) -> Elm msg
-- render maybeNodeName pos attributes children =
--     let
--         htmlChildren =
--             List.foldr gather [] children
--         gather child htmls =
--             case child of
--                 Unstyled html ->
--                     html :: htmls
--                 Styled { html, styles, children } ->
--                     html pos :: htmls
--         rendered =
--             renderAttributes attributes
--     in
--     Styled
--         { html =
--             \pos ->
--                 let
--                     createNode =
--                         case pos of
--                             AsEl ->
--                                 case rendered.node of
--                                     Generic ->
--                                         VirtualDom.node
--                             AsRow ->
--                                 VirtualDom.node
--                             AsColumn ->
--                                 VirtualDom.node
--                     content =
--                         case rendered.absoluteChildren of
--                             Nothing ->
--                                 htmlChildren
--                             Just additional ->
--                                 htmlChildren
--                                     ++ [ VirtualDom.node "div" [ VirtualDom.property "className" (Json.string "se el nearby") ] additional ]
--                 in
--                 VirtualDom.node nodeName
--                     rendered.attrs
--                     content
--         , styles = rendered.styles
--         , children = children
--         }
-- resolveNodeName maybeNode override attributes content =
--     case maybeNode of
--         Just node ->
--             case override of
--                 Nothing ->
--                     VirtualDom.node node attributes content
--                 Just over ->
--                     VirtualDom.node node
--                         attributes
--                         [ VirtualDom.node over [] content ]
--         Nothing ->
--             case override of
--                 Just over ->
--                     VirtualDom.node over attributes content
--                 Nothing ->
--                     VirtualDom.node "div" attributes content
-- wrapAligned layout alignment el =
--     case layout of
--         AsEl ->
--             el
--         AsRow ->
--             case alignment of
--                 NoAlignment ->
--                     el
--         AsColumn ->
--             case alignment of
--                 NoAlignment ->
--                     el
-- renderAttributes attrs =
--     { alignment = NoAlignment
--     , node = Nothing
--     , attrs = []
--     , styles = []
--     , absoluteChildren = Nothing
--     }
-- type Alignment
--     = NoAlignment
