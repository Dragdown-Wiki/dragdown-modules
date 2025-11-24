sudo apt update
sudo apt install lua5.1 luarocks inotify-tools -y

# lua dependencies
luarocks install luassert --local
luarocks install save-table-to-file --local
luarocks install inspect --local
luarocks install http --local
luarocks install cjson --local
luarocks install tableshape --local
luarocks install penlight --local