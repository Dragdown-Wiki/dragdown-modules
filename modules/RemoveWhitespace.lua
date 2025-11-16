-- i copied this from the user "archimedes.5000" on MediaWiki discord
-- i'll test this for less painful template development.

--lua pattern special chars escape function
local function lua_escape(s)
   local chars = "[%^%$%(%)%%%.%[%]%*%+%-%?]"
   return s:gsub(chars, "%%" .. "%0")
end

return {
   main = function(frame)
      local text = require("Arguments").getArgs(frame)[1]
      local e = {}
      local tag = {}

      --replace escape tag "no" with strip markers and store values
      local i = 1
      for m, n in text:gmatch("(<no%s->(.-)</no%s->)") do
         text = text:gsub(lua_escape(m), "⌦" .. i .. "⌫")
         e[i] = lua_escape(n)
         i = i + 1
      end

      --replace all opening/closing/self-closing tags with strip markers and store their insides
      i = 1
      for m in text:gmatch("(<.->)") do
         text = text:gsub(lua_escape(m), "⌦TAG" .. i .. "⌫")
         tag[i] = lua_escape(m)
         i = i + 1
      end

      --remove all whitespace
      text = text:gsub("%s%s+", "")

      --remove newlines
      text = text:gsub("\n", "")

      --replace back escape tag contents
      for m, n in text:gmatch("(⌦(%d+)⌫)") do
         n = tonumber(n)
         text = text:gsub(lua_escape(m), e[n])
      end

      --replace back tags
      for m, n in text:gmatch("(⌦TAG(%d+)⌫)") do
         n = tonumber(n)
         text = text:gsub(lua_escape(m), tag[n])
      end

      return text
   end
}