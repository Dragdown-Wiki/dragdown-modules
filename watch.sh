while inotifywait -q -e close_write main.lua; do
    lua main.lua
done
