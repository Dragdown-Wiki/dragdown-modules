sudo apt update
sudo apt install lua5.1 luarocks inotify-tools -y

# lua dependencies
luarocks install --local luassert
luarocks install --local save-table-to-file
luarocks install --local inspect
luarocks install --local http
luarocks install --local cjson
luarocks install --local tableshape
luarocks install --local penlight
luarocks install --local lua-dotenv