#!/usr/bin/env bash

for file in "$@"; do
    aspell check "$file" --conf ./tests/aspell.conf
done