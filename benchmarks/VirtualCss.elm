module VirtualCss exposing (StyleSheet, delete, insert)

import Native.VirtualCss


type StyleSheet
    = StyleSheet


insert : String -> Int -> Int
insert =
    Native.VirtualCss.insert


delete : Int -> Int
delete =
    Native.VirtualCss.delete
