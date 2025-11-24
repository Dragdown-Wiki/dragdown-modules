while inotifywait -q -e close_write ./*.lua **/*.lua; do
    LUA_PATH="./?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;/config/.luarocks/share/lua/5.1/?.lua;/config/.luarocks/share/lua/5.1/?/init.lua" \
    LUA_CPATH="./?.so;/usr/local/lib/lua/5.1/?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/config/.luarocks/lib/lua/5.1/?.so" \
    PATH="/config/.luarocks/bin:/app/code-server/lib/vscode/bin/remote-cli:/config/.local/share/pnpm:/command:/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    lua main.lua
done
