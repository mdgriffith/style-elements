module Main exposing (..)

import Expect
import Fuzz
import Layout.Auto
import Layout.Fuzz
import Test exposing (..)
import Window


suite : Test
suite =
    describe "The String module"
        [ describe "String.reverse"
            -- Nest as many descriptions as you like.
            [ test "has no effect on a palindrome" <|
                \_ ->
                    let
                        palindrome =
                            "hannah"
                    in
                    Expect.equal palindrome (String.reverse palindrome)

            -- Expect.equal is designed to be used in pipeline style, like this.
            , test "reverses a known string" <|
                \_ ->
                    "ABCDEFG"
                        |> String.reverse
                        |> Expect.equal "GFEDCBA"

            -- fuzz runs the test 100 times with randomly-generated inputs!
            -- , fuzz (Layout.Fuzz.element 5) "auto-self testing auto fuzz" <|
            --     \element ->
            --         let
            --             ( elems, tests ) =
            --                 Layout.Auto.test element
            --         in
            --         tests (Window.Size 0 0)
            -- , fuzz string "restores the original string if you run it again" <|
            --     \randomlyGeneratedString ->
            --         randomlyGeneratedString
            --             |> String.reverse
            --             |> String.reverse
            --             |> Expect.equal randomlyGeneratedString
            ]
        ]
