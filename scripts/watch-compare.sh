while inotifywait -q -e close_write **/*.lua; do
    lua scripts/compare-reference-output.lua
done
