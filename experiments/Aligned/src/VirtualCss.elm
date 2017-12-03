module VirtualCss exposing (StyleSheet, clear, delete, insert)

import Native.VirtualCss


type StyleSheet
    = StyleSheet


insert : String -> Int -> Int
insert =
    Native.VirtualCss.insert


delete : Int -> Int
delete =
    Native.VirtualCss.delete


clear : () -> ()
clear =
    Native.VirtualCss.clear
