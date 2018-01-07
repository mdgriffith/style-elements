module Main exposing (..)

-- import Element.Attributes exposing (..)

import Color exposing (..)
import Element exposing (..)
import Element.Area
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Palette as Palette
import Html exposing (Html)
import Html.Attributes
import Element.Input as Input
import Internal.Model
import Internal.Style as Internal
import Json.Decode as Json
-- import Mouse
import Time exposing (Time)
import VirtualDom


{- Define Palette as a Record -}
-- user definition


main =
    Html.program
        { init =
            ( Debug.log "init"
                { timeline = 0
                , trackingMouse = False
                , checked = False
                , text = "MY input!"
                , lunch = Taco
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
    | Check Bool
    | Coords { x : Int, y : Int }
    | Change String
    | ChooseLunch Lunch


update msg model =
    case Debug.log "msg!" msg of
        NoOp ->
            ( model, Cmd.none )

        Check checked ->
            ( { model | checked = checked }, Cmd.none )

        Coords coords ->
            ( model, Cmd.none )

        ChooseLunch lunch ->
            ( { model | lunch = lunch }
            , Cmd.none
            )

        Change str ->
            ( { model | text = str }, Cmd.none )



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
-- view model =
--     layout
--         [ Background.color white
--         , Font.color black
--         ]
--     <|
--         el
--             [ width (px 200)
--             , height (px 200)
--             , padding 10
--             , Events.onMouseCoords Coords
--             -- , Events.onMouseScreenCoords Coords
--             , Background.color blue
--             , Font.color white
--             ]
--             (text "Hello stylish friend!")


type Lunch
    = Burrito
    | Gyro
    | Taco


boxTest =
    column [ spacing 20 ]
        [ box
        , box
        , box
        , box
        ]


box =
    el
        [ Element.width (px 60)
        , Element.height (px 60)
        , Background.color blue
        , Font.color white
        ]
        (text "box")


view model =
    layoutWith
        { options = []

        -- [ focusStyle
        --     { backgroundColor = Nothing
        --     , borderColor = Nothing --Just Color.red
        --     , shadow =
        --         Just
        --             { color = Color.red
        --             , offset = ( 0, 0 )
        --             , blur = 3
        --             , size = 3
        --             }
        --     }
        -- ]
        }
        [ -- Modal logic.
          -- Only shown when checked
          --   inFront <|
          --     el
          --         [ width fill
          --         , height fill
          --         , behind <|
          --             el
          --                 [ width fill
          --                 , height fill
          --                 , Background.color (Color.rgba 0 0 0 0.3)
          --                 , Events.onClick (Check False)
          --                 -- , blur 5
          --                 ]
          --                 empty
          --         ]
          --     <|
          --         el
          --             [ center
          --             , centerY
          --             , width (px 200)
          --             , height (px 200)
          --             , Font.color white
          --             , paddingXY 10 5
          --             , Background.color green
          --             -- , blur 5
          --             -- , inFront <|
          --             --     el [] (text "wut?")
          --             ]
          --             (text "Welcome!")
          Background.color white
        , Font.color black
        , Font.family
            [ --      Font.typeface "Open Sans"
              -- , Font.typeface "Helvetica"
              -- , Font.typeface "Verdana"
              Font.external
                { name = "Bellefair"
                , url = "https://fonts.googleapis.com/css?family=Bellefair"
                }
            , Font.serif
            ]
        ]
    <|
        -- row
        --     [ Background.color blue
        --     ]
        --     [ el [ width (fillPortion 2), Background.color red ] (text "I am the main page, damnit")
        --     , el [ width fill, Background.color green ] (text "I am the main page, damnit")
        --     , el
        --         [ width fill
        --         , Background.color red
        --         , pointer
        --         , mouseOver
        --             [ Background.color yellow
        --             -- , above <|
        --             --     el
        --             --         [ width fill
        --             --         , height fill
        --             --         , Background.color (Color.rgba 0 0 0 0.3)
        --             --         , Events.onClick (Check False)
        --             --         ]
        --             --         empty
        --             ]
        --         ]
        --         (text "I am the main page, damnit")
        --     ]
        -- el [ width (px 800), Font.alignRight ] <|
        -- column []
        --     [ el
        --         [ Background.color white
        --         , Font.color black
        --         , paddingXY 20 10
        --         -- , alignTop
        --         , alignBottom
        --         ]
        --         (text "Center me pls")
        --     -- , el
        --     --     [ Background.color white
        --     --     , Font.color black
        --     --     , paddingXY 20 10
        --     --     , centerY
        --     --     , onLeft <|
        --     --         el
        --     --             [ Background.color red
        --     --             , centerY
        --     --             -- , alignRight
        --     --             ]
        --     --             (text "below")
        --     --     -- , centerY
        --     --     -- , alignLeft
        --     --     -- , alignTop
        --     --     ]
        --     --     (text "Center me pls")
        --     -- , el
        --     --     [ Background.color white
        --     --     , Font.color black
        --     --     , paddingXY 20 10
        --     --     , alignTop
        --     --     -- , center
        --     --     -- , alignLeft
        --     --     -- , centerY
        --     --     ]
        --     --     (text "Center me pls")
        --     ]
        column [ width (px 800), center, spacing 20 ]
            [ -- row
              --     [ height (px 100)
              --     , Background.color Color.green
              --     , Font.color Color.white
              --     -- , spaceEvenly
              --     ]
              --     [ el
              --         [ alignLeft
              --         , Element.Area.heading 1
              --         ]
              --       <|
              --         text "Hello World!!"
              --     , el
              --         []
              --         (text "Hello World!!")
              --     , el
              --         [ --height (px 8000)
              --           --   alignTop
              --           alignRight
              --         ]
              --         (text "Hello World!! BLABLABLABLABLABLBALA")
              --     ]
              -- , el
              --     [ height (px 1000)
              --     -- , centerY
              --     -- , alignLeft
              --     ]
              --     (text "MAIN CONTENT")
              --   Input.button
              --     [ Background.color grey
              --     , Background.mouseOverColor yellow
              --     , Font.color black
              --     , paddingXY 10 2
              --     , Border.rounded 10
              --     , centerY
              --     , scale 1.5
              --     -- , mouseOverScale 2.0
              --     -- , mouseOverRotate (pi * 0.5)
              --     , rotate pi
              --     , moveRight 200
              --     ]
              --     { onPress = Just NoOp
              --     , label = text "Press Me!"
              --     }
              image [ height (px 500) ]
                { src = "https://placeimg.com/640/420/animals/grayscale"
                , description = "Here's my image!"
                }
            , el
                [ width (px 500)
                , height (px 200)
                , alignLeft
                , Background.fittedImage "https://placeimg.com/640/420/animals/grayscale"
                ]
                empty
            , el
                [ width (px 500)
                , height (px 200)
                , alignLeft
                , Background.image "https://placeimg.com/640/420/animals/grayscale"
                ]
                empty
            , el
                [ width (px 800)
                , height (px 400)

                -- , alignLeft
                , Background.tiledY "https://placeimg.com/200/200/animals/grayscale"
                ]
                empty
            , el
                [ width (px 800)
                , height (px 400)

                -- , alignLeft
                , Background.gradient 0
                    [ red
                    , blue
                    , green
                    ]
                ]
                empty
            , Input.checkbox
                []
                { onChange = Just Check
                , checked = model.checked
                , icon = Nothing
                , label = Input.labelRight [] (text "Checkbox Label")
                , notice =
                    Just <|
                        Input.warningBelow [] (text "Warning!")
                }

            -- , Element.table []
            --     { data =
            --         [ { firstName = "Cheryl", lastName = "Boo" }
            --         , { firstName = "Basil", lastName = "Honeyfoot" }
            --         ]
            --     , columns =
            --         [ { header = text "First Name"
            --           , view =
            --                 \person ->
            --                     text person.firstName
            --           }
            --         , { header = text "Last Name"
            --           , view =
            --                 \person ->
            --                     text person.lastName
            --           }
            --         ]
            --     }
            , Input.text
                [ Background.color grey
                , Border.color grey
                , Border.width 1
                , Border.rounded 10
                , Font.lineHeight 1.5
                , spacing 10
                ]
                { text = model.text
                , onChange = Just Change
                , placeholder =
                    Just <| Input.placeholder [ Background.color blue, Font.color white ] (text "placeholder")
                , label =
                    Input.labelLeft [] (text "Label")
                , notice =
                    Just <|
                        Input.warningBelow [] (text "Warning Below")
                }
            , Input.text
                [ Background.color grey
                , Border.color grey
                , Border.width 1
                , Border.rounded 10
                , Font.lineHeight 1.5
                , spacing 10
                ]
                { text = model.text
                , onChange = Just Change
                , placeholder =
                    Just <| Input.placeholder [ Background.color blue, Font.color white ] (text "placeholder")
                , label =
                    Input.labelBelow
                        []
                        (text "Label")
                , notice =
                    Just <|
                        Input.warningBelow [] (text "Warning Below")
                }

            --   Input.multiline
            --     [ --width (px 600)
            --       height shrink
            --     , Background.color grey
            --     , Border.color grey
            --     , Border.width 1
            --     , Border.rounded 10
            --     , Font.lineHeight 1.5
            --     , padding 20
            --     -- , spacing 80
            --     -- , width (px 300)
            --     -- , width fill
            --     , alignLeft
            --     -- , Input.focused [ Font.color blue ]
            --     ]
            --     { text = model.text
            --     , onChange = Just Change
            --     , placeholder =
            --         Just
            --             (Input.placeholder []
            --                 (text "placeholder")
            --             )
            --     , label =
            --         Input.labelBelow
            --             [--Input.focused [ Font.color red ]
            --             ]
            --             (text "Label Left")
            --     , notice =
            --         Just <|
            --             Input.warningBelow [ alignRight ] (text "Warning Below")
            --     }
            -- , Input.radio
            --     [ padding 10
            --     , spacing 5
            --     ]
            --     { onChange = Just ChooseLunch
            --     , selected = Just model.lunch
            --     , label = Input.labelAbove [] (text "Lunch")
            --     , notice = Nothing
            --     , options =
            --         [ -- Input.styledChoice Burrito <|
            --           -- \selected ->
            --           --     Element.row
            --           --         [ spacing 5 ]
            --           --         [ el None [] <|
            --           --             if selected then
            --           --                 text ":D"
            --           --             else
            --           --                 text ":("
            --           --         , text "burrito"
            --           --         ]
            --           Input.option Taco (text "Taco!")
            --         , Input.option Gyro (text "Gyro")
            --         ]
            --     }
            , Input.select
                [ padding 10
                , spacing 5
                , Border.width 1
                , Border.color grey
                , width fill
                ]
                { onChange = Just ChooseLunch
                , selected = Just model.lunch
                , label = Input.labelAbove [ width fill ] (text "Lunch")
                , notice = Nothing
                , menu =
                    Input.menuBelow
                        [ Border.width 1
                        , Border.color grey
                        , padding 10
                        ]
                        [ -- Input.styledChoice Burrito <|
                          -- \selected ->
                          --     Element.row
                          --         [ spacing 5 ]
                          --         [ el None [] <|
                          --             if selected then
                          --                 text ":D"
                          --             else
                          --                 text ":("
                          --         , text "burrito"
                          --         ]
                          Input.option Taco (text "Taco!")
                        , Input.option Gyro (text "Gyro")
                        ]
                }
            , Element.text "Yo yo yo"
            , Input.checkbox
                []
                { onChange = Just Check
                , checked = model.checked
                , icon = Nothing
                , label = Input.labelRight [] (text "Checkbox Label")
                , notice =
                    Just <|
                        Input.warningBelow [] (text "Warning!")
                }

            -- , Input.select
            --     [ padding 10
            --     , spacing 5
            --     , Border.width 1
            --     , Border.color grey
            --     , width fill
            --     ]
            --     { onChange = Just ChooseLunch
            --     , selected = Just model.lunch
            --     , label = Input.labelAbove [ width fill ] (text "Lunch")
            --     , notice = Nothing
            --     , menu =
            --         Input.menuBelow
            --             [ Border.width 1
            --             , Border.color grey
            --             , padding 10
            --             ]
            --             [ -- Input.styledChoice Burrito <|
            --               -- \selected ->
            --               --     Element.row
            --               --         [ spacing 5 ]
            --               --         [ el None [] <|
            --               --             if selected then
            --               --                 text ":D"
            --               --             else
            --               --                 text ":("
            --               --         , text "burrito"
            --               --         ]
            --               Input.option Taco (text "Taco!")
            --             , Input.option Gyro (text "Gyro")
            --             ]
            --     }
            -- , Input.sliderX
            --     []
            --     { onChange = Nothing
            --     , range = ( 0, 10 )
            --     , value = 5
            --     , label = Input.labelAbove [] (text "My Slider")
            --     , notice = Nothing
            --     }
            -- , Input.multiline
            --     [ width (px 600)
            --     , Background.color white
            --     , Border.color grey
            --     , Border.all 1
            --     , Border.rounded 10
            --     , spacing 80
            --     ]
            --     { text = ""
            --     , onChange = Just <| always NoOp
            --     , placeholder = Just (text "hello!")
            --     , label = Input.labelLeft [] (text "Label Left")
            --     , notice =
            --         Just <|
            --             Input.warningBelow [] (text "Warning!")
            --     }
            -- , row
            --     [ height (px 100)
            --     , Background.color Color.green
            --     , Font.color Color.white
            --     , alignBottom
            --     ]
            --     [ el
            --         [ alignLeft
            --         , Element.Area.heading 1
            --         ]
            --       <|
            --         text "Hello World!!"
            --     -- , link
            --     --     [ alignLeft
            --     --     , Element.Area.heading 1
            --     --     ]
            --     --     { url = "www.zombo.com"
            --     --     , label = text "Hello World!!"
            --     --     }
            --     , el
            --         []
            --         (text "Hello World!!")
            --     , el
            --         [ --height (px 8000)
            --           --   alignTop
            --           alignRight
            --         ]
            --         (text "Hello World!! BLABLABLABLABLABLBALA")
            --     ]
            -- , row
            --     [ height (px 100)
            --     , Background.color Color.green
            --     , Font.color Color.white
            --     , alignBottom
            --     ]
            --     [ el
            --         [ alignLeft
            --         , Element.Area.heading 1
            --         ]
            --       <|
            --         text "Hello World!!"
            --     -- , link
            --     --     [ alignLeft
            --     --     , Element.Area.heading 1
            --     --     ]
            --     --     { url = "www.zombo.com"
            --     --     , label = text "Hello World!!"
            --     --     }
            --     , el
            --         []
            --         (text "Hello World!!")
            --     , el
            --         [ --height (px 8000)
            --           --   alignTop
            --           alignRight
            --         ]
            --         (text "Hello World!! BLABLABLABLABLABLBALA")
            -- ]
            ]



-- [ el
--     [ Background.color white
--     , Font.color black
--     , paddingXY 20 10
--     , alignTop
--     -- , centerY
--     , onRight <|
--         el [] (text "onRight")
--     ]
--     (text "Center me pls")
-- , el
--     [ Background.color white
--     , Font.color black
--     , paddingXY 20 10
--     -- , alignTop
--     ]
--     (text "Center me pls")
-- , el
--     [ Background.color white
--     , Font.color black
--     , paddingXY 20 10
--     -- , centerY
--     ]
--     (text "Center me pls")
-- ]
-- <|
--     column [ height fill ]
--         [ row
--             [ height (px 100)
--             , Background.color Color.green
--             , Font.color Color.white
--             -- , spaceEvenly
--             ]
--             [ link
--                 [ alignLeft
--                 , Element.Area.heading 1
--                 ]
--                 { url = "www.zombo.com"
--                 , label = text "Hello World!!"
--                 }
--             , el
--                 []
--                 (text "Hello World!!")
--             , el
--                 [ --height (px 8000)
--                   --   alignTop
--                   alignRight
--                 ]
--                 (text "Hello World!! BLABLABLABLABLABLBALA")
--             ]
--         , el
--             [ height (px 1000)
--             , centerY
--             -- , alignLeft
--             ]
--             (text "MAIN CONTENT")
--         , Input.button []
--             { onPress = Just NoOp
--             , label = text "Press Me!"
--             }
--         , Input.checkbox [ spacing 20 ]
--             { onChange = Just Check
--             , checked = model.checked
--             , icon = Nothing
--             , label = Input.labelRight [] (text "hello!")
--             , notice =
--                 Just <|
--                     Input.warningAbove [] (text "wut?")
--             }
--         , Input.text [ center, width (px 800) ]
--             { text = "Helloooooo!"
--             , onChange = Just <| always NoOp
--             , placeholder = Nothing
--             , label = Input.labelAbove [] (text "hello!")
--             , notice =
--                 Just <|
--                     Input.warningAbove [ alignLeft ] (text "wut?")
--             }
--         , row
--             [ height (px 100)
--             , Background.color Color.green
--             , Font.color Color.white
--             , alignBottom
--             ]
--             [ link
--                 [ alignLeft
--                 , Element.Area.heading 1
--                 ]
--                 { url = "www.zombo.com"
--                 , label = text "Hello World!!"
--                 }
--             , el
--                 []
--                 (text "Hello World!!")
--             , el
--                 [ alignRight
--                 ]
--               <|
--                 text "Hello World!! BLABLABLABLABLABLBALA"
--             ]
--         , row
--             [ height (px 100)
--             , Background.color Color.green
--             , Font.color Color.white
--             , alignBottom
--             ]
--             [ link
--                 [ alignLeft
--                 , Element.Area.heading 1
--                 ]
--                 { url = "www.zombo.com"
--                 , label = text "Hello World!!"
--                 }
--             , el
--                 []
--                 (text "Hello World!!")
--             , el
--                 [ --height (px 8000)
--                   --   alignTop
--                   alignRight
--                 ]
--                 (text "Hello World!! BLABLABLABLABLABLBALA")
--             ]
--         ]
