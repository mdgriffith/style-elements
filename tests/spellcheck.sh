#!/usr/bin/env bash

for file in $@; do
    aspell -c "$file" \
	   --add-filter context \
	   --add-context-delimiters="{- -}" \
	   --add-context-delimiters='" "' \
	   --home-dir=./docs/ \
	   --lang=en_US \
	   --dont-backup
done