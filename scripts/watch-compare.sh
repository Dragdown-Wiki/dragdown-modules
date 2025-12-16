lua scripts/compare-reference-output.lua

inotifywait -m -r -e close_write --format '%w%f' --include '.*\.lua$' . | while read -r changed; do
    echo "$changed changed"
    lua scripts/compare-reference-output.lua
done