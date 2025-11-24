---@diagnostic disable: need-check-nil
local http_request = require "http.request"
local http_util = require "http.util"
local cjson = require "cjson"

local res, err = table.load(".cache/cookie")

if err == nil then
  return res.cookie
end

print("cookie cache miss")

local headers, token_stream = http_request.new_from_uri(
  "https://dragdown.wiki/w/api.php?action=query&format=json&meta=tokens&type=*"
):go()

local login = http_request.new_from_uri("https://dragdown.wiki/w/api.php")
login.headers:upsert(":method", "POST")
login.headers:upsert("content-type", "application/x-www-form-urlencoded")
login.headers:upsert("cookie", headers:get("set-cookie"))

login:set_body(http_util.dict_to_query({
  action = "login",
  lgname = "Waffeln",
  lgpassword = "f%17ntfY@d5#t5yJFKhOzp8n",
  lgtoken = cjson.decode(token_stream:get_body_as_string()).query.tokens.logintoken,
}))

local login_headers = login:go()
local cookie = table.concat(login_headers:get_as_sequence("set-cookie"), ";")

table.save({cookie = cookie}, ".cache/cookie")
return cookie