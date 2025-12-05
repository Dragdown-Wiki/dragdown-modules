local thing = require("../framework/reference-lib")

thing(function(html, filePath)
  local file = io.open(filePath, "w")
  file:write(html)
  file:close()
end)

print("done :)")
