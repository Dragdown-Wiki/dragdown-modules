lua scripts/test.lua

inotifywait -m -r -e close_write --format '%w%f' --include '.*\.lua$' . | while read -r changed; do
    echo "$changed changed"
    lua scripts/test.lua
done