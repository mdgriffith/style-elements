elm-make Base.elm
echo "baseline"
du -h index.html

elm-make ../../examples/Basic.elm
echo "Basic Example with Style Elements"
du -h index.html